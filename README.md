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
- `QuakeML.read`: Read a QuakeML file.  (This function is not exported.)
- `QuakeML.readstring`: Read a QuakeML document from a string.  (This 
  function is not exported.)
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

To write a set of events:
```julia
julia> println("/tmp/quakeml_file.qml", quakeml(qml))
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
