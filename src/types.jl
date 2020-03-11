# Definition of types as per the QuakeML schema

# Shorthand for single values which may or may not be present once,
# equivalent to `minOccurs="1" maxOccurs="1"` in the schema.
const M{T} = Union{Missing,T}

struct RealQuantity
    value::Float64
    uncertainty::M{Float64}
    lower_uncertainty::M{Float64}
    upper_uncertainty::M{Float64}
    confidence_level::M{Float64}
end

struct IntegerQuanitity
    value::Int
    uncertainty::M{Int}
    lower_uncertainty::M{Int}
    upper_uncertainty::M{Int}
    confidence_level::M{Float64}
end

struct ResourceIdentifier
    uri::String
    function ResourceIdentifier(uri)
        occursin(r"(smi|quakeml):[\w\d][\w\d\-\.\*\(\)_~']{2,}/[\w\d\-\.\*\(\)_~'][\w\d\-\.\*\(\)\+\?_~'=,;#/&amp;]*",
            uri) || throw(ArgumentError("ResourceIdentifier '$uri' is not valid URI"))
        new(uri)
    end
end

struct WhitespaceOrEmptyString
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

struct TimeQuantity
    value::DateTime
    uncertainty::M{Float64}
    lower_uncertainty::M{Float64}
    upper_uncertainty::M{Float64}
    confidence_level::M{Float64}
end

struct CreationInfo
    agency_id::M{String}
    agency_uri::M{ResourceReference}
    author::M{String}
    author_uri::M{ResourceReference}
    creation_time::M{DateTime}
    version::M{String}
    function CreationInfo(agency_id, agency_uri, author, author_uri, creation_time, version)
        check_string_length("agency_id", agency_id, 64)
        check_string_length("author", author, 128)
        check_string_length("version", version, 64)
        new(agency_id, agency_uri, author, author_uri, creation_time, version)
    end
end

struct EventDescription
    text::String
    type::M{EventDescriptionType}
end

struct Phase
    value::String
end

struct Comment
    text::String
    creation_info::M{CreationInfo}
    id::M{ResourceReference}
end

struct Axis
    azimuth::RealQuantity
    plunge::RealQuantity
    length::RealQuantity
end

struct PrincipleAxes
    t_axis::Axis
    p_axis::Axis
    n_axis::M{Axis}
end

struct DataUsed
    wave_type::DataUsedWaveType
    station_count::M{Int}
    component_cound::M{Int}
    shortest_period::M{Float64}
    longest_period::M{Float64}
end

struct CompositeTime
    year::M{IntegerQuanitity}
    month::M{IntegerQuanitity}
    day::M{IntegerQuanitity}
    hour::M{IntegerQuanitity}
    minute::M{IntegerQuanitity}
    second::M{RealQuantity}
end

struct Tensor
    m_rr::RealQuantity
    m_tt::RealQuantity
    m_pp::RealQuantity
    m_rt::RealQuantity
    m_rp::RealQuantity
    m_tp::RealQuantity
end

struct OriginQuality
    associated_phase_count::M{Int}
    used_phase_count::M{Int}
    associated_station_count::M{Int}
    used_station_count::M{Int}
    depth_phase_count::M{Int}
    standard_error::M{Float64}
    azimuthal_gap::M{Float64}
    secondary_azimuthal_gap::M{Float64}
    ground_truth_level::M{String}
    maximum_distance::M{Float64}
    minimum_distance::M{Float64}
    median_distance::M{Float64}
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

struct NodalPlane
    strike::RealQuantity
    dip::RealQuantity
    rake::RealQuantity
end

struct TimeWindow
    begin_::Float64
    end_::Float64
    reference::DateTime
end

struct WaveformStreamID
    uri::M{String}
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

struct SourceTimeFunction
    type::SourceTimeFunctionType
    duration::Float64
    rise_time::M{Float64}
    decay_time::M{Float64}
end

struct NodalPlanes
    nodal_plane1::M{NodalPlane}
    nodal_plane2::M{NodalPlane}
    preferred_plane::Int
end

struct ConfidenceEllipsoid
    semi_major_axis_length::Float64
    semi_minor_axis_length::Float64
    semi_intermediate_axis_length::Float64
    major_axis_plunge::Float64
    major_axis_azimuth::Float64
    major_axis_rotation::Float64
end

struct MomentTensor
    data_used::Vector{DataUsed}
    comment::Vector{Comment}
    derived_origin_id::ResourceReference
    moment_magnitude_id::M{ResourceReference}
    scalar_moment::M{RealQuantity}
    tensor::M{Tensor}
    variance::M{Float64}
    variance_reduction::M{Float64}
    double_couple::M{Float64}
    clvd::M{Float64}
    iso::M{Float64}
    greens_function_id::M{ResourceReference}
    filter_id::M{ResourceReference}
    source_time_function::M{SourceTimeFunction}
    method_id::M{ResourceReference}
    category::M{MomentTensorCategory}
    inversion_type::M{MTInversionType}
    creation_info::M{CreationInfo}
    public_id::ResourceReference
end

