#Note: these are almost the same methods as defined for ImageInterpLast2.  Some are even exact duplicates.
#However we need to inherit from CachedSeries3D.  A redesign (mabye using traits) would prevent this duplication

mutable struct ImageInterpLast3{TO,TI,N} <: CachedSeries3D{TO,TI,N}
    parent::AbstractArray{TI,N}
    coefs::Vector{Float64}
    cached::Array{TO,3}
    cache_idxs::Tuple
end

#function ImageInterpLast3(img::Array34{T}, coefs, out_type=Float64; correct_bias=true, sqrt_tfm=false) where {T}
function ImageInterpLast3(img::AbstractArray{T,N}, coefs, out_type=Float64) where {T,N}
    if N <=3
        error("$N-dimensional image was provided, but image must be 4D or higher")
    end
    map(check01, coefs)
    if size(img,3) !== length(coefs)
        error("Input image size in the Z-slice dimension (3) should equal the number of interpolation coefficients provided")
    end
    za = ImageInterpLast3{out_type, T, ndims(img)}(img, coefs, zeros(out_type, size(img)[1:3]...), (ones(ndims(img)-3)...))
    update_cache!(za, (ones(Int, ndims(img)-3)...))
    return za
end

cache(A::ImageInterpLast3) = A.cached
cache_idxs(A::ImageInterpLast3) = A.cache_idxs

ImageInterpLast3(img::Array34{T}, coef::Float64, out_type=Float64) where {T} = ImageInterpLast3(img, fill(coef, size(img, 3)), out_type)

function update_cache!(A::ImageInterpLast3{TO, TI, N}, inds::NTuple{N2, Int}) where {TO, TI, N, N2}
    #sometimes indexing works better than views with memory-mapped arrays
    pslice = A.parent[:, :, :, inds...]
    pslice_next = A.parent[:, :, :, Base.front(inds)...,last(inds)+1]
    interp!(A.cached, pslice, pslice_next, A.coefs)
    A.cache_idxs = inds
end

size(A::ImageInterpLast3) = (Base.front(size(A.parent))...,last(size(A.parent))-1)
show(io::IO, A::ImageInterpLast3{TO}) where {TO} = print(io, "ImageInterpLast3 of size $(size(A)) mapped to element type $TO\n")
show(io::IO, ::MIME"text/plain", A::ImageInterpLast3{TO}) where {TO} = show(io, A)

ImageInterpLast3(img::ImageMeta, coefs, out_type=Float64; kwargs...) = ImageMeta(ImageInterpLast3(data(img), coefs, out_type; kwargs...), properties(img))
ImageInterpLast3(img::AxisArray, coefs, out_type=Float64; kwargs...) = match_axisspacing(ImageInterpLast3(data(img),coefs,out_type; kwargs...), img)
