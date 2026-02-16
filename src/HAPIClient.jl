module HAPIClient

using HTTP
using HTTP: request_uri, URI
import JSON
using Dates
import CSV
using Tables
using SpaceDataModel: AbstractDataVariable, parse_datetime
using SpaceDataModel: name, units, meta
import SpaceDataModel: times

export hapi, get_data, meta, times
export HAPIVariable, HAPIVariables, Server

json_parse(x) = JSON.parse(String(x))

include("server.jl")
include("metadata.jl")
include("data.jl")
include("specs/time.jl")
include("specs/parameter.jl")
include("types.jl")

"""
Main interface to HAPI servers and provides multiple dispatch for different use cases:

- `hapi()` - List available HAPI servers ([`get_servers`](@ref))
- `hapi(server)` - Get catalog of datasets from a server ([`get_catalog`](@ref))
- `hapi(server, dataset)` - Get parameter information for a dataset ([`get_parameters`](@ref))
- `hapi(server, dataset, parameters)` - Get parameter information for specific parameters ([`get_parameters`](@ref))
- `hapi(server, dataset, tmin, tmax)` - Get all data for a dataset in a time range ([`get_data`](@ref))
- `hapi(server, dataset, parameters, tmin, tmax)` - Get specific parameter data in a time range ([`get_data`](@ref))
"""
function hapi end

hapi() = get_servers()
hapi(server) = get_catalog(server)
hapi(server, dataset) = get_parameters(server, dataset)
hapi(server, dataset, parameters) = get_parameters(server, dataset, parameters)
hapi(server, dataset, tmin, tmax; kwargs...) = get_data(server, dataset, "", tmin, tmax; kwargs...)
hapi(server, dataset, parameters, tmin, tmax; kwargs...) = get_data(server, dataset, parameters, tmin, tmax; kwargs...)

function __init__()
    ccall(:jl_generating_output, Cint, ()) == 1 && return nothing
    load_servers_from_json(; register = true)
    return Base.invokelatest(_define_server_constants)
end

function _define_server_constants()
    return foreach(values(SERVERS)) do server
        sym = Symbol(server.id)
        @eval const $sym = $server
        @eval export $sym
    end
end

end
