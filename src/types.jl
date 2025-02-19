struct HAPIParameter
    time::Vector
    values::Vector
    meta::Dict
end

function HAPIParameters(data, meta)
    params = meta["parameters"]
    [HAPIParameter(data, params, i) for i in 1:length(params)-1]
end

colsize(param) = get(param, "size", 1) |> only

"""
    HAPIParameter(data, meta, i::Integer)

Construct a `HAPIParameter` object from CSV `data` and `meta` at index `i`.
"""
function HAPIParameter(data, meta, i::Integer)
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
