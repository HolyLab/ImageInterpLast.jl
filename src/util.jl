const Array34{T} = Union{AbstractArray{T,3}, AbstractArray{T,4}}

function interp!(ca::AbstractArray{T,3}, img1::AbstractArray{T,3}, img2::AbstractArray{T,3}, coefs::Vector{Float64}) where {T}
    for i = 1:size(ca,3)
         interp!(view(ca,:,:,i), view(img1,:,:,i), view(img2,:,:,i), coefs[i])
    end
    return ca
end

function interp!(ca::AbstractArray{T,2}, img1::AbstractArray{T,2}, img2::AbstractArray{T,2}, coef::Float64) where {T}
    for i in eachindex(ca)
        ca[i] = img1[i]*coef + img2[i]*(1.0-coef)
    end
    return ca
end

function check01(coef)
    if coef<0.0 || coef >1.0
        error("All coefficients must lie in the interval (0.0,1.0)")
    end
end
