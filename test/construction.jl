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
end