module HAPIClient

using HTTP
using JSON
using Dates
using CSV
using Tables
using Unitful
using SpaceDataModel: AbstractDataVariable, parse_datetime
import Unitful: unit
using SpaceDataModel: name, units, meta
import SpaceDataModel: times

export hapi, get_data, meta, times
export HAPIVariable, HAPIVariables

include("server.jl")
include("metadata.jl")
include("data.jl")
include("specs/time.jl")
include("specs/parameter.jl")
include("types.jl")

hapi() = get_servers()
hapi(server) = get_catalog(server)
hapi(server, dataset) = get_parameters(server, dataset)
hapi(server, dataset, parameters) = get_parameters(server, dataset, parameters)
hapi(server, dataset, tmin, tmax; kwargs...) = get_data(server, dataset, "", tmin, tmax; kwargs...)
hapi(server, dataset, parameters, tmin, tmax; kwargs...) = get_data(server, dataset, parameters, tmin, tmax; kwargs...)

function __init__()
    ccall(:jl_generating_output, Cint, ()) == 1 && return nothing
    load_servers_from_json(; register=true)
    # export servers
    foreach(values(SERVERS)) do value
        sym = Symbol(value.id)
        @eval const $sym = $value
        @eval export $sym
    end
end

end
