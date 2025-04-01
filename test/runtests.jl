using HAPIClient
using Test
using TestItems, TestItemRunner

@run_package_tests

@testset "Aqua" begin
    include("Aqua.jl")
end

@testset "DateTime" begin
    using HAPIClient: HAPIDateTime
    @test HAPIDateTime("2001-01-01") == "2001-01-01T00:00:00.000Z"
    @test HAPIDateTime("2001-01-01T05:00:00Z") == "2001-01-01T05:00:00.000Z"
    @test HAPIDateTime("1999-01Z") == "1999-01-01T00:00:00.000Z"
    @test HAPIDateTime("1999-032T02:03:05Z") == "1999-02-01T02:03:05.000Z"
    @test HAPIDateTime("1999-032T02:04") == "1999-02-01T02:04:00.000Z"
end

@testset "Metadata" begin
    include("metadata.jl")
end

@testset "DimensionalDataExt" begin
    include("ext/DimensionalDataExt.jl")
end