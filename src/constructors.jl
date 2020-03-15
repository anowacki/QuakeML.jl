# More convenient constructors for types and conversions to types

RealQuantity(value::Real) = RealQuantity(value=value)
IntegerQuantity(value::Number) = IntegerQuantity(value=value)

# Allow filling of fields which are types with only a single field
# e.g., EventParameters(public_id="example string")
# rather than EventParameters(public_id=ResourceReference("example string"))
for T in Base.uniontypes(ValueTypes)
    @eval Base.convert(::Type{$T}, s::AbstractString) = $T(s)
end

# Allow contruction of types which use the following more easily.
# e.g.,
#     QuakeML.Origin(time=DateTime("2012-01-01T00:00:00"),
#         longitude=1, latitude=2, public_id="smi:a.com/b")
# rather than
#     QuakeML.Origin(time=TimeQuantity(value=DateTime("2012-01-01T00:00:00")),
#         longitude=RealQuantity(value=1), etc...)
Base.convert(::Type{RealQuantity}, value::Real) = RealQuantity(value=value)
Base.convert(::Type{IntegerQuantity}, value::Integer) = IntegerQuantity(value=value)
Base.convert(::Type{TimeQuantity}, value::DateTime) = TimeQuantity(value=value)
