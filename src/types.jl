struct HAPIVariable{T,N,A<:AbstractArray{T,N},Tt<:AbstractVector} <: AbstractDataVariable{T,N}
    data::A
    time::Tt
    meta::Dict
end

Base.parent(var::HAPIVariable) = var.data

function HAPIVariables(data, meta)
    params = meta["parameters"]
    n = length(params) - 1
    vars = [HAPIVariable(data, meta, i) for i in 1:n]
    return n == 1 ? first(vars) : vars
end

colsize(param) = prod(get(param, "size", 1))

"""
    HAPIVariable(data, meta, i)

Construct a `HAPIVariable` object from CSV.File `data` and `meta` at index `i`.
"""
function HAPIVariable(data::CSV.File, meta, i::Integer; merge_metadata=true)
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
    final_meta = merge_metadata ? delete!(merge(meta, param), "parameters") : param
    HAPIVariable(values, time, final_meta)
end

"""
    HAPIVariable(data, meta, i)

Construct a `HAPIVariable` object from a JSON-parsed `data` and `meta` at index `i`.
"""
function HAPIVariable(data, meta, i::Integer; merge_metadata=true)
    time = @. DateTime(getindex(data, 1), DEFAULT_DATE_FORMAT)
    param = meta["parameters"][i+1]
    values = getindex.(data, i + 1)
    final_meta = merge_metadata ? delete!(merge(meta, param), "parameters") : param
    HAPIVariable(values, time, final_meta)
end

"""
    HAPIVariable(d, i)

Construct a `HAPIVariable` object from a JSON-parsed Dict `d` (containing parameters) at index `i`.
"""
function HAPIVariable(d::Dict, i::Integer)
    data = d["data"]
    param = d["parameters"][i+1]
    time = @. DateTime(getindex(data, 1), DEFAULT_DATE_FORMAT)
    values = getindex.(data, i + 1)
    HAPIVariable(values, time, param)
end

HAPIVariable(d::Dict, meta, i::Integer) = HAPIVariable(d, i)

name(var::HAPIVariable) = get(meta(var), "name", "")
columns(var::HAPIVariable) = meta(var)["columns"]
colsize(var::HAPIVariable) = colsize(meta(var))

# when units have more than one value, return an array
function hapi_uparse(u)
    isnothing(u) && return 1
    u == "UTC" && return 1
    u == "degrees" && return u"°"
    uparse(u)
end
hapi_uparse(units::AbstractArray) = hapi_uparse.(units)

units(var::HAPIVariable) = get(meta(var), "units", nothing)
Unitful.unit(var::HAPIVariable) = hapi_uparse.(units(var))