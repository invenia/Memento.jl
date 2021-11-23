using .TimeZones

# We're just adding one timezone specific method for constructing and formatting a ZonedDateTime
function _format_datetime(dt::DateTime, fmt::AbstractString, tz::Dates.TimeZone)
    return Dates.format(astimezone(ZonedDateTime(dt, localzone()), tz), fmt)
end

# Since we already default to local zone in the base case explicitly convert a
# ZonedDateTime to be consistent.
function _format_datetime(zdt::ZonedDateTime, fmt::AbstractString, tz::Nothing)
    return Dates.format(astimezone(zdt, localzone()), fmt)
end

# Convert ZonedDateTimes to a specified output tz
function _format_datetime(zdt::ZonedDateTime, fmt::AbstractString, tz::Dates.TimeZone)
    return Dates.format(astimezone(zdt, tz), fmt)
end
