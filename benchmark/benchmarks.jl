using BenchmarkTools
using Downloads
using HAPIClient
using HTTP

const SUITE = BenchmarkGroup()

# Real CDAWeb responses, replayed by a local server: `get_data` runs end to end, parsing included,
# without network noise, and through public API only, so the suite also runs on older revisions.
const CDAWEB = "https://cdaweb.gsfc.nasa.gov/hapi"
const CASES = [
    # 1-s magnetic field, a day: `double` scalar and vector parameters (nested arrays in JSON)
    ("AC_H3_MFI", "Magnitude,BGSEc", "2020-01-01T00:00:00.000Z", "2020-01-02T00:00:00.000Z", ["csv", "json"]),
    # 1-min OMNI, a week of every parameter: many `integer` and `double` columns, all with fills
    ("OMNI_HRO2_1MIN", "", "2020-01-01T00:00:00.000Z", "2020-01-08T00:00:00.000Z", ["csv", "json"]),
]

function fixture(query)
    dir = joinpath(tempdir(), "HAPIClient_benchmark_data")
    mkpath(dir)
    path = joinpath(dir, string(hash(query), base = 16))
    isfile(path) || Downloads.download("$CDAWEB/$query", path)
    return read(path)
end

# Keyed by endpoint and sorted query parameters, as the client orders them differently.
_key(target) = (u = HTTP.URI(target); (basename(u.path), sort!(collect(HTTP.queryparams(u)))))

const ROUTES = Dict{Any, Vector{UInt8}}()
for (id, params, tmin, tmax, formats) in CASES
    info = "info?id=$id&parameters=$params"
    ROUTES[_key("/" * info)] = fixture(info)
    for fmt in formats
        data = replace(info, "info?" => "data?") * "&time.min=$tmin&time.max=$tmax&format=$fmt"
        ROUTES[_key("/" * data)] = fixture(data)
    end
end

const SERVER = HTTP.serve!(req -> HTTP.Response(200, ROUTES[_key(req.target)]), "127.0.0.1", 0)
const URL = "http://127.0.0.1:$(HTTP.port(SERVER))/hapi"

for (id, params, tmin, tmax, formats) in CASES
    g = SUITE[id] = BenchmarkGroup()
    for fmt in formats
        g[fmt] = @benchmarkable get_data($URL, $id, $params, $tmin, $tmax; format = $fmt)
    end
end
