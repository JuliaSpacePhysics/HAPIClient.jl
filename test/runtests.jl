using TestItems, TestItemRunner

@run_package_tests

@testitem "Aqua" begin
    using Aqua
    Aqua.test_all(HAPIClient)
end

@testitem "HAPISchema" begin
    using HAPIClient: HAPISchema, get_data
    using SpaceDataModel: get_schema

    id  = "CDAWeb/AC_H0_MFI/Magnitude,BGSEc"
    data = get_data(id, ["2001-01-01T05", "2001-01-01T06"])
    mag = data.Magnitude

    @test get_schema(mag) isa HAPISchema

    attrs = HAPISchema()(mag)
    @test attrs[:name] == "Magnitude"
    @test attrs[:unit] == "nT"
    @test attrs[:desc] isa AbstractString
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