# Changelog

## Unreleased

## [0.2.7] - 2026-10-02

### Changed

- Data time axes are `Timestamp{Nanosecond}` (from Durations.jl / the Dates stdlib on Julia 1.14+) instead of `DateTime`, preserving up to nanosecond precision in HAPI time strings, including day-of-year and truncated forms
- Request times accept any `Dates.TimeType` and sub-millisecond strings; sub-millisecond digits are forwarded to the server

### Fixed

- Implement `tdimnum` for `HAPIVariable` (time is the first dimension), so `SpaceDataModel` consumers no longer fall back to the last dimension

## [0.2.0] - 2025-08-17

### Changed

- **Breaking**: Always return `HAPIVariables` for `hapi` and `get_data` ([#9](https://github.com/JuliaSpacePhysics/HAPIClient.jl/issues/9))

