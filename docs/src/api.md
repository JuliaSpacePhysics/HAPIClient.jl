# API Reference

```@meta
CurrentModule = HAPIClient
```

## Core functions

```@docs; canonical=false
hapi
get_data
```

## Types

```@autodocs
Modules = [HAPIClient]
Private = false
Order = [:type]
```

## Predefined Servers

Convenient constants for commonly used HAPI servers are automatically exported (the valid keys of the `SERVERS` dictionary, e.g. `DAS2`, `CDAWeb`, etc.) and can be used directly:

```@example servers
using HAPIClient
HAPIClient.SERVERS
```

## Public

```@autodocs
Modules = [HAPIClient]
Private = false
Order = [:function]
```

## Private

```@autodocs
Modules = [HAPIClient]
Public = false
```
