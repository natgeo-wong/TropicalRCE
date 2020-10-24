using DrWatson
@quickactivate "TropicalRCE"
using GeoRegions
using NCDatasets

using PyCall
using LaTeXStrings
pplt = pyimport("proplot");

include(srcdir("reanalysis.jl"))

ds = NCDataset(datadir("gpmimerg-prcp_rate-cmp-TRP.nc"))
elon = ds["longitude"][:]
elat = ds["latitude"][:]
eavg = ds["average"][:]*3600
close(ds)

ods = NCDataset(datadir("ETOPO1.grd"))
olon = ods["x"][:]; olat = ods["y"][:]; oro = ods["z"][:]*1
oro[oro.>0] .= 1; oro[oro.<0] .= 0
close(ods)

bins = -3:0.02:0; pbin = (bins[2:end].+bins[1:(end-1)])/2

function bindata(coords,bins,eavg,elon,elat,oro,olon1,olat)

    tlon,tlat,rinfo = regiongridvec(coords,elon,elat);
    ravg = regionextractgrid(eavg,rinfo)

    rlon,rlat,rinfo = regiongridvec(coords,olon1,olat)
    roro = regionextractgrid(oro,rinfo); nlon = length(tlon); nlat = length(tlat);
    glon = zeros(Int32,nlon); for i = 1 : nlon; glon[i] = argmin(abs.(tlon[i] .- rlon)) end
    glat = zeros(Int32,nlat); for i = 1 : nlat; glat[i] = argmin(abs.(tlat[i] .- rlat)) end

    rlsm = roro[glon,glat]

    lavg = ravg[rlsm .>0.5]; lavg = fit(Histogram,lavg,10 .^(bins)).weights
    savg = ravg[rlsm .<0.5]; savg = fit(Histogram,savg,10 .^(bins)).weights
    lavg = lavg ./ sum(lavg) * 120
    savg = savg ./ sum(savg) * 120

    return lavg,savg

end

lavg_DTP,savg_DTP = bindata([20,-20,270,60],bins,eavg,elon,elat,oro,olon,olat)
lavg_IPW,savg_IPW = bindata([15,-15,180,90],bins,eavg,elon,elat,oro,olon,olat)
lavg_WPW,savg_WPW = bindata([5,-10,180,135],bins,eavg,elon,elat,oro,olon,olat)
lavg_DRY,savg_DRY = bindata([5,-5,275,180],bins,eavg,elon,elat,oro,olon,olat)

coord = readdlm(datadir("GLB-i.txt"),comments=true,comment_char='#')
x = coord[:,1]; y = coord[:,2];

DTP = prect(15,-15,0,360)
WPW = prect(5,-10,135,180)
IPW = prect(15,-15,90,180)
DRY = prect(5,-5,180,275)

pplt.close(); arr = [[1,1],[2,3],[2,3]];
f,axs = pplt.subplots(arr,aspect=6,axwidth=6,sharey=0);

c1 = axs[1].contourf(elon,elat,eavg',levels=0:0.05:0.5,cmap="Blues",extend="max");
axs[1].plot(x,y,c="k",lw=0.2)
axs[1].plot(DTP[1],DTP[2],c="b",lw=1)
axs[1].plot(IPW[1],IPW[2],c="r",lw=1)
axs[1].plot(WPW[1],WPW[2],c="k",lw=1)
axs[1].plot(DRY[1],DRY[2],c="k",lw=1,linestyle="--")
axs[1].format(
    ylim=(-30,30),
    xlim=(0,360),xlocator=[0:60:360],
    suptitle=L"Precipitation Rate / mm hr$^{-1}$"
)
f.colorbar(c1,loc="r")

axs[2].plot(10 .^pbin,lavg_DTP,c="b")
axs[2].plot(10 .^pbin,lavg_IPW,c="r")
axs[2].plot(10 .^pbin,lavg_WPW,c="k")
axs[2].plot(10 .^pbin,lavg_DRY,c="k",linestyle=":")
axs[2].format(xscale="log",ylim=(0,20),rtitle="Land",ylabel="Normalized Frequency")

axs[3].plot(10 .^pbin,savg_DTP,c="b")
axs[3].plot(10 .^pbin,savg_IPW,c="r")
axs[3].plot(10 .^pbin,savg_WPW,c="k")
axs[3].plot(10 .^pbin,savg_DRY,c="k",linestyle=":")
axs[3].format(xscale="log",ylim=(0,20),rtitle="Ocean")

for ax in axs
    ax.format(abc=true,grid="on")
end

mkpath(plotsdir("REANALYSIS"))
f.savefig(plotsdir("REANALYSIS/gpmprcp.png"),transparent=false,dpi=200)
