import Base: /

const DEFAULT_SERVERS_JSON_URL = "https://raw.githubusercontent.com/hapi-server/servers/refs/heads/master/servers.json"
const DEFAULT_FORMAT = "csv"

abstract type AbstractServer end

@kwdef struct Server <: AbstractServer
    url::String
    id::String
    title::String
    HAPI::Union{String,Nothing} = nothing
    format::String = DEFAULT_FORMAT
end

# CSA = Server(; url="https://csatools.esac.esa.int/HapiServer/hapi", id="CSA", title="Cluster Science Archive", HAPI="3.2", format="csv")

# Define available servers
const SERVERS = Dict{String,Server}()

register_server!(server::Server) = (SERVERS[uppercase(server.id)] = server)

"""Get a HAPI server instance by its ID."""
Server(id) = SERVERS[uppercase(id)]

(/)(s::Server, t::AbstractString) = "$(url(s))/$t"
format(s::Server) = getfield(s, :format)
"""Default format for HAPI servers."""
format(s) = DEFAULT_FORMAT

"""
    get_capabilities(server) -> Dict

Get server capabilities.
"""
function get_capabilities(server)
    url = server / "capabilities"
    response = HTTP.get(url)
    return JSON.parse(String(response.body))
end

"""
    load_servers_from_json(; url=DEFAULT_SERVERS_JSON_URL, register=false)

Load HAPI servers from a JSON file at the specified URL.
"""
function load_servers_from_json(; url=DEFAULT_SERVERS_JSON_URL, register=false)
    # Fetch the JSON data
    response = HTTP.get(url)
    servers_data = JSON.parse(String(response.body))

    # Register each server
    servers = map(servers_data["servers"]) do server_info
        Server(
            url=server_info["url"],
            id=server_info["id"],
            title=server_info["title"],
            HAPI=get(server_info, "HAPI", nothing),
            format=get(server_info, "format", DEFAULT_FORMAT)
        )
    end

    register && register_server!.(servers)

    return servers
end