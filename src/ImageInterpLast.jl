__precompile__()

module ImageInterpLast

using CachedSeries, Images, AxisArrays

import CachedSeries: update_cache!, cache, cache_idxs
import Base: size, getindex, show

export interplast, ImageInterpLast2, ImageInterpLast3

include("util.jl")
include("interp_last2.jl")
include("interp_last3.jl")
include("interp_last.jl")

end
