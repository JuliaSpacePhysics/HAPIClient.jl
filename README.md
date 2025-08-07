# HAPIClient

[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://JuliaSpacePhysics.github.io/HAPIClient.jl/dev/)
[![DOI](https://zenodo.org/badge/935193759.svg)](https://doi.org/10.5281/zenodo.15108960)
[![Build Status](https://github.com/JuliaSpacePhysics/HAPIClient.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/JuliaSpacePhysics/HAPIClient.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Aqua QA](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)
[![Coverage](https://codecov.io/gh/JuliaSpacePhysics/HAPIClient.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/JuliaSpacePhysics/HAPIClient.jl)

A Julia client for the Heliophysics Application Programmer's Interface (HAPI).

See [HAPI Server Browser](https://hapi-server.org/servers/) for a list of HAPI servers and datasets.

## Installation

```julia
using Pkg
Pkg.add("HAPIClient")
```

## Usage Example

```julia
using HAPIClient
using Dates

# List available HAPI servers
servers = hapi()

# Use a predefined server (CDAWeb or CSA)
# Get catalog of available datasets from CDAWeb
catalog = hapi(CDAWeb)

# Get information about parameters in a dataset
dataset = "AC_H0_MFI"
params = hapi(CDAWeb, dataset)

# Retrieve data for specific parameters within a time range
parameters = "Magnitude,BGSEc"
start_time = DateTime(2001, 1, 1, 5, 0, 0)
end_time = DateTime(2001, 1, 1, 6, 0, 0)
data = hapi(CDAWeb, dataset, parameters, start_time, end_time)

# Alternative method using path format
data = get_data("CDAWeb/AC_H0_MFI/Magnitude,BGSEc", start_time, end_time)

# Access the data
Magnitude = data[1]
BGSEc = data[2]
```

Recommended way to access variable properties:

```julia
var = data[1]
# to retrieve the values
parent(var)
# to retrieve the timestamps
times(var)
# to retrieve the metadata
meta(var)
```