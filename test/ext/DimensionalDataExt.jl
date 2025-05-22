@testitem "DimensionalDataExt" begin
    using DimensionalData
    server = "http://hapi-server.org/servers/TestData2.0/hapi"
    dataset = "dataset1"
    parameters = "scalar,vector"
    tmin = "1970-01-01T00:00:00"
    tmax = "1970-01-01T00:00:10"

    hapi_parameters = hapi(server, dataset, parameters, tmin, tmax; format="csv")
    ds = DimStack(hapi_parameters)
    @test length(layers(ds)) == 2
    @test size(ds, 1) == 10
end