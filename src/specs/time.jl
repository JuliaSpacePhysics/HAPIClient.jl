# https://github.com/hapi-server/data-specification/blob/master/hapi-3.2.0/HAPI-data-access-spec-3.2.0.md#376-representation-of-time

# Time values are always strings, and the HAPI Time format is a subset of the ISO 8601 date and time format.
const DEFAULT_DATE_FORMAT = dateformat"yyyy-mm-ddTHH:MM:SS.sssZ"

function HAPIDateTime(t::AbstractString)
    # Check if the string ends with Z and remove it for parsing
    t = rstrip(t, ['Z'])
    # Split into date and time parts if T is present
    parts = split(t, "T", limit=2)
    date_part = parts[1]
    time_part = length(parts) > 1 ? parts[2] : ""

    # Parse date part
    date = @something(
        tryparse(Date, date_part),
        tryparse_doy_date(date_part),
    )

    # Create DateTime with or without time
    if isempty(time_part)
        dt = DateTime(date)
    else
        dt = date + Time(time_part)
    end

    return Dates.format(dt, DEFAULT_DATE_FORMAT)
end

"""
Parse a date in Day of Year format (YYYY-DDD)
"""
function tryparse_doy_date(date_str::AbstractString)
    doy_regex = r"^(\d{4})-(\d{3})$"

    if occursin(doy_regex, date_str)
        m = match(doy_regex, date_str)
        year = parse(Int, m[1])
        doy = parse(Int, m[2])
        return Date(year) + Day(doy - 1)
    end

    return nothing
end

HAPIDateTime(t::DateTime) = Dates.format(t, DEFAULT_DATE_FORMAT)