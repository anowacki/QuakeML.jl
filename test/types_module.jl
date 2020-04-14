using QuakeML.Types
using Test

@testset "Types" begin
    for type in Types.EXPORTED_TYPES
        @test isdefined(@__MODULE__, type)
    end
    for type in (
            :OriginUncertaintyDescription,
            :AmplitudeCategory,
            :OriginDepthType,
            :OriginType,
            :MTInversionType,
            :EvaluationMode,
            :EvaluationStatus,
            :PickOnset,
            :EventType,
            :DataUsedWaveType,
            :AmplitudeUnit,
            :EventDescriptionType,
            :MomentTensorCategory,
            :EventTypeCertainty,
            :SourceTimeFunctionType,
            :PickPolarity
            )
        @test !isdefined(@__MODULE__, type)
    end
    events = EventParameters()
    @test events isa EventParameters
end