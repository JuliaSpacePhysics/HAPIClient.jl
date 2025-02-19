


"""
    compute_types(meta::Dict)

Compute data types for HAPI parameters based on metadata.

Returns:
- dtypes: Array of tuples (name, type, size) for each parameter
- cols: Matrix of start/end column numbers for each parameter
- sizes: Array of sizes for each parameter
- names: Array of parameter names
- types: Array of parameter types
- missing_length: Boolean indicating if any string/isotime parameter is missing length
"""
function compute_types(meta::Dict)
    params = meta["parameters"]
    n_params = length(params)

    # Initialize arrays
    names = String[]
    types = String[]
    sizes = []
    dtypes = []
    cols = zeros(Int, n_params, 2)

    # Track running sum of columns
    ss = 0
    missing_length = false

    for (i, param) in enumerate(params)
        ptype = param["type"]
        pname = param["name"]

        push!(types, ptype)
        push!(names, pname)

        # Handle parameter size
        if haskey(param, "size")
            psize = param["size"]
            # Convert single-element array to scalar
            if isa(psize, Vector) && length(psize) == 1
                psize = first(psize)
            end
            push!(sizes, psize)
        else
            push!(sizes, 1)
        end

        # Calculate column ranges
        size_prod = isa(sizes[i], Number) ? sizes[i] : prod(sizes[i])
        cols[i, 1] = ss  # First column
        cols[i, 2] = ss + size_prod - 1  # Last column
        ss = cols[i, 2] + 1

        # Determine data type
        if ptype == "double"
            dtype = (pname, Float64, sizes[i])
        elseif ptype == "integer"
            dtype = (pname, Int32, sizes[i])
        elseif ptype ∈ ["string", "isotime"]
            if haskey(param, "length")
                len = param["length"]
                if ptype == "string"
                    dtype = (pname, String, sizes[i])
                else # isotime
                    dtype = (pname, DateTime, sizes[i])
                end
            else
                missing_length = true
                dtype = (pname, Any, sizes[i])
            end
        else
            throw(ArgumentError("Unknown parameter type: $ptype"))
        end

        # Collapse single-element size
        if dtype[3] == 1
            dtype = dtype[1:2]
        end

        push!(dtypes, dtype)
    end

    return dtypes, cols, sizes, names, types, missing_length
end
