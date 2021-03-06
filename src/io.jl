# Reading and parsing functions

#
# Reading
#

"""
    read(filename) -> ::EventParameters

Read a QuakeML file with name `filename` from disk and return an
`EventParameters` object.

# Example
```
julia> file = joinpath(dirname(pathof(QuakeML)), "..", "test", "data", "nepal_mw7.2.qml");

julia> events = QuakeML.read(file)
EventParameters
  comment: Array{QuakeML.Comment}((0,))
  event: Array{QuakeML.Event}((1,))
  description: Missing missing
  creation_info: QuakeML.CreationInfo
  public_id: QuakeML.ResourceIdentifier
```

---
    read(io) -> ::EventParameters

Read a QuakeML document from the stream `io`.

# Example
```
julia> io = IOBuffer(\"\"\"
       <quakeml xmlns="http://quakeml.org/xmlns/quakeml/1.2">
       <eventParameters></eventParameters>
       </quakeml>
       \"\"\");

julia> QuakeML.read(io)
EventParameters
  comment: Array{QuakeML.Comment}((0,))
  event: Array{QuakeML.Event}((0,))
  description: Missing missing
  creation_info: Missing missing
  public_id: QuakeML.ResourceIdentifier
```
"""
read(filename::AbstractString) = readstring(String(Base.read(filename)), filename=filename)
read(io) = readstring(String(Base.read(io)))

"""
    readstring(xml_string) -> ::EventParameters

Read the QuakeML contained in `xml_string` and return a `EventParameters` object.
"""
function readstring(xml_string; filename=nothing)
    # Extremely basic check that this is XML at all
    occursin(r"^\s*<", xml_string) ||
        throw(ArgumentError("string does not appear to be XML:\n'$(first(xml_string, 100))'"))
    xml = EzXML.parsexml(xml_string)
    file_string = filename === nothing ? "" : " in file $filename"
    xml_is_quakeml(xml) ||
        throw(ArgumentError("QuakeML$file_string does not appear to be a StationXML file"))
    schema_version_is_okay(xml) ||
        throw(ArgumentError("QuakeML$file_string does not have the correct schema version"))
    elements = EzXML.elements(xml.root)
    length(elements) == 1 || error("QuakeML$file_string does not have one single root element")
    parse_node(first(elements))
end

"""
    xml_is_quakeml(xml)

Return `true` if `xml` appears to be a QuakeML file.
"""
xml_is_quakeml(xml) = EzXML.hasroot(xml) && xml.root.name == "quakeml"

"""
    schema_version_is_okay(xml::EzXML.Document) -> ::Bool

Return `true` if this XML document is of a version which we
know we can correctly parse.

Note: QuakeML does not include the schema version as a field
of its own, so we simply try and parse the namespace definition.
QuakeML files in the wild appear to do this a number of ways.
"""
function schema_version_is_okay(xml::EzXML.Document)
    namespaces = Dict(EzXML.namespaces(xml.root))
    version_string = if haskey(namespaces, "q")
        last(split(namespaces["q"], '/'))
    elseif haskey(namespaces, "")
        last(split(namespaces[""], '/'))
    else
        @warn("cannot determine QuakeML schema version from file")
        return true
    end
    version = VersionNumber(version_string)
    if version <= v"1.2"
        return true
    elseif version > v"1.2"
        @warn("document is StationXML version $version; only v1.2 data will be read")
        return true
    end
end

attributes_and_elements(node::EzXML.Node) = vcat(EzXML.attributes(node), EzXML.elements(node))

"""
    parse_node(root::EzXML.Node) -> ::EventParameters

Parse the `root` node of a QuakeML document.  This can be accessed as
`EzXML.readxml(file).root`.
"""
parse_node(root::EzXML.Node) = parse_node(EventParameters, root)

"Types which can be directly parsed from a Node"
const ParsableTypes = Union{Type{String},Type{Float64},Type{Int},Type{Bool}}

parse_node(T::ParsableTypes, node::EzXML.Node) = local_parse(T, node.content)

# Handle dates with greater than millisecond precision by truncating to nearest millisecond,
# cope with UTC time zone information (ends with 'Z'), and convert non-UTC time zones to UTC
function parse_node(T::Type{DateTime}, node::EzXML.Node)
    # Remove sub-millisecond intervals
    m = match(r"(.*T..:..:..[\.]?)([0-9]{0,3})[0-9]*([-+Z].*)*", node.content)
    dt = DateTime(m.captures[1] * m.captures[2]) # Local date to ms
    (m.captures[3] === nothing || m.captures[3] in ("", "Z", "+00:00", "-00:00")) && return dt # UTC
    pm = m.captures[3][1] # Whether ahead or behind UTC
    offset = Time(m.captures[3][2:end]) - Time("00:00")
    dt = pm == '+' ? dt + offset : dt - offset
    dt
