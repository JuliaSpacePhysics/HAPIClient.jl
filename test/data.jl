# Reference: https://github.com/hapi-server/client-matlab/blob/master/hapi_test.m

@testitem "get_data" begin
    using Unitful
    id = "CDAWeb/AC_H0_MFI/Magnitude,BGSEc"
    tmin = "2001-01-01T05"
    tmax = "2001-01-01T06"
    data = get_data(id, [tmin, tmax]; verbose = 1)
    @test data.Magnitude == data[1]
    @test length(data) == 2
    @test length(times(data)) == 225
    @test eltype(times(data)) == HAPIClient.HAPITime
    @test meta(data[1])["name"] == "Magnitude"
    @test_nowarn display(data)
    @test unit(data.Magnitude) == u"nT"

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
    @test_nowarn hapi(server, dataset, parameters, tmin, tmax; format = "json")
    @time hapi(server, dataset, parameters, tmin, tmax)

    B = hapi(server, dataset, parameters, tmin, tmax).BGSEc
    @test HAPIClient.tdimnum(B) == 1
end

@testitem "types from metadata, fill as NaN" begin
    using HAPIClient: read_csv
    P(name, type, fill, extra...) = Dict{String, Any}("name" => name, "type" => type, "fill" => fill, extra...)
    params = [
        P("Time", "isotime", nothing), P("d", "double", "-1e31"), P("i", "integer", "99"),
        Dict{String, Any}("name" => "c", "type" => "integer"), P("v", "double", "-1e31", "size" => [2]), P("s", "string", nothing),
    ]
    # Whole-number doubles and numeric strings, which CSV.jl would infer as Int; integers written as the HAPI verifier allows;
    # `-9.9999998e30` is the `-1e31` fill as a server writing Float32 prints it
    csv = """
    2001-01-01T00:00:00.000Z,0,5,1.0,1,-1e31,7
    2001-01-01T00:00:01.000Z,-1,99,+2,-9.9999998e30,2,8
    """
    json = Dict("data" => [
        ["2001-01-01T00:00:00.000Z", 0, 5, 1, [1, -1.0e31], "7"],
        ["2001-01-01T00:00:01.000Z", -1, 99, 2, [-9.9999998e30, 2], "8"],
    ])
    # Bare records with array parameters flattened, as TestData2.0 serves JSON
    json_flat = [
        ["2001-01-01T00:00:00.000Z", 0, 5, 1, 1, -1.0e31, "7"],
        ["2001-01-01T00:00:01.000Z", -1, 99, 2, -9.9999998e30, 2, "8"],
    ]
    for data in (read_csv(Vector{UInt8}(csv), params), json, json_flat)
        x(i; kw...) = parent(HAPIVariable(data, params, i; kw...))
        @test x(1) isa AbstractVector{Float64} && x(1) == [0.0, -1.0]
        @test x(2) isa AbstractVector{Float64} && isequal(x(2), [5.0, NaN])
        @test x(3) isa AbstractVector{Int} && x(3) == [1, 2]
        @test x(4) isa AbstractMatrix{Float64} && isequal(x(4), [1.0 NaN; NaN 2.0])
        @test x(5) == ["7", "8"]
        @test x(2; mask = false) isa AbstractVector{Int} && x(2; mask = false) == [5, 99]
        @test isequal(x(4; mask = false), [1.0 -1.0e31; -9.9999998e30 2.0])
    end
    # JSON `null` reads as fill, like an empty CSV cell
    @test isequal(parent(HAPIVariable([["2001-01-01T00:00:00Z", 0, nothing, 1, [1, 2], "7"]], params, 2)), [NaN])
    # A time range without records
    @test parent(HAPIVariable(Dict("data" => []), params, 4)) isa Matrix{Float64}
    @test parent(HAPIVariable(HAPIClient._checked(Dict("status" => Dict("code" => 1201))), params, 4)) isa Matrix{Float64}
    @test_throws ErrorException HAPIClient._checked(Dict("status" => Dict("code" => 1406)))
    # A fill Float32 holds exactly matches exactly
    zparams = [P("Time", "isotime", nothing), P("z", "double", "0")]
    @test isequal(parent(HAPIVariable([["2001-01-01T00:00:00Z", 1.0e-50], ["2001-01-01T00:00:01Z", 0]], zparams, 1)), [1.0e-50, NaN])
end
