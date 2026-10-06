abstract type AbstractHAPIVariable{T, N} <: AbstractDataVariable{T, N} end

"""
An array-like object that represents a HAPI variable.

## Fields

- `data`: The underlying data values (use `parent(x)` to access).
- `time`: The time axis (use `times(x)` to access).
- `meta`: The metadata (use `meta(x)` to access).
"""
struct HAPIVariable{T, N, A <: AbstractArray{T, N}, Tt <: AbstractVector, M <: AbstractDict} <: AbstractHAPIVariable{T, N}
    data::A
    time::Tt
    meta::M
end

tdimnum(::HAPIVariable) = 1

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

colsize(param) = prod(get(param, "size", 1))
colsize(var::HAPIVariable) = colsize(meta(var))