end

"Types of types with a single field: `value::String`"
const ValueFieldType = Union{
    # XML URI; aliased to ResourceReference
    Type{ResourceIdentifier},
    # Unconstrained phase name
    Type{Phase},
    # String types with value restrictions
    Type{OriginUncertaintyDescription},
    Type{AmplitudeCategory},
    Type{OriginDepthType},
    Type{OriginType},
    Type{MTInversionType},
    Type{EvaluationMode},
    Type{EvaluationStatus},
    Type{PickOnset},
    Type{EventType},
    Type{DataUsedWaveType},
    Type{AmplitudeUnit},
    Type{EventDescriptionType},
    Type{MomentTensorCategory},
    Type{EventTypeCertainty},
    Type{SourceTimeFunctionType},
    Type{PickPolarity}
    }

# FIXME: Maintain one list which automatically fills this and ValueFieldType
"Types with a single field: `value::String"
const ValueTypes = Union{
    ResourceIdentifier,
    Phase,
    OriginUncertaintyDescription,
    AmplitudeCategory,
    OriginDepthType,
    OriginType,
    MTInversionType,
    EvaluationMode,
    EvaluationStatus,
    PickOnset,
    EventType,
    DataUsedWaveType,
    AmplitudeUnit,
    EventDescriptionType,
    MomentTensorCategory,
    EventTypeCertainty,
    SourceTimeFunctionType,
    PickPolarity
}

parse_node(T::ValueFieldType, node::EzXML.Node) = T(node.content)

"""
    parse_node(T, node::EzXML.Node) -> ::T

Create a type `T` from the QuakeML module from an XML `node`.
"""
function parse_node(T, node::EzXML.Node)
    @debug("\n===\nParsing node type $T\n===")
    # Value field types have extra attributes
    is_value_field = Type{T} <: ValueFieldType
    @debug("$T is a value field: $is_value_field")
    node_name = transform_name(node.name)
    @debug("Node name is $(node_name)")
    is_attribute = is_attribute_field(T, node_name)
    @debug if is_attribute
        "Node corresponds to an attribute field"
    end
    # Arguments to the keyword constructor of the type T
    args = Dict{Symbol,Any}()
    all_elements = is_attribute ? EzXML.elements(node) : attributes_and_elements(node)
    all_names = [transform_name(e.name) for e in all_elements]
    @debug("Element names: $all_names")
    @debug("Field names: $(fieldnames(T))")
    # Fill in the field
    for field in fieldnames(T)
        field_type = fieldtype(T, field)
        @debug field, T, field_type
        # Skip fields not in our types
        if !(field in all_names)
            # Types with a `value` field with the same name as the upper field would
            # fail the test without `field == :value`
            if !(is_value_field && field == :value)
                @debug("   Skipping non-value field")
                continue
            end
        end
        if !(is_value_field && field == :value)
            elm = all_elements[findfirst(isequal(field), all_names)]
        end
        # Unions are Missing-supporting fields; should only ever have two types
        if field_type isa Union
            @debug("Field $field is a Union type")
            union_types = Base.uniontypes(field_type)
            @assert length(union_types) == 2 && Missing in union_types
            field_type = union_types[1] == Missing ? union_types[2] : union_types[1]
            @debug("Field type is $field_type")
            args[field] = parse_node(field_type, elm)
            @debug("\n   Saving $field as $(args[field])")
        # Multiple elements allowed
        elseif field_type <: AbstractVector
            el_type = eltype(field_type)
            @debug("Element type is $el_type")
            ifields = findall(isequal(field), all_names)
            values = el_type[]
            for i in ifields
                push!(values, parse_node(el_type, all_elements[i]))
            end
            args[field] = values
            @debug("\n   Saving $field as $values")
        # The value field of a ValueFieldType
        elseif field == :value && is_value_field
            @assert value !== nothing
            @debug("Value of field is $(repr(value))")
            args[field] = local_parse(field_type, value)
            @debug("\n   Saving $field as $(repr(args[field]))")
        # Just one (maybe optional) field
        else
            args[field] = parse_node(field_type, elm)
            @debug("\n   Saving $field as $(repr(args[field]))")
        end
    end
    T(; args...)
end

