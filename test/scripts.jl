# Report software bugs/issues/feature requests at
# https://github.com/JuliaSpacePhysics/HAPIClient.jl/issues
# Report data server issues to CONTACT

## Set-up
# Install HAPIClient.jl
# Only needs to be executed once.
using Pkg
Pkg.add("HAPIClient")

## Get data and metadata
using HAPIClient
using Dates

server = "SERVER"
dataset = "DATASET"
# Use parameters="" to request all data. Multiple parameters
# can be requested using a comma-separated list, e.g., "param1,param2"
parameters = "PARAMETERS"
start = "START"
stop = "STOP"

data = hapi(server, dataset, parameters, start, stop)
meta = hapi(server, dataset, parameters)