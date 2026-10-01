# Changelog

## Unreleased

### Fixed

- Implement `tdimnum` for `HAPIVariable` (time is the first dimension), so `SpaceDataModel` consumers no longer fall back to the last dimension

## [0.2.0] - 2025-08-17

### Changed

- **Breaking**: Always return `HAPIVariables` for `hapi` and `get_data` ([#9](https://github.com/JuliaSpacePhysics/HAPIClient.jl/issues/9))

