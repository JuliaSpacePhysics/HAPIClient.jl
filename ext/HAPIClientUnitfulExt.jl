module HAPIClientUnitfulExt

using HAPIClient
using Unitful
using SpaceDataModel: units

# when units have more than one value, return an array
function hapi_uparse(u)
    isnothing(u) && return 1
    u == "UTC" && return 1
    u == "degrees" && return u"°"
    return uparse(u)
end
hapi_uparse(units::AbstractArray) = hapi_uparse.(units)

Unitful.unit(var::HAPIClient.HAPIVariable) = hapi_uparse.(units(var))

end
