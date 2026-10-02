# https://github.com/hapi-server/data-specification/blob/master/hapi-3.2.0/HAPI-data-access-spec-3.2.0.md#376-representation-of-time

const HAPITime = Timestamp{Nanosecond}

const DEFAULT_DATE_FORMAT = dateformat"yyyy-mm-ddTHH:MM:SS.sssZ"
const NS_DATE_FORMAT = dateformat"yyyy-mm-ddTHH:MM:SS.nZ"

@noinline _invalid_time(s) = throw(ArgumentError("Invalid HAPI time string: $(repr(s))"))

@inline function _read_digits(s, cu, i, n)
    v = 0
    for k in i:(i + n - 1)
        d = cu[k] - 0x30
        d > 0x09 && _invalid_time(s)
        v = 10v + d
    end
    return v
end

@inline _expect(s, cu, i, c) = cu[i] == UInt8(c) || _invalid_time(s)

"""
    parse_hapi_time(s) -> Timestamp{Nanosecond}

Parse a (possibly truncated) HAPI time string, in `yyyy-mm-dd` or day-of-year `yyyy-ddd` form,
with up to nanosecond precision.
"""
function parse_hapi_time(s::AbstractString)
    cu = codeunits(s)
    n = length(cu)
    n > 0 && cu[n] == UInt8('Z') && (n -= 1)
    n >= 4 || _invalid_time(s)
    y = _read_digits(s, cu, 1, 4)
    tpos = something(findnext(==(UInt8('T')), cu, 5), n + 1)
    dlen = tpos - 5
    m, d = if dlen == 0
        1, 1
    elseif dlen == 3
        _expect(s, cu, 5, '-')
        _read_digits(s, cu, 6, 2), 1
    elseif dlen == 4
        _expect(s, cu, 5, '-')
        doy = _read_digits(s, cu, 6, 3)
        1 <= doy <= daysinyear(y) || _invalid_time(s)
        monthday(Date(y) + Day(doy - 1))
    elseif dlen == 6
        _expect(s, cu, 5, '-')
        _expect(s, cu, 8, '-')
        _read_digits(s, cu, 6, 2), _read_digits(s, cu, 9, 2)
    else
        _invalid_time(s)
    end

    i = tpos + 1
    tlen = n - tpos
    H = M = S = ns = 0
    tlen in (-1, 2, 5) || tlen >= 8 || _invalid_time(s)
    tlen >= 2 && (H = _read_digits(s, cu, i, 2))
    tlen >= 5 && (_expect(s, cu, i + 2, ':'); M = _read_digits(s, cu, i + 3, 2))
    tlen >= 8 && (_expect(s, cu, i + 5, ':'); S = _read_digits(s, cu, i + 6, 2))
    if tlen > 8
        _expect(s, cu, i + 8, '.')
        nfrac = tlen - 9
        nfrac <= 9 || _invalid_time(s)
        ns = _read_digits(s, cu, i + 9, nfrac) * 10^(9 - nfrac)
    end
    return HAPITime(y, m, d, H, M, S, 0, 0, ns)
end

parse_hapi_time(t::Dates.TimeType) = HAPITime(t)

# CSV ≥ 1 parses `DEFAULT_DATE_FORMAT` natively (any 1–9 digit fraction) and leaves the column as strings
# when any row is in another HAPI form, e.g. SSCWeb's `2001-001T00:00:00Z`.
hapi_times(t::AbstractVector{HAPITime}) = t
hapi_times(t::AbstractVector) = parse_hapi_time.(t)

"""
    HAPIDateTime(t)

Format `t` (a string or any `Dates.TimeType`) as a HAPI request time string,
at millisecond precision unless `t` carries sub-millisecond digits.
"""
function HAPIDateTime(t)
    ts = parse_hapi_time(t)
    fmt = iszero(Dates.value(ts) % 1_000_000) ? DEFAULT_DATE_FORMAT : NS_DATE_FORMAT
    return Dates.format(ts, fmt)
end
