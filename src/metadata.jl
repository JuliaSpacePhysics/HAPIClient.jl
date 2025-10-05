const DEFAULT_SERVER_LIST = "https://github.com/hapi-server/servers/raw/master/all.txt"

@doc """
    get_servers()

Get a list of available HAPI server URLs from $DEFAULT_SERVER_LIST
"""
function get_servers(server_list::String = DEFAULT_SERVER_LIST)
    response = HTTP.get(server_list)
    servers = split(String(response.body), '\n', keepempty = false)
    return strip.(servers)
end

# HAPI servers must categorize the response status using at least three status codes: 1200 - OK, 1400 - Bad Request, and 1500 - Internal Server Error.
function check_status_code(i)
    if 1200 <= i < 1400
        return true
    elseif 1400 <= i < 1500
        error("Bad request - user input error")
    elseif i >= 1500
        error("Internal server error")
    end
end

check_status_code(response::AbstractDict) = check_status_code(response["status"]["code"])

"""
    get_catalog(server)

Get a list of datasets available from the server.

HAPI info response JSON structure: https://github.com/hapi-server/data-specification/blob/master/hapi-dev/HAPI-data-access-spec-dev.md#35-catalog
"""
function get_catalog(server)
    response = HTTP.get(url(server, "catalog"))
    response_dict = json_parse(response.body)
    if check_status_code(response_dict)
        return response_dict["catalog"]
    end
end

"""
    get_parameters(server, id)

Get a dictionary containing the HAPI info metadata for all parameters in the `id` dataset.
Returns a tuple of (info, parameters) where info is the full response and parameters is
a Vector of Parameter objects.

HAPI info response JSON structure: https://github.com/hapi-server/data-specification/blob/master/hapi-dev/HAPI-data-access-spec-dev.md#36-info
"""
function get_parameters(server, id)
    response = HTTP.get(url(server, "info"); query = (; id))
    return json_parse(response.body)
end

"""
    get_parameters(server, id, parameters)

Get a dictionary containing the HAPI info metadata for each parameter in the comma-separated string `parameters`.
"""
function get_parameters(server, id, parameters)
    query = (; id, parameters)
    response = HTTP.get(url(server, "info"); query)
    return json_parse(response.body)
end
