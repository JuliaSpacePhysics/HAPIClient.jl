using HAPIClient
using Test
using TestItems, TestItemRunner

@run_package_tests

@testset "Aqua" begin
    include("Aqua.jl")
end

@testitem "DateTime" begin
    using HAPIClient: HAPIDateTime
    @test HAPIDateTime("2001-01-01") == "2001-01-01T00:00:00.000Z"
    @test HAPIDateTime("2001-01-01T05:00:00Z") == "2001-01-01T05:00:00.000Z"
    @test HAPIDateTime("1999-01Z") == "1999-01-01T00:00:00.000Z"
    @test HAPIDateTime("1999-032T02:03:05Z") == "1999-02-01T02:03:05.000Z"
    @test HAPIDateTime("1999-032T02:04") == "1999-02-01T02:04:00.000Z"

    dts = [
        "1989Z", "1989-01Z", "1989-001Z",
        "1989-01-01Z", "1989-001T00Z",
        "1989-01-01T00Z", "1989-001T00:00Z",
        "1989-01-01T00:00Z", "1989-001T00:00:00.Z",
        "1989-01-01T00:00:00.Z", "1989-01-01T00:00:00.0Z",
        "1989-001T00:00:00.0Z", "1989-01-01T00:00:00.00Z",
        "1989-001T00:00:00.00Z", "1989-01-01T00:00:00.000Z",
        "1989-001T00:00:00.000Z"
    ]

    expected = "1989-01-01T00:00:00.000Z"

    for dt in dts
        @test HAPIDateTime(dt) == expected
    end

    dts = [
        "1989-01-01T00:00:00.0001Z", "1989-001T00:00:00.0001Z",
        "1989-01-01T00:00:00.00001Z", "1989-001T00:00:00.00001Z",
        "1989-01-01T00:00:00.000001Z", "1989-001T00:00:00.000001Z"
    ]

    for dt in dts
        @test_throws ArgumentError HAPIDateTime(dt)
    end
end

@testset "Metadata" begin
    include("metadata.jl")
end

@testset "DimensionalDataExt" begin
    include("ext/DimensionalDataExt.jl")
end