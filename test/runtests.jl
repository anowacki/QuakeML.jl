using Test
using QuakeML

"For each field in `fields`, test that x.field is `missing`"
function test_all_missing(x, fields...)
    for f in fields
        getfield(x, f) === missing || (@show f)
        @test getfield(x, f) === missing
    end
end

"For each field in `fields`, test that x.field is empty"
function test_all_empty(x, fields...)
    for f in fields
        @test isempty(getfield(x, f))
    end
end

@testset "All tests" begin
    include("util.jl")
    include("construction.jl")
    include("parsing.jl")
    include("io.jl")
    include("accessors.jl")
end
