module HAPIClient

using HTTP
using URIs: URI
import JSON
using Dates
import CSV
using Tables
using SpaceDataModel: SpaceDataModel, AbstractDataVariable, AbstractDataset, DataSource, getdata, getmeta
using Durations: Timestamp
using SpaceDataModel: name, units, meta
import SpaceDataModel: times, tdimnum, dims

export hapi, get_data, getdata, getmeta, meta, times
export HAPIVariable, HAPIVariables, Server, refresh_servers!

json_parse(x) = JSON.parse(String(x))

include("server.jl")
include("metadata.jl")
include("data.jl")
include("specs/time.jl")
include("specs/parameter.jl")
include("schema.jl")
include("types.jl")
include("parse.jl")
include("datamodel.jl")

"""
- `hapi()` - List available HAPI servers ([`get_servers`](@ref))
- `hapi(server, dataset, parameters)` - Get parameter information for specific parameters ([`get_parameters`](@ref))
"""
function hapi end

hapi() = get_servers()
hapi(server) = get_catalog(server)
hapi(server, dataset) = get_parameters(server, dataset)
hapi(server, dataset, parameters) = get_parameters(server, dataset, parameters)
hapi(server, dataset, tmin, tmax; kwargs...) = get_data(server, dataset, "", tmin, tmax; kwargs...)
hapi(server, dataset, parameters, tmin, tmax; kwargs...) = get_data(server, dataset, parameters, tmin, tmax; kwargs...)

# Load bundled server list and define per-server constants at precompile time.
# Use refresh_servers!() to update from the remote registry at runtime.
let _servers = load_servers_from_json(; register = true)
    for _server in _servers
        _sym = Symbol(_server.id)
        @eval const $_sym = $_server
        @eval export $_sym
    end
end

end
