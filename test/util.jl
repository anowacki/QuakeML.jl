using QuakeML, Test
import UUIDs

@testset "Utils" begin
    @testset "Macros" begin
        @eval QuakeML.@enumerated_struct(ExampleStruct, Float32, (1.f0, 2.f0))
        @test isdefined(Main, :ExampleStruct)
        @test fieldnames(ExampleStruct) == (:value,)
        @test fieldtype(ExampleStruct, :value) == Float32
        @test ExampleStruct(1.f0) isa ExampleStruct
        @test_throws ArgumentError ExampleStruct(3.f0)
    end

    @testset "String length" begin
        @test QuakeML.check_string_length("A", "ABC", 3) === nothing
        @test QuakeML.check_string_length("A", "ABC", 10) === nothing
        @test_throws ArgumentError QuakeML.check_string_length("A", "ABC", 2)
    end

    @testset "XML escaping" begin
        let s = "a&amp;b&lt;c&gt;d&quot;e&apos;f", s′ = "a&b<c>d\"e'f"
            @test QuakeML.xml_unescape(s) == s′
            @test QuakeML.xml_escape(s′) == s
        end
    end

    @testset "Name transform" begin
        let f = QuakeML.transform_name
            @test f("ModuleURI") == :module_uri
            @test f("Email") == :email
            @test f("SelectedNumberChannels") == :selected_number_channels
            @test f("SomethingLikeID") == :something_like_id
        end
        let f = QuakeML.retransform_name
            @test f(:public_id) == "publicID"
            @test f(:moment_tensor) == "momentTensor"
            @test f(:selected_number_channels) == "selectedNumberChannels"
            @test f(:something_with_id_in_it) == "somethingWithIDInIt"
        end
        # Round trip for all names in all types
        function test_round_trip(T::Union{QuakeML.ParsableTypes,Type{Missing}}, name)
            @test name == QuakeML.transform_name(QuakeML.retransform_name(name))
        end
        test_round_trip(type::Type{Union{Missing,T}}, name) where T = test_round_trip(T, name)
        test_round_trip(type::Type{<:AbstractArray{T}}, name) where T = test_round_trip(T, name)
        function test_round_trip(T, name)
            for nm in fieldnames(T)
                type = fieldtype(T, nm)
                test_round_trip(type, nm)
            end
        end
        test_round_trip(QuakeML.EventParameters, :dummy_name)
    end

    @testset "Random reference URI" begin
        @test QuakeML.random_reference() isa QuakeML.ResourceReference
        @test startswith(QuakeML.random_reference().value, "smi:local/")
        @test startswith(QuakeML.random_reference("quakeml").value, "quakeml:local/")
        @test occursin(
            r"^(quakeml|smi):local/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$",
            QuakeML.random_reference().value)
        ref = QuakeML.random_reference()
        uuid_string = replace(replace(ref.value, r".*/"=>""), "-"=>"")
        uuid = parse(UInt128, uuid_string, base=16)
        @test UUIDs.UUID(uuid) isa UUIDs.UUID
    end
end
