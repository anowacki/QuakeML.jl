# Definition of types as per the QuakeML schema

using Parameters: @with_kw

# Shorthand for single values which may or may not be present once,
# equivalent to `minOccurs="0" maxOccurs="1"` in the schema.
const M{T} = Union{Missing,T}

"""
    RealQuantity(; kwargs...)

Physical quantities that can be expressed numerically—either as integers
or as floating point numbers—are represented by their measured or
computed values and optional values for symmetric or upper and lower
uncertainties. The interpretation of these uncertainties is not defined
in the standard. They can contain statistically well-defined error
measures, but the mechanism can also be used to simply describe a possible
value range. Ifthe confidence level of the uncertainty is known, it can be
listed in the optional field `confidence_level`. Note that `uncertainty`,
`upper_uncertainty`, and `lower_uncertainty` are given as absolute values
of the deviation from the main `value`.

# List of fields
- `value :: Float64`: Value of the quantity. The unit is implicitly defined and depends
  on the context. (**Required field.**)
- `uncertainty :: Float64`: Uncertainty as the absolute value of symmetric deviation
  from the main value.
- `lower_uncertainty :: Float64`: Uncertainty as the absolute value of deviation from
  the main `value` towards smaller values.
- `upper_uncertainty :: Float64`: Uncertainty as the absolute value of deviation from
  the main `value` towards larger values.
- `confidence_level :: Float64`: Confidence level of the uncertainty, given in percent.
"""
@with_kw mutable struct RealQuantity
    value::Float64
    uncertainty::M{Float64} = missing
    lower_uncertainty::M{Float64} = missing
    upper_uncertainty::M{Float64} = missing
    confidence_level::M{Float64} = missing
end

"""
    IntegerQuantity(; kwargs...)

Physical quantities that can be expressed numerically—either as integers
or as floating point numbers—are represented by their measured or
computed values and optional values for symmetric or upper and lower
uncertainties. The interpretation of these uncertainties is not defined
in the standard. They can contain statistically well-defined error
measures, but the mechanism can also be used to simply describe a possible
value range. Ifthe confidence level of the uncertainty is known, it can be
listed in the optional field `confidence_level`. Note that `uncertainty`,
`upper_uncertainty`, and `lower_uncertainty` are given as absolute values
of the deviation from the main `value`.

# List of fields
- `value :: Int`: Value of the quantity. The unit is implicitly defined and depends
  on the context. (**Required field.**)
- `uncertainty :: Int`: Uncertainty as the absolute value of symmetric deviation
  from the main value.
- `lower_uncertainty :: Int`: Uncertainty as the absolute value of deviation from
  the main `value` towards smaller values.
- `upper_uncertainty :: Int`: Uncertainty as the absolute value of deviation from
  the main `value` towards larger values.
- `confidence_level :: Float64`: Confidence level of the uncertainty, given in percent.
"""
@with_kw mutable struct IntegerQuantity
    value::Int
    uncertainty::M{Int} = missing
    lower_uncertainty::M{Int} = missing
    upper_uncertainty::M{Int} = missing
    confidence_level::M{Float64} = missing
end

"""
    ResourceReference(value)
    ResourceReference(; value=::String)

`String` that is used as a reference to a QuakeML resource. It must adhere
to the format specificationsgiven in Sect. 3.1 of the QuakeML specificaiton.
The string has a maximum length of 255 characters.

In this package, when creating objects which require a `ResourceReference`
(usually in a field called `public_id`), a unique URI is created of the form
`"smi:local/XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"`, where `X` represents
a hexadecimal characters (matching `r"[0-9a-f]"`).  This is generated
by calling [`QuakeML.random_reference`](@ref).


# Further information

Identifiers take the generic form of:

    [smi|quakeml]:〈authority-id〉/〈resource-id〉[#〈local-id〉]

They consist of an authority identifier, a unique resource identifier, and an
optional local identifier. The URI schema name `smi` stands for
'seismological meta-information', thus indicating a connection to a set of
metadata associated with the resource.

The authority-id part must consist of at least three characters, of which
the first character has to be alphanu-meric. The subsequent characters can be
alphanumeric or from the following list: `-`, `.`, `~`, `*`, `'`, `(`, `)`.
After the authority-id, a forward slash (`"/"`) must follow which separates
the authority-id from the resource-id. The resource-id must contain at least
one character, which can be either alphanumeric, or from the eight special
characters which are allowed for the authority-id. For the remaining characters
of the resource-id, also the comma (`","`) and semicolon (`";"`) characters
and characters from the following list can be used: `+`, `?`, `=`, `#`, `/`, `&`.
Note that the forward slash which separates authority-id and resource-id is
always the first forwards lash in the resource identifier. The resource-id
may be followed by a stop character (`"#"`) and a local identifier which
can be made up of alphanumeric characters, the comma (`","`) and semicolon
(`";"`) characters, and the characters from the following list:
`-`, `.`, `~`, `*`, `'`, `(`, `)`, `/`, `+`, `=`, `?`. Local identifiers
are thought to denote resources that have no own metadata description associated,
but are part of a larger collection for which such metadata exists.

For even more information, see
[Section 3.1 of the QuakeML specification](https://quake.ethz.ch/quakeml/docs/latest?action=AttachFile&do=get&target=QuakeML-BED.pdf)

!!! note
    `ResourceReference`s are also called `ResourceIdentifier`s.
"""
@with_kw struct ResourceIdentifier
    value::String
    function ResourceIdentifier(value)
        occursin(r"(smi|quakeml):[\w\d][\w\d\-\.\*\(\)_~']{2,}/[\w\d\-\.\*\(\)_~'][\w\d\-\.\*\(\)\+\?_~'=,;#/&amp;]*",
            value) || throw(ArgumentError("ResourceIdentifier '$value' is not valid URI"))
        check_string_length("value", value, 255)
        new(value)
    end
end

"""
    WhitespaceOrEmptyString

Contains a single field, `value`, which may only contain an empty
`String`, or one that contains only whitespace characters.
"""
@with_kw struct WhitespaceOrEmptyString
    value::String
    WhitespaceOrEmptyString(value) = (occursin(r"^\s*$", value) ||
        throw(ArgumentError("\"" * value *"\" is not blank")); new(value))
end
const ResourceReference = ResourceIdentifier
const ResourceReference_optional = Union{ResourceReference, WhitespaceOrEmptyString}

@enumerated_struct(
    OriginUncertaintyDescription,
    String,
    ("horizontal uncertainty", "uncertainty ellipse", "confidence ellipsoid")
    )

@enumerated_struct(
    AmplitudeCategory,
    String,
    ("point", "mean", "duration", "period", "integral", "other")
    )

@enumerated_struct(
    OriginDepthType,
    String,
    ("from location", "from moment tensor inversion",
     "from modeling of broad-band P waveforms", "constrained by depth phases",
     "constrained by direct phases", "constrained by depth and direct phases",
     "operator assigned", "other")
    )

@enumerated_struct(
    OriginType,
    String,
    ("hypocenter", "centroid", "amplitude", "macroseismic", "rupture start",
     "rupture end")
    )

@enumerated_struct(
    MTInversionType,
    String,
    ("general", "zero trace", "double couple")
    )

@enumerated_struct(
    EvaluationMode,
    String,
    ("manual", "automatic")
    )

@enumerated_struct(
    EvaluationStatus,
    String,
    ("preliminary", "confirmed", "reviewed", "final", "rejected")
    )

@enumerated_struct(
    PickOnset,
    String,
    ("emergent", "impulsive", "questionable")
    )

@enumerated_struct(
    EventType,
    String,
    ("not existing", "not reported", "earthquake", "anthropogenic event",
     "collapse", "cavity collapse", "mine collapse", "building collapse",
     "explosion", "accidental explosion", "chemical explosion",
     "controlled explosion", "experimental explosion", "industrial explosion",
     "mining explosion", "quarry blast", "road cut", "blasting levee",
     "nuclear explosion", "induced or triggered event", "rock burst",
     "reservoir loading", "fluid injection", "fluid extraction", "crash",
     "plane crash", "train crash", "boat crash", "other event", "atmospheric event",
     "sonic boom", "sonic blast", "acoustic noise", "thunder", "avalanche",
     "snow avalanche", "debris avalanche", "hydroacoustic event", "ice quake",
     "slide", "landslide", "rockslide", "meteorite", "volcanic eruption")
    )

@enumerated_struct(
    DataUsedWaveType,
    String,
    ("P waves", "body waves", "surface waves", "mantle waves", "combined", "unknown")
    )

@enumerated_struct(
    AmplitudeUnit,
    String,
    ("m", "s", "m/s", "m/(s*s)", "m*s", "dimensionless", "other")
    )

@enumerated_struct(
    EventDescriptionType,
    String,
    ("felt report", "Flinn-Engdahl region", "local time", "tectonic summary",
     "nearest cities", "earthquake name", "region name")
    )

@enumerated_struct(
    MomentTensorCategory,
    String,
    ("teleseismic", "regional")
    )

@enumerated_struct(
    EventTypeCertainty,
    String,
    ("known", "suspected")
    )

