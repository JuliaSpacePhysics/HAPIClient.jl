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
tmin = DateTime(2001, 1, 1, 5, 0, 0)
tmax = DateTime(2001, 1, 1, 6, 0, 0)

# Retrieve the data
data = hapi(CDAWeb, dataset, parameters, tmin, tmax)
```

### Alternative Path Format

You can also use a path-like format for data retrieval. The path format is `"server/dataset/parameter"`, where datasets may contain slashes:

```julia
data = get_data("CDAWeb/AC_H0_MFI/Magnitude,BGSEc", tmin, tmax)
```

!!! note
    This path format cannot handle cases where both the dataset and parameter contain slashes (e.g., dataset=`abc/123` and parameter=`p1/v1`). In such cases, use the `hapi()` function directly.

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
dataset = "C4_CP_FGM_FULL"
parameters = "B_vec_xyz_gse,B_mag"
tmin = DateTime(2001, 6, 11, 0, 0, 0)
tmax = DateTime(2001, 6, 11, 0, 1, 0)
data = hapi(CSA, dataset, parameters, tmin, tmax)
```

### INTERMAGNET Example

```julia
# Example with INTERMAGNET server (datasets with slashes in names)
dataset = "aae/definitive/PT1M/xyzf"
parameters = "Field_Vector"
tmin = DateTime(2001, 6, 11, 0, 0, 0)
tmax = DateTime(2001, 6, 11, 0, 1, 0)
data = hapi(INTERMAGNET, dataset, parameters, tmin, tmax)
data = get_data("INTERMAGNET/aae/definitive/PT1M/xyzf/Field_Vector", tmin, tmax)
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
