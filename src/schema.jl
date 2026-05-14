using SpaceDataModel: MetadataSchema, SchemaDict
import SpaceDataModel: rules

"""
    HAPISchema <: MetadataSchema

Schema for [HAPI](https://hapi-server.github.io/) parameter metadata.

# References
- [HAPI Parameter Object](https://github.com/hapi-server/data-specification/blob/master/hapi-dev/HAPI-data-access-spec-dev.md#367-parameter-object)
"""
struct HAPISchema <: MetadataSchema end

const _HAPI_SCHEMA = (
    name = "name",
    long_name = "label",
    unit = "units",
    desc = "description",
    fill = "fill",
)

rules(::HAPISchema) = _HAPI_SCHEMA
