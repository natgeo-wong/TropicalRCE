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

function plottmp(
    sbin::AbstractRange,
    lbin::AbstractRange,
    lvls::AbstractRange,
    extd::AbstractString
)

    ds = NCDataset(datadir("reanalysis/era5-TRPx0.25-sst-sfc.nc"))
    lon = ds["longitude"][:]
    lat = ds["latitude"][:]
    sst = ds["sst"][:]*1
    close(ds)

    ds = NCDataset(datadir("reanalysis/era5-TRPx0.25-t2m-sfc.nc"))
    lon = ds["longitude"][:]
    lat = ds["latitude"][:]
    t2m = ds["t2m"][:]*1
    close(ds)

    ds = NCDataset(datadir("reanalysis/era5-TRPx0.25-lsm-sfc.nc"))
    lsm = ds["lsm"][:]*1
    close(ds)

    psbin = (sbin[2:end].+sbin[1:(end-1)])/2
    plbin = (lbin[2:end].+lbin[1:(end-1)])/2

    sst[ismissing.(sst)] .= NaN; sst = convert.(Float64,sst)

    _,sbin_DTP,_,savg_DTP = bindatasfc([20,-20,270,60],sbin,sst,lon,lat,lsm)
    _,sbin_IPW,_,savg_IPW = bindatasfc([15,-15,180,90],sbin,sst,lon,lat,lsm)
    _,sbin_WPW,_,savg_WPW = bindatasfc([5,-10,180,135],sbin,sst,lon,lat,lsm)
    _,sbin_DRY,_,savg_DRY = bindatasfc([5,-5,275,180],sbin,sst,lon,lat,lsm)

    lbin_DTP,_,lavg_DTP,_ = bindatasfc([20,-20,270,60],lbin,t2m,lon,lat,lsm)
    lbin_IPW,_,lavg_IPW,_ = bindatasfc([15,-15,180,90],lbin,t2m,lon,lat,lsm)
    lbin_WPW,_,lavg_WPW,_ = bindatasfc([5,-10,180,135],lbin,t2m,lon,lat,lsm)
    lbin_DRY,_,lavg_DRY,_ = bindatasfc([5,-5,275,180],lbin,t2m,lon,lat,lsm)

    coord = readdlm(datadir("GLB-i.txt"),comments=true,comment_char='#')
    x = coord[:,1]; y = coord[:,2];

    DTP = prect(15,-15,0,360)
    WPW = prect(5,-10,135,180)
    IPW = prect(15,-15,90,180)
    DRY = prect(5,-5,180,275)

    pplt.close(); arr = [[1,1],[2,3],[2,3]];
    f,axs = pplt.subplots(arr,aspect=6,axwidth=6,sharey=0);

    c1 = axs[1].contourf(lon,lat,t2m',levels=lvls,extend=extd);
    c1 = axs[1].contourf(lon,lat,sst',levels=lvls,extend=extd);
    axs[1].plot(x,y,c="k",lw=0.2)
    axs[1].plot(DTP[1],DTP[2],c="b",lw=1)
    axs[1].plot(IPW[1],IPW[2],c="r",lw=1)
    axs[1].plot(WPW[1],WPW[2],c="k",lw=1)
    axs[1].plot(DRY[1],DRY[2],c="k",lw=1,linestyle="--")
    axs[1].format(
        ylim=(-30,30),
        xlim=(0,360),xlocator=[0:60:360],
        suptitle="Surface Temperature / K"
    )
    f.colorbar(c1,loc="r")

    axs[2].plot(plbin,lbin_DTP,c="b",lw=1); axs[2].plot([1,1]*lavg_DTP,[0.1,50],c="b")
    axs[2].plot(plbin,lbin_IPW,c="r",lw=1); axs[2].plot([1,1]*lavg_IPW,[0.1,50],c="r")
    axs[2].plot(plbin,lbin_WPW,c="k",lw=1); axs[2].plot([1,1]*lavg_WPW,[0.1,50],c="k")
    axs[2].format(
        xlim=(minimum(lbin),maximum(lbin)),ylim=(0.1,50),yscale="log",
        rtitle="Land",ylabel="Normalized Frequency"
    )

    axs[3].plot(psbin,sbin_DTP,c="b",lw=1); axs[3].plot([1,1]*savg_DTP,[0.1,50],c="b")
    axs[3].plot(psbin,sbin_IPW,c="r",lw=1); axs[3].plot([1,1]*savg_IPW,[0.1,50],c="r")
    axs[3].plot(psbin,sbin_WPW,c="k",lw=1); axs[3].plot([1,1]*savg_WPW,[0.1,50],c="k")
    axs[3].plot(psbin,sbin_DRY,c="k",lw=1,linestyle=":")
    axs[3].plot([1,1]*savg_DRY,[0.1,50],c="k",linestyle=":")
    axs[3].format(
        xlim=(minimum(sbin),maximum(sbin)),ylim=(0.1,50),yscale="log",
        rtitle="Ocean"
    )

    for ax in axs
        ax.format(abc=true,grid="on")
    end

    mkpath(plotsdir("REANALYSIS"))
    f.savefig(plotsdir("REANALYSIS/t_sfc.png"),transparent=false,dpi=200)

end

plottmp(295:0.05:305,280:0.05:305,295:0.5:305,"both")
