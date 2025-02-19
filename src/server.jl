import Base: string

abstract type AbstractServer end

@kwdef struct Server <: AbstractServer
    url::String
    id::String
    title::String
    HAPI::Union{String,Nothing} = nothing
    format::String = "json"
end

CDAWeb = Server(; url="https://cdaweb.gsfc.nasa.gov/hapi", id="CDAWeb", title="CDAWeb")
CSA = Server(; url="https://csatools.esac.esa.int/HapiServer/hapi", id="CSA", title="Cluster Science Archive", HAPI="3.2", format="csv")

Base.string(s::Server) = getfield(s, :url)
format(s::Server) = getfield(s, :format)
"""Default format for HAPI servers."""
format(s) = "json"


"""
    get_capabilities(server) -> Dict

Get server capabilities.
"""
function get_capabilities(server)
    url = string(server) * "/capabilities"
    response = HTTP.get(url)
    return JSON.parse(String(response.body))
end