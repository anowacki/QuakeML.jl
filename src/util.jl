# Utility functions

"""
    @enumerated_struct(name, T, values)

Create a `struct` called `name` with a single field, `:value` which
must match one of the items in `values`.

Also create a keyword constructor with one required keyword argument,
`value`.

# Example

The following code
```
@enumerated_struct(Example, Float64, (1.0, 2.0))
```

is equivalent to
```
struct Example
    value::Float64
    function Example(value)
        if value ∉ (1.0, 2.0)
            throw(ArgumentError("value must be one of `(1.0, 2.0)`"))
        end
        new(value)
    end
    Example(; value) = Example(value)
end

```
"""
macro enumerated_struct(name, T, values)
    values.head === :tuple || throw(ArgumentError("final argument must be a tuple of values"))
    values_string = string(values)
    # A nice set of Markdown-formatted values.
    values_docstring = join((string("`\"", val, "\"`") for val in values.args), ", ", " or ")
    # For the example in the docstring
    first_value = string(first(values.args))
    @assert length(values.args) > 1
    second_value = string(values.args[2])
    T = esc(T) 
    name = esc(name)
    quote
        """
            $($name)(value)
            $($name)(; value)

        Enumerated struct containing a single string which must be one
        of the following: $($values_docstring).

        Note that when a field of another type is a `$($name)`, it
        is not necessary to assign a field of type `$($name)` to the
        field.  Instead, one can simply use a `String`, from which a
        `$($name)` will be automatically constructed.

        For this reason, $($name) is not exported even when bringing
        QuakeML's types into scope by doing `using QuakeML.Types`.

        # Example
        ```
        julia> using QuakeML

        julia> mutable struct ExampleStruct
                   field::$($name)
               end

        julia> es = ExampleStruct("$($first_value)")
        ExampleStruct($($name)("$($first_value)"))

        julia> es.field = "$($second_value)"
        "$($second_value)"
        ```
        """
        struct $name
            value::$T
            function $name(value)
                if value ∉ $values
                    $(esc(throw))($(esc(ArgumentError))("value must be one of $($values_string)"))
                end
                new(value)
            end
            $name(; value) = $name(value)
        end
    end
end

"""
    check_string_length(name, value, maxlen) -> nothing

Throw an `ArgumentError` if `value` is longer than `maxlen` characters.
`name` is the name of the field to report in the error message.
"""
function check_string_length(name, value, maxlen)
    value === missing && return nothing
    length(value) > maxlen &&
        throw(ArgumentError("field `$name` can be at most $maxlen characters long"))
    nothing
end

"""
    transform_name(s::AbstractString) -> s′::Symbol

Transform the name of an attribute or element of a QuakeML XML
document into a `Symbol` suitable for assignment into a `struct`.

# Example
```julia
julia> QuakeML.transform_name("triggeringOriginID")
:triggering_origin_id
```
"""
function transform_name(s)
    s = string(s)
    # CamelCase to Camel_Case
    s = replace(s, r"([a-z])([A-Z])" => s"\1_\2")
    # lowercase
    s = lowercase(s)
    # Special cases
    s = replace(s, r"^begin$" => "begin_")
    s = replace(s, r"^end$" => "end_")
    Symbol(s)
end

"""
    retransform_name(s::Symbol) -> s′::String

Transform the field name of a struct into an element or attribute name
as a string, suitable for inclusion into a QuakeML XML document.
"""
function retransform_name(s)
    s = string(s)
    # Special cases
    s = replace(s, r"^begin_$" => "begin")
    s = replace(s, r"^end_$" => "end")
    s = replace(s, "_id" => "ID")
    # 'x_y' to 'x_Y'
    s = replace(s, r"(_.)" => uppercase)
    # 'x_Y' to 'xY'
    s = replace(s, "_" => "")
    s
end

"""
    xml_unescape(s) -> s′

Replace escaped occurrences of the five XML character entity
references `&`, `<`, `>`, `"` and `'` with their unescaped equivalents.

Reference:
    https://en.wikipedia.org/wiki/Character_encodings_in_HTML#XML_character_references
"""
xml_unescape(s) =
    # Workaround for JuliaLang/julia#28967
                  reduce(replace,
                         ("&amp;"  => "&",
                          "&lt;"   => "<",
                          "&gt;"   => ">",
                          "&quot;" => "\"",
                          "&apos;" => "'"),
                         init=s)

"""
    xml_escape(s) -> s′

Replace unescaped occurrences of the five XML characters
`&`, `<`, `>`, `"` and `'` with their escaped equivalents.

Reference:
    https://en.wikipedia.org/wiki/Character_encodings_in_HTML#XML_character_references
"""
xml_escape(s) =
    # Workaround for JuliaLang/julia#28967
                reduce(replace,
                       ("&"  => "&amp;",
                        "<"  => "&lt;",
                        ">"  => "&gt;",
                        "\"" => "&quot;",
                        "'"  => "&apos;"),
                       init=s)

"""
    random_reference() -> ::ResourceReference

Create a new, random [`ResourceReference`](@ref QuakeML.ResourceReference).
"""
random_reference(prefix="smi") =
    ResourceReference(prefix * string(":local/", UUIDs.uuid4()))
