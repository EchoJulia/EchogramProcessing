using EchogramProcessing
using Test

a = rand(100, 100)

medianfilter(a, 9, 9)

meanfilter(a, 9, 9)

