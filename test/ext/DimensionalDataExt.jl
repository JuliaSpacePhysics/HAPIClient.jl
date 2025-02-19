using HAPI
using Test
using DimensionalData

@testset "DimensionalDataExt" begin
    server = "http://hapi-server.org/servers/TestData2.0/hapi"
    dataset = "dataset1"
    parameters = "scalar,vector"
    tmin = "1970-01-01T00:00:00"
    tmax = "1970-01-01T00:00:10"

    data, meta = hapi(server, dataset, parameters, tmin, tmax; format="csv")
    hapi_parameters = HAPIParameters(data, meta)
    ds = DimStack(hapi_parameters)
    @test length(layers(ds)) == 2
    @test length(ds) == 10
end