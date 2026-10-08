# Catalogs and info responses are cached for the session: `show`, plotting and `keys` read them repeatedly.
const _CATALOGS = Dict{String, Vector{String}}()
const _INFOS = Dict{Tuple{String, String}, Any}()
const _CACHE_LOCK = ReentrantLock()

Base.keys(s::Server) = lock(_CACHE_LOCK) do
    get!(() -> [String(d["id"]) for d in get_catalog(s)], _CATALOGS, url(s))
end
Base.getindex(s::Server, id::AbstractString) = HAPIDataset(s, String(id))
SpaceDataModel.name(s::Server) = id(s)

"""
    HAPIDataset(server, id)

The dataset `id` of a HAPI `server`.
"""
struct HAPIDataset{S} <: AbstractDataset
    server::S
    id::String
end

SpaceDataModel.name(ds::HAPIDataset) = ds.id
SpaceDataModel.getmeta(ds::HAPIDataset) = lock(_CACHE_LOCK) do
    get!(() -> get_parameters(ds.server, ds.id), _INFOS, (url(ds.server), ds.id))
end
# The first parameter is the time column.
Base.keys(ds::HAPIDataset) = [String(p["name"]) for p in getmeta(ds)["parameters"][2:end]]
Base.show(io::IO, ds::HAPIDataset) = print(io, id(ds.server), "[", repr(ds.id), "]")

Base.getindex(ds::HAPIDataset, name::Union{AbstractString, Symbol}) = HAPIParameter(ds, String(name))
Base.getindex(ds::HAPIDataset, names::AbstractVector) = HAPIParameter(ds, String.(names))

SpaceDataModel.getdata(ds::HAPIDataset, t0, t1; kw...) = get_data(ds.server, ds.id, "", t0, t1; kw...)

"""
    HAPIParameter(dataset, name)
    HAPIParameter(dataset, names)

`dataset[name]`, whose `getdata` returns a `HAPIVariable`; `dataset[names]` fetches several parameters in one request as `HAPIVariables`.
"""
struct HAPIParameter{V <: Union{String, Vector{String}}, D <: HAPIDataset} <: DataSource
    dataset::D
    name::V
end

SpaceDataModel.name(p::HAPIParameter) = p.name
SpaceDataModel.name(p::HAPIParameter{Vector{String}}) = join(p.name, ",")
Base.show(io::IO, p::HAPIParameter) = print(io, p.dataset, "[", repr(p.name), "]")

# The parameter's info entry, as `getmeta` of the fetched `HAPIVariable`.
function SpaceDataModel.getmeta(p::HAPIParameter{String})
    params = getmeta(p.dataset)["parameters"]
    i = findfirst(q -> q["name"] == p.name, params)
    isnothing(i) && throw(KeyError(p.name))
    return params[i]
end

SpaceDataModel.getdata(p::HAPIParameter, t0, t1; kw...) =
    get_data(p.dataset.server, p.dataset.id, name(p), t0, t1; kw...)
SpaceDataModel.getdata(p::HAPIParameter{String}, t0, t1; kw...) =
    only(get_data(p.dataset.server, p.dataset.id, p.name, t0, t1; kw...))
