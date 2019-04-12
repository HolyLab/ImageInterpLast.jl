using ImageInterpLast

using Test

a = zeros(10,10,10,10)
for t = 1:10
    a[:,:,:,t] .= t
end

img0 = interp_last(a, 0.5; cache3d=false, out_type=Float64)
img1 = interp_last(a, 0.5; cache3d=false, out_type=Float32)
img2 = ImgItpLast(a, 0.5, 2, Float64)
img3 = ImgItpLast(a, 0.5, 3, Float64)

for img in (img0,img1,img2,img3)
    @test all(img[:,:,:,1].==1.5)
    @test all(img[1:2,:,:,1].==1.5)
    @test all(img[1:2,:,2,1].==1.5)
    @test all(img[:,:,:,2].==2.5)
    @test all(img[1:2,:,:,2].==2.5)
    @test all(img[1:2,:,2,2].==2.5)
end

coefs = fill(0.25, 10)
coefs[6:10] .= 1.0

img2 = ImgItpLast(a, coefs, 2, Float64)
img3 = ImgItpLast(a, coefs, 3, Float64)

for img in (img2,img3)
    @test all(img[:,:,1:5,1].==1.75)
    @test all(img[1:2,:,1:5,1].==1.75)
    @test all(img[1:2,:,2,1].==1.75)

    @test all(img[:,:,6:10,1].==1.0)
    @test all(img[1:2,:,6:10,1].==1.0)
    @test all(img[1:2,:,7,1].==1.0)
    
    @test all(img[:,:,1:5,2].==2.75)
    @test all(img[1:2,:,1:5,2].==2.75)
    @test all(img[1:2,:,2,2].==2.75)

    @test all(img[:,:,6:10,2].==2.0)
    @test all(img[1:2,:,6:10,2].==2.0)
    @test all(img[1:2,:,7,2].==2.0)
end

img4 = interp_last(a, coefs; cache3d=false, out_type=Float64)
img5 = interp_last(a, coefs; cache3d=true, out_type=Float64)

@test all(img4[:,:,:,:].==img2[:,:,:,:])
@test all(img5[:,:,:,:].==img3[:,:,:,:])
