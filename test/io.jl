using Test, QuakeML
using Dates: DateTime

datafile1 = joinpath(@__DIR__, "data", "nepal_mw7.2.qml")
datafile2 = joinpath(@__DIR__, "data", "2004-12-26_mag6+.qml")
datafile3 = joinpath(@__DIR__, "data", "2004-12-26_mag5+.qml")
datafiles = (datafile1, datafile2, datafile3)

@testset "IO" begin
    @testset "Read string" begin
        for file in datafiles
            @test QuakeML.read(file) == QuakeML.readstring(String(read(file)))
        end
    end

    @testset "Read" begin
        let badstring = """
            <?xml version="1.0" encoding="UTF8"?>
            <SomeWeirdThing xmlns="http://quakeml.org/xmlns/bed/1.2">
            </SomeWeirdThing>
            """
            @test_throws ArgumentError QuakeML.readstring(badstring)
        end

        let qml = QuakeML.read(datafile1)
            @test qml isa QuakeML.EventParameters
            @test isempty(qml.comment)
            let ci = qml.creation_info
                test_all_missing(ci, :agency_id, :agency_uri, :author, :author_uri)
                @test ci.creation_time == DateTime("2020-03-11T11:41:23.271")
                @test ci.version == "V10"
            end
            @test qml.description === missing
            @test qml.public_id.value == "smi:service.iris.edu/fdsnws/event/1/query"
            @test length(qml.event) == 1
            let e = qml.event[1]
                @test isempty(e.amplitude)
                @test isempty(e.comment)
                @test e.creation_info === missing
                @test length(e.focal_mechanism) == 1
                let fm = e.focal_mechanism[1]
                    test_all_missing(fm, :azimuthal_gap, :evaluation_status,
                        :evaluation_mode, :method_id,
                        :misfit, :principle_axes, :station_distribution_ratio,
                        :station_polarity_count)
                    @test isempty(fm.comment)
                    ci = fm.creation_info
                    test_all_missing(ci, :agency_uri, :author, :author_uri,
                        :creation_time)
                    @test ci.agency_id == "GCMT"
                    @test ci.version == "V10"
                    @test length(fm.moment_tensor) == 1
                    let mt = fm.moment_tensor[1]
                        test_all_missing(mt, :category, :clvd, :creation_info,
                            :double_couple, :filter_id, :greens_function_id,
                            :inversion_type, :iso, :method_id, :variance,
                            :variance_reduction)
                        @test length(mt.data_used) == 3
                        @test mt.data_used[1] == QuakeML.DataUsed(
                            QuakeML.DataUsedWaveType("body waves"), 169, 459, 50.0,
                            missing)
                        @test mt.data_used[2] == QuakeML.DataUsed(
                            QuakeML.DataUsedWaveType("surface waves"), 173, 459, 50.0,
                            missing)
                        @test mt.data_used[3] == QuakeML.DataUsed(
                            QuakeML.DataUsedWaveType("mantle waves"), 168, 404, 150.0,
                            missing)
                        @test mt.derived_origin_id.value ==
                            "smi:www.iris.edu/spudservice/momenttensor/gcmtid/C201505120705A#cmtorigin"
                        @test mt.moment_magnitude_id.value ==
                            "smi:www.iris.washington.edu/spudservice/momenttensor/gcmtid/C201505120705A/quakeml#magnitude"
                        @test mt.public_id.value ==
                            "smi:www.iris.washington.edu/spudservice/momenttensor/gcmtid/C201505120705A/quakeml#momenttensor"
                        @test mt.scalar_moment == QuakeML.RealQuantity(; value=88440000000000000000.0)
                        @test mt.source_time_function.type.value == "triangle"
                        @test mt.source_time_function.duration == 20.2
                        test_all_missing(mt.source_time_function, :rise_time, :decay_time)
                        let t = mt.tensor
                            @test t.mrr == QuakeML.RealQuantity(;
                                value=27000000000000000000.0,
                                uncertainty=90000000000000000.0)
                            @test t.mtt == QuakeML.RealQuantity(;
                                value=-26200000000000000000.0,
                                uncertainty=80000000000000000.0)
                            @test t.mpp == QuakeML.RealQuantity(;
                                value=-830000000000000000.0,
                                uncertainty=80000000000000000.0)
                            @test t.mrt == QuakeML.RealQuantity(;
                                value=82500000000000000000.0,
                                uncertainty=740000000000000000.0)
                            @test t.mrp == QuakeML.RealQuantity(;
                                value=-12800000000000000000.0,
                                uncertainty=800000000000000000.0)
                            @test t.mtp == QuakeML.RealQuantity(;
                                value=12200000000000000000.0,
                                uncertainty=70000000000000000.0)
                        end # t
                        @test mt.public_id.value == "smi:www.iris.washington.edu/spudservice/momenttensor/gcmtid/C201505120705A/quakeml#momenttensor"
                    end # mt
                    @test fm.triggering_origin_id.value == "smi:www.iris.edu/spudservice/momenttensor/gcmtid/C201505120705A#reforigin"
                    @test isempty(fm.waveform_id)
                end # fm
                @test length(e.magnitude) == 1
                let mag = e.magnitude[1]
                    test_all_missing(mag, :azimuthal_gap, :creation_info,
                        :evaluation_mode, :evaluation_status, :method_id,
                        :origin_id, :station_count)
                    test_all_empty(mag, :comment, :station_magnitude_contribution)
                    @test mag.mag == QuakeML.RealQuantity(value=7.2)
                    @test mag.public_id.value == "smi:www.iris.washington.edu/spudservice/momenttensor/gcmtid/C201505120705A/quakeml#magnitude"
                    @test mag.type == "Mwc"
                end # mag
                @test length(e.origin) == 2
                let o = e.origin[1]
                    test_all_missing(o, :creation_info, :depth_type,
                        :earth_model_id, :epicenter_fixed, :evaluation_mode,
                        :evaluation_status, :method_id, :quality,
                        :reference_system_id, :region, :time_fixed, :type)
                    test_all_empty(o, :comment)
                    @test o.depth == QuakeML.RealQuantity(value=15000.0)
                    @test o.latitude == QuakeML.RealQuantity(value=27.81)
                    @test o.longitude == QuakeML.RealQuantity(value=86.07)
                    @test o.public_id.value == "smi:www.iris.edu/spudservice/momenttensor/gcmtid/C201505120705A#reforigin"
                    @test o.time == QuakeML.TimeQuantity(value=DateTime(2015, 05, 12, 07, 05, 19, 700))
                end # o
                let o = e.origin[2]
                    test_all_missing(o, :creation_info, :depth_type,
                        :earth_model_id, :evaluation_mode,
                        :evaluation_status, :method_id, :quality,
                        :reference_system_id, :region, :type)
                    test_all_empty(o, :comment)
                    @test o.depth == QuakeML.RealQuantity(value=12000.0)
                    @test o.epicenter_fixed == false
                    @test o.latitude == QuakeML.RealQuantity(value=27.67)
                    @test o.longitude == QuakeML.RealQuantity(value=86.08)
                    @test o.public_id.value == "smi:www.iris.edu/spudservice/momenttensor/gcmtid/C201505120705A#cmtorigin"
                    @test o.time == QuakeML.TimeQuantity(value=DateTime(2015, 05, 12, 07, 05, 27, 500))
                    @test o.time_fixed == false
                end # o
                @test isempty(e.pick)
                @test e.preferred_focal_mechanism_id.value ==
                    "smi:www.iris.washington.edu/spudservice/momenttensor/gcmtid/C201505120705A/quakeml#focalmechanism"
                @test e.preferred_origin_id.value ==
                    "smi:www.iris.edu/spudservice/momenttensor/gcmtid/C201505120705A#cmtorigin"
                @test e.public_id.value ==
                    "smi:service.iris.edu/fdsnws/event/1/query?eventid=5113514"
                @test isempty(e.station_magnitude)
                @test e.type.value == "earthquake"
                @test e.type_certainty === missing
            end # e
        end

        # File with quite a few events
        let qml = QuakeML.read(datafile2)
            @test qml.creation_info.agency_id == "ISC"
            @test qml.creation_info.creation_time == DateTime(2020, 03, 11, 11, 45, 58)
            @test qml.description == "ISC Bulletin"
            @test qml.public_id.value == "smi:ISC/bulletin"
            @test length(qml.event) == 23
            @test qml.event[1].description[1].text == "Off west coast of northern Sumatera"
            @test qml.event[1].description[1].type.value == "Flinn-Engdahl region"
            @test qml.event[1].origin[1].time.value == DateTime(2004, 12, 26, 00, 58, 53, 080)
            @test qml.event[1].origin[1].time.uncertainty == 0.26
            @test qml.event[1].origin[1].latitude.value == 3.3148
            @test qml.event[1].origin[1].longitude.value == 95.9829
            @test qml.event[1].origin[1].depth.value == 26451.8
            q = qml.event[1].origin[1].quality
            @test q.used_phase_count == 1671
            @test q.associated_station_count == 1653
            @test q.standard_error == 2.3141
            @test q.azimuthal_gap == 15.980
            @test q.minimum_distance == 2.273
            @test q.maximum_distance == 173.412
            @test length(qml.event[1].origin[1].origin_uncertainty) == 1
            ou = qml.event[1].origin[1].origin_uncertainty[1]
            @test ou.preferred_description.value == "uncertainty ellipse"
            @test ou.min_horizontal_uncertainty == 3652.95
            @test ou.max_horizontal_uncertainty == 4573.66
            @test ou.azimuth_max_horizontal_uncertainty == 49.5
            @test length(qml.event[1].magnitude) == 2
            mag = qml.event[1].magnitude[1]
            @test mag.mag.value == 6.96
            @test mag.type == "mb"
            @test mag.station_count == 275
            @test mag.origin_id.value == "smi:ISC/origid=7900012"
        end
    end
end