@enumerated_struct(
    SourceTimeFunctionType,
    String,
    ("box car", "triangle", "trapezoid", "unknown")
    )

@enumerated_struct(
    PickPolarity,
    String,
    ("positive", "negative", "undecidable")
    )

"""
    TimeQuantity(; kwargs...)

Describes a point in time, given in ISO 8601 format, with
optional symmetric or asymmetric uncertainties given in seconds.
The time has to be specified in UTC.

# List of fields
- `value :: Dates.DateTime`: Point in time (UTC), given in ISO 8601 format.
  (**Required field.**)
- `uncertainty :: Float64`: Symmetric uncertainty of point in time.  Unit: s.
- `lower_uncertainty :: Float64`: Lower uncertainty of point in time.  Unit: s.
- `upper_uncertainty :: Float64`: Upper uncertainty of point in time.  Unit: s.
- `confidence_level :: Float64`: Confidence level of the uncertainty, given in percent.
"""
@with_kw mutable struct TimeQuantity
    value::DateTime
    uncertainty::M{Float64} = missing
    lower_uncertainty::M{Float64} = missing
    upper_uncertainty::M{Float64} = missing
    confidence_level::M{Float64} = missing
end

"""
    CreationInfo(; kwargs...)

Used to describe creation metadata (author, version, and creation time)
of a resource.

# List of fields
- `agency_id :: String`: Designation of agency that published a resource. The string
  has a maximum length of 64 characters.
- `agency_uri :: ResourceReference`: URI of the agency that published a resource.
- `author :: String`: Name describing the author of a resource. The string has a
  maximum length of 128 characters.
- `author_uri :: ResourceReference`: URI of the author of a resource.
- `creation_time :: Dates.DateTime`: Time of creation of a resource, in ISO 8601 format.
  It has to be given in UTC.
- `version :: String`: Version string of a resource.  The string has a maximum length
  of 64 characters.
"""
@with_kw mutable struct CreationInfo
    agency_id::M{String} = missing
    agency_uri::M{ResourceReference} = missing
    author::M{String} = missing
    author_uri::M{ResourceReference} = missing
    creation_time::M{DateTime} = missing
    version::M{String} = missing
    function CreationInfo(agency_id, agency_uri, author, author_uri, creation_time, version)
        check_string_length("agency_id", agency_id, 64)
        check_string_length("author", author, 128)
        check_string_length("version", version, 64)
        new(agency_id, agency_uri, author, author_uri, creation_time, version)
    end
end

# Enforce string lengths upon field setting
function Base.setproperty!(ci::CreationInfo, field::Symbol, value)
    if field === :agency_id || field === :version
        check_string_length(String(field), value, 64)
    elseif field === :author
        check_string_length(String(field), value, 128)
    end
    setfield!(ci, field, value)
end

"""
    EventDescription(; text, type)

Free-form string with additional event description.  This can be a
well-known name, like `"1906 San Francisco Earthquake"`.
A number of categories can be given in `type`.

# List of fields
- `text :: String`: Free-form text with earthquake description. (**Required field.**)
- `type :: EventDescriptionType`: Category of earthquake description. Values can be taken from the following:
  - `"felt report"`
  - `"Flinn-Engdahl region"`
  - `"local time"`
  - `"tectonic summary"`
  - `"nearest cities"`
  - `"earthquake name"`
  - `"region name"`
"""
@with_kw mutable struct EventDescription
    text::String
    type::M{EventDescriptionType} = missing
end

"""
    Phase(code)
    Phase(; value=code)

Phase code as given in the IASPEI Standard Seismic Phase List
(Storchak et al. 2003). String with a maximum length of 32 characters.

# List of fields
- `value :: String`: Phase code. (**Required field.**)
"""
@with_kw mutable struct Phase
    value::String
end

"""
    Comment(; text, creation_info, id)

Holds information on comments to a resource as well as author
and creation time information.

# List of fields
- `text :: String`: Text of comment. (**Required field.**)
- `creation_info :: CreationInfo`: [`CreationInfo`](@ref QuakeML.CreationInfo) for the `Comment` object.
- `id :: ResourceReference`: Identifier of comment, in QuakeML URI format.
"""
@with_kw mutable struct Comment
    text::String
    creation_info::M{CreationInfo} = missing
    id::M{ResourceReference} = missing
end

"""
    Axis(; azimuth, plunge, length)

Describes an eigenvector of a moment tensor expressed in its
principal-axes system. It uses the angles `azimuth`, `plunge`, and the
eigenvalue `length`.

# List of fields
- `azimuth :: RealQuantity`: Azimuth of eigenvector of moment tensor expressed in
  principal-axes system. Measured clockwisefrom south-north direction at
  epicenter.  Unit: °. (**Required field.**)
- `plunge :: RealQuantity`: Plunge of eigenvector of moment tensor expressed in principal-axes
  system. Measured against downward vertical direction at epicenter. Unit: °. (**Required field.**)
- `length :: RealQuantity`: Eigenvalue of moment tensor expressed in principal-axes system.
  Unit: N m. (**Required field.**)
"""
@with_kw mutable struct Axis
    azimuth::RealQuantity
    plunge::RealQuantity
    length::RealQuantity
end

"""
    PrincipleAxes(; t_axis, p_axis, n_axis)

# List of fields
- `tAxis :: Axis`: T (tension) axis of a moment tensor. (**Required field.**)
- `p_axis :: Axis`: P (pressure) axis of a moment tensor. (**Required field.**)
- `n_axis :: Axis`: N (neutral) axis of a moment tensor.
"""
@with_kw mutable struct PrincipleAxes
    t_axis::Axis
    p_axis::Axis
    n_axis::M{Axis} = missing
end

"""
    DataUsed(; kwargs...)

Describes the type of data that has been used for a moment-tensor inversion.

# List of fields
- `wave_type : DataUsedWaveType`: Type of waveform data. This can be one of the following
  values (see [`DataUsedWaveType`](@ref)):
  - `"P waves"`
  - `"body waves"`
  - `"surface waves"`
  - `"mantle waves"`
  - `"combined"`
  - `"unknown"`
   (**Required field.**)
- `station_count :: Int`: Number of stations that have contributed data of the type
  given in `wave_type`.
- `component_count :: Int`: Number of data components of the type given in `wave_type`.
- `shortest_period :: Float64`: Shortest period present in data.  Unit: s.
- `longest_period :: Float64`: Longest period present in data.  Unit: s.
"""
@with_kw mutable struct DataUsed
    wave_type::DataUsedWaveType
    station_count::M{Int} = missing
    component_count::M{Int} = missing
    shortest_period::M{Float64} = missing
    longest_period::M{Float64} = missing
end

"""
    CompositeTime(; year, month, day, hour, minute, second)

Focal times differ significantly in their precision. While focal times of
instrumentally located earthquakes areestimated precisely down to seconds,
historic events have only incomplete time descriptions. Sometimes, even
contradictory information about the rupture time exist.  The `CompositeTime`
type allows for such complex descriptions. If the specification is given with
no greater accuracy than days (i.e., no time components are given), the date
refers to local time. However, if time components are given, they have to
refer to UTC.

As an example, consider a historic earthquake in California, e.g., on 28
February 1730, with no time information given. Expressed in UTC, this day
extends from 1730-02-28T08:00:00Z until 1730-03-01T08:00:00Z. Such a
specification would be against intuition. Therefore, for date-time
specifications without time components, local time is used. In the example,
the `CompositeTime` fields are simply `year=1730`, `month=2`, and `day=28`.
In the corresponding time attribute of the origin, however, UTC has to be used.
If the unknown time components are assumed to be zero, the value is
`DateTime("1730-02-28T08:00:00")`.

# List of fields
- `year ::IntegerQuantity`: Year or range of years of the event’s focal time.
- `month ::IntegerQuantity`: Month or range of months of the event’s focal time.
- `day ::IntegerQuantity`: Day or range of days of the event’s focal time.
- `hour ::IntegerQuantity`: Hour or range of hours of the event’s focal time.
- `minute ::IntegerQuantity`: Minute or range of minutes of the event’s focal time.
- `second :: RealQuantity`: Second and fraction of seconds or range of seconds with fraction
  of the event’s focal time.
"""
@with_kw mutable struct CompositeTime
    year::M{IntegerQuantity} = missing
    month::M{IntegerQuantity} = missing
    day::M{IntegerQuantity} = missing
    hour::M{IntegerQuantity} = missing
    minute::M{IntegerQuantity} = missing
    second::M{RealQuantity} = missing
end

