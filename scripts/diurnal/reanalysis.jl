using DrWatson
@quickactivate "TropicalRCE"

using PyCall
using LaTeXStrings
pplt = pyimport("proplot");

include(srcdir("common.jl"))
include(srcdir("reanalysis.jl"))

ds = NCDataset(datadir("reanalysis/era5-TRPx0.25-cc_air-diurnal.nc"))
lon = ds["longitude"][:]
lat = ds["latitude"][:]
lvl = ds["level"][:];    nlvl = length(lvl)
cca = ds["cc_air"][:]*100
close(ds)

ds = NCDataset(datadir("reanalysis/era5-TRPx0.25-lsm-sfc.nc"))
lsm = ds["lsm"][:]*1
close(ds)

occa_DTP = zeros(25,nlvl); occa_IPW = zeros(25,nlvl)
occa_WPW = zeros(25,nlvl); occa_DRY = zeros(25,nlvl)

clvl = [-10,-5,-2,-1,-0.5,-0.2,0.2,0.5,1,2,5,10]

for it = 1 : 24

    _,occa_DTP[it,:] = getmean([15,-15,360,0],cca[:,:,:,it],lon,lat,nlvl,lsm)
    _,occa_IPW[it,:] = getmean([15,-15,180,90],cca[:,:,:,it],lon,lat,nlvl,lsm)
    _,occa_WPW[it,:] = getmean([5,-10,180,135],cca[:,:,:,it],lon,lat,nlvl,lsm)
    _,occa_DRY[it,:] = getmean([5,-5,275,180],cca[:,:,:,it],lon,lat,nlvl,lsm)

end

_,occa_DTP[25,:] = getmean([15,-15,360,0],cca[:,:,:,1],lon,lat,nlvl,lsm)
_,occa_IPW[25,:] = getmean([15,-15,180,90],cca[:,:,:,1],lon,lat,nlvl,lsm)
_,occa_WPW[25,:] = getmean([5,-10,180,135],cca[:,:,:,1],lon,lat,nlvl,lsm)
_,occa_DRY[25,:] = getmean([5,-5,275,180],cca[:,:,:,1],lon,lat,nlvl,lsm)

arr = [[1,2,2,2,3,4,4,4],[5,6,6,6,7,8,8,8]]
pplt.close(); f,axs = pplt.subplots(arr,aspect=0.5,axwidth=1,wspace=(0,0,0,nothing,0,0,0));

axs[1].plot(mocca_DTP[:],lvl)
c = axs[2].contourf(0:24,lvl,vocca_DTP',cmap="drywet",levels=clvl,extend="both")
axs[1].format(urtitle="DTP",suptitle="Diurnal Cycle of Cloud Cover (ERA5) / %")

axs[3].plot(mocca_IPW[:],lvl)
axs[4].contourf(0:24,lvl,vocca_IPW',cmap="drywet",levels=clvl,extend="both")
axs[3].format(urtitle="IPW")

axs[5].plot(mocca_WPW[:],lvl)
axs[6].contourf(0:24,lvl,vocca_WPW',cmap="drywet",levels=clvl,extend="both")
axs[5].format(urtitle="WPW")

axs[7].plot(mocca_DRY[:],lvl)
axs[8].contourf(0:24,lvl,vocca_DRY',cmap="drywet",levels=clvl,extend="both")
axs[7].format(urtitle="DRY")

for ii = 1 : 8
    axs[ii].format(ylim=(1000,10))
    if mod(ii,2) == 0
        axs[ii].format(xlim=(0,24),xlocator=4:4:20)
    else
        axs[ii].format(xlim=(0,50))
    end
end

f.colorbar(c,loc="r")
f.savefig(plotsdir("REANALYSIS/cc_air-diurnal.png"),transparent=false,dpi=200)
