using Test
using QuakeML

@testset "Comparison" begin
    # Two identical EventParameters
    datafile = joinpath(@__DIR__, "data", "2004-12-26_mag5+.qml")
    qml = QuakeML.read(datafile)
    qml′ = QuakeML.read(datafile)
    # A different EventParameters: one field is missing in one and set in another
    qml″ = deepcopy(qml)
    qml″.event[end].magnitude[1].mag.uncertainty = 0.1

    @testset "==" begin
        @test qml == qml′
        @test qml != qml″
    end

    @testset "hash" begin
        @test hash(qml) == hash(qml′)
        @test hash(qml) != hash(qml″)
    end

    # These should follow from the above
    @testset "Others" begin
        @test unique([qml, qml′]) == [qml]
        @test unique([qml, qml″]) == [qml, qml″]
        @test Dict(qml=>1) == Dict(qml′=>1) != Dict(qml″=>1)
    end
end