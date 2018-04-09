mutable struct ImageInterpLast2{TO,TI,N} <: CachedSeries2D{TO,TI,N}
    parent::AbstractArray{TI,N}
    coefs::Vector{Float64}
    cached::Array{TO,2}
    cache_idxs::Tuple
end

function ImageInterpLast2(img::Array34{T}, coefs, out_type=Float64) where {T}
    map(check01, coefs)
    if size(img,3) !== length(coefs)
        error("Input image size in the Z-slice dimension (3) should be equal the number of interpolation coefficients provided")
    end
    za = ImageInterpLast2{out_type, T, ndims(img)}(img, coefs, zeros(out_type, size(img)[1:2]...), (ones(ndims(img)-2)...))
    update_cache!(za, (ones(Int, ndims(img)-2)...))
    return za
end

cache(A::ImageInterpLast2) = A.cached
cache_idxs(A::ImageInterpLast2) = A.cache_idxs

ImageInterpLast2(img::Array34{T}, coef::Float64, out_type=Float64) where {T} = ImageInterpLast2(img, fill(coef, size(img, 3)), out_type)

function update_cache!(A::ImageInterpLast2{TO, TI, N}, inds::NTuple{N2, Int}) where {TO, TI, N, N2}
    #sometimes indexing works better than views with memory-mapped arrays
    pslice = A.parent[:, :, inds...]
    pslice_next = A.parent[:, :, Base.front(inds)...,last(inds)+1]
    coef = N-2 > 1 ? A.coefs[first(inds)] : A.coefs[1] #get coef for this slice
    interp!(A.cached, pslice, pslice_next, coef)
    A.cache_idxs = inds
end

size(A::ImageInterpLast2) = (Base.front(size(A.parent))...,last(size(A.parent))-1)
show(io::IO, A::ImageInterpLast2{TO}) where {TO} = print(io, "ImageInterpLast2 of size $(size(A)) mapped to element type $TO\n")
show(io::IO, ::MIME"text/plain", A::ImageInterpLast2{TO}) where {TO} = show(io, A)

ImageInterpLast2(img::ImageMeta, coefs, out_type=Float64; kwargs...) = ImageMeta(ImageInterpLast2(data(img), coefs, out_type; kwargs...), properties(img))
ImageInterpLast2(img::AxisArray, coefs, out_type=Float64; kwargs...) = match_axisspacing(ImageInterpLast2(data(img),coefs,out_type; kwargs...), img)
