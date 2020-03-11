# Definition of types as per the QuakeML schema

using Base: @kwdef

# Shorthand for single values which may or may not be present once,
# equivalent to `minOccurs="1" maxOccurs="1"` in the schema.
const M{T} = Union{Missing,T}

@kwdef struct RealQuantity
    value::Float64
    uncertainty::M{Float64} = missing
    lower_uncertainty::M{Float64} = missing
    upper_uncertainty::M{Float64} = missing
    confidence_level::M{Float64} = missing
end

@kwdef struct IntegerQuanitity
    value::Int
    uncertainty::M{Int} = missing
    lower_uncertainty::M{Int} = missing
    upper_uncertainty::M{Int} = missing
    confidence_level::M{Float64} = missing
end

@kwdef struct ResourceIdentifier
    uri::String
    function ResourceIdentifier(uri)
        occursin(r"(smi|quakeml):[\w\d][\w\d\-\.\*\(\)_~']{2,}/[\w\d\-\.\*\(\)_~'][\w\d\-\.\*\(\)\+\?_~'=,;#/&amp;]*",
            uri) || throw(ArgumentError("ResourceIdentifier '$uri' is not valid URI"))
        new(uri)
    end
end

@kwdef struct WhitespaceOrEmptyString
    value::String
    WhitespaceOrEmptyString(value) = (occursin(r"\s*", value) ||
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

@kwdef struct TimeQuantity
    value::DateTime
    uncertainty::M{Float64} = missing
    lower_uncertainty::M{Float64} = missing
    upper_uncertainty::M{Float64} = missing
    confidence_level::M{Float64} = missing
end

@kwdef struct CreationInfo
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

@kwdef struct EventDescription
    text::String
    type::M{EventDescriptionType} = missing
end

@kwdef struct Phase
    value::String
end

@kwdef struct Comment
    text::String
    creation_info::M{CreationInfo} = missing
    id::M{ResourceReference} = missing
end

@kwdef struct Axis
    azimuth::RealQuantity
    plunge::RealQuantity
    length::RealQuantity
end

@kwdef struct PrincipleAxes
    t_axis::Axis
    p_axis::Axis
    n_axis::M{Axis} = missing
end

@kwdef struct DataUsed
    wave_type::DataUsedWaveType
    station_count::M{Int} = missing
    component_cound::M{Int} = missing
    shortest_period::M{Float64} = missing
    longest_period::M{Float64} = missing
end

@kwdef struct CompositeTime
    year::M{IntegerQuanitity} = missing
    month::M{IntegerQuanitity} = missing
    day::M{IntegerQuanitity} = missing
    hour::M{IntegerQuanitity} = missing
    minute::M{IntegerQuanitity} = missing
    second::M{RealQuantity} = missing
end

@kwdef struct Tensor
    m_rr::RealQuantity
    m_tt::RealQuantity
    m_pp::RealQuantity
    m_rt::RealQuantity
    m_rp::RealQuantity
    m_tp::RealQuantity
end

@kwdef struct OriginQuality
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

@kwdef struct NodalPlane
    strike::RealQuantity
    dip::RealQuantity
    rake::RealQuantity
end

@kwdef struct TimeWindow
    begin_::Float64
    end_::Float64
    reference::DateTime
end

@kwdef struct WaveformStreamID
    uri::M{String} = missing
    network_code::String
    station_code::String
    channel_code::String
    location_code::String
    function WaveformStreamID(uri, net, sta, cha, loc)
        check_string_length("network_code", net, 8)
        check_string_length("station_code", sta, 8)
        check_string_length("channel_code", cha, 8)
        check_string_length("location_code", loc, 8)
        new(uri, net, sta, cha, loc)
    end
end

@kwdef struct SourceTimeFunction
    type::SourceTimeFunctionType
    duration::Float64
    rise_time::M{Float64} = missing
    decay_time::M{Float64} = missing
end

@kwdef struct NodalPlanes
    nodal_plane1::M{NodalPlane} = missing
    nodal_plane2::M{NodalPlane} = missing
    preferred_plane::Int
end

@kwdef struct ConfidenceEllipsoid
    semi_major_axis_length::Float64
    semi_minor_axis_length::Float64
    semi_intermediate_axis_length::Float64
    major_axis_plunge::Float64
    major_axis_azimuth::Float64
    major_axis_rotation::Float64
end

@kwdef struct MomentTensor
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
    public_id::ResourceReference
end

@kwdef struct FocalMechanism
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
    public_id::ResourceReference
end

@kwdef struct Amplitude
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
    public_id::ResourceReference
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

@kwdef struct StationMagnitudeContribution
    station_magnitude_id::ResourceReference
    residual::M{Float64} = missing
    weight::M{Float64} = missing
end

@kwdef struct Magnitude
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
    public_id::ResourceReference
    function Magnitude(comment, station_magnitude_contribution, mag, type,
        origin_id, method_id, station_count, azimuthal_gap, evaluation_mode,
        evaluation_status, creation_info, public_id)
        check_string_length("type", type, 32)
        new(comment, station_magnitude_contribution, mag, type,
        origin_id, method_id, station_count, azimuthal_gap, evaluation_mode,
        evaluation_status, creation_info, public_id)
    end
end

@kwdef struct StationMagnitude
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
    public_id::ResourceReference
    function StationMagnitude(comment, station_magnitude_contribution, mag, type,
        origin_id, method_id, station_count, azimuthal_gap, evaluation_mode,
        evaluation_status, creation_info, public_id)
        check_string_length("type", type, 32)
        new(comment, station_magnitude_contribution, mag, type,
        origin_id, method_id, station_count, azimuthal_gap, evaluation_mode,
        evaluation_status, creation_info, public_id)
    end
end

@kwdef struct OriginUncertainty
    horizontal_uncertainty::M{Float64} = missing
    min_horizontal_uncertainty::M{Float64} = missing
    max_horizontal_uncertainty::M{Float64} = missing
    azimuth_horizontal_uncertainty::M{Float64} = missing
    confidence_ellipsoid::M{ConfidenceEllipsoid} = missing
    preferred_description::M{OriginUncertaintyDescription} = missing
    confidence_level::M{Float64} = missing
end

@kwdef struct Arrival
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
    public_id::ResourceReference
end

@kwdef struct Origin
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
    public_id::ResourceReference
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

@kwdef struct Pick
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
    public_id::ResourceReference
end

@kwdef struct Event
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
    public_id::ResourceReference
end

@kwdef struct EventParameters
    comment::Vector{Comment} = Comment[]
    event::Vector{Event} = Event[]
    description::M{String} = missing
    creation_info::M{CreationInfo} = missing
    public_id::ResourceReference
end