# Versions of parse which accept String as the type.
# Don't define this for Base as this is type piracy.
local_tryparse(T::Type{<:AbstractString}, s::AbstractString) = s
local_tryparse(T::DataType, s::AbstractString) = tryparse(T, s)
local_parse(T::Type{<:AbstractString}, s::AbstractString) = s
local_parse(T::DataType, s::AbstractString) = parse(T, s)

#
# Writing
#
"""
    write(io, qml::EventParameters; kwargs...)

Write a set of `EventParameters` to `io`.  `kwargs` are passed to
[`quakeml`](@ref) to control the creation of the XML representing
the catalogue.

# Examples
(Note that `"example_quakeml_file.xml"` may not exist.)

Write a file with the default settings
```
julia> qml = QuakeML.read("example_quakeml_file.xml");

julia> write("new_file.xml", qml)
```

Write a file with custom version
```
julia> write("new_file2.xml", qml, version="1.1")
```
"""
function Base.write(io::IO, qml::EventParameters; kwargs...)
    EzXML.prettyprint(io, quakeml(qml; kwargs...))
end


"""
    quakeml(qml::EventParameters; version="1.2") -> xml::EzXML.XMLDocument

Create an XML document from `qml`, a set of events of type `EventParameters`.
`xml` is an `EzXML.XMLDocument` suitable for output.

The user may also set the nominal `version` of QuakeML created.

The QuakeML document `xml` may be written with `write(io, xml)`
or converted to a string with `string(xml)`.
"""
function quakeml(qml::EventParameters; version::AbstractString="1.2")
    doc = EzXML.XMLDocument("1.0")
    root = EzXML.ElementNode("quakeml")
    # FIXME: Is this the only way to set a namespace in EzXML?
    namespace = EzXML.AttributeNode("xmlns", "http://quakeml.org/xmlns/quakeml/" * version)
    EzXML.link!(root, namespace)
    EzXML.setroot!(doc, root)
    event_parameters = EzXML.ElementNode("eventParameters")
    EzXML.link!(root, event_parameters)
    add_attributes!(event_parameters, qml)
    add_elements!(event_parameters, :event_parameters, qml)
    doc
end

"""
    add_attributes!(node, value) -> node

Add the attribute fields from the structure `value` to a `node`.
For QuakeML documents, all attributes should be `ResourceReference`s.
"""
function add_attributes!(node, value::T) where T
    for field in attribute_fields(T)
        content = getfield(value, field)
        content === missing && continue
        @assert content isa ResourceIdentifier
        name = retransform_name(field)
        attr = EzXML.AttributeNode(name, content.value)
        EzXML.link!(node, attr)
    end
    node
end

"""
    add_elements!(node, parent_field, value) -> node

Add the elements to `node` contained within `value`.  `parent_field`
is the name of the field which contains `value`.
"""
function add_elements!(node, parent_field, value::T) where T
    for field in fieldnames(T)
        @debug("adding $parent_field: $field")
        is_attribute_field(T, field) && continue
        content = getfield(value, field)
        if content === missing
            continue
        end
        add_element!(node, field, content)
    end
    node
end

function add_elements!(node, parent_field, values::AbstractArray)
    for value in values
        add_elements!(node, parent_field, value)
    end
    node
end

"Union of types which can be natively written"
const WritableTypes = Union{Float64, Int, String, DateTime, Bool}

"""
    add_element!(node, field, value) -> node

Add an element called `field` to `node` with content `value`.
"""
function add_element!(node, field, value::WritableTypes)
    @debug("  adding writable type name $field with value $value")
    name = retransform_name(field)
    elem = EzXML.ElementNode(name)
    content = EzXML.TextNode(string(value))
    EzXML.link!(elem, content)
    EzXML.link!(node, elem)
    node
end

function add_element!(node, field, value::ValueTypes)
    @debug("  adding value type name $field with value $value")
    name = retransform_name(field)
    elem = EzXML.ElementNode(name)
    content = EzXML.TextNode(value.value)
    EzXML.link!(elem, content)
    EzXML.link!(node, elem)
    node
end

function add_element!(node, field, values::AbstractArray)
    @debug("  adding array type name $field with $(length(values)) values")
    for value in values
        add_element!(node, field, value)
    end
    node
end

function add_element!(node, field, value)
    @debug("  adding compound type name $field of type $(typeof(value))")
    name = retransform_name(field)
    elem = EzXML.ElementNode(name)
    EzXML.link!(node, elem)
    add_attributes!(elem, value)
    add_elements!(elem, field, value)
    node
end
