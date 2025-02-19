module DimensionalDataExt
using DimensionalData
using HAPI
using Unitful
using HAPI: colsize
import DimensionalData: DimArray, DimStack

"""
    DimArray(v::HAPIParameter; unit=unit(v), add_axes=true)

Convert a `HAPIParameter` to a `DimArray`.
"""
function DimensionalData.DimArray(v::HAPIParameter; unit=unit(v))
    name = Symbol(v.name)
    if ndims(v.values) == 1
        dims = (Ti(v.time),)
    elseif ndims(v.values) == 2
        odim = Dim{name}(get(v.meta, "label", 1:colsize(v)))
        dims = (Ti(v.time), odim)
    end
    metadata = Dict{Any,Any}(v.meta)
    DimArray(v.values * unit, dims; name, metadata)
end

DimStack(vs::AbstractArray{HAPIParameter}) = DimStack(DimArray.(vs)...)

end