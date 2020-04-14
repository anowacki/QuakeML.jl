# QuakeML.jl

## What is [QuakeML.jl](https://github.com/anowacki/QuakeML.jl)?
A [Julia](http://julialang.org) package for reading and writing files
in the [QuakeML](https://quake.ethz.ch/quakeml) format, which describes
the properties of sets of seismic events, such as earthquakes and explosions.

This package is primarily meant to be used by other software to correctly
and reliably interact with QuakeML files.  For example,
[Seis.jl](https://github.com/anowacki/Seis.jl) and its related libraries
use QuakeML.jl to parse QuakeML files, but do not expose QuakeML.jl
types or functions to the user.  Though QuakeML.jl is intended to be used
as software by other software, it is still a goal that it should be easy
to use directly and well-documented and -tested.

### Note on naming
In this documentation, ‘QuakeML’ refers to the QuakeML standard, and
‘QuakeML.jl’ refers to this Julia package, which implements the QuakeML
standard.

### Current version
The current version of QuakeML is
[1.2](https://quake.ethz.ch/quakeml/Documents).  This is the version
of QuakeML supported by QuakeML.jl.

## How to install
QuakeML.jl can be added to your Julia environment like so:

```julia
julia> import Pkg; Pkg.pkg"add https://github.com/anowacki/QuakeML.jl"
```

## Testing
To check that your install is working correctly, you can run the package's
tests by doing:

```julia
julia> import Pkg; Pkg.test("QuakeML")
```
