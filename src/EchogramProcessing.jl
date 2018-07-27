module EchogramProcessing

export vertically_smooth, vertically_bin, IN, db2pow, pow2db, mag2db,
db2mag, linearav

using Images
using ImageFiltering

"""
    vertically_smooth(A, r, thickness)

Taking an echogram array `A` and a range vector `r`, smooth values
vertically by taking the mean over succesive `thickness` bins.

N.B. if your data is in dB, consider converting to linear (perhaps
using `dB2linear`).

"""
function vertically_smooth(A, r, thickness)
    b = zeros(size(A))
    for i in 0:thickness:r[end]
        mask = (r .>= i)  .& (r .< i+thickness)
        b[mask,:] .= mean(A[mask,:],1)
    end
    return b
end

"""
    vertically_bin(A, r, thickness)

Taking an echogram array `A` and a range vector `r`, bin values
vertically by taking the mean over succesive `thickness` sized bins.

N.B. if your data is in dB, consider converting to linear (perhaps
using `dB2linear`).

"""
function vertically_bin(A, r, thickness)
    b = []
    for i in 0:thickness:r[end]
        mask = (r .>= i)  .& (r .< i+thickness)
        push!(b,mean(A[mask,:],1))
    end
    return vcat(b...)
end

"""
    IN(A, delta)

Impulse noise filter based based on the two-sided comparison method
described by Anderson et al. (2005) and further described in Ryan et
al. (2015).

It is often desirable to linearly average to a coarser vertical
resolution (perhaps using `vertically_smooth`) before calling IN.

`A` is an echogram array and `delta` is the threshold. A sample is
marked as true if its value is more than `delta` greater than samples
on either side.

Returns a `BitArray` with the same dimensions as `A`.

"""
function IN(A, delta)
    m,n = size(A)

    a = A[:,1:end-2]
    b = A[:,2:end-1]
    c = A[:,3:end]
    m1 = (b.-a) .> delta
    m2 = (b.-c) .> delta

    hcat(falses(m), m1 .& m2, falses(m))
end

"""
    db2pow(ydb)

Convert decibels to power
"""
db2pow(ydb) = 10^(ydb/10)

"""
    pow2db(y)

Convert power to decibels.
"""
pow2db(y) = 10log10(y)

"""
    mag2db(y)

Convert magnitude to decibels.
"""
mag2db(y) = 20log10(y)

"""
    db2mag(ydb)

Convert decibels to magnitude.
"""
db2mag(ydb) = 10^(ydb/20)

"""
    linearav(db, height, width)

Averaging of an echogram in the linear domain with a window size of
height x width.

Remember, the Average of the Log is Not the Log of the Average!
"""
function linearav(db, height, width)

    a = db2pow.(db)

    kernel  = Array{Float64}(height, width)
    kernel .= 1 / (width * height)
    kernel = centered(kernel)

    a = imfilter(a, kernel, Fill(0))

    pow2db.(a)
end



end # module
