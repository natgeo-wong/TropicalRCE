using DrWatson
@quickactivate "TropicalRCE"
using ClimateERA
using DelimitedFiles
using Dierckx
using NCDatasets
using SAMTools

using PyCall
using LaTeXStrings
pplt = pyimport("proplot");

include(srcdir("reanalysis.jl"))

function z2p(
    variable::AbstractVector{<:Real},
    pressure::AbstractVector{<:Real},
    height::AbstractVector{<:Real}
)

    splzp = Spline1D(pressure*100,height)
    dzdp  = derivative(splzp,pressure*100;nu=1)
    return variable .* dzdp

end

ds = NCDataset(datadir("reanalysis/era5-TRPx0.25-t_air.nc"))
lon = ds["longitude"][:]; nlon = length(lon)
lat = ds["latitude"][:];  nlat = length(lat)
lvl = ds["level"][:];     nlvl = length(lvl)
t_air = ds["t_air"][:]*1
close(ds)

ds = NCDataset(datadir("reanalysis/era5-TRPx0.25-q_air.nc"))
q_air = ds["q_air"][:] * 1000
close(ds)

ds = NCDataset(datadir("reanalysis/era5-TRPx0.25-lsm-sfc.nc"))
lsm = ds["lsm"][:]*1
close(ds)

_,stair_DTP = getmean([15,-15,360,0],t_air,lon,lat,nlvl,lsm)
_,sqair_DTP = getmean([15,-15,360,0],q_air,lon,lat,nlvl,lsm)

stair_DTP = stair_DTP .* (1000 ./lvl).^0.287

lsf = sndinit(nlvl); lsf[:,2] .= reverse(lvl)
lsf[:,3] .= reverse(stair_DTP)
lsf[:,4] .= reverse(sqair_DTP)
sndprint(projectdir("exp/snd/DTPera5"),lsf,1005.50)
