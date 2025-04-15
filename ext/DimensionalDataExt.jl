module DimensionalDataExt
using DimensionalData
using HAPIClient
using Unitful
using HAPIClient: colsize, name, meta
import DimensionalData: DimArray, DimStack

"""
    DimArray(v::HAPIVariable; add_unit=true)

Convert a `HAPIVariable` to a `DimArray`.
"""
function DimensionalData.DimArray(v::HAPIVariable; add_unit=true)
    values = add_unit ? parent(v) * unit(v) : parent(v)
    if ndims(v) == 1
        dims = (Ti(v.time),)
    elseif ndims(v) == 2
        odim = Y(get(meta(v), "label", 1:colsize(v)))
        dims = (Ti(v.time), odim)
    end
    metadata = Dict{Any,Any}(meta(v))
    DimArray(values, dims; name=Symbol(name(v)), metadata)
end

DimStack(vs::AbstractArray{<:HAPIVariable}) = DimStack(DimArray.(vs)...)

end