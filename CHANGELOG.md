# Changelog

## Unreleased

### Added

- Servers and datasets follow SpaceDataModel's interface: `keys(server)` lists dataset ids, `server[id]` is a dataset, `keys(ds)` lists parameter names, and `getdata(ds[name], tmin, tmax)` returns a `HAPIVariable`
- `getdata(ds[[name1, name2]], tmin, tmax)` fetches several parameters in one request as `HAPIVariables`
- `getmeta(ds[name])` returns the parameter's info entry; info responses are cached for the session

## [0.3.0] - 2026-10-06

### Changed

- **Breaking**: Values equal to a parameter's `fill` read as `NaN` (opt out with `mask = false`), so an `integer` parameter with a `fill` reads as `Float64` ([#42](https://github.com/JuliaSpacePhysics/HAPIClient.jl/pull/42))
- **Breaking**: `HAPIVariable(json::AbstractDict, i)` and `HAPIVariable(json, meta, i)` are replaced by `HAPIVariable(data, params, i)`, which takes a CSV table or a JSON response
- Column types follow the parameter metadata instead of CSV.jl inference, so a `double` parameter is `Float64` in every time range and CSV and JSON responses give the same types
- JSON responses parse about twice as fast for scalar parameters

### Fixed

- A time range without data returns empty variables instead of erroring, including CDAWeb's `1201` status reply to a CSV request
- An error status in a JSON body with HTTP 200 throws instead of returning empty data
- `integer` values written as `1.0` or `+3`, which the HAPI verifier accepts, parse as integers

## [0.2.7] - 2026-10-02

### Changed

- Data time axes are `Timestamp{Nanosecond}` (from Durations.jl / the Dates stdlib on Julia 1.14+) instead of `DateTime`, preserving up to nanosecond precision in HAPI time strings, including day-of-year and truncated forms
- Request times accept any `Dates.TimeType` and sub-millisecond strings; sub-millisecond digits are forwarded to the server

### Fixed

- Implement `tdimnum` for `HAPIVariable` (time is the first dimension), so `SpaceDataModel` consumers no longer fall back to the last dimension

## [0.2.0] - 2025-08-17

### Changed

- **Breaking**: Always return `HAPIVariables` for `hapi` and `get_data` ([#9](https://github.com/JuliaSpacePhysics/HAPIClient.jl/issues/9))

