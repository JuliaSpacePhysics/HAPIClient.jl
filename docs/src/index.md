# HAPIClient.jl

[![DOI](https://zenodo.org/badge/935193759.svg)](https://doi.org/10.5281/zenodo.15108960)

[![Build Status](https://github.com/JuliaSpacePhysics/HAPIClient.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/JuliaSpacePhysics/HAPIClient.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Aqua QA](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)
[![Coverage](https://codecov.io/gh/JuliaSpacePhysics/HAPIClient.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/JuliaSpacePhysics/HAPIClient.jl)

A Julia client for the Heliophysics Application Programmer's Interface (HAPI).

HAPIClient.jl makes it easy to access heliophysics data from HAPI-compliant servers. The package supports:

- Listing available HAPI servers (See [HAPI Server Browser](https://hapi-server.org/servers/))
- Browsing catalogs of datasets
- Retrieving parameter information
- Downloading time series data
- Integration with Julia's ecosystem (Unitful, [DimensionalData](https://github.com/rafaqz/DimensionalData.jl))

## Installation

```julia
using Pkg
Pkg.add("HAPIClient")
```

## Quick Start

```@example start
using HAPIClient
using Dates

# Get data from CDAWeb
dataset = "AC_H0_MFI"
parameters = "Magnitude,BGSEc"
start_time = DateTime(2001, 1, 1, 5, 0, 0)
end_time = DateTime(2001, 1, 1, 6, 0, 0)
data = hapi(CDAWeb, dataset, parameters, start_time, end_time)
```

## Navigation

- [Usage](usage.md) - Detailed usage examples and tutorials
- [API Reference](api.md) - Complete API documentation
