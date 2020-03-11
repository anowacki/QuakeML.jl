using QuakeML, Test
import Dates

@testset "Parsing" begin
    @testset "Local parsing" begin
        @test QuakeML.local_parse(String, "xyzx̂") == "xyzx̂"
        @test QuakeML.local_parse(String, SubString("φabc")) == "φabc"
        @test QuakeML.local_parse(SubString, "ABC ♪") == "ABC ♪"
        @test QuakeML.local_parse(Float64, "-1.0") == -1.0 == parse(Float64, "-1.0")
        @test QuakeML.local_tryparse(Int, "12") == 12
        @test QuakeML.local_tryparse(Int, "1.23") === nothing
        @test QuakeML.local_tryparse(String, "⊫") == "⊫"
    end

    @testset "Dates" begin
        let
            # Too much precision
            @test QuakeML.readstring("""
                <?xml version="1.0" encoding="UTF-8"?>
                <quakeml xmlns="http://quakeml.org/xmlns/quakeml/1.0">
                  <eventParameters publicID="smi:TEST/test">
                    <creationInfo>
                      <agencyID>ISC</agencyID>
                      <creationTime>2020-03-11T11:45:58.1234567890</creationTime>
                    </creationInfo>
                  </eventParameters>
                </quakeml>
                """).creation_info.creation_time == Dates.DateTime(2020, 03, 11, 11, 45, 58, 123)

            # Time zone ahead of UTC and too much precision
            @test QuakeML.readstring("""
                <?xml version="1.0" encoding="UTF-8"?>
                <quakeml xmlns="http://quakeml.org/xmlns/quakeml/1.0">
                  <eventParameters publicID="smi:TEST/test">
                    <creationInfo>
                      <agencyID>ISC</agencyID>
                      <creationTime>2000-01-01T12:34:00.123456789-12:34</creationTime>
                    </creationInfo>
                  </eventParameters>
                </quakeml>
                """).creation_info.creation_time == Dates.DateTime(2000, 1, 1, 0, 0, 0, 123)
            # UTC specified
            @test QuakeML.readstring("""
                <?xml version="1.0" encoding="UTF-8"?>
                <quakeml xmlns="http://quakeml.org/xmlns/quakeml/1.0">
                  <eventParameters publicID="smi:TEST/test">
                    <creationInfo>
                      <agencyID>ISC</agencyID>
                      <creationTime>2020-03-11T11:45:58.1234567890Z</creationTime>
                    </creationInfo>
                  </eventParameters>
                </quakeml>
                """).creation_info.creation_time == Dates.DateTime(2020, 03, 11, 11, 45, 58, 123)

        end
    end

    @testset "Version" begin
        @test_logs (:warn,
          "document is StationXML version 1.3.0; only v1.2 data will be read") QuakeML.readstring("""
                <?xml version="1.0" encoding="UTF-8"?>
                <quakeml xmlns="http://quakeml.org/xmlns/quakeml/1.3">
                  <eventParameters publicID="smi:TEST/test">
                  </eventParameters>
                </quakeml>
                """)
    end
end