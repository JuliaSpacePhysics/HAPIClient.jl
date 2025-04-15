module HAPIClient

using HTTP
using JSON
using Dates
using CSV
using Tables
using Unitful
using SpaceDataModel: AbstractDataVariable
import Base: getproperty, propertynames, getindex, show
import Unitful: unit
import SpaceDataModel: name, meta

export hapi, get_data
export HAPIVariable, HAPIVariables

include("server.jl")
include("metadata.jl")
include("data.jl")
include("specs/time.jl")
include("specs/parameter.jl")
include("utils.jl")
include("types.jl")

hapi() = get_servers()
hapi(server) = get_catalog(server)
hapi(server, dataset) = get_parameters(server, dataset)
hapi(server, dataset, parameters) = get_parameters(server, dataset, parameters)
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
