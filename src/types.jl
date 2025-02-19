struct HAPIParameter{T<:AbstractArray}
    time::Vector
    values::T
    meta::Dict
end

function HAPIParameters(data, meta)
    params = meta["parameters"]
    [HAPIParameter(data, meta, i) for i in 1:length(params)-1]
end

colsize(param) = get(param, "size", 1) |> only

"""
    HAPIParameter(data, meta, i)

Construct a `HAPIParameter` object from CSV.File `data` and `meta` at index `i`.
"""
function HAPIParameter(data::CSV.File, meta, i)
    time = Tables.getcolumn(data, 1)
    params = meta["parameters"]
    param = params[i+1]
    size = colsize(param)
    coloffset = mapreduce(colsize, +, @view(params[1:i])) + 1

    values = if size == 1
        Tables.getcolumn(data, coloffset)
    else
        cols = coloffset:(coloffset+size-1)
        map(row -> getindex.(Ref(row), cols), data)
    end
    HAPIParameter(time, values, param)
end

"""
    HAPIParameter(data, meta, i)

Construct a `HAPIParameter` object from a JSON-parsed `data` and `meta` at index `i`.
"""
function HAPIParameter(data, meta, i)
    time = @. DateTime(getindex(data, 1), DEFAULT_DATE_FORMAT)
    param = meta["parameters"][i+1]
    values = getindex.(data, i + 1)
    HAPIParameter(time, values, param)
end

hapi_properties = (:name, :columns, :units,)

meta(var::HAPIParameter) = get_field(var, :meta)
name(var::HAPIParameter) = get(var.meta, "name", "")
columns(var::HAPIParameter) = var.meta["columns"]
colsize(var::HAPIParameter) = colsize(var.meta)

function Base.getproperty(var::HAPIParameter, s::Symbol)
    s in (:time, :values, :meta) && return getfield(var, s)
    s in hapi_properties && return eval(s)(var)
    return getproperty(var.py, s)
end

function Base.show(io::IO, var::T) where {T<:HAPIParameter}
    println(io, "$T:")
    println(io, "  Name: ", name(var))
    println(io, "  Time Range: ", var.time[1], " to ", var.time[end])
    println(io, "  Units: ", unit(var))
    println(io, "  Shape: ", size(var.values))
    println(io, "  Metadata:")
    for (key, value) in sort(collect(var.meta), by=x -> x[1])
        println(io, "    ", key, ": ", value)
    end
end

function Unitful.unit(var::HAPIParameter)
    get(var.meta, "units", 1) |> uparse
end