"""
    Tensor(mrr, mtt, mpp, mrt, mrp, mtp)
    Tensor(; mrr, mtt, mpp, mrt, mrp, mtp)

The `Tensor` type represents the six moment-tensor elements
Mrr, Mtt, Mpp, Mrt, Mrp, Mtp in the spherical coordinate system defined by
local upward vertical (r), North-South (t), and West-East (p) directions.
See Aki and Richards(1980) for conversions to other coordinate systems.

# List of fields
- `mrr :: RealQuantity`: Moment-tensor component Mrr.  Unit: N m.  (**Required field.**)
- `mtt :: RealQuantity`: Moment-tensor component Mtt.  Unit: N m.  (**Required field.**)
- `mpp :: RealQuantity`: Moment-tensor component Mpp.  Unit: N m.  (**Required field.**)
- `mrt :: RealQuantity`: Moment-tensor component Mrt.  Unit: N m.  (**Required field.**)
- `mrp :: RealQuantity`: Moment-tensor component Mrp.  Unit: N m.  (**Required field.**)
- `mtp :: RealQuantity`: Moment-tensor component Mtp.  Unit: N m.  (**Required field.**)
"""
@with_kw mutable struct Tensor
    mrr::RealQuantity
    mtt::RealQuantity
    mpp::RealQuantity
    mrt::RealQuantity
    mrp::RealQuantity
    mtp::RealQuantity
end

"""
    OriginQuality(; kwargs...)

This type contains various attributes commonly used to describe the quality
of an origin, e. g., errors, azimuthal coverage, etc.  `Origin` objects have
an optional attribute of the type `OriginQuality`.

# List of fields
- `associated_phase_count :: Int`: Number of associated phases, regardless of their
  use for origin computation.
- `used_phase_count :: Int`: Number of defining phases, i. e., phase observations
  that were actually used for computingthe origin. Note that there may be more
  than one defining phase per station.
- `associated_station_count :: Int`: Number of stations at which the event was observed.
- `used_station_count :: Int`: Number of stations from which data was used for origin
  computation.
- `depth_phase_count :: Int`: Number of depth phases (typically pP, sometimes sP)
  used in depth computation.
- `standard_error :: Float64`: RMS of the travel time residuals of the arrivals used for
  the origin computation. Unit: s.
- `azimuthal_gap :: Float64`: Largest azimuthal gap in station distribution as seen from
  epicenter.  For an illustration of azimuthal gap and secondary azimuthal gap
  (see below), see Fig. 5 of Bondár et al. (2004). Unit: °.
- `secondary_azimuthal_gap :: Float64`: Secondary azimuthal gap in station distribution,
  i. e., the largest azimuthal gap a station closes.  Unit: °.
- `ground_truth_level :: String`: `String` describing ground-truth level, e. g. GT0,
  GT5, etc. It has a maximum length of 32 characters.
- `minimum_distance :: Float64`: Epicentral distance of station closest to the epicenter.
  Unit: °.
- `maximum_distance :: Float64`: Epicentral distance of station farthest from the epicenter.
  Unit: °.
- `median_distance :: Float64`: Median epicentral distance of used stations.  Unit: °.
"""
@with_kw mutable struct OriginQuality
    associated_phase_count::M{Int} = missing
    used_phase_count::M{Int} = missing
    associated_station_count::M{Int} = missing
    used_station_count::M{Int} = missing
    depth_phase_count::M{Int} = missing
    standard_error::M{Float64} = missing
    azimuthal_gap::M{Float64} = missing
    secondary_azimuthal_gap::M{Float64} = missing
    ground_truth_level::M{String} = missing
    maximum_distance::M{Float64} = missing
    minimum_distance::M{Float64} = missing
    median_distance::M{Float64} = missing
    function OriginQuality(associated_phase_count, used_phase_count,
            associated_station_count, used_station_count, depth_phase_count,
            standard_error, azimuthal_gap, secondary_azimuthal_gap,
            ground_truth_level, maximum_distance, minimum_distance, median_distance)
        check_string_length("ground_truth_level", ground_truth_level, 32)
        new(associated_phase_count, used_phase_count, associated_station_count,
            used_station_count, depth_phase_count, standard_error, azimuthal_gap,
            secondary_azimuthal_gap, ground_truth_level, maximum_distance,
            minimum_distance, median_distance)
    end
end

function Base.setproperty!(oq::OriginQuality, field::Symbol, value)
    if field === :ground_truth_level
        check_string_length("ground_truth_level", value, 32)
    end
    type = fieldtype(OriginQuality, field)
    setfield!(oq, field, convert(type, value))
end


"""
    NodalPlane(; strike, dip, rake)

This class describes a nodal plane using the fields `strike`, `dip`, and
`rake`. For a definition of the angles see Aki and Richards (1980).

# List of fields
- `strike :: RealQuantity`: Strike angle of nodal plane.  Unit: °.   (**Required field.**)
- `dip :: RealQuantity`: Dip angle of nodal plane.  Unit: °.   (**Required field.**)
- `rake :: RealQuantity`: Rake angle of nodal plane.  Unit: °.   (**Required field.**)
"""
@with_kw mutable struct NodalPlane
    strike::RealQuantity
    dip::RealQuantity
    rake::RealQuantity
end

"""
    TimeWindow(; begin_, end_, reference)

Describes a time window for amplitude measurements, given by a central point
in time, and points in time before and after this central point. Both points
before and after may coincide with the central point.

# List of fields
- `begin_ :: Float64`: Absolute value of duration of time interval before `reference` point
  in time window. The value may be zero, but not negative. Unit: s.
  (**Required field.**)
- `end_ :: Float64`: Absolute value of duration of time interval after `reference` point
  in time window. The value may be zero, but not negative. Unit: s.
  (**Required field.**)
- `reference :: Dates.DateTime`: Reference point in time (“central” point).
  It has to be given in UTC.  (**Required field.**)
"""
@with_kw mutable struct TimeWindow
    begin_::Float64
    end_::Float64
    reference::DateTime
    function TimeWindow(begin_, end_, reference)
        any(x->x<0, (begin_, end_)) &&
            throw(ArgumentError("begin and end times cannot be negative"))
        new(begin_, end_, reference)
    end
end

"""
    WaveformStreamID(; kwargs...)

Reference to a stream description in an inventory. This is mostly equivalent
to the combination of `network_code`, `station_code`, `location_code`,
and `channel_code`. However, additional information, e. g., sampling rate,
can be referenced by the resource `uri`. It is recommended to use
resource URI as a flexible, abstract, and unique stream ID that allows
to describe different processing levels, or resampled/filtered products of
the same initialstream, without violating the intrinsic meaning of the legacy
identifiers (network, station, channel, and location codes). However, for
operation in the context of legacy systems, the classical identifier
components are upported.

# List of fields
- `network_code :: String`: Network code. String with a maximum length of 8 characters.  (**Required field.**)
- `station_code :: String`: Station code. String with a maximum length of 8 characters.  (**Required field.**)
- `channel_code :: String`: Channel code. String with a maximum length of 8 characters.
- `location_code :: String`: Location code. String with a maximum length of 8 characters.
- `uri :: ResourceReference`: Resource identifier for the waveform stream.
"""
@with_kw mutable struct WaveformStreamID
    uri::M{ResourceReference} = missing
    network_code::String
    station_code::String
    channel_code::M{String} = missing
    location_code::M{String} = missing
    function WaveformStreamID(uri, net, sta, cha, loc)
        check_string_length("network_code", net, 8)
        check_string_length("station_code", sta, 8)
        check_string_length("channel_code", cha, 8)
        check_string_length("location_code", loc, 8)
        new(uri, net, sta, cha, loc)
    end
end

function Base.setproperty!(ws::WaveformStreamID, field::Symbol, value)
    if field !== :uri
        check_string_length(String(field), value, 8)
    end
    type = fieldtype(WaveformStreamID, field)
    setfield!(ws, field, convert(type, value))
end

"""
    SourceTimeFunction(; type, duration, rise_time, decay_time)

Source time function used in moment-tensor inversion.

# List of fields
- `type :: SourceTimeFunctionType`: Type of source time function. Values can be taken from the following:
  - `"box car"`
  - `"triangle"`
  - `"trapezoid"`
  - `"unknown"`
  (**Required field.**)
- `duration :: Float64` Source time function duration.  Unit: s.  (**Required field.**)
- `rise_time :: Float64`: Source time function rise time.  Unit: s.
- `decay_time :: Float64`: Source time function decay time.  Unit: s.
"""
@with_kw mutable struct SourceTimeFunction
    type::SourceTimeFunctionType
    duration::Float64
    rise_time::M{Float64} = missing
    decay_time::M{Float64} = missing
end

"""
    NodalPlanes(; nodal_plane1=::NodalPlane, nodal_plane2=::NodalPlane, preferred_plane=::Int)

This describes the nodal planes of a moment tensor. The field
`preferred_plane` can be used to define which plane is the preferred one,
taking a value of `1` or `2`.

# List of fields
- `nodal_plane1 :: NodalPlane`: First nodal plane of moment tensor.
- `nodal_plane2 :: NodalPlane`: Second nodal plane of moment tensor.
- `preferred_plane :: Int`: Indicator for preferred nodal plane of moment tensor.
  It can take integer values `1` or `2`.
"""
@with_kw mutable struct NodalPlanes
    nodal_plane1::M{NodalPlane} = missing
    nodal_plane2::M{NodalPlane} = missing
    preferred_plane::M{Int} = missing
    function NodalPlanes(nodal_plane1, nodal_plane2, preferred_plane)
        if preferred_plane !== missing
            preferred_plane in (1, 2) ||
                throw(ArgumentError("preferred_plane must be 1 or 2"))
        end
        new(nodal_plane1, nodal_plane2, preferred_plane)
    end
