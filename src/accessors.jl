# Functions to get values

"""
    preferred_focal_mechanism(event; verbose=false) -> magnitude

Return the preferred focal mechanism for an `event`.  This may be defined if
there is more than one focal mechanism given for an event, and the
`preferred_focal_mechanism_id` field is set.  If there is only one focal mechanism
for this `event`, then that is returned.  If there is no focal mechanism
associated with this event which matches the stated `preferred_focal_mechanism_id`,
then the first focal mechanism is returned, and a warning given is `verbose` is `true`.
"""
function preferred_focal_mechanism(e::Event; verbose=false)
    isempty(e.focal_mechanism) &&
        throw(ArgumentError("event contains no focal mechanisms"))
    length(e.focal_mechanism) == 1 && return first(e.focal_mechanism)
    preferred_id = e.preferred_focal_mechanism_id
    ind = findfirst(x -> x.public_id == preferred_id, e.focal_mechanism)
    focal_mechanism = if ind === nothing
        verbose &&
            @warn("no focal mechanism with preferred id; returning the first focal mechanism")
        first(e.focal_mechanism)
    else
        e.focal_mechanism[ind]
    end
    focal_mechanism
end

"""
    preferred_focal_mechanisms(quakeml::EventParameters; verbose=false) -> focal_mechanisms

Return the preferred focal mechanisms for the events contained within `quakeml`.
See [`preferred_magnitude`](@ref).
"""
preferred_focal_mechanisms(ep::EventParameters; verbose=false) =
    preferred_focal_mechanism.(ep.event; verbose=verbose)

"""
    preferred_magnitude(event; verbose=false) -> magnitude

Return the preferred magnitude for an `event`.  This may be defined if
there is more than one magnitude given for an event, and the
`preferred_magnitude_id` field is set.  If there is only one magnitude
for this `event`, then that is returned.  If there is no magnitude
associated with this event which matches the stated `preferred_magnitude_id`,
then the first magnitude is returned, and a warning given is `verbose` is `true`.
"""
function preferred_magnitude(e::Event; verbose=false)
    isempty(e.magnitude) && throw(ArgumentError("event contains no magnitudes"))
    length(e.magnitude) == 1 && return first(e.magnitude)
    preferred_id = e.preferred_magnitude_id
    ind = findfirst(x -> x.public_id == preferred_id, e.magnitude)
    magnitude = if ind === nothing
        verbose && @warn("no magnitude with preferred id; returning the first magnitude")
        first(e.magnitude)
    else
        e.magnitude[ind]
    end
    magnitude
end

"""
    preferred_magnitueds(quakeml::EventParameters; verbose=false) -> magnitudes

Return the preferred magnitudes for the events contained within `quakeml`.
See [`preferred_magnitude`](@ref).
"""
preferred_magnitudes(ep::EventParameters; verbose=false) =
    preferred_magnitude.(ep.event; verbose=verbose)

"""
    preferred_origin(event; verbose=false) -> origin

Return the preferred origin for an `event`.  This may be defined if
there is more than one origin given for an event, and the `preferred_origin_id`
field is set.  If there is only one origin for this `event`, then that is
returned.  If there is no origin associated with this event which matches
the stated `preferred_origin_id`, then the first origin is returned
and a warning is given when `verbose=true`
"""
function preferred_origin(e::Event; verbose=false)
    isempty(e.origin) && throw(ArgumentError("event contains no origins"))
    length(e.origin) == 1 && return first(e.origin)
    preferred_id = e.preferred_origin_id
    ind = findfirst(x -> x.public_id == preferred_id, e.origin)
    origin = if ind === nothing
        verbose && @warn("no origin with preferred id; returning the first origin")
        first(e.origin)
    else
        e.origin[ind]
    end
    origin
end

"""
    preferred_origins(quakeml::EventParameters; verbose=false) -> origins

Return the preferred origins for the events contained within `quakeml`.
See [`preferred_origin`](@ref).
"""
preferred_origins(ep::EventParameters; verbose=false) =
    preferred_origin.(ep.event; verbose=verbose)
