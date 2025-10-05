# Reference: https://github.com/hapi-server/client-matlab/blob/master/hapi_test.m

@testitem "get_data" begin
    id = "CDAWeb/AC_H0_MFI/Magnitude,BGSEc"
    tmin = "2001-01-01T05"
    tmax =  "2001-01-01T06"
    data = get_data(id, [tmin, tmax]; verbose=1)
    @test data.Magnitude == data[1]
    @test length(data) == 2
    @test length(times(data)) == 225
    @test meta(data[1])["name"] == "Magnitude"
    @test_nowarn display(data)

    for fmt in ["csv", "json"]
        @test_nowarn get_data(id, [tmin, tmax]; format = fmt)
    end
end
@testitem "TestData2.0" begin
    server = "http://hapi-server.org/servers/TestData2.0/hapi"
    dataset = "dataset1"
    parameters = "scalar,vector"
    tmin = "1970-01-01T00:00:00"
    tmax = "1970-01-01T00:00:10"

    vars = hapi(server, dataset, parameters, tmin, tmax)
    display(vars)
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

@testitem "TestData3.1" begin
    server = "http://hapi-server.org/servers/TestData3.1/hapi"
    dataset = "dataset1"
    parameters = ""
    start = "1970-01-01"
    stop = "1970-01-01T00:01:11"
    @test_nowarn hapi(server, dataset, parameters, start, stop)


    dataset = "dataset1-Aα☃"
    parameters = ""
    @test_nowarn hapi(server, dataset, parameters, start, stop)


    dataset = "dataset2"
    parameters = ""
    @test_nowarn hapi(server, dataset, parameters, start, stop)
end

@testitem "TestData3.2" begin
    server = "http://hapi-server.org/servers/TestData3.2/hapi"
    dataset = "DE1/PWI/B_H"
    parameters = ""
    start = "1981-09-16T02:19Z"
    stop = "1981-09-17T19:24Z"

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

@testitem "INTERMAGNET" begin
    server = INTERMAGNET
    dataset = "aae/definitive/PT1M/xyzf"
    parameters = "Field_Vector"
    start = "2001-06-11T00:00:00"
    stop = "2001-06-11T00:01:00"

    @test_nowarn hapi(server, dataset, parameters, start, stop)
    @test_nowarn get_data("INTERMAGNET/aae/definitive/PT1M/xyzf/Field_Vector", start, stop)
end

@testitem "CDAWeb" begin
    server = CDAWeb
    dataset = "AC_H0_MFI"
    parameters = "Magnitude,BGSEc"
    tmin = "2001-01-01T05:00:00"
    tmax = "2001-01-01T06:00:00"

    @test_nowarn hapi(server, dataset, parameters, tmin, tmax)
end
