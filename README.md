# QuakeML

## Build status

[![Build Status](https://travis-ci.org/anowacki/QuakeML.jl.svg?branch=master)](https://travis-ci.org/anowacki/QuakeML.jl)
[![Build status](https://ci.appveyor.com/api/projects/status/v0c5uj3s6nf9v026/branch/master?svg=true)](https://ci.appveyor.com/project/AndyNowacki/quakeml-jl/branch/master)
[![Coverage Status](https://coveralls.io/repos/github/anowacki/QuakeML.jl/badge.svg?branch=master)](https://coveralls.io/github/anowacki/QuakeML.jl?branch=master)

## What is QuakeML.jl?

QuakeML.jl is a Julia package to read and write information about
earthquakes and seismic events in the
[QuakeML format](https://quake.ethz.ch/quakeml).

## User-facing functions
- `QuakeML.read`: Read a QuakeML file.  (This function is not exported.
  and requires the module prefix `QuakeML`.)
- `QuakeML.readstring`: Read a QuakeML document from a string.  (This 
  function is not exported.)
- `write`: Write a set of `EventParameters` as a QuakeML XML document.
- `preferred_focal_mechanism`: Get the preferred focal mechanism for an event
- `preferred_magnitude`: Get the preferred magnitude for an event
- `preferred_origin`: Get the preferred origin for an event
- `has_focal_mechanism`: Check to see if an event contains any
  focal mechanisms
- `has_magnitude`: Check to see if an event contains any magnitude
- `has_origin`: Check to see if an event contains any origins
- `quakeml`: Create an XML document from a set of events which can
  be written with `print(io, quakeml(qml))`

## Examples

### Reading
To read a QuakeML document on your computer (e.g., one of the ones
supplied with QuakeML.jl), do:
```julia
julia> using QuakeML

julia> qml_file = joinpath(dirname(dirname(pathof(QuakeML))), "test", "data", "nepal_mw7.2.qml");

julia> qml = QuakeML.read(qml_file)
```

To read a set of events from a string:
```julia
julia> QuakeML.readstring(String(read(qml_file)))
```

### Writing
To write a set of events to disk:
```julia
julia> write("file/on/disk.xml", qml)
```

For more control of output, convert your set of `EventParameters`
into an XML document, and write that:
```julia
julia> xml = quakeml(qml);

julia> println("/tmp/quakeml_file.qml", quakeml(qml))
```

Note that here `xml` is an
[`EzXML.XMLDocument`](https://bicycle1885.github.io/EzXML.jl/stable/manual/).

Or convert your XML document into a `String`:
```julia
julia> str = string(xml)
```

## Export of types

By default, QuakeML does not export the types it uses.  The user should
usually create sets of `EventParameters`, for example, by calling the
type's qualified constructor:
```julia
julia> QuakeML.EventParameters()
QuakeML.EventParameters
  comment: Array{QuakeML.Comment}((0,))
  event: Array{QuakeML.Event}((0,))
  description: Missing missing
  creation_info: Missing missing
  public_id: QuakeML.ResourceIdentifier
```

To allow less typing, one could create a module alias, such as:
```julia
julia> const QML = QuakeML
```

### `QuakeML.Types` module
As an **experimental** feature, the user may use the `QuakeML.Types`
module, which exports all the types which are needed to construct a
full set of `EventParameters`.  For example, to specify a catalogue
with one event with an unspecified magnitude type with magnitude 1.0:

```julia
julia> using QuakeML.Types

julia> event = Event(magnitude=[Magnitude(mag=1.0)])
QuakeML.Event
  description: Array{QuakeML.EventDescription}((0,))
  comment: Array{QuakeML.Comment}((0,))
  focal_mechanism: Array{QuakeML.FocalMechanism}((0,))
  amplitude: Array{QuakeML.Amplitude}((0,))
  magnitude: Array{QuakeML.Magnitude}((1,))
  station_magnitude: Array{QuakeML.StationMagnitude}((0,))
  origin: Array{QuakeML.Origin}((0,))
  pick: Array{QuakeML.Pick}((0,))
  preferred_origin_id: Missing missing
  preferred_magnitude_id: Missing missing
  preferred_focal_mechanism_id: Missing missing
  type: Missing missing
  type_certainty: Missing missing
  creation_info: Missing missing
  public_id: QuakeML.ResourceIdentifier
```

## Repo status

QuakeML.jl is alpha software.  All functionality included is tested
and should work as advertised, but the public API of the package is
still to be decided and may change before an initial v0.1 release.

### Activating debugging messages
To turn debugging messages on when running QuakeML, set the
environment variable `JULIA_DEBUG` to `QuakeML` or `"all"`, which can
even be done at run time in the repl like so:
```julia
julia> ENV["JULIA_DEBUG"] = QuakeML
```

Unsetting this value will turn these debugging messages off.

See the [manual section on environment variables and logging messages](https://docs.julialang.org/en/v1/stdlib/Logging/#Environment-variables-1) for more information on setting the debug level for QuakeML or other modules.
