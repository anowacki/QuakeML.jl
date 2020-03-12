# Utility functions

"Flag for verbose debugging output in some functions."
const VERBOSE = Ref(false)

"""
    set_verbose!(true_or_false)

Set whether (`true`) or not (`false`) to print debugging information for the
`StationXML` module.
"""
set_verbose!(true_or_false) = VERBOSE[] = true_or_false

"""
    @enumerated_struct(name, T, values)

Create a `struct` called `name` with a single field, `:value` which
must match one of the items in `values`.

Also create a keyword constructor with one required keyword argument,
`value`.

## Example:

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
    values_string = string(values)
    T = esc(T)
    name = esc(name)
    :(struct $name
        value::$T
        function $name(value)
            if value ∉ $values
                $(esc(throw))($(esc(ArgumentError))("value must be one of $($values_string)"))
            end
            new(value)
        end
        $name(; value) = $name(value)
    end
    )
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

For example:

```julia
julia> QuakeML.transform_name("triggeringOriginID")
:triggering_origin_id
```
"""
function transform_name(s)
    s = string(s)
    # CamelCase to Camel_Case
    s = replace(s, r"([a-z])([A-Z])"=>s"\1_\2")
    # lowercase
    s = lowercase(s)
    # Special cases
    s = replace(s, r"^begin$"=>"begin_")
    s = replace(s, r"^end$"=>"end_")
    Symbol(s)
end

"""
    xml_unescape(s) -> s′

Replace escaped occurrences of the five XML character entity
references &, <, >, " and ' with their unescaped equivalents.

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
&, <, >, " and ' with their escaped equivalents.

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