end

function Base.setproperty!(nps::NodalPlanes, field::Symbol, value)
    if field === :preferred_plane && value !== missing
        value in (1, 2) || throw(ArgumentError("preferred_plane must be 1 or 2"))
        value = Int(value)
    end
    type = fieldtype(NodalPlanes, field)
    # Don't convert here, since preferred_plane should really be
    # an Integer 
    setfield!(nps, field, value)
end

"""
    ConfidenceEllipsoid(; kwargs...)

This type represents a description of the location uncertainty as a
confidence ellipsoid with arbitrary orientationin space.  The orientation
of a rigid body in three-dimensional Euclidean space can be described by
three parameters.  We use the convention of Euler angles, which can be
interpreted as a composition of three elemental rotations (i.e., rotations
around a single axis). In the special case of Euler angles we use here, the
angles are referred to as Tait-Bryan (or Cardan) angles. These angles may be
familiar to the reader from their application in flight dynamics, and are
referred to as heading (yaw, ψ), elevation (attitude, pitch, φ), and bank
(roll, θ).
For a definition of the angles, see Figure 4 of the QuakeML specification
document at https://quake.ethz.ch/quakeml/docs/latest?action=AttachFile&do=get&target=QuakeML-BED.pdf.
Through the three elemental rotations, a Cartesian system `(x,y,z)`
centered at the epicenter, with the south-north direction `x`, the west-east
direction `y`, and the downward vertical direction `z`, is transferred into a
different Cartesian system `(X,Y,Z)` centered on the confidence ellipsoid.
Here, `X` denotes the direction of the major axis, and `Y` denotes the
direction of the minor axis of the ellipsoid. Note that Figure 4 can be
interpreted as a hypothetical view from the _interior_ of the Earth to the
inner face of a shell representing Earth's surface.

The three Tait-Bryan rotations are performed as follows:
(i) a rotation about the `Z` axis with angle ψ (heading, or azimuth);
(ii) a rotation about the `Y` axis with angle φ (elevation, or plunge); and
(iii) a rotation about the `X` axis with angle θ (bank). Note that in the
case of Tait-Bryan angles, the rotations are performed about the ellipsoid's
axes, not about the axes of the fixed `(x,y,z)` Cartesian system.

# List of fields
- `semi_major_axis_length :: Float64`: Largest uncertainty, corresponding to the semi-major axis
  of the confidence ellipsoid.  Unit: m.  (**Required field.**)
- `semi_minor_axis_length :: Float64`: Smallest uncertainty, corresponding to the semi-minor axis
  of the confidence ellipsoid.  Unit: m.  (**Required field.**)
- `semi_intermediate_axis_length :: Float64`: Uncertainty in direction orthogonal to major
  and minor axesof the confidence ellipsoid.  Unit: m.  (**Required field.**)
- `major_axis_plunge :: Float64`: Plunge angle of major axis of confidence ellipsoid.
  Corresponds to Tait-Bryan angle φ.  Unit: °.  (**Required field.**)
- `major_axis_azimuth :: Float64`: Azimuth angle of major axis of confidence ellipsoid.
  Corresponds to Tait-Bryan angle ψ.  Unit: °.  (**Required field.**)
- `major_axis_rotation :: Float64`: This angle describes a rotation about the confidence
  ellipsoid's major axis which is required to define the direction of the
  ellipsoid's minor axis. Corresponds to Tait-Bryan angle θ.  Unit: °.  (**Required field.**)
"""
@with_kw mutable struct ConfidenceEllipsoid
    semi_major_axis_length::Float64
    semi_minor_axis_length::Float64
    semi_intermediate_axis_length::Float64
    major_axis_plunge::Float64
    major_axis_azimuth::Float64
    major_axis_rotation::Float64
end

"""
    MomentTensor(; kwargs...)

Represents a moment tensor solution for an event. It is an optional
part of a `FocalMechanism` description.

# List of fields
- `public_id :: ResourceReference` Resource identifier of `MomentTensor`.
  (**Required field.**)
- `derived_origin_id :: ResourceReference`: Refers to the `public_id` of the `Origin` derived
  in the moment tensor inversion.  (**Required field.**)
- `moment_magnitude_id :: ResourceReference`: Refers to the `public_id` of the `Magnitude`
  object which represents the derived moment magnitude.
- `scalar_moment :: RealQuantity`: Scalar moment as derived in moment tensor inversion.
  Unit: N m.
- `tensor :: Tensor`: `Tensor` object holding the moment tensor elements.
- `variance :: Float64`: Variance of moment tensor inversion.
- `variance_reduction :: Float64`: Variance reduction of moment tensor inversion,
  given in percent (Dreger 2003). This is a goodness-of-fit measure.
- `double_couple :: Float64`: Double couple parameter obtained from moment tensor
  inversion (decimal fraction between 0 and 1).
- `clvd :: Float64`: CLVD (compensated linear vector dipole) parameter obtained
  from moment tensor inversion (decimal fraction between 0 and 1).
- `iso :: Float64`: Isotropic part obtained from moment tensor inversion (decimal
  fraction between 0 and 1).
- `greens_function_id :: ResourceReference`: Resource identifier of the Green’s function used
  in moment tensor inversion.
- `filter_id :: ResourceReference`: Resource identifier of the filter setup used in moment
  tensor inversion.
- `source_time_function :: SourceTimeFunction`: Source time function used in moment-tensor inversion.
- `data_used :: Vector{DataUsed}`: Describes waveform data used for moment-tensor inversion.
- `method_id :: ResourceReference`: Resource identifier of the method used for moment-tensor
  inversion.
- `category :: MomentTensorCategory`: Category of moment tensor inversion. Valid entries are
  given in the following list (see [`MomentTensorCategory`](@ref)):
  - `"teleseismic"`
  - `"regional"`
- `inversion_type :: MTInversionType`: Type of moment tensor inversion.  Users should avoid
  giving contradictory information in `inversion_type` and `method_id`.
  Valid entries are given in the following list (see
  [`MTInversionType`](@ref)):
  - general
  - zero trace
  - double couple
- `comment :: Vector{Comment}`: Additional comments.
- `creation_info :: CreationInfo`: [`CreationInfo`](@ref QuakeML.CreationInfo) for the `MomentTensor` object.
"""
@with_kw mutable struct MomentTensor
    data_used::Vector{DataUsed} = DataUsed[]
    comment::Vector{Comment} = Comment[]
    derived_origin_id::ResourceReference
    moment_magnitude_id::M{ResourceReference} = missing
    scalar_moment::M{RealQuantity} = missing
    tensor::M{Tensor} = missing
    variance::M{Float64} = missing
    variance_reduction::M{Float64} = missing
    double_couple::M{Float64} = missing
    clvd::M{Float64} = missing
    iso::M{Float64} = missing
    greens_function_id::M{ResourceReference} = missing
    filter_id::M{ResourceReference} = missing
    source_time_function::M{SourceTimeFunction} = missing
    method_id::M{ResourceReference} = missing
    category::M{MomentTensorCategory} = missing
    inversion_type::M{MTInversionType} = missing
    creation_info::M{CreationInfo} = missing
    public_id::ResourceReference = random_reference()
end

"""
    FocalMechanism(; kwargs...)

Describes the focal mechanism of an event. It includes different
descriptions like nodal planes, principal axes, and a moment tensor.
The moment tensor description is provided by objects of the type
`MomentTensor` which can be specified as fields of `FocalMechanism`.

# List of fields
- `public_id :: ResourceReference`: Resource identifier of `FocalMechanism`.
  (**Required field.**)
- `triggering_origin_id :: ResourceReference`: Refers to the `public_id` of the triggering
  origin.
- `nodal_planes :: NodalPlanes`: Nodal planes of the focal mechanism.
- `principal_axes :: PrincipleAxes`: Principal axes of the focal mechanism.
- `azimuthal_gap :: Float64`: Largest azimuthal gap in distribution of stations
  used for determination of focal mechanism.  Unit: °.
- `station_polarity_count :: Int`: Number of station polarities used for
  determination of focal mechanism.
- `misfit :: Float64`: Fraction of misfit polarities in a first-motion focal
  mechanism determination. Decimal fraction between 0 and 1.
- `station_distribution_ratio :: Float64`: Station distribution ratio (STDR)
  parameter. Indicates how the stations are distributed about the
  focal sphere (Reasenberg and Oppenheimer 1985). Decimal fraction
  between 0 and 1.
- `method_id :: ResourceReference`: Resource identifier of the method used for determination
  of the focal mechanism.
- `waveform_id :: Vector{ResourceReference}`: Refers to a set of waveform streams from which the
  focal mechanism was derived.
- `evaluation_mode :: EvaluationMode`: Evaluation mode of `FocalMechanism` (see
  [`EvaluationMode`](@ref)).
- `evaluation_status :: EvaluationStatus`: Evaluation status of `FocalMechanism`
  (see [`EvaluationStatus`](@ref)).
- `comment :: Vector{Comment}`: Additional comments.
- `creation_info :: CreationInfo`: [`CreationInfo`](@ref QuakeML.CreationInfo) for the `FocalMechanism` object.
"""
@with_kw mutable struct FocalMechanism
    waveform_id::Vector{WaveformStreamID} = WaveformStreamID[]
    comment::Vector{Comment} = Comment[]
    moment_tensor::Vector{MomentTensor} = MomentTensor[]
    triggering_origin_id::M{ResourceReference} = missing
    nodal_planes::M{NodalPlanes} = missing
    principle_axes::M{PrincipleAxes} = missing
    azimuthal_gap::M{Float64} = missing
    station_polarity_count::M{Int} = missing
    misfit::M{Float64} = missing
    station_distribution_ratio::M{Float64} = missing
    method_id::M{ResourceReference} = missing
    evaluation_mode::M{EvaluationMode} = missing
    evaluation_status::M{EvaluationStatus} = missing
    creation_info::M{CreationInfo} = missing
    public_id::ResourceReference = random_reference()
