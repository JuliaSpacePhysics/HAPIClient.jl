using HAPI
using Test

@testset "Data" begin
    include("data.jl")
end

@testset "Metadata" begin
    include("metadata.jl")
end
