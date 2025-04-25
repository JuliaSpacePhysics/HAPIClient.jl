# https://github.com/hapi-server/data-specification/blob/master/hapi-3.2.0/HAPI-data-access-spec-3.2.0.md#376-representation-of-time

# Time values are always strings, and the HAPI Time format is a subset of the ISO 8601 date and time format.
const DEFAULT_DATE_FORMAT = dateformat"yyyy-mm-ddTHH:MM:SS.sssZ"

function HAPIDateTime(t::AbstractString)
    # Check if the string ends with Z and remove it for parsing
    dt = parse_datetime(rstrip(t, 'Z'))
    Dates.format(dt, DEFAULT_DATE_FORMAT)
end

HAPIDateTime(t::DateTime) = Dates.format(t, DEFAULT_DATE_FORMAT)