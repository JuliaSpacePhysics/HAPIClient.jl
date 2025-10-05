# https://github.com/hapi-server/data-specification/blob/master/hapi-dev/HAPI-data-access-spec-dev.md#367-parameter-object


"""
    Parameter

Represents a HAPI parameter with validation according to the specification.

Required fields:
- `name`: String identifier for the parameter
- `type`: One of "string", "double", "integer", or "isotime"
- `units`: String, array of strings, or nothing for dimensionless quantities
- `fill`: String or nothing indicating no fill value

Type-specific requirements:
- For `string` and `isotime` types: must specify `length`
- For array parameters: must specify `size`

Optional fields:
- `description`: Brief description of the parameter
- `label`: Display label or array of labels
- `size`: Array dimensions for array parameters
- `bins`: Array parameter bin information
- `stringType`: For string parameters that represent URIs
- `coordinateSystemName`: Name of coordinate system for vector quantities
- `vectorComponents`: Component names for vector quantities
"""
struct Parameter
    name::String
    type::String
    units::Union{String,Vector{String},Nothing}
    fill::Union{String,Nothing}
    length::Union{Int,Nothing}
    size::Union{Vector{Int},Nothing}
    description::Union{String,Nothing}
    label::Union{String,Vector{String},Nothing}
    stringType::Union{String,Dict{String,Any},Nothing}
    coordinateSystemName::Union{String,Nothing}
    vectorComponents::Union{String,Vector{String},Nothing}
    bins::Union{Vector{Dict{String,Any}},Nothing}

    function Parameter(dict::AbstractDict)
        # Validate required fields
        name = get(dict, "name") do
            throw(ArgumentError("Parameter missing required field 'name'"))
        end

        type = get(dict, "type") do
            throw(ArgumentError("Parameter '$name' missing required field 'type'"))
        end

        if !(type in ["string", "double", "integer", "isotime"])
            throw(ArgumentError("Parameter '$name' has invalid type '$type'"))
        end

        units = get(dict, "units") do
            throw(ArgumentError("Parameter '$name' missing required field 'units'"))
        end

        # Validate units
        if units isa String
            units == "" && throw(ArgumentError("Parameter '$name' units cannot be empty string"))
        elseif units isa Vector
            all(u -> u isa String && u != "", units) || throw(ArgumentError("Parameter '$name' units array must contain non-empty strings"))
        elseif units !== nothing
            throw(ArgumentError("Parameter '$name' units must be string, array of strings, or null"))
        end

        fill = get(dict, "fill") do
            throw(ArgumentError("Parameter '$name' missing required field 'fill'"))
        end

        # Type-specific validation
        length = get(dict, "length", nothing)
        if type in ["string", "isotime"]
            length === nothing && throw(ArgumentError("Parameter '$name' of type '$type' must specify 'length'"))
        end

        size = get(dict, "size", nothing)
        if size !== nothing
            if units isa Vector
                size_prod = prod(size)
                length(units) != size_prod && throw(ArgumentError("Parameter '$name' units array length ($(length(units))) must match size product ($size_prod)"))
            end
        end

        # Optional fields
        description = get(dict, "description", nothing)
        label = get(dict, "label", nothing)
        stringType = get(dict, "stringType", nothing)
        coordinateSystemName = get(dict, "coordinateSystemName", nothing)
        vectorComponents = get(dict, "vectorComponents", nothing)
        bins = get(dict, "bins", nothing)

        new(
            name, type, units, fill, length, size,
            description, label, stringType,
            coordinateSystemName, vectorComponents, bins
        )
    end
end

# Constructor from JSON-like dictionary
Base.convert(::Type{Parameter}, dict::AbstractDict{String,Any}) = Parameter(dict)

"""
    is_time_parameter(param::Parameter)

Check if a parameter is a valid time parameter (first parameter in a dataset).
"""
function is_time_parameter(param::Parameter)
    param.type == "isotime" &&
        param.fill === nothing &&
        param.units == "UTC"
end

"""
Parse parameters into a Vector of Parameter objects and validate first parameter is time.
"""
function parameters(params)
    param_dicts = params
    parameters = Parameter[]
    for param_dict in param_dicts
        push!(parameters, Parameter(param_dict))
    end

    # Validate first parameter is time
    is_time_parameter(first(parameters)) || throw(ArgumentError("First parameter must be a valid time parameter"))

    return parameters
end