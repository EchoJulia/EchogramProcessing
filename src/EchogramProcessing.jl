module EchogramProcessing

export meanfilter, medianfilter, meanfilterdb

using Images
using ImageFiltering
using EchogramUtils

function meanfilter(A, height, width)
    kernel  = Array{Float64}(height, width)
    kernel .= 1 / (width * height)
    kernel = centered(kernel)
    imfilter(A, kernel, Fill(0))
end

function medianfilter(A, height, width)
    mapwindow(median, A, (height, width))
end

"""
    meanfilterdb(db, height, width)

Remember, the Average of the Log is Not the Log of the Average,
so averaging dB requires conversion to and from the linear domain.
"""
function meanfilterdb(db, height, width)
    a = db2pow.(db)
    b = meanfilter(a, height, width)
    pow2db.(b)
end



end # module
