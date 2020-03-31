using Test, QuakeML
using Dates: DateTime

@testset "Accessors" begin
    @testset "preferred_origin" begin
        let qml = QuakeML.read(joinpath(@__DIR__, "data", "nepal_mw7.2.qml"))
            @test preferred_origin(qml.event[1]).public_id ==
                qml.event[1].preferred_origin_id
            @test preferred_origin(qml.event[1]) == qml.event[1].origin[2]
            empty!(qml.event[1].origin)
            @test_throws ArgumentError preferred_origin(qml.event[1])
        end
        origin1 = QuakeML.Origin(time=Dates.now(), longitude=0, latitude=0,
            public_id="smi:QuakeML.jl/origin/a")
        origin2 = QuakeML.Origin(time=Dates.now(), longitude=1, latitude=1,
            public_id="smi:QuakeML.jl/origin/b")
        origin3 = QuakeML.Origin(time=Dates.now(), longitude=2, latitude=2,
            public_id="smi:QuakeML.jl/origin/c")
        event = QuakeML.Event(public_id="smi:QuakeML.jl/event/a",
            preferred_origin_id="smi:QuakeML.jl/origin/b")
        # No origins
        @test_throws ArgumentError QuakeML.preferred_origin(event)
        # Returns first regardless
        push!(event.origin, origin1) # Add one origin with wrong ID
        @test preferred_origin(event) == origin1
        @test_nowarn preferred_origin(event, verbose=true)
        # Finds the preferred one
        push!(event.origin, origin2) # Add the right origin
        @test preferred_origin(event) == origin2
        @test preferred_origin(event).longitude.value == 1
        # Returns the first if no match
        empty!(event.origin)
        append!(event.origin, [origin1, origin3]) # Two wrong origins
        @test preferred_origin(event) == origin1
        @test_nowarn preferred_origin(event)
        @test_logs((:warn, "no origin with preferred id; returning the first origin"),
            preferred_origin(event, verbose=true))
    end

    @testset "preferred_origins" begin
        let qml = QuakeML.read(joinpath(@__DIR__, "data", "nepal_mw7.2.qml"))
            @test preferred_origins(qml) == [preferred_origin(qml.event[1])]
            empty!(qml.event[1].origin)
            @test_throws ArgumentError preferred_origins(qml)
        end
    end

    @testset "preferred_magnitude" begin
        mag1 = QuakeML.Magnitude(mag=1, public_id="smi:QuakeML.jl/magnitude/a")
        mag2 = QuakeML.Magnitude(mag=2, public_id="smi:QuakeML.jl/magnitude/b")
        mag3 = QuakeML.Magnitude(mag=3, public_id="smi:QuakeML.jl/magnitude/c")
        event = QuakeML.Event(public_id="smi:QuakeML.jl/event/a",
            preferred_magnitude_id="smi:QuakeML.jl/magnitude/b")
        # No magnitudes
        @test_throws ArgumentError preferred_magnitude(event)
        # Returns first regardless
        push!(event.magnitude, mag1)
        @test preferred_magnitude(event) == mag1
        @test_nowarn preferred_magnitude(event, verbose=true)
        # Finds the preferred one
        push!(event.magnitude, mag2)
        @test preferred_magnitude(event) == mag2
        @test preferred_magnitude(event).mag.value == 2
        # Return the first if no match
        empty!(event.magnitude)
        append!(event.magnitude, [mag1, mag3])
        @test preferred_magnitude(event) == mag1
        @test_nowarn preferred_magnitude(event)
        @test_logs((:warn, "no magnitude with preferred id; returning the first magnitude"),
            preferred_magnitude(event, verbose=true))
    end

    @testset "preferred_magnitudes" begin
        let qml = QuakeML.read(joinpath(@__DIR__, "data", "nepal_mw7.2.qml"))
            @test preferred_magnitudes(qml) == [preferred_magnitude(qml.event[1])]
            empty!(qml.event[1].magnitude)
            @test_throws ArgumentError preferred_magnitudes(qml)
        end
    end

    @testset "preferred_focal_mechanism" begin
        fm1 = QuakeML.FocalMechanism(public_id="smi:QuakeML.jl/focmech/a")
        fm2 = QuakeML.FocalMechanism(public_id="smi:QuakeML.jl/focmech/b")
        fm3 = QuakeML.FocalMechanism(public_id="smi:QuakeML.jl/focmech/c")
        event = QuakeML.Event(public_id="smi:QuakeML.jl/event/a",
            preferred_focal_mechanism_id="smi:QuakeML.jl/focmech/b")
        # No focal mechanisms
        @test_throws ArgumentError preferred_focal_mechanism(event)
        # Returns first regardless
        push!(event.focal_mechanism, fm1)
        @test preferred_focal_mechanism(event) == fm1
        @test_nowarn preferred_focal_mechanism(event, verbose=true)
        # Finds the preferred one
        push!(event.focal_mechanism, fm2)
        @test preferred_focal_mechanism(event) == fm2
        # Return the first if no match
        empty!(event.focal_mechanism)
        append!(event.focal_mechanism, [fm1, fm3])
        @test preferred_focal_mechanism(event) == fm1
        @test_nowarn preferred_focal_mechanism(event)
        @test_logs((:warn, "no focal mechanism with preferred id; returning the first focal mechanism"),
            preferred_focal_mechanism(event, verbose=true))
    end

    @testset "preferred_focal_mechanisms" begin
        let qml = QuakeML.read(joinpath(@__DIR__, "data", "nepal_mw7.2.qml"))
            @test preferred_focal_mechanisms(qml) == [preferred_focal_mechanism(qml.event[1])]
            empty!(qml.event[1].focal_mechanism)
            @test_throws ArgumentError preferred_focal_mechanisms(qml)
        end
    end
    
end
