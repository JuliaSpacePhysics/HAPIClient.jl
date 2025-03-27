using HAPIClient
using Test

@testset "Aqua" begin
    include("Aqua.jl")
end

@testset "Data" begin
    include("data.jl")
end

@testset "Metadata" begin
    include("metadata.jl")
end

@testset "DimensionalDataExt" begin
    include("ext/DimensionalDataExt.jl")
end