struct FocalMechanism
    waveform_id::Vector{WaveformStreamID}
    comment::Vector{Comment}
    moment_tensor::Vector{MomentTensor}
    triggering_origin_id::M{ResourceReference}
    nodal_planes::M{NodalPlanes}
    principle_axes::M{PrincipleAxes}
    azimuthal_gap::M{Float64}
    station_polarity_count::M{Int}
    misfit::M{Float64}
    station_distribution_ratio::M{Float64}
    method_id::M{ResourceReference}
    evaluation_mode::M{EvaluationMode}
    evaluation_status::M{EvaluationStatus}
    creation_info::M{CreationInfo}
    public_id::ResourceReference
end

struct Amplitude
    comment::Vector{Comment}
    generic_amplitude::RealQuantity
    type::M{String}
    category::M{AmplitudeCategory}
    unit::M{AmplitudeUnit}
    method_id::M{ResourceReference}
    period::M{RealQuantity}
    snr::M{Float64}
    time_window::M{TimeWindow}
    pick_id::M{ResourceReference}
    waveform_id::M{WaveformStreamID}
    filter_id::M{ResourceReference}
    scaling_time::M{TimeQuantity}
    magnitude_hint::M{String}
    evaluation_mode::M{EvaluationMode}
    evaluation_status::M{EvaluationStatus}
    creation_info::M{CreationInfo}
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

struct StationMagnitudeContribution
    station_magnitude_id::ResourceReference
    residual::M{Float64}
    weight::M{Float64}
end

struct Magnitude
    comment::Vector{Comment}
    station_magnitude_contribution::Vector{StationMagnitudeContribution}
    mag::RealQuantity
    type::M{String}
    origin_id::M{ResourceReference}
    method_id::M{ResourceReference}
    station_count::M{Int}
    azimuthal_gap::M{Float64}
    evaluation_mode::M{EvaluationMode}
    evaluation_status::M{EvaluationStatus}
    creation_info::M{CreationInfo}
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

struct StationMagnitude
    comment::Vector{Comment}
    station_magnitude_contribution::Vector{StationMagnitudeContribution}
    mag::RealQuantity
    type::M{String}
    origin_id::M{ResourceReference}
    method_id::M{ResourceReference}
    station_count::M{Int}
    azimuthal_gap::M{Float64}
    evaluation_mode::M{EvaluationMode}
    evaluation_status::M{EvaluationStatus}
    creation_info::M{CreationInfo}
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

struct OriginUncertainty
    horizontal_uncertainty::M{Float64}
    min_horizontal_uncertainty::M{Float64}
    max_horizontal_uncertainty::M{Float64}
    azimuth_horizontal_uncertainty::M{Float64}
    confidence_ellipsoid::M{ConfidenceEllipsoid}
    preferred_description::M{OriginUncertaintyDescription}
    confidence_level::M{Float64}
end

struct Arrival
    comment::Vector{Comment}
    pick_id::ResourceReference
    phase::Phase
    time_correction::M{Float64}
    azimuth::M{Float64}
    distance::M{Float64}
    takeoff_angle::M{RealQuantity}
    time_residual::M{Float64}
    horizontal_slowness_residual::M{Float64}
    backazimuth_residual::M{Float64}
    time_weight::M{Float64}
    horizontal_slowness_weight::M{Float64}
    backazimuth_weight::M{Float64}
    earth_model_id::M{ResourceReference}
    creation_info::M{CreationInfo}
    public_id::ResourceReference
end

struct Origin
    composite_time::Vector{CompositeTime}
    comment::Vector{Comment}
    origin_uncertainty::Vector{OriginUncertainty}
    arrival::Vector{Arrival}
    time::TimeQuantity
    longitude::RealQuantity
    latitude::RealQuantity
    depth::M{RealQuantity}
    depth_type::M{OriginDepthType}
    time_fixed::M{Bool}
    epicenter_fixed::M{Bool}
    reference_system_id::M{ResourceReference}
    method_id::M{ResourceReference}
    earth_model_id::M{ResourceReference}
    quality::M{OriginQuality}
    type::M{OriginType}
    region::M{String}
    evaluation_mode::M{EvaluationMode}
    evaluation_status::M{EvaluationStatus}
    creation_info::M{CreationInfo}
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

struct Pick
    comment::Vector{Comment}
    time::TimeQuantity
    waveform_id::WaveformStreamID
    filter_id::M{ResourceReference}
    method_id::M{ResourceReference}
    horizontal_slowness::M{RealQuantity}
    backazimuth::M{RealQuantity}
    slowness_method_id::M{ResourceReference}
    onset::M{PickOnset}
    phase_hint::M{Phase}
    polarity::M{PickPolarity}
    evaluation_mode::M{EvaluationMode}
    evaluation_status::M{EvaluationStatus}
    creation_info::M{CreationInfo}
    public_id::ResourceReference
end

struct Event
    description::Vector{EventDescription}
    comment::Vector{Comment}
    focal_mechanism::Vector{FocalMechanism}
    amplitude::Vector{Amplitude}
    magnitude::Vector{Magnitude}
    station_magnitude::Vector{StationMagnitude}
    origin::Vector{Origin}
    pick::Vector{Pick}
    preferred_origin_id::M{ResourceReference}
    preferred_magnitude_id::M{ResourceReference}
    preferred_focal_mechanism_id::M{ResourceReference}
    type::M{EventType}
    type_certainty::M{EventTypeCertainty}
    creation_info::M{CreationInfo}
    public_id::ResourceReference
end

struct EventParameters
    comment::Vector{Comment}
    event::Vector{Event}
    description::M{String}
    creation_info::M{CreationInfo}
    public_id::ResourceReference
end
