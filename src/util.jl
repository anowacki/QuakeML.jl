# Utility functions for defining types

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

function check_string_length(name, value, maxlen)
    value === missing && return nothing
    length(value) > maxlen &&
        throw(ArgumentError("field `$name` can be at most $maxlen characters long"))
    nothing
end
