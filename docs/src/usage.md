# Usage Guide

This guide provides detailed examples of how to use `HAPIClient.jl` to access heliophysics data from HAPI servers.

## Basic Usage

### Listing Available Servers

Start by exploring what HAPI servers are available:

```@example usage
using HAPIClient

# List all available HAPI servers
servers = hapi()
```

### Getting Dataset Catalogs

Once you know which servers are available, you can browse their catalogs:

```@example usage
# Get catalog of available datasets from CDAWeb
catalog = hapi(CDAWeb)
```

### Dataset Information

Get detailed information about parameters in a specific dataset:

```@example usage
dataset = "AC_H0_MFI"
params = hapi(CDAWeb, dataset)
```

## Data Retrieval and Access

### Basic Data Download

Retrieve data for specific parameters within a time range:

```@example usage
using Dates

dataset = "AC_H0_MFI"
parameters = "Magnitude,BGSEc"
start_time = DateTime(2001, 1, 1, 5, 0, 0)
end_time = DateTime(2001, 1, 1, 6, 0, 0)

# Retrieve the data
data = hapi(CDAWeb, dataset, parameters, start_time, end_time)
```

### Alternative Path Format

You can also use a path-like format for data retrieval:

```julia
# Alternative method using path format
data = get_data("CDAWeb/AC_H0_MFI/Magnitude,BGSEc", start_time, end_time)
```

### Accessing Retrieved Data

Once you have retrieved data, you can access individual variables:

```@example usage
Magnitude = data.Magnitude # or data[1] if you know the order (same as `parameters` order)
BGSEc = data.BGSEc # or data[2]
var = data[2]
```

Retrieve the values

```@example usage
values = parent(var)
```

Retrieve the timestamps

```@example usage
timestamps = times(var)
```

Retrieve the metadata

```@example usage
metadata = meta(var)
```

## Working with Different Servers

### CSA Example

```julia
# Example with CSA (Cluster Science Archive) server
csa_dataset = "C4_CP_FGM_FULL"
csa_parameters = "B_vec_xyz_gse,B_mag"
csa_start = DateTime(2001, 6, 11, 0, 0, 0)
csa_end = DateTime(2001, 6, 11, 0, 1, 0)
csa_data = hapi(CSA, csa_dataset, csa_parameters, csa_start, csa_end)
```

## Data Analysis

The retrieved data integrates well with Julia's ecosystem:

```@example usage
using CairoMakie

f = Figure()
for (i, var) in enumerate(data)
    m = meta(var)
    ax = Axis(f[i,1]; xlabel="Time", ylabel=m["name"], title=m["description"])
    t = times(var)
    for c in eachcol(var)
        lines!(t, c)
    end
    i != length(data) && hidexdecorations!(; grid=false)
end
f
```

For advanced visualization capabilities, `HAPIClient.jl` works well with the `SPEDAS.jl` ecosystem. See the [SPEDAS.jl quickstart guide](https://JuliaSpacePhysics.github.io/SPEDAS.jl/dev/tutorials/getting-started/) for detailed visualization examples.
