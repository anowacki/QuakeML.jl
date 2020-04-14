using QuakeML, Test
using Dates: DateTime

@testset "Field access" begin
    @testset "CreationInfo" begin
        let ci = QuakeML.CreationInfo()
            @test ci.agency_id === missing
            ci.agency_id = "a"^64
            @test ci.agency_id == "a"^64
            @test_throws ArgumentError ci.agency_id = "a"^65
            @test_throws ArgumentError ci.version = "a"^65
            @test_throws ArgumentError ci.author = "a"^129
        end
    end

    @testset "WaveformStreamID" begin
        let ws = QuakeML.WaveformStreamID(network_code="AN", station_code="QML")
            @test ws.network_code == "AN"
            @test ws.station_code == "QML"
            @test ws.uri === missing
            @test_throws ArgumentError ws.uri = "not a URI"
            ws.uri = "smi:local/uri"
            @test ws.uri == QuakeML.ResourceReference("smi:local/uri")
            @test_throws ArgumentError ws.network_code = "123456789"
            @test_throws ArgumentError ws.station_code = "123456789"
            @test_throws ArgumentError ws.location_code = "123456789"
            @test_throws ArgumentError ws.channel_code = "123456789"
        end
    end

    @testset "Amplitude" begin
        let a = QuakeML.Amplitude(generic_amplitude=1)
            a.snr = 1
            @test a.snr === 1.0
            a.snr = 1.f0
            @test a.snr === 1.0
            @test_throws ArgumentError a.type = "a"^33
            @test_throws ArgumentError a.magnitude_hint = "a"^33
        end
    end

    @testset "Magnitude" begin
        let a = QuakeML.Magnitude(mag=1)
            a.mag == QuakeML.RealQuantity(value=1.0)
            @test_throws ArgumentError a.type = "a"^33
        end
    end

    @testset "StationMagnitude" begin
        let a = QuakeML.StationMagnitude(mag=1)
            @test a.mag == QuakeML.RealQuantity(value=1)
            @test_throws ArgumentError a.type = "a"^33
        end
    end

    @testset "Origin" begin
        let a = QuakeML.Origin(time=DateTime(2000), longitude=0, latitude=1)
            @test a.time == QuakeML.TimeQuantity(value=DateTime(2000))
            @test a.longitude == QuakeML.RealQuantity(value=0.0)
            @test a.latitude == QuakeML.RealQuantity(value=1.0)
            @test_throws ArgumentError a.region = "a"^129
        end
    end

    @testset "OriginQuality" begin
        let oq = QuakeML.OriginQuality()
            @test_throws ArgumentError oq.ground_truth_level = "a"^33
            oq.ground_truth_level = "a"^32
            @test oq.ground_truth_level == "a"^32
        end
    end
end
