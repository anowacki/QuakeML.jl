using Test, QuakeML
using Dates: DateTime

@testset "Construction" begin
    @testset "Convenience" begin
        @test QuakeML.RealQuantity(1) == QuakeML.RealQuantity(value=1)
        @test QuakeML.IntegerQuantity(2) == QuakeML.IntegerQuantity(value=2)
        @test convert(QuakeML.IntegerQuantity, 3) == QuakeML.IntegerQuantity(value=3)
        @test QuakeML.Origin(time=DateTime(2000), longitude=1, latitude=2,
            public_id="smi:QuakeML.jl/origin/a").time.value == DateTime(2000)
    end

    @testset "Schema version" begin
    end

    @testset "ResourceReference" begin
        # Not a proper URI
        @test_throws ArgumentError QuakeML.ResourceReference(value="bad URI")
        # String too long
        @test_throws ArgumentError QuakeML.ResourceReference(value="smi:local/" * "a"^246)
        @test QuakeML.ResourceReference("quakeml:QuakeML.jl/refA") isa QuakeML.ResourceReference
        @test QuakeML.ResourceReference("smi:QuakeML.jl/refB") isa QuakeML.ResourceReference
        @test QuakeML.ResourceReference("smi:local/a") isa QuakeML.ResourceReference
    end

    @testset "WhitespaceOrEmptyString" begin
        @test_throws ArgumentError QuakeML.WhitespaceOrEmptyString("x")
        @test QuakeML.WhitespaceOrEmptyString(" \t  \n ").value == " \t  \n "
        @test isempty(QuakeML.WhitespaceOrEmptyString("").value)
    end
end