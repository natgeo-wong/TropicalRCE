using DrWatson
@quickactivate "TropicalRCE"
using DelimitedFiles
using GeoRegions
using NCDatasets
using StatsBase

using PyCall
using LaTeXStrings
pplt = pyimport("proplot");

include(srcdir("reanalysis.jl"))

ds = NCDataset(datadir("gpmimerg-prcp_rate-cmp-TRP.nc"))
elon = ds["longitude"][:]
elat = ds["latitude"][:]
eavg = ds["average"][:]*3600*24
close(ds)

ods = NCDataset(datadir("ETOPO1.grd"))
olon = ods["x"][:]; olat = ods["y"][:]; oro = ods["z"][:]*1
oro[oro.>0] .= 1; oro[oro.<0] .= 0
close(ods)

bins = -1:0.02:2; pbin = (bins[2:end].+bins[1:(end-1)])/2

function bindata(coords,bins,evar,elon,elat,oro,olon,olat)

    tlon,tlat,rinfo = regiongridvec(coords,elon,elat);
    rvar = regionextractgrid(evar,rinfo)

    rlon,rlat,rinfo = regiongridvec(coords,olon,olat)
    roro = regionextractgrid(oro,rinfo); nlon = length(tlon); nlat = length(tlat);
    glon = zeros(Int32,nlon); for i = 1 : nlon; glon[i] = argmin(abs.(tlon[i] .- rlon)) end
    glat = zeros(Int32,nlat); for i = 1 : nlat; glat[i] = argmin(abs.(tlat[i] .- rlat)) end

    rlsm = roro[glon,glat]

    lvar = rvar[rlsm .>0.5]; lbin = fit(Histogram,lvar,10 .^(bins)).weights
    svar = rvar[rlsm .<0.5]; sbin = fit(Histogram,svar,10 .^(bins)).weights
    lbin = lbin ./ sum(lbin) * (length(bins) - 1)
    sbin = sbin ./ sum(sbin) * (length(bins) - 1)

    return lbin,sbin,mean(lvar),mean(svar)

end

lbin_DTP,sbin_DTP,lavg_DTP,savg_DTP = bindata([15,-15,360,0],bins,eavg,elon,elat,oro,olon,olat)
lbin_IPW,sbin_IPW,lavg_IPW,savg_IPW = bindata([15,-15,180,90],bins,eavg,elon,elat,oro,olon,olat)
lbin_WPW,sbin_WPW,lavg_WPW,savg_WPW = bindata([5,-10,180,135],bins,eavg,elon,elat,oro,olon,olat)
lbin_DRY,sbin_DRY,lavg_DRY,savg_DRY = bindata([5,-5,275,180],bins,eavg,elon,elat,oro,olon,olat)

coord = readdlm(datadir("GLB-i.txt"),comments=true,comment_char='#')
x = coord[:,1]; y = coord[:,2];

DTP = prect(15,-15,0,360)
WPW = prect(5,-10,135,180)
IPW = prect(15,-15,90,180)
DRY = prect(5,-5,180,275)

pplt.close(); arr = [[1,1],[2,3]];
f,axs = pplt.subplots(arr,aspect=6,axwidth=6,sharey=0);

c1 = axs[1].contourf(elon,elat,eavg',levels=0:15,cmap="Blues",extend="max");
axs[1].plot(x,y,c="k",lw=0.2)
axs[1].plot(DTP[1],DTP[2],c="b",lw=1)
axs[1].plot(IPW[1],IPW[2],c="r",lw=1)
axs[1].plot(WPW[1],WPW[2],c="k",lw=1)
axs[1].plot(DRY[1],DRY[2],c="k",lw=1,linestyle="--")
axs[1].format(
    ylim=(-30,30),
    xlim=(0,360),xlocator=[0:60:360],
    suptitle="Precipitation Rate / mm day**-1"
)
f.colorbar(c1,loc="r")

axs[2].plot(10 .^pbin,lbin_DTP,c="b",lw=0.5); axs[2].plot([1,1]*lavg_DTP,[0.1,50],c="b")
axs[2].plot(10 .^pbin,lbin_IPW,c="r",lw=0.5); axs[2].plot([1,1]*lavg_IPW,[0.1,50],c="r")
axs[2].plot(10 .^pbin,lbin_WPW,c="k",lw=0.5); axs[2].plot([1,1]*lavg_WPW,[0.1,50],c="k")
axs[2].plot(10 .^pbin,lbin_DRY,c="k",lw=0.5,linestyle=":")
axs[2].plot([1,1]*lavg_DRY,[0.1,50],c="k",linestyle=":")
axs[2].format(
    xlim=(10 .^minimum(bins),10 .^maximum(bins)),xscale="log",ylim=(0.1,50),yscale="log",
    rtitle="Land",ylabel="Normalized Frequency"
)

axs[3].plot(10 .^pbin,sbin_DTP,c="b",lw=0.5); axs[3].plot([1,1]*savg_DTP,[0.1,50],c="b")
axs[3].plot(10 .^pbin,sbin_IPW,c="r",lw=0.5); axs[3].plot([1,1]*savg_IPW,[0.1,50],c="r")
axs[3].plot(10 .^pbin,sbin_WPW,c="k",lw=0.5); axs[3].plot([1,1]*savg_WPW,[0.1,50],c="k")
axs[3].plot(10 .^pbin,sbin_DRY,c="k",lw=0.5,linestyle=":")
axs[3].plot([1,1]*savg_DRY,[0.1,50],c="k",linestyle=":")
axs[3].format(
    xlim=(10 .^minimum(bins),10 .^maximum(bins)),xscale="log",ylim=(0.1,50),yscale="log",
    rtitle="Ocean"
)

for ax in axs
    ax.format(abc=true,grid="on")
end

@info """Average Precipitation Rate (1979-2019):
  $(BOLD("DTP (Deep Tropics):"))          $(@sprintf("%0.2f",savg_DTP)) mm day**-1
  $(BOLD("IPW (Indo-Pacific Warmpool):")) $(@sprintf("%0.2f",savg_IPW)) mm day**-1
  $(BOLD("WPW (West Pacific Warmpool):")) $(@sprintf("%0.2f",savg_WPW)) mm day**-1
  $(BOLD("DRY (Dry Pacific):"))           $(@sprintf("%0.2f",savg_DRY)) mm day**-1

Average Precipitation Rate (1979-2019):
  $(BOLD("DTP (Deep Tropics):"))          $(@sprintf("%0.2f",lavg_DTP)) mm day**-1
  $(BOLD("IPW (Indo-Pacific Warmpool):")) $(@sprintf("%0.2f",lavg_IPW)) mm day**-1
  $(BOLD("WPW (West Pacific Warmpool):")) $(@sprintf("%0.2f",lavg_WPW)) mm day**-1
"""

mkpath(plotsdir("REANALYSIS"))
f.savefig(plotsdir("REANALYSIS/gpmprcp.png"),transparent=false,dpi=200)
