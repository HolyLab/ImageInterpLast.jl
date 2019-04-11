#Note: these are almost the same methods as defined for ImageInterpLast2.  Some are even exact duplicates.
#However we need to inherit from CachedSeries3D.  A redesign (mabye using traits) would prevent this duplication

mutable struct ImageInterpLast3{TO,N,TI,NC,A<:AbstractArray{TI,N}} <: AbstractCachedArray{TO,N,TI,NC,A}
    parent::A
    coefs::Vector{Float64}
    cached::Array{TO,3}
    current_I::Tuple
end

function ImageInterpLast3(img::AbstractArray{T,N}, coefs, out_type=Float64) where {T,N}
    if N <=3
        error("$N-dimensional image was provided, but image must be 4D or higher")
    end
    map(check01, coefs)
    if size(img,3) !== length(coefs)
        error("Input image size in the Z-slice dimension (3) should equal the number of interpolation coefficients provided")
    end
    nd_cache = 3
    ncache_rngs = axes(img)[nd_cache+1:N]
    ci = map(first, ncache_rngs)
    za = ImageInterpLast3{out_type,N,T,3,typeof(img)}(img, coefs, zeros(out_type, size(img)[1:3]...), ci)
    update_cache!(za, ci)
    return za
end

ImageInterpLast3(img::Array34{T}, coef::Float64, out_type=Float64) where {T} = ImageInterpLast3(img, fill(coef, size(img, 3)), out_type)

function update_cache!(A::ImageInterpLast3{TO,N,TI,NC}, inds::NTuple{NQ,Int}) where {TO,N,TI,NC,NQ}
    #sometimes indexing works better than views with memory-mapped arrays
    pslice = A.parent[:, :, :, inds...]
    pslice_next = A.parent[:, :, :, Base.front(inds)...,last(inds)+1]
    interp!(A.cached, pslice, pslice_next, A.coefs)
    A.current_I = inds
end

size(A::ImageInterpLast3) = (Base.front(size(A.parent))...,last(size(A.parent))-1,)
Base.axes(A::ImageInterpLast3) = (Base.front(axes(parent(A)))..., first(last(axes(parent(A)))):(last(last(axes(parent(A))))-1),)
show(io::IO, A::ImageInterpLast3{TO}) where {TO} = print(io, "ImageInterpLast3 of size $(size(A)) mapped to element type $TO\n")
show(io::IO, ::MIME"text/plain", A::ImageInterpLast3{TO}) where {TO} = show(io, A)

ImageInterpLast3(img::ImageMeta, coefs, out_type=Float64; kwargs...) = ImageMeta(ImageInterpLast3(data(img), coefs, out_type; kwargs...), properties(img))
ImageInterpLast3(img::AxisArray, coefs, out_type=Float64; kwargs...) = match_axisspacing(ImageInterpLast3(data(img),coefs,out_type; kwargs...), img)
