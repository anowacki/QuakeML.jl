"""
# QuakeML

Read and write files in the QuakeML format which describes seismic events.

## User functions

- [`QuakeML.read`](@ref): Read a QuakeML file
- [`QuakeML.readstring`](@ref): Read a QuakeML document from a string
- [`preferred_focal_mechanism`](@ref): Get the preferred focal mechanism for an event
- [`preferred_magnitude`](@ref): Get the preferred magnitude for an event
- [`preferred_origin`](@ref): Get the preferred origin for an event
- [`quakeml`](@ref): Create an XML document from a set of events which can
  be written with `print(io, quakeml(qml))`
"""
module QuakeML

using Dates: DateTime, Time

import EzXML

export
    EventParameters,
    has_focal_mechanism,
    has_magnitude,
    has_origin,
    preferred_focal_mechanism,
    preferred_focal_mechanisms,
    preferred_magnitude,
    preferred_magnitudes,
    preferred_origin,
    preferred_origins,
    quakeml

include("compat.jl")
include("util.jl")
include("types.jl")
include("io.jl")
include("constructors.jl")
include("accessors.jl")

end # module
