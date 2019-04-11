module ImageInterpLast

using CachedArrays, Images, AxisArrays
const axes = Base.axes

import CachedArrays: update_cache!, cache, AbstractCachedArray
import Base: size, getindex, show

export interp_last, ImgItpLast

include("util.jl")
include("interp_last.jl")

end
