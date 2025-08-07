# API Reference

```@meta
CurrentModule = HAPIClient
```

## Main Functions

### Core HAPI Interface

```@docs; canonical=false
hapi
```

### Data Retrieval

```@docs; canonical=false
get_data
```

## Types

### Data Variables

```@docs; canonical=false
HAPIVariable
HAPIVariables
```

## Constants

### Predefined Servers

HAPIClient.jl provides convenient constants for commonly used HAPI servers:

- `CDAWeb` - NASA's Coordinated Data Analysis Web
- `CSA` - ESA's Cluster Science Archive

These are automatically exported and can be used directly:

```julia
# Use predefined server constants
catalog = hapi(CDAWeb)
data = hapi(CSA, "C1_CP_FGM_FULL", "B_vec_xyz_gse", start_time, end_time)
```

## Examples

### Basic Usage

```julia
using HAPIClient
using Dates

# List servers
servers = hapi()

# Get catalog
catalog = hapi(CDAWeb)

# Get data
data = hapi(CDAWeb, "AC_H0_MFI", "Magnitude", 
           DateTime(2001, 1, 1), DateTime(2001, 1, 2))
```

### Working with Retrieved Data

```julia
# Access first variable
var = data[1]

# Get values, timestamps, and metadata
values = parent(var)
timestamps = times(var)
metadata = meta(var)
```


## Public

```@autodocs
Modules = [HAPIClient]
Private = false
```

## Private

```@autodocs
Modules = [HAPIClient]
Public = false
```
