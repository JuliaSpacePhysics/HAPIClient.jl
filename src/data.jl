"""
    get_data(server, dataset, parameters, tmin, tmax; format="csv", mask=true, kw...)

Get data and metadata from a HAPI `server` for a given `dataset` and `parameters` within a time range `[tmin, tmax]`.

With `mask = true`, values equal to a parameter's `fill` read as
`NaN`, so an `integer` parameter with a `fill` reads as `Float64`.

Supported keyword arguments:
- `format = "csv"`: Data format (other options: "binary", "json").
- `verbose = 0`: Verbosity level passed to `HTTP.get` (other options: 1, 2).
"""
function get_data(server, dataset, parameters, tmin, tmax; format = format(server), mask = true, verbose = 0, kw...)

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
    uri = URI(URI(url); query)
    verbose > 0 && @info "Getting data from $uri"
    info = @async get_parameters(server, dataset, parameters)
    response = HTTP.get(uri; verbose, kw...)
    meta = fetch(info)
    params = meta["parameters"]

    # A time range without records is an empty CSV body, or a JSON status (code 1201) with no `data`, from CDAWeb.
    data = if format == "csv"
        isempty(response.body) ? [] :
            first(response.body) == UInt8('{') ? _checked(json_parse(response.body)) : read_csv(response.body, params)
    elseif format == "json"
        _checked(json_parse(response.body))
    elseif format == "binary"
        error("Binary format not yet implemented")
    else
        throw("Unsupported format: $format")
    end
    verbose > 0 && @info "Got $(length(params) - 1) parameters"
    return HAPIVariables(data, params, meta, server, dataset, uri; mask)
end

_checked(json::AbstractDict) = (check_status_code(json); haskey(json, "data") ? json : [])
_checked(records) = records

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
