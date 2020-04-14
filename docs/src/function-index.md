# Function index

## Public types and functions
### IO
```@docs
QuakeML.read(filename::AbstractString)
QuakeML.readstring
write(io::IO, qml::EventParameters; kwargs...)
quakeml
```

### Accessors
```@docs
preferred_focal_mechanism
preferred_magnitude
preferred_origin
has_focal_mechanism
has_magnitude
has_origin
```

### Types
Where a constructor's arguments are given as `Constructor(; kwargs...)`,
this means that each listed field name can be given as a keyword
argument and a value passed to the constructor that way.

!!! note
    By default, calling a constructor for a type which is required to
    have a public ID (URI) by the QuakeML specification creates a
    unique, random URI for that object.  To specify your own ID for
    an object, provide a `String` to the constructor's `public_id`
    keyword argument; or you can later set the `public_id` field directly.
    See [`ResourceReference`](@ref QuakeML.ResourceReference) for details
    of the form that URIs must take.

```@docs
QuakeML.Amplitude
QuakeML.Arrival
QuakeML.Axis
QuakeML.Comment
QuakeML.CompositeTime
QuakeML.ConfidenceEllipsoid
QuakeML.CreationInfo
QuakeML.DataUsed
QuakeML.Event
QuakeML.EventDescription
QuakeML.EventParameters
QuakeML.FocalMechanism
QuakeML.IntegerQuantity
QuakeML.Magnitude
QuakeML.MomentTensor
QuakeML.NodalPlane
QuakeML.NodalPlanes
QuakeML.Origin
QuakeML.OriginQuality
QuakeML.OriginUncertainty
QuakeML.Phase
QuakeML.Pick
QuakeML.PrincipleAxes
QuakeML.RealQuantity
QuakeML.ResourceReference
QuakeML.SourceTimeFunction
QuakeML.StationMagnitude
QuakeML.StationMagnitudeContribution
QuakeML.Tensor
QuakeML.TimeQuantity
QuakeML.TimeWindow
QuakeML.WaveformStreamID
```

## Private types and functions
### ID generation
```@docs
QuakeML.random_reference
```

### Enumerated types
```@docs
QuakeML.AmplitudeCategory
QuakeML.AmplitudeUnit
QuakeML.DataUsedWaveType
QuakeML.EvaluationMode
QuakeML.EvaluationStatus
QuakeML.EventDescriptionType
QuakeML.EventType
QuakeML.EventTypeCertainty
QuakeML.MomentTensorCategory
QuakeML.MTInversionType
QuakeML.OriginDepthType
QuakeML.OriginType
QuakeML.OriginUncertaintyDescription
QuakeML.PickOnset
QuakeML.PickPolarity
QuakeML.SourceTimeFunctionType
```
