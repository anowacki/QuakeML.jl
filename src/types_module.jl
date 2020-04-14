module Types

import ..QuakeML

"All types exported by this module"
const EXPORTED_TYPES = (
    :RealQuantity,
    :IntegerQuantity,
    :ResourceReference,
    :TimeQuantity,
    :CreationInfo,
    :EventDescription,
    :Phase,
    :Comment,
    :Axis,
    :PrincipleAxes,
    :DataUsed,
    :CompositeTime,
    :Tensor,
    :OriginQuality,
    :NodalPlane,
    :TimeWindow,
    :WaveformStreamID,
    :SourceTimeFunction,
    :NodalPlanes,
    :ConfidenceEllipsoid,
    :MomentTensor,
    :FocalMechanism,
    :Amplitude,
    :StationMagnitudeContribution,
    :Magnitude,
    :StationMagnitude,
    :OriginUncertainty,
    :Arrival,
    :Origin,
    :Pick,
    :Event,
    :EventParameters)

for type in EXPORTED_TYPES
    @eval begin
        const $type = QuakeML.$type
        export $type
    end
end

# Document the module
let exported_types_list = join(string.("- `", sort([s for s in String.(EXPORTED_TYPES)]), "`"), "\n")
    @doc """
    The `Types` module exports all the public-facing types used by
    QuakeML.

    By doing
    ```julia
    julia> using QuakeML.Types
    ```
    you may more succinctly write code.

    !!! note
        QuakeML's types share names with other packages, such as
        [Seis.jl](https://github.com/anowacki/Seis.jl)'s `Event` and `Pick`,
        and [SeisTau.jl](https://github.com/anowacki/SeisTau.jl)'s
        `Phase`, amongst others.  This is because QuakeML's names follow
        those in the QuakeML specification.

    # List of exported types
    $(exported_types_list)
    """ Types
end

end