end

"""
    Amplitude(; kwargs...)

Represents a quantification of the waveform anomaly, usually a single
amplitude measurement or a measurement of the visible signal duration
for duration magnitudes.

# List of fields
- `public_id :: ResourceReference`: Resource identifier of `Amplitude`.
  (**Required field.**)
- `genericAmplitude :: RealQuantity`: Measured amplitude value for the given
  `waveform_id`. Note that this attribute can describe different physical
  quantities, depending on the `type` and `category` of the amplitude.
  These can be, e.g., displacement, velocity, or a period. If the only
  amplitude information is a period, it has to specified here, not in the
  `period` field. The latter can be used if the amplitude measurement
  contains information on, e.g., displacement and an additional period.
  Since the physical quantity described by this attributeis not fixed,
  the unit of measurement cannot be defined in advance. However, the
  quantity has to be specified in SI base units. The enumeration given
  in the field `unit` provides the most likely units that could be needed
  here. For clarity, using the optional `unit` field is highly encouraged.
  (**Required field.**)
- `type :: String`: `String` that describes the type of amplitude using the
  nomenclature from Storchak et al. (2003). Possible values include
  unspecified amplitude reading (`"A"`), amplitude reading for local
  magnitude (`"AML"`), amplitude reading for body wave magnitude (`"AMB"`),
  amplitude reading for surface wave magnitude (`"AMS"`), and time of
  visible end of record for duration magnitude (`"END"`). It has a maximum
  length of 32 characters.
- `category :: AmplitudeCategory`: This field describes the way the waveform trace is evaluated
  to derive an amplitude value. This can be just reading a single value for
  a given point in time (`"point"`), taking a mean value over a time
  interval (`"mean"`), integrating the trace over a time interval
  (`"integral"`), specifying just a time interval (`"duration"`), or
  evaluating a period (`"period"`).  (See [`AmplitudeCategory`](@ref).)
  - `"point"`
  - `"mean"`
  - `"duration"`
  - `"period"`
  - `"integral"`
  - `"other"`
- `unit :: AmplitudeUnit`: This field provides the most likely measurement units for the
  physical quantity described in the `generic_Amplitude` field. Possible
  values are specified as combinations of SI base units.
  (See [`AmplitudeUnit`](@ref)
  - `"m"`
  - `"s:`
  - `"m/s"`
  - `"m/(s*s)"`
  - `"m*s"`
  - `"dimensionless"`
  - `"other"`
- `method_id :: ResourceReference`: Describes the method of amplitude determination.
- `period :: RealQuantity`: Dominant period in the `time_window` in case of amplitude
  measurements.  Not used for duration magnitude.  Unit: s.
- `snr :: Float64`: Signal-to-noise ratio of the spectrogram at the location the
  amplitude was measured.
- `time_window :: TimeWindow`: Description of the time window used for amplitude
  measurement. Recommended for duration magnitudes.
- `pick_id :: ResourceReference`: Refers to the `public_id` of an associated `Pick` object.
- `waveform_id :: ResourceReference`: Identifies the waveform stream on which the amplitude
  was measured.
- `filter_id :: ResourceReference`: Identifies the filter or filter setup used for filtering
  the waveform stream referenced by `waveform_id`.
- `scaling_time :: TimeQuantity`: Scaling time for amplitude measurement.
- `magnitude_hint :: String`: Type of magnitude the amplitude measurement is used
  for.  For valid values see [`Magnitude`](@ref QuakeML.Magnitude). String value with a
  maximum length of 32 characters.
- `evaluation_mode :: EvaluationMode`: Evaluation mode of `Amplitude` (see [`EvaluationMode`](@ref)).
- `evaluation_status :: EvaluationStatus`: Evaluation status of `Amplitude` (see
  [`EvaluationStatus`](@ref)).
- `comment :: Vector{Comment}`: Additional comments.
- `creation_info :: CreationInfo`: [`CreationInfo`](@ref QuakeML.CreationInfo) for the `Amplitude` object.
"""
@with_kw mutable struct Amplitude
    comment::Vector{Comment} = Comment[]
    generic_amplitude::RealQuantity
    type::M{String} = missing
    category::M{AmplitudeCategory} = missing
    unit::M{AmplitudeUnit} = missing
    method_id::M{ResourceReference} = missing
    period::M{RealQuantity} = missing
    snr::M{Float64} = missing
    time_window::M{TimeWindow} = missing
    pick_id::M{ResourceReference} = missing
    waveform_id::M{WaveformStreamID} = missing
    filter_id::M{ResourceReference} = missing
    scaling_time::M{TimeQuantity} = missing
    magnitude_hint::M{String} = missing
    evaluation_mode::M{EvaluationMode} = missing
    evaluation_status::M{EvaluationStatus} = missing
    creation_info::M{CreationInfo} = missing
    public_id::ResourceReference = random_reference()
    function Amplitude(comment, generic_amplitude, type, category, unit,
        method_id, period, snr, time_window, pick_id, waveform_id, filter_id,
        scaling_time, magnitude_hint, evaluation_mode, evaluation_status,
        creation_info, public_id)
        check_string_length("type", type, 32)
        check_string_length("magnitude_hint", magnitude_hint, 32)
        new(comment, generic_amplitude, type, category, unit,
        method_id, period, snr, time_window, pick_id, waveform_id, filter_id,
        scaling_time, magnitude_hint, evaluation_mode, evaluation_status,
        creation_info, public_id)
    end
end

function Base.setproperty!(amp::Amplitude, field::Symbol, value)
    if field === :type || field === :magnitude_hint
        check_string_length(String(field), value, 32)
    end
    type = fieldtype(Amplitude, field)
    setfield!(amp, field, convert(type, value))
end

"""
    StationMagnitudeContribution(; station_magnitude_id, residual, weight)

Describes the weighting of magnitude values froms everal
`StationMagnitude` objects for computing a network magnitude estimation.

# List of fields
- `stationMagnitudeID :: ResourceReference`: Refers to the `publicID` of a [`StationMagnitude`](@ref QuakeML.StationMagnitude)
  object.  (**Required field.**)
- `residual :: Float64`: Residual of magnitude computation.
- `weight :: Float64`: Weight of the magnitude value from [`StationMagnitude`](@ref QuakeML.StationMagnitude)
  for computing the magnitude value in [`Magnitude`](@ref).
  Note that there is no rule for the sum of the weights of all station
  magnitude contributions to a specific network magnitude. In particular,
  the weights are not required to sum up to unity.
"""
@with_kw mutable struct StationMagnitudeContribution
    station_magnitude_id::ResourceReference
    residual::M{Float64} = missing
    weight::M{Float64} = missing
end

