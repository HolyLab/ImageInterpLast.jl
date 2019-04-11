module ImageInterpLast

using CachedArrays, Images, AxisArrays
const axes = Base.axes

import CachedArrays: update_cache!, cache, AbstractCachedArray
import Base: size, getindex, show

export interplast, ImageInterpLast2, ImageInterpLast3

include("util.jl")
include("interp_last2.jl")
include("interp_last3.jl")
include("interp_last.jl")

end
