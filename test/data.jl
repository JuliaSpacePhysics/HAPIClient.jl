@testitem "TestData2.0" begin
    server = "http://hapi-server.org/servers/TestData2.0/hapi"
    dataset = "dataset1"
    parameters = "scalar,vector"
    tmin = "1970-01-01T00:00:00"
    tmax = "1970-01-01T00:00:10"

    @test_nowarn hapi(server, dataset, parameters, tmin, tmax)
end

@testitem "TestData2.1" begin
    server = "http://hapi-server.org/servers/TestData2.1/hapi"
    dataset = "dataset1"
    parameters = ""
    start = "1970-01-01"
    stop = "1970-01-01T00:00:11"

    @test_nowarn hapi(server, dataset, parameters, start, stop)
end

@testitem "TestData3.0" begin
    server = "http://hapi-server.org/servers/TestData3.0/hapi"
    dataset = "dataset1"
    parameters = ""
    start = "1970-01-01"
    stop = "1970-01-01T00:01:11"

    @test_nowarn hapi(server, dataset, parameters, start, stop)
end

@testitem "CSA" begin
    server = CSA
    dataset = "C4_CP_FGM_FULL"
    parameters = "B_vec_xyz_gse,B_mag"
    tmin = "2001-06-11T00:00:00"
    tmax = "2001-06-11T00:01:00"

    @test_nowarn hapi(server, dataset, parameters, tmin, tmax)
end

@testitem "CDAWeb" begin
    server = CDAWeb
    dataset = "AC_H0_MFI"
    parameters = "Magnitude,BGSEc"
    tmin = "2001-01-01T05:00:00"
    tmax = "2001-01-01T06:00:00"

    @test_nowarn hapi(server, dataset, parameters, tmin, tmax)
end