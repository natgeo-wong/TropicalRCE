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

ds = NCDataset(datadir("reanalysis/era5-TRPx0.25-w_air.nc"))
lon = ds["longitude"][:]; nlon = length(lon)
lat = ds["latitude"][:];  nlat = length(lat)
lvl = ds["level"][:];     nlvl = length(lvl)
w_air = ds["w_air"][:]*1
close(ds)

ds = NCDataset(datadir("reanalysis/era5-TRPx0.25-z_air.nc"))
z_air = ds["z_air"][:] ./ 9.81
close(ds)

ds = NCDataset(datadir("reanalysis/era5-TRPx0.25-lsm-sfc.nc"))
lsm = ds["lsm"][:]*1
close(ds)

lwair_DTP,swair_DTP = getmean([15,-15,360,0],w_air,lon,lat,nlvl,lsm)
lwair_IPW,swair_IPW = getmean([15,-15,180,90],w_air,lon,lat,nlvl,lsm)
lwair_WPW,swair_WPW = getmean([5,-10,180,135],w_air,lon,lat,nlvl,lsm)
lwair_DRY,swair_DRY = getmean([5,-5,275,180],w_air,lon,lat,nlvl,lsm)

lzair_DTP,szair_DTP = getmean([15,-15,360,0],z_air,lon,lat,nlvl,lsm)
lzair_IPW,szair_IPW = getmean([15,-15,180,90],z_air,lon,lat,nlvl,lsm)
lzair_WPW,szair_WPW = getmean([5,-10,180,135],z_air,lon,lat,nlvl,lsm)
lzair_DRY,szair_DRY = getmean([5,-5,275,180],z_air,lon,lat,nlvl,lsm)

swz_DTP = z2p(swair_DTP,lvl,szair_DTP); lwz_DTP = z2p(lwair_DTP,lvl,lzair_DTP)
swz_IPW = z2p(swair_IPW,lvl,szair_IPW); lwz_IPW = z2p(lwair_IPW,lvl,lzair_IPW)
swz_WPW = z2p(swair_WPW,lvl,szair_WPW); lwz_WPW = z2p(lwair_WPW,lvl,lzair_WPW)
swz_DRY = z2p(swair_DRY,lvl,szair_DRY); lwz_DRY = z2p(lwair_DRY,lvl,lzair_DRY)

pplt.close(); f,axs = pplt.subplots(ncols=2,aspect=0.5,axwidth=1.5);

axs[1].plot(lwz_DTP,lvl,c="b")
axs[1].plot(lwz_IPW,lvl,c="r")
axs[1].plot(lwz_WPW,lvl,c="k")
axs[1].format(title="Land")

axs[2].plot(swz_DTP,lvl,c="b")
axs[2].plot(swz_IPW,lvl,c="r")
axs[2].plot(swz_WPW,lvl,c="k")
axs[2].plot(swz_DRY,lvl,c="k",linestyle=":")
axs[2].format(title="Ocean")

for ax in axs
    ax.format(
        abc=true,grid="on",xlim=(-0.02,0.02),ylim=(1000,70),xlocator=(-2:2)/100,
        ylabel="Pressure / hPa",xlabel=L"Vertical Velocity / m s$^{-1}$"
    )
end

mkpath(plotsdir("REANALYSIS"))
f.savefig(plotsdir("REANALYSIS/w_air-p2z.png"),transparent=false,dpi=200)

lsf = lsfinit()
lsf[1:end-5,7] .= reverse(swz_DTP[5:end]); lsfprint(projectdir("exp/lsf/DTP"),lsf,1005.50)
lsf[1:end-5,7] .= reverse(swz_IPW[5:end]); lsfprint(projectdir("exp/lsf/IPW"),lsf,1005.50)
lsf[1:end-5,7] .= reverse(swz_WPW[5:end]); lsfprint(projectdir("exp/lsf/WPW"),lsf,1005.50)
lsf[1:end-5,7] .= reverse(swz_DRY[5:end]); lsfprint(projectdir("exp/lsf/DRY"),lsf,1005.50)
