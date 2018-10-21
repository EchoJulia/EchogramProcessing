module EchogramProcessing

export meanfilter, medianfilter, meanfilterdb, removeholes

using Images
using ImageFiltering
using EchogramUtils
using Statistics

function meanfilter(A, height, width)
    kernel  = Array{Float64}(undef, height, width)
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

"""
    removeholes(A; min=9)

Remove holes in binary array A.

e.g.

```
    removeholes([1 1 1; 1 0 1; 1 1 1])

    3×3 Array{Int64,2}:
     1  1  1
     1  1  1
     1  1  1
```
"""
function removeholes(A; min=9)
    c = copy(A)
    A= 1 .- A # invert

    # Label background regions
    labels = label_components(A)
    for i in 1:maximum(labels)
        b = (labels .== i)
        # Remove small regions
        if sum(b) <= min
            c[b] .= 1
        end
    end
    return c
end

end # module
