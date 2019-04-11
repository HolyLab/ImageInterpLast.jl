mutable struct ImageInterpLast2{TO,N,TI,NC,A<:AbstractArray{TI,N}} <: AbstractCachedArray{TO,N,TI,NC,A}
    parent::A
    coefs::Vector{Float64}
    cached::Array{TO,2}
    current_I::Tuple
end

function ImageInterpLast2(img::Array34{T}, coefs, out_type=Float64) where {T}
    map(check01, coefs)
    if size(img,3) !== length(coefs)
        error("Input image size in the Z-slice dimension (3) should be equal the number of interpolation coefficients provided")
    end
    nd = ndims(img)
    nd_cache = 2
    ncache_rngs = axes(img)[nd_cache+1:nd]
    ci = map(first, ncache_rngs)
    za = ImageInterpLast2{out_type,nd,T,2,typeof(img)}(img, coefs, zeros(out_type, size(img)[1:2]...), ci)
    update_cache!(za, ci)
    return za
end


ImageInterpLast2(img::Array34{T}, coef::Float64, out_type=Float64) where {T} = ImageInterpLast2(img, fill(coef, size(img, 3)), out_type)

function update_cache!(A::ImageInterpLast2{TO,N,TI,NC}, inds::NTuple{NQ, Int}) where {TO,N,TI,NC,NQ}
    #sometimes indexing works better than views with memory-mapped arrays
    pslice = A.parent[:, :, inds...]
    pslice_next = A.parent[:, :, Base.front(inds)...,last(inds)+1]
    coef = NC > 1 ? A.coefs[first(inds)] : A.coefs[1] #get coef for this slice
    interp!(A.cached, pslice, pslice_next, coef)
    A.current_I = inds
end

size(A::ImageInterpLast2) = (Base.front(size(A.parent))...,last(size(A.parent))-1,)
Base.axes(A::ImageInterpLast2) = (Base.front(axes(parent(A)))..., first(last(axes(parent(A)))):(last(last(axes(parent(A))))-1),)
show(io::IO, A::ImageInterpLast2{TO}) where {TO} = print(io, "ImageInterpLast2 of size $(size(A)) mapped to element type $TO\n")
show(io::IO, ::MIME"text/plain", A::ImageInterpLast2{TO}) where {TO} = show(io, A)

ImageInterpLast2(img::ImageMeta, coefs, out_type=Float64; kwargs...) = ImageMeta(ImageInterpLast2(data(img), coefs, out_type; kwargs...), properties(img))
ImageInterpLast2(img::AxisArray, coefs, out_type=Float64; kwargs...) = match_axisspacing(ImageInterpLast2(data(img),coefs,out_type; kwargs...), img)
