const DEFAULT_DATE_FORMAT = DateFormat("yyyy-mm-ddTHH:MM:SS.sssZ")

"""
    get_data(server, dataset, parameters, tmin, tmax; format="csv")

Get data and metadata from a HAPI `server` for a given `dataset` and `parameters` within a time range `[tmin, tmax]`.

Supported data formats: "csv", "binary", "json".
"""
function get_data(server, dataset, parameters, tmin, tmax; format=format(server))

    # Validate time format
    tmin = Dates.format(DateTime(tmin), DEFAULT_DATE_FORMAT)
    tmax = Dates.format(DateTime(tmax), DEFAULT_DATE_FORMAT)

    # Get metadata first to determine data types
    meta = get_parameters(server, dataset, parameters)
    dtypes, cols, sizes, names, types, missing_length = compute_types(meta)

    # Construct data request URL
    url = string(server) * "/data"
    params = Dict(
        "id" => dataset,
        "parameters" => parameters,
        "time.min" => tmin,
        "time.max" => tmax,
        "format" => format
    )

    # Make request
    response = HTTP.get(url; query=params)

    if format == "csv"
        data = CSV.File(response.body; header=false, dateformat=DEFAULT_DATE_FORMAT)
        return data, meta
    elseif format == "json"
        # Parse JSON data with computed types
        raw_data = JSON.parse(String(response.body))
        # Convert to columns by parameter
        columns = [getindex.(raw_data, i) for i in 1:length(names)]
        # Convert Time column to DateTime
        if "Time" in names
            time_idx = findfirst(==(("Time")), names)
            columns[time_idx] = DateTime.(columns[time_idx], DEFAULT_DATE_FORMAT)
        end
        data = NamedTuple{Tuple(Symbol.(names))}(tuple(columns...))
        return data, meta
    elseif format == "binary"
        error("Binary format not yet implemented")
    else
        throw("Unsupported format: $format")
    end
end