# A response becomes a table in the HAPI CSV column layout (time first, array parameters flattened),
# whose columns are typed from the parameter metadata; variables are column ranges of that table.

function HAPIVariables(data, params, meta, args...; mask = true)
    table = _table(data, params)
    time = _times(table)
    n = length(params) - 1
    names = Tuple(Symbol(params[i + 1]["name"]) for i in 1:n)
    values = (_variable(table, params, i, time, mask) for i in 1:n)
    return HAPIVariables(NamedTuple{names}(values), meta, args...)
end

"""
    HAPIVariable(data, params, i; mask = true)

Construct a `HAPIVariable` object for parameter `params[i + 1]` from `data`: a `CSV.File` (or any Tables.jl table)
in the HAPI CSV column layout, or a JSON-parsed response.
With `mask`, values equal to the parameter's `fill` read as `NaN`.
"""
function HAPIVariable(data, params::AbstractVector, i::Integer; mask = true)
    table = _table(data, params)
    return _variable(table, params, i, _times(table), mask)
end

function _variable(table, params, i, time, mask)
    param = params[i + 1]
    cols = _colrange(params, i)
    values = length(cols) == 1 ? _column(table, only(cols)) : stack(c -> _column(table, c), cols)
    return HAPIVariable(_decode(values, param, mask), time, SchemaDict(HAPISchema(), param))
end

function _colrange(params, i)
    offset = mapreduce(colsize, +, @view(params[1:i])) + 1
    return offset:(offset + colsize(params[i + 1]) - 1)
end

_times(table) = hapi_times(_column(table, 1))

_column(columns::Vector{AbstractVector}, j) = columns[j]
_column(table, j) = Tables.getcolumn(table, j)

# `isotime` parameters keep the parser's own handling, e.g. CSV.jl's date inference, which `hapi_times` relies on.
# `integer` columns parse as `Float64`: the HAPI verifier accepts `1.0` as an integer, which CSV.jl's `Int`
# parser rejects. `_decode` makes them `Int`, unless masking makes them `Float64` anyway.
function _eltype(param)
    t = param["type"]
    return t in ("double", "integer") ? Float64 : t == "string" ? String : Any
end

_coltypes(params) = mapreduce(p -> fill(_eltype(p), colsize(p)), vcat, params)

# Without `types`, CSV.jl infers from the values: servers write whole doubles as `0`, which would
# read as `Int` in some time ranges and `Float64` in others.
function read_csv(body, params = nothing)
    types = isnothing(params) ? nothing : Dict{Int, Type}(j => T for (j, T) in enumerate(_coltypes(params)) if T !== Any)
    return CSV.File(body; header = false, delim = ',', dateformat = DEFAULT_DATE_FORMAT, stringtype = String, types)
end

_table(data::CSV.File, params) = data
_table(json::AbstractDict, params) = _table(json["data"], params)
_table(table, params) = table

# JSON records nest array parameters (spec) or flatten them like CSV (TestData2.0); flattened, both
# have the CSV column layout. Some servers' JSON is the bare record array, without the header.
function _table(records::AbstractVector, params)
    types = _coltypes(params)
    (isempty(records) || !any(x -> x isa AbstractVector, first(records))) &&
        return AbstractVector[_coerce(T, [r[j] for r in records]) for (j, T) in enumerate(types)]
    cols = AbstractVector[]
    for (k, p) in enumerate(params)
        T = _eltype(p)
        if !haskey(p, "size")
            push!(cols, _coerce(T, [r[k] for r in records]))
        else
            vals = [r[k] for r in records]
            # A 1-D array indexes directly; higher dimensions flatten per record.
            any(x -> x isa AbstractVector, first(vals)) && (vals = map(_flatten, vals))
            append!(cols, (_coerce(T, [v[e] for v in vals]) for e in 1:colsize(p)))
        end
    end
    return cols
end

_flatten(x) = _flatten!(Any[], x)
_flatten!(out, x::AbstractVector) = (foreach(e -> _flatten!(out, e), x); out)
_flatten!(out, x) = push!(out, x)

# JSON cells coerce as CSV.jl does with `types`: a `null` or unparseable cell reads as `missing`.
_coerce(::Type{Any}, raw) = identity.(raw)
_coerce(::Type{T}, raw) where {T} = eltype(raw) === T ? raw : isempty(raw) ? similar(raw, T) : map(x -> _cell(T, x), raw)

_cell(T, ::Nothing) = missing
_cell(::Type{Float64}, x::Real) = Float64(x)
_cell(::Type{Int}, x::Integer) = Int(x)
_cell(::Type{Int}, x::AbstractFloat) = isinteger(x) && abs(x) < 0x1p63 ? Int(x) : missing
_cell(::Type{String}, x::AbstractString) = String(x)
_cell(::Type{String}, x::Real) = string(x)
_cell(T, x::AbstractString) = something(tryparse(T, x), missing)
_cell(T, x) = missing

# A missing or non-whole value, from a non-conforming server writing `null`, `NaN`, `1.5` or nothing in an `integer` column, is fill too.
# Servers writing Float32 data print a `double` fill at single precision (`-9.9999998E30` for `-1.0E31`),
# so a `double` fill that Float32 can't hold exactly matches at Float32 precision. Any other fill matches exactly:
# its Float32 print reads back exact, and a Float32 match would also catch real values near it (`1e-50` for `0`).
function _decode(A, param, mask)
    fill = get(param, "fill", nothing)
    type = param["type"]
    if !mask || isnothing(fill) || type ∉ ("double", "integer")
        return type == "integer" ? _coerce(Int, A) : A
    end
    f = parse(Float64, fill)
    f32 = Float32(f)
    isfill = type == "double" && isfinite(f32) && f32 != f ? (y -> Float32(y) == f32) :
        type == "integer" ? (y -> !isinteger(y) || y == f) : (y -> y == f)
    return map(A) do x
        y = ismissing(x) ? NaN : Float64(x)
        isfill(y) ? NaN : y
    end
end
