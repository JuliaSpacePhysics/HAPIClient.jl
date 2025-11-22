@testitem "Servers" begin
    servers = hapi()
    @test "https://cdaweb.gsfc.nasa.gov/hapi" in servers
    @test length(servers) > 0

    @test HAPIClient.get_capabilities(CDAWeb)["status"]["code"] == 1200
end

@testitem "Catalog" begin
    @test length(hapi(CDAWeb)) > 0
end

@testitem "Dataset parameters" begin
    server = "https://cdaweb.gsfc.nasa.gov/hapi"
    dataset = "AC_H0_MFI"

    meta = hapi(server, dataset)
    parameters = meta["parameters"]
    @test HAPIClient.parameters(parameters)[1].name == "Time"
end


@testitem "Parameters" begin
    server = "https://cdaweb.gsfc.nasa.gov/hapi"
    dataset = "AC_H0_MFI"
    parameters = "Magnitude,BGSEc"

    meta = hapi(server, dataset, parameters)
    @test meta["parameters"][1]["name"] == "Time"
    @test length(meta["parameters"]) == 3
end
