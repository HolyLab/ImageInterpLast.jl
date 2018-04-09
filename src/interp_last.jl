#user interface

interplast(A::AbstractArray, coef::Float64; kwargs...) = interplast(A, fill(coef, size(A,3)); kwargs...)

function interplast(A::AbstractArray{T,N}, coefs::Vector{Float64}; cache3d=false, out_type=Float64) where {T,N}
    if !in(N, (3,4))
        warn("$N-dimensional input was provided.  Only 3D and 4D inputs are tested; this will probably fail")
    end
    if N ==3 && cache3d
        cache3d = false
        warn("The cache3d kwarg was set for a 3D input matrix. This is only useful for 4D timeseries; ignoring kwarg")
    end
    return cache3d ? ImageInterpLast3(A, coefs, out_type) : ImageInterpLast2(A, coefs, out_type)
end
