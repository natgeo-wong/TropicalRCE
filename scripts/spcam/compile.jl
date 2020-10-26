using DrWatson
@quickactivate "TropicalRCE"

include(srcdir("SPCAM.jl"))

camcompilesfc.([
    "SST","TMQ",
    "TCLDAREA","HCLDAREA","MCLDAREA","LCLDAREA",
    "FSNS","FLNS","SHFLX","LHFLX","FSNTOA","FLUT"
])

camcompilepre.([
    "CLOUD","T"
])
