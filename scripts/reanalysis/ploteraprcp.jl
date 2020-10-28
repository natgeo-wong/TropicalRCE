using DrWatson
@quickactivate "TropicalRCE"
using Crayons.Box
using DelimitedFiles
using GeoRegions
using NCDatasets
using StatsBase

using PyCall
using LaTeXStrings
pplt = pyimport("proplot");

include(srcdir("reanalysis.jl"))

ds = NCDataset(datadir("reanalysis/era5-TRPx0.25-prcp_tot-sfc.nc"))

lon = ds["longitude"][:]
lat = ds["latitude"][:]
prcp = ds["average"][:]*24000

close(ds)

ds = NCDataset(datadir("reanalysis/era5-TRPx0.25-lsm-sfc.nc"))
lsm = ds["lsm"][:]*1
close(ds)

bins = -1:0.02:2; pbin = (bins[2:end].+bins[1:(end-1)])/2

lbin_DTP,sbin_DTP,lavg_DTP,savg_DTP = bindatasfc([20,-20,270,60],10 .^bins,prcp,lon,lat,lsm)
lbin_IPW,sbin_IPW,lavg_IPW,savg_IPW = bindatasfc([15,-15,180,90],10 .^bins,prcp,lon,lat,lsm)
lbin_WPW,sbin_WPW,lavg_WPW,savg_WPW = bindatasfc([5,-10,180,135],10 .^bins,prcp,lon,lat,lsm)
lbin_DRY,sbin_DRY,lavg_DRY,savg_DRY = bindatasfc([5,-5,275,180],10 .^bins,prcp,lon,lat,lsm)

coord = readdlm(datadir("GLB-i.txt"),comments=true,comment_char='#')
x = coord[:,1]; y = coord[:,2];

DTP = prect(15,-15,0,360)
WPW = prect(5,-10,135,180)
IPW = prect(15,-15,90,180)
DRY = prect(5,-5,180,275)

pplt.close(); arr = [[1,1],[2,3]];
f,axs = pplt.subplots(arr,aspect=6,axwidth=6,sharey=0);

c1 = axs[1].contourf(lon,lat,prcp',levels=0:15,cmap="Blues",extend="max");
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
f.savefig(plotsdir("REANALYSIS/prcp_tot.png"),transparent=false,dpi=200)
