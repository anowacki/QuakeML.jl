"""
# QuakeML

Read files in the  QuakeML format which describe seismic events.
"""
module QuakeML

using Dates

import EzXML

export EventParameters

include("util.jl")
include("types.jl")
include("io.jl")

end # module
