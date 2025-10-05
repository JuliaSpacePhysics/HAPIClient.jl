"""
    get_data(server, dataset, parameters, tmin, tmax; format="csv")

Get data and metadata from a HAPI `server` for a given `dataset` and `parameters` within a time range `[tmin, tmax]`.

Supported optional keyword arguments:
- `format`: Data format, default is "csv" (other options: "binary", "json"). 
- `verbose`: Verbosity level (passed to `HTTP.get`), default is 0 (other options: 1, 2).
"""
function get_data(server, dataset, parameters, tmin, tmax; format = format(server), verbose = 0, kw...)

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
    uri = request_uri(url, query)
    verbose > 0 && @info "Getting data from $uri"
    response = HTTP.get(uri; verbose, kw...)

    data = if format == "csv"
        CSV.File(response.body; header = false, dateformat = DEFAULT_DATE_FORMAT)
    elseif format == "json"
        json_parse(response.body)
    elseif format == "binary"
        error("Binary format not yet implemented")
    else
        throw("Unsupported format: $format")
    end
    meta = get_parameters(server, dataset, parameters)
    params = meta["parameters"]
    verbose > 0 && @info "Got $(length(params) - 1) parameters"
    return HAPIVariables(data, params, meta, server, dataset, uri)
end

"""
    get_data(path, tmin, tmax; kwargs...)

Get data and metadata using a `path` in the format "server/dataset/parameter".
"""
function get_data(path, tmin, tmax; kwargs...)
    # Split path into components - handle datasets with slashes
    parts = split(path, "/")
    length(parts) < 3 && throw(ArgumentError("Path must be in format 'server/dataset/parameter'"))

    # First part is server, last part is parameter, everything in between is dataset
    server = Server(parts[1])
    parameters = parts[end]
    dataset = join(parts[2:(end - 1)], "/")

    return get_data(server, dataset, parameters, tmin, tmax; kwargs...)
end

get_data(server, dataset, parameters, trange; kwargs...) = get_data(server, dataset, parameters, first(trange), last(trange); kwargs...)
get_data(path, trange; kwargs...) = get_data(path, first(trange), last(trange); kwargs...)
