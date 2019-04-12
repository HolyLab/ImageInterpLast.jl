mutable struct ImgItpLast{TO,N,TI,NC,A<:AbstractArray{TI,N}} <: AbstractCachedArray{TO,N,TI,NC,A}
    parent::A
    coefs::Vector{Float64}
    cached::Array{TO,NC}
    current_I::Tuple
end

function ImgItpLast(img::Array34{T}, coefs, nd_cache=ndims(img)-1, out_type=Float64) where {T}
    nd = ndims(img)
    map(check01, coefs)
    if size(img,3) !== length(coefs)
        error("Input image size in the Z-slice dimension (3) should equal the number of interpolation coefficients provided")
    end
    if nd_cache > nd
        error("nd_cache must be less than or equal to ndims(img)")
    end
    ncache_rngs = axes(img)[nd_cache+1:nd]
    ci = map(first, ncache_rngs)
    za = ImgItpLast{out_type,nd,T,nd_cache,typeof(img)}(img, coefs, zeros(out_type, size(img)[1:nd_cache]...), ci)
    update_cache!(za, ci)
    return za
end

ImgItpLast(img::Array34{T}, coef::Float64, nd_cache=ndims(img)-1, out_type=Float64) where {T} =
    ImgItpLast(img, fill(coef, size(img, 3)), nd_cache, out_type)

function update_cache!(A::ImgItpLast{TO,N,TI,2}, inds::NTuple{NQ, Int}) where {TO,N,TI,NQ}
    #sometimes indexing works better than views with memory-mapped arrays
    pslice = A.parent[:, :, inds...]
    pslice_next = A.parent[:, :, Base.front(inds)...,last(inds)+1]
    coef = A.coefs[first(inds)] #get coef for this slice
    interp!(A.cached, pslice, pslice_next, coef)
    A.current_I = inds
end

function update_cache!(A::ImgItpLast{TO,N,TI,3}, inds::NTuple{NQ,Int}) where {TO,N,TI,NQ}
    #sometimes indexing works better than views with memory-mapped arrays
    pslice = A.parent[:, :, :, inds...]
    pslice_next = A.parent[:, :, :, Base.front(inds)...,last(inds)+1]
    interp!(A.cached, pslice, pslice_next, A.coefs)
    A.current_I = inds
end

size(A::ImgItpLast) = (Base.front(size(A.parent))...,last(size(A.parent))-1,)
Base.axes(A::ImgItpLast) = (Base.front(axes(parent(A)))..., first(last(axes(parent(A)))):(last(last(axes(parent(A))))-1),)
show(io::IO, A::ImgItpLast{TO}) where {TO} = print(io, "ImgItpLast of size $(size(A)) mapped to element type $TO\n")
show(io::IO, ::MIME"text/plain", A::ImgItpLast{TO}) where {TO} = show(io, A)

ImgItpLast(img::ImageMeta, coefs, out_type=Float64; kwargs...) = ImageMeta(ImgItpLast(data(img), coefs, out_type; kwargs...), properties(img))
ImgItpLast(img::AxisArray, coefs, out_type=Float64; kwargs...) = match_axisspacing(ImgItpLast(data(img),coefs,out_type; kwargs...), img)


#user interface
interp_last(A::AbstractArray, coef::Float64; kwargs...) = interp_last(A, fill(coef, size(A,3)); kwargs...)

function interp_last(A::AbstractArray{T,N}, coefs::Vector{Float64}; cache3d=false, out_type=Float64) where {T,N}
    if !in(N, (3,4))
        warn("$N-dimensional input was provided.  Only 3D and 4D inputs are tested; this will probably fail")
    end
    if N ==3 && cache3d
        cache3d = false
        warn("The cache3d kwarg was set for a 3D input matrix. This is only useful for 4D timeseries; ignoring kwarg")
    end
    return cache3d ? ImgItpLast(A, coefs, 3, out_type) : ImgItpLast(A, coefs, 2, out_type)
end
