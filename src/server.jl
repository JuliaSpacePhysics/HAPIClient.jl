import Base: /

const DEFAULT_SERVERS_JSON_URL = "https://raw.githubusercontent.com/hapi-server/servers/refs/heads/master/abouts.json"
const DEFAULT_FORMAT = "csv"

abstract type AbstractServer end

@kwdef struct Server <: AbstractServer
    url::String
    id::String
    title::String
    HAPI::Union{String, Nothing} = nothing
    format::String = DEFAULT_FORMAT
end

id(s::Server) = s.id
url(s) = s
url(s::Server) = s.url
url(s, t) = "$(url(s))/$t"
(/)(s::Server, t::AbstractString) = url(s, t)
# CSA = Server(; url="https://csatools.esac.esa.int/HapiServer/hapi", id="CSA", title="Cluster Science Archive", HAPI="3.2", format="csv")

# Define available servers
const SERVERS = Dict{String, Server}()

register_server!(server::Server) = (SERVERS[uppercase(server.id)] = server)

"""
    Server(id)

Get a HAPI server instance by its ID.

# Examples
```julia
cdaweb = Server("CDAWeb") # same as HAPIClient.CDAWeb
```
"""
Server(id) = SERVERS[uppercase(id)]

format(s::Server) = getfield(s, :format)
"""Default format for HAPI servers."""
format(_) = DEFAULT_FORMAT

"""
    get_capabilities(server)

Get server capabilities.
"""
function get_capabilities(server)
    response = HTTP.get(url(server, "capabilities"))
    return json_parse(response.body)
end

"""
    load_servers_from_json(source=joinpath(@__DIR__, "abouts.json"); register=false)

Load HAPI servers from a local JSON file or remote URL.
"""
function load_servers_from_json(source = joinpath(@__DIR__, "abouts.json"); register = false)
    servers_data = if startswith(string(source), "http")
        json_parse(HTTP.get(source).body)
    else
        JSON.parsefile(source)
    end

    servers = map(servers_data) do server_info
        Server(
            url = server_info["x_url"],
            id = get(server_info, "id", ""),
            title = get(server_info, "title", ""),
            HAPI = get(server_info, "HAPI", nothing),
            format = get(server_info, "format", DEFAULT_FORMAT)
        )
    end

    register && register_server!.(servers)

    return servers
end

"""
    refresh_servers!(; url=DEFAULT_SERVERS_JSON_URL)

Fetch the latest server list from the remote URL and update the registry.
"""
function refresh_servers!(; url = DEFAULT_SERVERS_JSON_URL)
    return load_servers_from_json(url; register = true)
end
