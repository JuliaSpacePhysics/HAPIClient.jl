"""
    get_data(server, dataset, parameters, tmin, tmax; format="csv")

Get data and metadata from a HAPI `server` for a given `dataset` and `parameters` within a time range `[tmin, tmax]`.

Supported data formats: "csv", "binary", "json".
"""
function get_data(server, dataset, parameters, tmin, tmax; format = format(server))

    # Validate time format
    tmin = HAPIDateTime(tmin)
    tmax = HAPIDateTime(tmax)

    # Construct URL and make request
    url = HAPIClient.url(server, "data")
    query = Dict(
        "id" => dataset,
        "parameters" => parameters,
        "time.min" => tmin,
        "time.max" => tmax,
        "format" => format
    )
    uri = HTTP.request_uri(url, query)
    response = HTTP.get(uri)

    data = if format == "csv"
        CSV.File(response.body; header = false, dateformat = DEFAULT_DATE_FORMAT)
    elseif format == "json"
        JSON.parse(String(response.body))
    elseif format == "binary"
        error("Binary format not yet implemented")
    else
        throw("Unsupported format: $format")
    end
    meta = get_parameters(server, dataset, parameters)
    meta["uri"] = uri
    params = meta["parameters"]
    n = length(params) - 1
    return n == 1 ? _merge_meta!(HAPIVariable(data, params, 1), meta) : HAPIVariables(data, params, meta)
end

_merge_meta!(x, meta) = begin
    merge!(x.meta, meta)
    delete!(x.meta, "parameters")
    return x
end

"""
    get_data(path, tmin, tmax; kwargs...)

Get data and metadata using a `path` in the format "server/dataset/parameter".
"""
function get_data(path, tmin, tmax; kwargs...)
    # Split path into components
    parts = split(path, "/")
    length(parts) != 3 && throw(ArgumentError("Path must be in format 'server/dataset/parameter'"))
    server_id, dataset, parameters = parts
    server = Server(server_id)

    # Call the main get_data function
    return get_data(server, dataset, parameters, tmin, tmax; kwargs...)
end

get_data(server, dataset, parameters, trange; kwargs...) = get_data(server, dataset, parameters, first(trange), last(trange); kwargs...)
get_data(path, trange; kwargs...) = get_data(path, first(trange), last(trange); kwargs...)
