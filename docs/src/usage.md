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

A server is a registry of its catalog: `keys` lists dataset ids, and `server[id]` is a dataset.

```@example usage
filter(contains("AC_H0"), keys(CDAWeb))
```

### Dataset Information

`keys` lists a dataset's parameter names; `getmeta(ds)` returns the HAPI info response, and `getmeta(ds[name])` one parameter's entry.

```@example usage
ds = CDAWeb["AC_H0_MFI"]
keys(ds)
```

```@example usage
getmeta(ds)
```

```@example usage
getmeta(ds["Magnitude"])
```

## Data Retrieval and Access

### Basic Data Download

`ds[name]` fetches one parameter as a `HAPIVariable`; `ds[names]` fetches several in one request as `HAPIVariables`.

```@example usage
using Dates

tmin = DateTime(2001, 1, 1, 5, 0, 0)
tmax = DateTime(2001, 1, 1, 6, 0, 0)

Magnitude = getdata(ds["Magnitude"], tmin, tmax)
```

```@example usage
data = getdata(ds[["Magnitude", "BGSEc"]], tmin, tmax)
```

### Accessing Retrieved Data

```@example usage
var = data["BGSEc"]
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
metadata = getmeta(var)
```

## Working with Different Servers

### CSA Example

```julia
# Example with CSA (Cluster Science Archive) server
tmin = DateTime(2001, 6, 11, 0, 0, 0)
tmax = DateTime(2001, 6, 11, 0, 1, 0)
data = getdata(CSA["C4_CP_FGM_FULL"][["B_vec_xyz_gse", "B_mag"]], tmin, tmax)
```

### INTERMAGNET Example

```julia
# Example with INTERMAGNET server (datasets with slashes in names)
tmin = DateTime(2001, 6, 11, 0, 0, 0)
tmax = DateTime(2001, 6, 11, 0, 1, 0)
data = getdata(INTERMAGNET["aae/definitive/PT1M/xyzf"]["Field_Vector"], tmin, tmax)
```

## Data Analysis

The retrieved data integrates well with Julia's ecosystem:

```@example usage
using CairoMakie

f = Figure()
for (i, var) in enumerate(data)
    m = getmeta(var)
    ax = Axis(f[i,1]; ylabel=m["name"], title=m["description"])
    t = DateTime.(times(var))  # Makie time axes do not support Timestamp yet
    for c in eachcol(var)
        lines!(t, c)
    end
    i != length(data) && hidexdecorations!(; grid=false)
end
f
```

For advanced visualization capabilities, `HAPIClient.jl` works well with the `SPEDAS.jl` ecosystem. See the [SPEDAS.jl quickstart guide](https://JuliaSpacePhysics.github.io/SPEDAS.jl/dev/tutorials/getting-started/) for detailed visualization examples.
