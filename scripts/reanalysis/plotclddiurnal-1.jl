using DrWatson
@quickactivate "TropicalRCE"
using NCDatasets
using StatsBase

using PyCall
using LaTeXStrings
pplt = pyimport("proplot");

include(srcdir("reanalysis.jl"))

ds = NCDataset(datadir("reanalysis/era5-TRPx0.25-cc_air-diurnal.nc"))

lon = ds["longitude"][:]
lat = ds["latitude"][:]
cca = ds["cc_air"]

coord = readdlm(datadir("GLB-i.txt"),comments=true,comment_char='#')
x = coord[:,1]; y = coord[:,2];

for it = 0 : 23

    pplt.close(); f,axs = pplt.subplots(axwidth=6,aspect=6)
    axs[1].contourf(lon,lat,cca[:,:,10,(it+1)]',cmap="Blues",levels=0:0.05:0.75)
    axs[1].plot(x,y,lw=0.5,c="k")
    axs[1].format(xlim=(0,360),ylim=(-30,30))
    f.savefig(plotsdir("REANALYSIS/cc_air/$it.png"),transparent=false,dpi=200)

end

close(ds)
