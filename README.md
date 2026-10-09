# HAPIClient

[![DOI](https://zenodo.org/badge/935193759.svg)](https://doi.org/10.5281/zenodo.15108960)

A Julia client for the Heliophysics Application Programmer's Interface (HAPI).

For information on using the package, see the [documentation](https://JuliaSpacePhysics.github.io/HAPIClient.jl/dev/). For the list of HAPI servers and datasets, see [HAPI Server Browser](https://hapi-server.org/servers/).

## Usage Example

```julia
using Pkg; Pkg.add("HAPIClient")
using HAPIClient
using Dates

# List available HAPI servers
servers = hapi()

# A server is a catalog of datasets
filter(contains("AC_H0"), keys(CDAWeb))   # dataset ids
ds = CDAWeb["AC_H0_MFI"]                  # a dataset
keys(ds)                                  # parameter names
getmeta(ds)                               # HAPI info response
getmeta(ds["Magnitude"])                  # the parameter's info entry

tmin = DateTime(2001, 1, 1, 5, 0, 0)
tmax = DateTime(2001, 1, 1, 6, 0, 0)
var = getdata(ds["Magnitude"], tmin, tmax)                # a HAPIVariable
data = getdata(ds[["Magnitude", "BGSEc"]], tmin, tmax)    # HAPIVariables, one request
data = getdata(ds, tmin, tmax)                            # all parameters
data["BGSEc"]

parent(var)   # values
times(var)    # timestamps
getmeta(var)  # metadata
```

## Elsewhere

- [HAPI GitHub](https://github.com/hapi-server): Official HAPI GitHub organization