"""
    Magnitude(; kwargs...)

Describes a magnitude which can, but does not need to be associated
with an origin. Association with an origin is expressed with the optional
field `origin_id`. It is either a combination of different magnitude
estimations, or it represents the reported magnitude for the given event.

# List of fields
- `public_id :: ResourceReference`: Resource identifier of `Magnitude`.
  (**Required field.**)
- `mag :: RealQuantity`: Resulting magnitude value from combining values of type
  `StationMagnitude`. If no estimations are available, this value can
  represent the reported magnitude.  (**Required field.**)
- `type :: String`: Describes the type of magnitude. This is a free-text field
  because it is impossible to cover all existing magnitude type designations
  with an enumeration. Possible values are unspecified magitude (`"M"`),
  local magnitude (`"ML"`), body wave magnitude (`"Mb"`), surface wave
  magnitude (`"MS"`), moment magnitude (`"Mw"`), duration magnitude (`"Md"`),
  coda magnitude (`"Mc"`), `"MH"`, `"Mwp"`, `"M50"`, `"M100"`, etc.
- `station_magnitude_contribution :: Vector{StationMagnitudeContribution}`:
  Set of [`StationMagnitudeContribution`](@ref QuakeML.StationMagnitudeContribution)s
  describing the contributions of each station used to compute the magnitude.
- `origin_id :: ResourceReference`: Reference to an origin’s `public_id` if the magnitude
  has an associated `Origin`.
- `method_id :: ResourceReference`: Identifies the method of magnitude estimation. Users
  should avoid giving contradictory information in `method_id` and `type`.
- `station_count` :: Int: Number of used stations for this magnitude computation.
- `azimuthal_gap :: Float64`: Azimuthal gap for this magnitude computation. Unit: °.
- `evaluation_mode :: EvaluationMode`: Evaluation mode of `Magnitude` (see [`EvaluationMode`](@ref)).
- `evaluation_status :: EvaluationStatus`: Evaluation status of `Magnitude` (see
  [`EvaluationStatus`](@ref)).
- `comment :: Vector{Comment}`: Additional comments.
- `creation_info :: CreationInfo`: [`CreationInfo`](@ref QuakeML.CreationInfo) for the `Magnitude` object.
"""
@with_kw mutable struct Magnitude
    comment::Vector{Comment} = Comment[]
    station_magnitude_contribution::Vector{StationMagnitudeContribution} = StationMagnitudeContribution[]
    mag::RealQuantity
    type::M{String} = missing
    origin_id::M{ResourceReference} = missing
    method_id::M{ResourceReference} = missing
    station_count::M{Int} = missing
    azimuthal_gap::M{Float64} = missing
    evaluation_mode::M{EvaluationMode} = missing
    evaluation_status::M{EvaluationStatus} = missing
    creation_info::M{CreationInfo} = missing
    public_id::ResourceReference = random_reference()
    function Magnitude(comment, station_magnitude_contribution, mag, type,
        origin_id, method_id, station_count, azimuthal_gap, evaluation_mode,
        evaluation_status, creation_info, public_id)
        check_string_length("type", type, 32)
        new(comment, station_magnitude_contribution, mag, type,
        origin_id, method_id, station_count, azimuthal_gap, evaluation_mode,
        evaluation_status, creation_info, public_id)
    end
end

function Base.setproperty!(mag::Magnitude, field::Symbol, value)
    if field === :type
        check_string_length("type", value, 32)
    end
    type = fieldtype(Magnitude, field)
    setfield!(mag, field, convert(type, value))
end

"""
    StationMagnitude(; kwargs...)

Describes the magnitude derived from a single waveform stream.

# List of fields
- `public_id :: ResourceReference`: Resource identifier of `StationMagnitude`.
  (**Required field.**)
- `origin_id :: ResourceReference`: Reference to an origin’s `public_id` if the
  `StationMagnitude` has an `associatedOrigin`.
- `mag :: RealQuantity`: Estimated magnitude.  (**Required field.**)
- `type :: String`: See [`Magnitude`](@ref QuakeML.Magnitude).
- `amplitude_id :: ResourceReference`: Identifies the data source of the `StationMagnitude`.
  For magnitudes derived from amplitudes in waveforms (e. g., local
  magnitude ML), `amplitude_id` points to `public_id` in [`Amplitude`](@ref QuakeML.Amplitude).
- `method_id :: ResourceReference`: See [`Magnitude`](@ref QuakeML.Magnitude).
- `waveform_id :: ResourceReference`: Identifies the waveform stream. This element can be
  helpful if no amplitude is referenced, or the amplitude is not
  available in the context. Otherwise, it would duplicate the
  `waveform_id` provided there and can be omitted.
- `comment :: Vector{Comment}`: Additional comments.
- `creationInfo :: CreationInfo`: [`CreationInfo`](@ref QuakeML.CreationInfo) for the `StationMagnitude` object.
"""
@with_kw mutable struct StationMagnitude
    comment::Vector{Comment} = Comment[]
    mag::RealQuantity
    type::M{String} = missing
    origin_id::M{ResourceReference} = missing
    method_id::M{ResourceReference} = missing
    creation_info::M{CreationInfo} = missing
    public_id::ResourceReference = random_reference()
    function StationMagnitude(comment,  mag, type,
        origin_id, method_id, creation_info, public_id)
        check_string_length("type", type, 32)
        new(comment, mag, type, origin_id, method_id, creation_info, public_id)
    end
end

function Base.setproperty!(stamag::StationMagnitude, field::Symbol, value)
    if field === :type
        check_string_length(String(field), value, 32)
    end
    type = fieldtype(StationMagnitude, field)
    setfield!(stamag, field, convert(type, value))
end

"""
    OriginUncertainty(; kwargs...)

Describes the location uncertainties of an origin. The uncertainty can
be described either as a simple circular horizontal uncertainty, an
uncertainty ellipse according to IMS1.0, or a confidence ellipsoid.
If multiple uncertainty models are given, the preferred variant can be
specified in the field `preferred_description`.

# List of fields
- `horizontal_uncertainty :: Float64`: Circular confidence region, given by single
  value of horizontal uncertainty.  Unit: m.
- `min_horizontal_uncertainty :: Float64`: Semi-minor axis of confidence ellipse.
  Unit: m.
- `max_horizontal_uncertainty :: Float64`: Semi-major axis of confidence ellipse.
  Unit: m.
- `azimuth_max_horizontal_uncertainty :: Float64`: Azimuth of major axis of confidence
  ellipse. Measured clockwise from south-north direction at epicenter.
  Unit: °.
- `confidence_ellipsoid :: ConfidenceEllipsoid`: Confidence ellipsoid (see [`ConfidenceEllipsoid`](@ref QuakeML.ConfidenceEllipsoid)).
- `preferred_description :: OriginUncertaintyDescription`: Preferred uncertainty description. Allowed
  values are the following (see [`OriginUncertaintyDescription`](@ref):
  - `"horizontal uncertainty"`
  - `"uncertainty ellipse"`
  - `"confidence ellipsoid"`
- `confidence_level :: Float64`: Confidence level of the uncertainty, given in
  percent.
"""
@with_kw mutable struct OriginUncertainty
    horizontal_uncertainty::M{Float64} = missing
    min_horizontal_uncertainty::M{Float64} = missing
    max_horizontal_uncertainty::M{Float64} = missing
    azimuth_max_horizontal_uncertainty::M{Float64} = missing
    confidence_ellipsoid::M{ConfidenceEllipsoid} = missing
    preferred_description::M{OriginUncertaintyDescription} = missing
    confidence_level::M{Float64} = missing
end

"""
    Arrival(; kwargs...)

Successful association of a pick with an origin qualifies this pick as
an arrival. An arrival thus connects a pick with an origin and provides
additional attributes that describe this relationship. Usually
qualification of a pick as an arrival for a given origin is a
hypothesis, which is based on assumptions about the type of arrival
(phase) as well as observed and (on the basis of an earth model)
computed arrival times, or the residual, respectively. Additional pick
attributes like the horizontal slowness and backazimuth of the observed
wave—especially if derived from array data—may further constrain the
nature of the arrival.

# List of fields
- `public_id :: ResourceReference`: Resource identifier of `Arrival`.
  (**Required field.**)
- `pick_id :: ResourceReference`: Refers to a `public_id` of a [`Pick`](@ref QuakeML.Pick).
  (**Required field.**)
- `phase :: Phase`: Phase identification. For possible values, please refer to the
  description of the [`Phase`](@ref QuakeML.Phase) type.  (**Required field.**)
- `time_correction :: Float64`: Time correction value. Usually, a value characteristic
  for the station at which the pick was detected, sometimes also characteristic
  for the phase type or the slowness. Unit: s.
- `azimuth :: Float64`: Azimuth of station as seen from the epicenter. Unit: °.
- `distance :: Float64`: Epicentral distance.  Unit: °.
- `takeoff_angle :: RealQuantity`: Angle of emerging ray at the source, measured against
  the downward normal direction.  Unit: °.
- `time_residual :: Float64`: Residual between observed and expected arrival time
  assuming proper phase identification and given the `earth_model_id` of
  the `Origin`, taking into account the `timeCorrection`.  Unit: s.
- `horizontal_slowness_residual :: Float64`: Residual of horizontal slowness and
  the expected slowness given the current origin (refers to field
  `horizontal_slowness` of [`Pick`](@ref QuakeML.Pick)).  Unit: s/°
- `backazimuthResidual :: Float64`: Residual of backazimuth and the backazimuth
  computed for the current origin (refers to field `backazimuth` of
  [`Pick`](@ref QuakeML.Pick)).  Unit: °.
- `time_weight :: Float64`: Weight of the arrival time for computation of the associated
  `Origin`. Note that the sum of all weights is not required to be unity.
- `horizontal_slowness_weight :: Float64`: Weight of the horizontal slowness for
  computation of the associated `Origin`. Note that the sum of all
  weights is not required to be unity.
- `backazimuth_weight :: Float64`: Weight of the backazimuth for computation of the
  associated `Origin`. Note that the sum of all weights is not required
  to be unity.
- `earth_model_id :: ResourceReference`: Earth model which is used for the association of
  `Arrival` to `Pick` and computation of the residuals.
- `comment :: Vector{Comment}`: Additional comments.
- `creation_info :: CreationInfo`: [`CreationInfo`](@ref QuakeML.CreationInfo) for the `Arrival` object
"""
@with_kw mutable struct Arrival
    comment::Vector{Comment} = Comment[]
    pick_id::ResourceReference
    phase::Phase
    time_correction::M{Float64} = missing
    azimuth::M{Float64} = missing
    distance::M{Float64} = missing
    takeoff_angle::M{RealQuantity} = missing
    time_residual::M{Float64} = missing
    horizontal_slowness_residual::M{Float64} = missing
    backazimuth_residual::M{Float64} = missing
    time_weight::M{Float64} = missing
    horizontal_slowness_weight::M{Float64} = missing
    backazimuth_weight::M{Float64} = missing
    earth_model_id::M{ResourceReference} = missing
    creation_info::M{CreationInfo} = missing
    public_id::ResourceReference = random_reference()
