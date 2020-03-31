"""
# QuakeML

Read files in the  QuakeML format which describe seismic events.
"""
module QuakeML

using Dates

import EzXML

export
    EventParameters,
    preferred_focal_mechanism,
    preferred_focal_mechanisms,
    preferred_magnitude,
    preferred_magnitudes,
    preferred_origin,
    preferred_origins

include("util.jl")
include("types.jl")
include("io.jl")
include("constructors.jl")
include("accessors.jl")

end # module
