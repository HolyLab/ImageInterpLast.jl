module ImageInterpLast

using CachedArrays, ImageCore, ImageMetadata
using AxisArrays: AxisArrays, AxisArray

import CachedArrays: update_cache!, cache, AbstractCachedArray
import Base: size, getindex, show

export interp_last, ImgItpLast

include("util.jl")
include("interp_last.jl")

end
