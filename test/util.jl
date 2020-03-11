using QuakeML, Test

@testset "Utils" begin
    @testset "Macros" begin
        @eval QuakeML.@enumerated_struct(ExampleStruct, Float32, (1.f0, 2.f0))
        @test isdefined(Main, :ExampleStruct)
        @test fieldnames(ExampleStruct) == (:value,)
        @test fieldtypes(ExampleStruct) == (Float32,)
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
    end
end
