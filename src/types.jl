"""
An array-like object that represents a HAPI variable.

## Fields

- `data`: The underlying data values (use `parent(x)` to access).
- `time`: The time axis (use `times(x)` to access).
- `meta`: The metadata (use `meta(x)` to access).
"""
struct HAPIVariable{T, N, A <: AbstractArray{T, N}, Tt <: AbstractVector, M <: AbstractDict} <: AbstractDataVariable{T, N}
    data::A
    time::Tt
    meta::M
end

"""
A thin wrapper over NamedTuple for HAPI variables that shares the same time axis.
"""
struct HAPIVariables{NT <: NamedTuple, D <: AbstractDict, S, DS}
    nt::NT
    meta::D
    server::S
    dataset::DS
    uri::URI
end

@inline Base.parent(x::HAPIVariables) = getfield(x, :nt)
times(x::HAPIVariables) = times(first(parent(x)))
server(x::HAPIVariables) = getfield(x, :server)
dataset(x::HAPIVariables) = getfield(x, :dataset)
function id(x::HAPIVariables)
    s = server(x)
    if s isa Server
        return id(s) * "/" * dataset(x)
    else
        return s * "/info?id=" * dataset(x)
    end
end
Base.propertynames(x::HAPIVariables) = propertynames(parent(x))
Base.getproperty(x::HAPIVariables, s::Symbol) = getproperty(parent(x), s)
Base.length(x::HAPIVariables) = length(parent(x))
Base.iterate(x::HAPIVariables, args...) = iterate(parent(x), args...)
Base.getindex(x::HAPIVariables, i) = getindex(parent(x), i)

Base.show(io::IO, x::HAPIVariables) = show(io, parent(x))
function Base.show(io::IO, m::MIME"text/plain", var::HAPIVariables)
    print(io, "HAPIVariables: ")
    printstyled(io, id(var), color = 209)
    print(io, " (", getfield(var, :uri), ")")
    foreach(var) do v
        print(io, "\n  ")
        show(io, v)
    end
    return if (mt = meta(var)) !== nothing
        print(io, "\nMetadata - ")
        show(io, m, mt)
    end
end

function HAPIVariables(data, params, meta, args...)
    n = length(params) - 1
    names = Tuple(Symbol(params[i + 1]["name"]) for i in 1:n)
    values = (HAPIVariable(data, params, i) for i in 1:n)
    return HAPIVariables(NamedTuple{names}(values), meta, args...)
end

colsize(param) = prod(get(param, "size", 1))

"""
    HAPIVariable(data, params, i)

Construct a `HAPIVariable` object from CSV.File `data` and `params` at index `i`.
"""
function HAPIVariable(data::CSV.File, params, i::Integer)
    time = Tables.getcolumn(data, 1)
    param = params[i + 1]
    size = colsize(param)
    coloffset = mapreduce(colsize, +, @view(params[1:i])) + 1

    values = if size == 1
        Tables.getcolumn(data, coloffset)
    else
        stack(coloffset:(coloffset + size - 1)) do i
            Tables.getcolumn(data, i)
        end
    end
    return HAPIVariable(values, time, param)
end

"""
    HAPIVariable(data, params, i)

Construct a `HAPIVariable` object from a JSON-parsed `data` and `params` at index `i`.
"""
function HAPIVariable(data, params, i::Integer)
    time = @. DateTime(getindex(data, 1), DEFAULT_DATE_FORMAT)
    param = params[i + 1]
    values = getindex.(data, i + 1)
    return HAPIVariable(values, time, param)
end

"""
    HAPIVariable(d, i)

Construct a `HAPIVariable` object from a JSON-parsed Dict `d` (containing parameters) at index `i`.
"""
function HAPIVariable(d::AbstractDict, i::Integer)
    data = d["data"]
    param = d["parameters"][i + 1]
    time = @. DateTime(getindex(data, 1), DEFAULT_DATE_FORMAT)
    values = getindex.(data, i + 1)
    return HAPIVariable(values, time, param)
end

HAPIVariable(d::AbstractDict, meta, i::Integer) = HAPIVariable(d, i)

colsize(var::HAPIVariable) = colsize(meta(var))

# when units have more than one value, return an array
function hapi_uparse(u)
    isnothing(u) && return 1
    u == "UTC" && return 1
    u == "degrees" && return u"°"
    return uparse(u)
end
hapi_uparse(units::AbstractArray) = hapi_uparse.(units)

Unitful.unit(var::HAPIVariable) = hapi_uparse.(units(var))