end

"""
    Origin(; kwargs...)

Represents the focal time and geographical location of an earthquake
hypocenter, as well as additional meta-information.  `Origin` can have
objects of type `OriginUncertainty` and `Arrival` as fields.

# List of fields
- `public_id :: ResourceReference`: Resource identifier of `Origin`.
  (**Required field.**)
- `time`: Focal time.  (**Required field.**)
- `longitude :: RealQuantity`: Hypocenter longitude, with respect to the World Geodetic
  System 1984 (WGS84) reference system (National Imagery and Mapping
  Agency 2000).  Unit: °.  (**Required field.**)
- `latitude :: RealQuantity`: Hypocenter latitude, with respect to the WGS84 reference
  system. Unit: °.  (**Required field.**)
- `depth :: RealQuantity`: Depth of hypocenter with respect to the nominal sea level
  given by the WGS84 geoid (Earth Gravitational Model, EGM96, Lemoine
  et al. 1998). Positive values indicate hypocenters below sea level.
  For shallow hypocenters, the `depth` value can be negative. Note:
  Other standards use different conventions for depth measurement.
  As an example, GSE 2.0, defines depth with respect to the local
  surface. If event data is converted from other formats to QuakeML,
  depth values may have to be modified accordingly.  Unit: m.
- `depth_type :: OriginDepthType`: Type of depth determination. Allowed values are the following
  (see [`OriginDepthType`](@ref)):
  - `"from location"`
  - `"from moment tensor inversion",`
  - `"from modeling of broad-band P waveforms"`
  - `"constrained by depth phases",`
  - `"constrained by direct phases"`
  - `"constrained by depth and direct phases",`
  - `"operator assigned"`
  - `"other"`
- `time_fixed :: Bool`: Boolean flag. `true` if focal time was kept fixed for
  computation of the `Origin`.
- `epicenter_fixed :: Bool`: Boolean flag. `true` if epicenter was kept fixed
  for computationof `Origin`.
- `reference_system_id :: ResourceReference`: Identifies the reference system used for
  hypocenter determination. This is only necessary if a modified version
  of the standard (with local extensions) is used that provides a
  non-standard coordinate system.
- `method_id :: ResourceReference`: Identifies the method used for locating the event.
- `earth_model_id :: ResourceReference`: Identifies the earth model used in `methodID`.
- `composite_time :: CompositeTime`: Supplementary information on time of rupture start.
  Complex descriptions of focal times of historic events are possible,
  see description of the [`CompositeTime`](@ref QuakeML.CompositeTime) type.
  Note that even if `composite_time` is used, the mandatory `time` field
  has to be set too.
  It has to be set to the single point in time (with uncertainties allowed)
  that is most characteristic for the event.
- `quality :: OriginQuality`: Additional parameters describing the quality of an `Origin`
  determination.
- `type :: OriginType`: Describes the `Origin` type. Allowed values are the following
  (see [`OriginType`](@ref QuakeML.OriginType)):
  - `"hypocenter"`
  - `"centroid"`
  - `"amplitude"`
  - `"macroseismic"`
  - `"rupture start"`
  - `"rupture end"`
- `region :: String`: Can be used to decribe the geographical region of the
  epicenter location. Useful if an event has multiple origins from
  different agencies, and these have different region designations.
  Note that an event-wide region can be defined in the `description`
  field of an [`Event`](@ref QuakeML.Event) object. The user has to take care
  that this information corresponds to the region attribute of the preferred
  `Origin`. String with maximum length of 255 chars.
- `evaluation_mode :: EvaluationMode`: Evaluation mode of `Origin` (see [`EvaluationMode`](@ref QuakeML.EvaluationMode).
- `evaluation_status :: EvaluationStatus`: Evaluation status of `Origin` (see [`EvaluationStatus`](@ref QuakeML.EvaluationStatus)).
- `comment :: Vector{Comment}`: Additional comments.
- `creation_info :: CreationInfo`: [`CreationInfo`](@ref QuakeML.CreationInfo) for the `Origin` object.
"""
@with_kw mutable struct Origin
    composite_time::Vector{CompositeTime} = CompositeTime[]
    comment::Vector{Comment} = Comment[]
    origin_uncertainty::Vector{OriginUncertainty} = OriginUncertainty[]
    arrival::Vector{Arrival} = Arrival[]
    time::TimeQuantity
    longitude::RealQuantity
    latitude::RealQuantity
    depth::M{RealQuantity} = missing
    depth_type::M{OriginDepthType} = missing
    time_fixed::M{Bool} = missing
    epicenter_fixed::M{Bool} = missing
    reference_system_id::M{ResourceReference} = missing
    method_id::M{ResourceReference} = missing
    earth_model_id::M{ResourceReference} = missing
    quality::M{OriginQuality} = missing
    type::M{OriginType} = missing
    region::M{String} = missing
    evaluation_mode::M{EvaluationMode} = missing
    evaluation_status::M{EvaluationStatus} = missing
    creation_info::M{CreationInfo} = missing
    public_id::ResourceReference = random_reference()
    function Origin(composite_time, comment, origin_uncertainty, arrival, time,
        longitude, latitude, depth, depth_type, time_fixed, epicenter_fixed,
        reference_system_id, method_id, earth_model_id, quality, type, region,
        evaluation_mode, evaluation_status, creation_info, public_id)
        check_string_length("region", region, 128)
        new(composite_time, comment, origin_uncertainty, arrival, time,
        longitude, latitude, depth, depth_type, time_fixed, epicenter_fixed,
        reference_system_id, method_id, earth_model_id, quality, type, region,
        evaluation_mode, evaluation_status, creation_info, public_id)
    end
end

function Base.setproperty!(origin::Origin, field::Symbol, value)
    if field === :region
        check_string_length("region", value, 128)
    end
    type = fieldtype(Origin, field)
    setfield!(origin, field, convert(type, value))
end

"""
    Pick(; kwargs...)

A pick is the observation of an amplitude anomaly in a seismogram at a
specific point in time.  It is notnecessarily related to a seismic event.

# List of fields
- `public_id :: ResourceReference`: Resource identifier of `Pick`.  (**Required field.**)
- `time :: TimeQuantity`: Observed onset time of signal (“pick time”).  (**Required field.**)
- `waveform_id :: ResourceReference`: Identifes the waveform stream.
  (**Required field.**)
- `filter_id :: ResourceReference`: Identifies the filter or filter setup used for filtering
  the waveform stream referenced by `waveform_id`.
- `method_id :: ResourceReference`: Identifies the picker that produced the pick. This can be
  either a detection software program or aperson.
- `horizontal_slowness :: RealQuantity`: Observed horizontal slowness of the signal. Most
  relevant in array measurements.  Unit: s/°.
- `backazimuth :: RealQuantity`: Observed backazimuth of the signal. Most relevant in
  array measurements.  Unit: °.
- `slowness_method_id :: ResourceReference`: Identifies the method that was used to determine
  the slowness.
- `onset :: PickOnset`: Flag that roughly categorizes the sharpness of the onset.
  Allowed values are (see [`PickOnset`](@ref QuakeML.PickOnset)):
  - `"impulsive"`
  - `"emergent"`
  - `"questionable"`
- `phase_hint :: Phase`: Tentative phase identification as specified by the picker.
- `polarity :: PickPolarity`: Indicates the polarity of first motion, usually from impulsive
  onsets. Allowed values are (see [`PickPolarity`](@ref)):
  - `"positive"`
  - `"negative"`
  - `"undecidable"`
- `evaluation_mode :: EvaluationMode`: Evaluation mode of `Pick` (see [`EvaluationMode`](@ref QuakeML.EvaluationMode)).
- `evaluation_status :: EvaluationStatus`: Evaluation status of `Pick` (see [`EvaluationStatus`](@ref QuakeML.EvaluationStatus)).
- `comment :: Vector{Comment}`: Additional comments.
- `creation_info :: CreationInfo`: [`CreationInfo`](@ref QuakeML.CreationInfo) for the `Pick` object.
"""
@with_kw mutable struct Pick
    comment::Vector{Comment} = Comment[]
    time::TimeQuantity
    waveform_id::WaveformStreamID
    filter_id::M{ResourceReference} = missing
    method_id::M{ResourceReference} = missing
    horizontal_slowness::M{RealQuantity} = missing
    backazimuth::M{RealQuantity} = missing
    slowness_method_id::M{ResourceReference} = missing
    onset::M{PickOnset} = missing
    phase_hint::M{Phase} = missing
    polarity::M{PickPolarity} = missing
    evaluation_mode::M{EvaluationMode} = missing
    evaluation_status::M{EvaluationStatus} = missing
    creation_info::M{CreationInfo} = missing
    public_id::ResourceReference = random_reference()
