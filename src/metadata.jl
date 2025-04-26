const DEFAULT_SERVER_LIST = "https://github.com/hapi-server/servers/raw/master/all.txt"

@doc """
    get_servers()

Get a list of available HAPI server URLs from $DEFAULT_SERVER_LIST
"""
function get_servers(server_list::String=DEFAULT_SERVER_LIST)
    response = HTTP.get(server_list)
    servers = split(String(response.body), '\n', keepempty=false)
    return strip.(servers)
end

"""
    get_catalog(server)

Get a list of datasets available from the server.

HAPI info response JSON structure: https://github.com/hapi-server/data-specification/blob/master/hapi-dev/HAPI-data-access-spec-dev.md#35-catalog
"""
function get_catalog(server)
    response = HTTP.get(url(server, "catalog"))
    return JSON.parse(String(response.body))
end

"""
    get_parameters(server, dataset)

Get a dictionary containing the HAPI info metadata for all parameters in the `dataset`.
Returns a tuple of (info, parameters) where info is the full response and parameters is
a Vector of Parameter objects.

HAPI info response JSON structure: https://github.com/hapi-server/data-specification/blob/master/hapi-dev/HAPI-data-access-spec-dev.md#36-info
"""
function get_parameters(server, dataset)
    query = Dict("id" => dataset)
    response = HTTP.get(url(server, "info"); query)
    return JSON.parse(String(response.body))
end

"""
    get_parameters(server, dataset, parameters)

Get a dictionary containing the HAPI info metadata for each parameter in the comma-separated string `parameters`.
"""
function get_parameters(server, dataset, parameters)
    query = Dict("id" => dataset, "parameters" => parameters)
    response = HTTP.get(url(server, "info"); query)
    return JSON.parse(String(response.body))
end