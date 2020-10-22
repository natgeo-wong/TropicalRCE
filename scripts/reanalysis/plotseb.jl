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

function plotfluxes(
    varname::AbstractString,
    bins::AbstractRange,
    lvls::AbstractArray,
    cmap::AbstractString,
    extd::AbstractString
)

    ds = NCDataset(datadir("reanalysis/era5-TRPx0.25-$(varname)-sfc.nc"))

    lon = ds["longitude"][:]
    lat = ds["latitude"][:]
    var = ds[varname][:] / (30*3600)

    long = ds[varname].attrib["long_name"]
    unit = ds[varname].attrib["units"]

    close(ds)

    ds = NCDataset(datadir("reanalysis/era5-TRPx0.25-lsm-sfc.nc"))
    lsm = ds["lsm"][:]*1
    close(ds)

    pbin = (bins[2:end].+bins[1:(end-1)])/2

    lavg_DTP,savg_DTP = bindatasfc([20,-20,270,60],bins,var,lon,lat,lsm)
    lavg_IPW,savg_IPW = bindatasfc([15,-15,180,90],bins,var,lon,lat,lsm)
    lavg_WPW,savg_WPW = bindatasfc([10,-10,180,120],bins,var,lon,lat,lsm)
    lavg_DRY,savg_DRY = bindatasfc([5,-5,275,180],bins,var,lon,lat,lsm)

    coord = readdlm(datadir("GLB-i.txt"),comments=true,comment_char='#')
    x = coord[:,1]; y = coord[:,2];

    DTP = prect(15,-15,0,360)
    WPW = prect(10,-10,120,180)
    IPW = prect(15,-15,90,180)
    DRY = prect(5,-5,180,275)

    pplt.close(); arr = [[1,1],[2,3],[2,3]];
    f,axs = pplt.subplots(arr,aspect=6,axwidth=6,sharey=0);

    c1 = axs[1].contourf(lon,lat,var',levels=lvls,cmap=cmap,extend=extd);
    axs[1].plot(x,y,c="k",lw=0.2)
    axs[1].plot(DTP[1],DTP[2],c="b",lw=1)
    axs[1].plot(IPW[1],IPW[2],c="r",lw=1)
    axs[1].plot(WPW[1],WPW[2],c="k",lw=1)
    axs[1].plot(DRY[1],DRY[2],c="k",lw=1,linestyle="--")
    axs[1].format(
        ylim=(-30,30),
        xlim=(0,360),xlocator=[0:60:360],
        suptitle="$(long) / W m**-2"
    )
    f.colorbar(c1,loc="r")

    axs[2].plot(pbin,lavg_DTP,c="b")
    axs[2].plot(pbin,lavg_IPW,c="r")
    axs[2].plot(pbin,lavg_WPW,c="k")
    axs[2].format(xlim=(minimum(bins),maximum(bins)),rtitle="Land",ylabel="Normalized Frequency")

    axs[3].plot(pbin,savg_DTP,c="b")
    axs[3].plot(pbin,savg_IPW,c="r")
    axs[3].plot(pbin,savg_WPW,c="k")
    axs[3].plot(pbin,savg_DRY,c="k",linestyle=":")
    axs[3].format(xlim=(minimum(bins),maximum(bins)),rtitle="Ocean")

    for ax in axs
        ax.format(abc=true,grid="on")
    end

    mkpath(plotsdir("REANALYSIS"))
    f.savefig(plotsdir("REANALYSIS/$varname.png"),transparent=false,dpi=200)

end

compilesfceb()
plotfluxes("ssr",100:250,100:10:250,"Reds","max")
plotfluxes("str",-100:0.5:0,-100:10:0,"Blues_r","min")
plotfluxes("sshf",-75:0.5:0,-75:5:0,"Blues_r","min")
plotfluxes("slhf",-150:0,-150:10:0,"Blues_r","min")
plotfluxes("seb",-200:200,-150:20:150,"RdBu_r","both")
