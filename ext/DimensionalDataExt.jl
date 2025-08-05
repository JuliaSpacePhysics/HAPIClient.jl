module DimensionalDataExt
using DimensionalData
using HAPIClient
using Unitful: unit
using HAPIClient: colsize, name, meta
using SpaceDataModel: times
import DimensionalData: DimArray, DimStack, dims

DimensionalData.dims(v::HAPIVariable) =
    if ndims(v) == 1
        (Ti(times(v)),)
    elseif ndims(v) == 2
        odim = Y(get(meta(v), "label", 1:colsize(v)))
        (Ti(times(v)), odim)
    else
        error("Unsupported number of dimensions: $(ndims(v))")
    end

"""
    DimArray(v::HAPIVariable; add_unit=true)

Convert a `HAPIVariable` to a `DimArray`.
"""
function DimensionalData.DimArray(v::HAPIVariable; add_unit=true)
    values = add_unit ? parent(v) * unit(v) : parent(v)
    metadata = Dict{Any,Any}(meta(v))
    DimArray(values, dims(v); name=Symbol(name(v)), metadata)
end

DimStack(vs::HAPIVariables) = DimStack(DimArray.(vs)...)

end