end

"""
    Event(; kwargs...)

Describes a seismic event which does not necessarily need to be a
tectonic earthquake. An event is usually associated with one or more
origins, which contain information about focal time and geographic
allocation of the event. Multiple origins can cover automatic and
manual locations, a set of location from different agencies, locations
generated with different location programs and earth models, etc.
Furthermore, an eventis usually associated with one or more magnitudes,
and with one or more focal mechanism determinations. In
standard QuakeML-BED, `Origin`, `Magnitude`, `StationMagnitude`, and
`FocalMechanism` are fields of `Event`. In BED-RT (the real-time version)
all these fields are on the same hierarchy level as child elements of
`EventParameters`.  The association of origins, magnitudes, and focal
mechanisms to a particular event is expressed using references inside `Event`.

# List of fields
- `public_id :: ResourceReference`: Resource identifier of `Event`.
  (**Required field.**)
- `preferred_origin_id :: ResourceReference`: Refers to the `public_id` of the
  `preferred_origin` object.
- `preferred_magnitude_id :: ResourceReference`: Refers to the `public_id` of the
  `preferred_magnitude` object.
- `preferred_focal_mechanism_id :: ResourceReference`: Refers to the `public_id`of the
  `preferred_focal_mechanism` object.
- `type :: EventType`: Describes the type of an event (Storchak et al. 2012).
  Allowed values are the following (see [`EventType`](@ref)):
  - `"not existing"`
  - `"not reported"`
  - `"earthquake"`
  - `"anthropogenic event"`
  - `"collapse"`
  - `"cavity collapse"`
  - `"mine collapse"`
  - `"building collapse"`
  - `"explosion"`
  - `"accidental explosion"`
  - `"chemical explosion"`
  - `"controlled explosion"`
  - `"experimental explosion"`
  - `"industrial explosion"`
  - `"mining explosion"`
  - `"quarry blast"`
  - `"road cut"`
  - `"blasting levee"`
  - `"nuclear explosion"`
  - `"induced or triggered event"`
  - `"rock burst"`
  - `"reservoir loading"`
  - `"fluid injection"`
  - `"fluid extraction"`
  - `"crash"`
  - `"plane crash"`
  - `"train crash"`
  - `"boat crash"`
  - `"other event"`
  - `"atmospheric event"`
  - `"sonic boom"`
  - `"sonic blast"`
  - `"acoustic noise"`
  - `"thunder"`
  - `"avalanche"`
  - `"snow avalanche"`
  - `"debris avalanche"`
  - `"hydroacoustic event"`
  - `"ice quake"`
  - `"slide"`
  - `"landslide"`
  - `"rockslide"`
  - `"meteorite"`
  - `"volcanic eruption"`
- `type_certainty :: EventTypeCertainty`: Denotes how certain the information on event type is
  (Storchak et al. 2012). Allowed values are the following 
  (see [`EventTypeCertainty`](@ref)):
  - `"known"`
  - `"suspected"`
- `description :: Vector{EventDescription}` Additional event description, like earthquake name,
  Flinn-Engdahl region, etc.
- `comment :: Vector{Comment}`: Comments.
- `creation_info :: CreationInfo`: `CreationInfo` for the `Event` object.
- `origin :: Vector{Event}`: Set of [`Origin`](@ref QuakeML.Event)s associated
  with this `Event`.  One of these may be the preferred origin, in which case
  preferred_origin_id` should be set.
- `magnitude :: Vector{Magnitude}`: Set of [`Magnitude`](@ref QuakeML.Magnitude)s
  for this `Event`.  One of these may be the preferred magnitude, in which case
  `preferred_magnitude_id` should be set.
- `station_magnitude :: Vector{StationMagnitude}`: Set of
  [`StationMagnitude`](@ref QuakeML.StationMagnitude)s contributing to the
  magnitude of this event.
- `focal_mechanism :: Vector{FocalMechanism}`: Set of
  [`FocalMechanism`](@ref QuakeML.FocalMechanism)s for this event.  One of these
  may be the preferred focal mechanism, in which case `preferred_focal_mechanism_id`
  should be set.
- `pick :: Vector{Pick}`: Set of [`Pick`](@ref QuakeML.Pick)s made from this
  event.
- `amplitude :: Vector{Amplitude}`: Set of [`Amplitude`](@ref QuakeML.Amplitude)s
  measured at stations from this event.


(Note: The additional real-time fields `origin_reference`,
`magnitude_reference` and `focal_mechanism_reference` are not
yet implemented.)
"""
@with_kw mutable struct Event
    description::Vector{EventDescription} = EventDescription[]
    comment::Vector{Comment} = Comment[]
    focal_mechanism::Vector{FocalMechanism} = FocalMechanism[]
    amplitude::Vector{Amplitude} = Amplitude[]
    magnitude::Vector{Magnitude} = Magnitude[]
    station_magnitude::Vector{StationMagnitude} = StationMagnitude[]
    origin::Vector{Origin} = Origin[]
    pick::Vector{Pick} = Pick[]
    preferred_origin_id::M{ResourceReference} = missing
    preferred_magnitude_id::M{ResourceReference} = missing
    preferred_focal_mechanism_id::M{ResourceReference} = missing
    type::M{EventType} = missing
    type_certainty::M{EventTypeCertainty} = missing
    creation_info::M{CreationInfo} = missing
    public_id::ResourceReference = random_reference()
end

"""
    EventParameters(; comment, event, description, creation_info, public_id)

Root type of QuakeML.  `EventParameters` objects contain a set of events
and a QuakeML XML file can contain only one `EventParameters` object.

In the bulletin-type (non real-time) model, this type serves as a
container for `Event` objects. In the real-time version, it can hold
objects of type `Event`, `Origin`, `Magnitude`, `StationMagnitude`,
`FocalMechanism`, `Reading`, `Amplitude`, and `Pick`.

# List of fields
- `event :: Vector{Event}`: Set of [`Event`](@ref QuakeML.Event)s making up
  a catalog or collection of events.
- `description :: String`: Description string that can be assigned to the earthquake
  catalog, or collection of events.
- `comment :: Vector{Comment}`: Additional comments.
- `creation_info :: CreationInfo`: [`CreationInfo`](@ref QuakeML.CreationInfo) for the earthquake catalog.
- `public_id :: ResourceReference`: Resource identifier of `EventParameters`.
  (**Required field.**)

!!! note
    At present, QuakeML.jl only supports the non-real-time version of QuakeML.
"""
@with_kw mutable struct EventParameters
    comment::Vector{Comment} = Comment[]
    event::Vector{Event} = Event[]
    description::M{String} = missing
    creation_info::M{CreationInfo} = missing
    public_id::ResourceReference = random_reference()
end

"""
    is_attribute_field(T, field) -> ::Bool

Return `true` if `field` is an attribute of the type `T`, and
`false` otherwise.  Other fields are assumed to be elements.
"""
is_attribute_field(::Type, field) where T = field === :public_id
is_attribute_field(::Type{Comment}, field) = field === :id
is_attribute_field(::Type{NodalPlanes}, field) = field === :preferred_plane
is_attribute_field(::Type{WaveformStreamID}, field) =
    any(x -> x === field, attribute_fields(WaveformStreamID))

"""
    has_attributes(T) -> ::Bool

Return `true` if the type `T` has fields which are contained
in QuakeML documents as attributes rather than elements.
"""
has_attributes(::Union{Type{Comment}, Type{NodalPlanes}, Type{WaveformStreamID}}) = true
has_attributes(T::Type) = hasfield(T, :public_id)

"""
    attribute_fields(T::Type) -> (:a, :b, ...)

Return a tuple of `Symbol`s giving the names of the fields of
type `T` which are contained in QuakeML documents as attributes
rather than elements.
"""
attribute_fields(T::Type) = hasfield(T, :public_id) ? (:public_id,) : ()
attribute_fields(::Type{Comment}) = (:id,)
attribute_fields(::Type{NodalPlanes}) = (:preferred_plane,)
attribute_fields(::Type{WaveformStreamID}) = (:network_code, :station_code,
    :location_code, :channel_code)

"Types which should be compared using Base.=="
const COMPARABLE_TYPES = Union{Missing, Float64, String, DateTime, Bool}

for T in (:EventParameters, :RealQuantity, :IntegerQuantity, :TimeQuantity, :DataUsed)
    @eval Base.:(==)(a::T, b::T) where T <: $(T) = a === b ? true : local_equals(a, b)
end

"""Local function to compare all types by each of their fields, apart from the types from
Base we use."""
function local_equals(a::COMPARABLE_TYPES, b::COMPARABLE_TYPES)
    a === missing && b === missing && return true
    a == b
end
function local_equals(a::T1, b::T2) where {T1,T2}
    T1 == T2 ? all(local_equals(getfield(a, f), getfield(b, f)) for f in fieldnames(T1)) : false
end
local_equals(a::AbstractArray, b::AbstractArray) =
    size(a) == size(b) && all(local_equals(aa, bb) for (aa, bb) in zip(a,b))
