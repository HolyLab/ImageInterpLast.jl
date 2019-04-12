# ImageInterpLast

This package uses interpolation to compensate for sampling time differences that occur when a sequence of 3D image "stacks" is assembled from a sequence of 2D snapshots.

```julia
using ImageInterpLast

#Lazy interpolation between "forward" stacks and "reverse" stacks in a bidirectional recording

img = rand(10,10,10,10) #suppose this is a 4D image sequence (3D + time)

coef = 0.5 #interpolation coefficient, 0.5 means simply average neighboring values

#Construct an interpolated image.
#This does not allocate memory, except for a cache holding data for the current image slice (reduces the number of reads from disk)
img_itp = interp_last(img, coef; cache3d=false, out_type=Float32)

#(cache3d=true would cache an entire 3D "stack" instead)

@show size(img)
@show size(img_itp) #one less in the time dimension due to interpolation

#Index the object like an AbstractArray. Interpolated values are computed on-demand.
#The statement below returns the pixel-wise average of stacks 3 and 4 (i.e. img[:,:,:,3] .* 0.5 + img[:,:,:,4] .* 0.5)
stack3 = img_itp[:,:,:,3]

#If needed you can also interpolate with a different coefficient for each 2D slice of a stack.
#To do this simply pass a vector of coefficients to interp_last.
#This would be useful for resampling an image timeseries acquired with conventional unidirectional scanning.
```
