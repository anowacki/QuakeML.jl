# User manual

This section describes how to use QuakeML.jl to read and write
QuakeML files, and how to create objects which describe sets
of seismic events.

## Preamble

The following examples all assume that you have first used
the module like so:

```@repl example
using QuakeML
```

### Namespace issues
QuakeML.jl deliberately does not export the types it uses by default,
since their names follow those in the QuakeML specification, and they
are quite generic to seismic processing—for example, `Event` and `Phase`.
The recommended way to interact with QuakeML.jl in the REPL or in your
own packages is to always use the module name (or an alias of it).

For instance, to define an empty set of events, which are held in the
type [`EventParameters`](@ref QuakeML.EventParameters), you would write

```@repl example
events = QuakeML.EventParameters()
```

!!! note
    If you _really_ want to bring the QuakeML.jl types into scope without
    manually importing them, then there is an option.  You can do
    `using QuakeML.Types`.  Note that this API is not yet stable and use of
    the `Types` module is recommended only for interactive use or
    throwaway scripts.

### Important types
For a full list of QuakeML types, see [Types](@ref).  The following
are a few of the most important when defining one's own catalogues.
- [`EventParameters`](@ref QuakeML.EventParameters) is the root type,
  and contains one or more `Event`s.
- An [`Event`](@ref QuakeML.Event) defines a known single source of seismic
  energy, which may contain one or several
- [`Origin`](@ref QuakeML.Origin)s.  Each `Origin` is one interpretation of the
  data, potentially containing information about the source location,
  origin time, focal mechanism, magnitude, and so on.

The types in this package are directly named after those in the
QuakeML specification.  Similarly, the fields of each type are named
to match the names of the attributes and elements of each QuakeML type.
Note however that rather than use [camel case](https://en.wikipedia.org/wiki/Camel_case) `likeThis` for these field names, in this package we use
[snake case](https://en.wikipedia.org/wiki/Snake_case) `like_this`.
Therefore translating between the XML and QuakeML.jl representations
of things in the specification should be simple.

### Sample data
QuakeML.jl comes with a few sample data sets.  To access these,
you can define the path to them using the `pathof`
function from `Base`.  We will call this path `data_dir`:

```@repl example
data_dir = joinpath(dirname(dirname(pathof(QuakeML))), "test", "data")
```

## Reading

### On-disk data
To read a set of events from disk, one simply calls [`QuakeML.read`](@ref):

```@repl example
nepal_event = QuakeML.read(joinpath(data_dir, "nepal_mw7.2.qml"))
```

### Strings
To read from a `String` which contains QuakeML, you use
[`QuakeML.readstring`](@ref):
```@repl example
qml_string = """
           <?xml version="1.0"?>
           <quakeml xmlns="http://quakeml.org/xmlns/quakeml/1.2">
               <eventParameters publicID="smi:local/events/XXX">
                   <event publicID="smi:local/event/A">
                   </event>
               </eventParameters>
           </quakeml>
           """;
events = QuakeML.readstring(qml_string)
```

## Writing

### Writing to disk or subtype of `IO`
To write a set of events to a file on disk, call
[`write(io, events)`](@ref Base.write(::AbstractString, ::QuakeML.EventParameters)).
```@repl example
write("nepal.xml", nepal_event)
```

You can easily verify that the file written is identical to the one we read:
```@repl example
QuakeML.read("nepal.xml") == nepal_event
```

### Converting to a string
To convert a set of events into a `String` for subsequent processing,
first convert the `EventParameters` object into an XML document, then
call `string`:
```@repl example
string2 = string(quakeml(events))
```

!!! note
    One could also create a `Base.IOBuffer` and `write` to that directly.

### Converting to an in-memory XML document
Internally, QuakeML.jl uses [EzXML.jl](https://github.com/bicycle1885/EzXML.jl)
to parse XML strings and create XML objects from `EventParameters`.
If you are happy to use EzXML, you can create an XML document
(an `EzXML.Document`) by calling [`quakeml`](@ref) on an `EventParameters`
object.
```@repl example
xml = quakeml(nepal_event)
typeof(xml)
```


## Accessing fields
In QuakeML.jl, all fields of types are publicly-accessible and part
of the API.  It is intended that users will directly access and
manipulate these fields.  Where restrictions on fields exist
(for instance, where strings can be only a certain number of characters
long, or can only consist of certain characters), these are enforced
both upon construction of types and when changing fields (via
`setproperty!`).

For example, to get the coordinate of the Nepal event we read in
earlier, you access the fields directly:
```@repl example
nepal_event.event[1]
```

This returns the first `Event` in the `event` field.  `event` is
a `Vector{Event}`, and may be empty.

In QuakeML, any `Event` may have several `Origin`s.  Each `Origin`
describes a unique onset time and location of the event.  Usually, one
of these origins is the 'preferred' origin.  Typically, one uses
[`preferred_origin`](@ref) to return this and then uses the origin
parameters within the particular `Origin`.

```@repl example
o = preferred_origin(nepal_event.event[1])
lon, lat = o.longitude.value, o.latitude.value
```

!!! note
    Note that the longitude and latitude of an `Origin` are
    [`QuakeML.RealQuantity`](@ref)s.  As well as the `value` field which
    contains the nominal value of the quantity, they can also contain
    uncertainties.  Hence in this case, we needed to access the actual
    value of longitude like `o.longitude.value`, and similarly for latitude.

Almost all types (apart from [Enumerated types](@ref)) are `mutable struct`s,
which means that their fields can be changed after construction.
Almost all types have at least one field which is optional.  In QuakeML.jl,
these can either take a concrete value, or `missing`.
Hence setting any optional field to `missing` (like `origin.depth = missing`)
will remove that value.

Where multiple values of a field are allowed (such as the `origin` field
of an `Event`), these are represented by `Vector`s, and can be empty.
