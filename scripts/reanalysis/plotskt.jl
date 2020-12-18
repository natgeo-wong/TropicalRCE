using DrWatson
@quickactivate "TropicalRCE"
using Crayons.Box
using DelimitedFiles
using GeoRegions
using NCDatasets
using Printf
using StatsBase

using PyCall
using LaTeXStrings
pplt = pyimport("proplot");

include(srcdir("reanalysis.jl"))

function plotskin(
    sbin::AbstractRange,
    lbin::AbstractRange,
    lvls::AbstractRange,
    extd::AbstractString;
    verbose::Bool=false
)

    ds = NCDataset(datadir("reanalysis/era5-TRPx0.25-skt-sfc.nc"))
    lon = ds["longitude"][:]
    lat = ds["latitude"][:]
    skt = ds["skt"][:]*1
    close(ds)

    ds = NCDataset(datadir("reanalysis/era5-TRPx0.25-lsm-sfc.nc"))
    lsm = ds["lsm"][:]*1
    close(ds)

    psbin = (sbin[2:end].+sbin[1:(end-1)])/2
    plbin = (lbin[2:end].+lbin[1:(end-1)])/2

    _,sbin_DTP,_,savg_DTP = bindatasfc([15,-15,360,0],sbin,skt,lon,lat,lsm)
    _,sbin_IPW,_,savg_IPW = bindatasfc([15,-15,180,90],sbin,skt,lon,lat,lsm)
    _,sbin_WPW,_,savg_WPW = bindatasfc([5,-10,180,135],sbin,skt,lon,lat,lsm)
    _,sbin_DRY,_,savg_DRY = bindatasfc([5,-5,275,180],sbin,skt,lon,lat,lsm)

    lbin_DTP,_,lavg_DTP,_ = bindatasfc([15,-15,360,0],lbin,skt,lon,lat,lsm)
    lbin_IPW,_,lavg_IPW,_ = bindatasfc([15,-15,180,90],lbin,skt,lon,lat,lsm)
    lbin_WPW,_,lavg_WPW,_ = bindatasfc([5,-10,180,135],lbin,skt,lon,lat,lsm)
    lbin_DRY,_,lavg_DRY,_ = bindatasfc([5,-5,275,180],lbin,skt,lon,lat,lsm)

    coord = readdlm(datadir("GLB-i.txt"),comments=true,comment_char='#')
    x = coord[:,1]; y = coord[:,2];

    DTP = prect(15,-15,0,360)
    WPW = prect(5,-10,135,180)
    IPW = prect(15,-15,90,180)
    DRY = prect(5,-5,180,275)

    pplt.close(); arr = [[1,1],[2,3]];
    f,axs = pplt.subplots(arr,aspect=6,axwidth=6,sharey=0);

    c1 = axs[1].contourf(lon,lat,skt',levels=lvls,extend=extd);
    axs[1].plot(x,y,c="k",lw=0.2)
    axs[1].plot(DTP[1],DTP[2],c="b",lw=1)
    axs[1].plot(IPW[1],IPW[2],c="r",lw=1)
    axs[1].plot(WPW[1],WPW[2],c="k",lw=1)
    axs[1].plot(DRY[1],DRY[2],c="k",lw=1,linestyle="--")
    axs[1].format(
        ylim=(-30,30),
        xlim=(0,360),xlocator=[0:60:360],
        suptitle="Skin Temperature / K"
    )
    f.colorbar(c1,loc="r")

    axs[2].plot([minimum(lbin),maximum(lbin)],[2,2],c="gray4",lw=0.5)
    axs[2].plot(plbin,lbin_DTP,c="b",lw=0.5); axs[2].plot([1,1]*lavg_DTP,[0.1,50],c="b")
    axs[2].plot(plbin,lbin_IPW,c="r",lw=0.5); axs[2].plot([1,1]*lavg_IPW,[0.1,50],c="r")
    axs[2].plot(plbin,lbin_WPW,c="k",lw=0.5); axs[2].plot([1,1]*lavg_WPW,[0.1,50],c="k")
    axs[2].format(
        xlim=(minimum(lbin),maximum(lbin)),ylim=(0.1,50),yscale="log",
        rtitle="Land",ylabel="Normalized Frequency"
    )

    axs[3].plot([minimum(sbin),maximum(sbin)],[2,2],c="gray4",lw=0.5)
    axs[3].plot(psbin,sbin_DTP,c="b",lw=0.5); axs[3].plot([1,1]*savg_DTP,[0.1,50],c="b")
    axs[3].plot(psbin,sbin_IPW,c="r",lw=0.5); axs[3].plot([1,1]*savg_IPW,[0.1,50],c="r")
    axs[3].plot(psbin,sbin_WPW,c="k",lw=0.5); axs[3].plot([1,1]*savg_WPW,[0.1,50],c="k")
    axs[3].plot(psbin,sbin_DRY,c="k",lw=0.5,linestyle=":")
    axs[3].plot([1,1]*savg_DRY,[0.1,50],c="k",linestyle=":")
    axs[3].format(
        xlim=(minimum(sbin),maximum(sbin)),ylim=(0.1,50),yscale="log",
        rtitle="Ocean"
    )

    for ax in axs
        ax.format(abc=true,grid="on")
    end

    mkpath(plotsdir("REANALYSIS"))
    f.savefig(plotsdir("REANALYSIS/t_skt.png"),transparent=false,dpi=200)

    if verbose
        @info """Average OCEAN $(BOLD(uppercase("SKIN TEMPERATURE"))) (1979-2019):
          $(BOLD("DTP (Deep Tropics):"))          $(@sprintf("%0.2f",savg_DTP)) K
          $(BOLD("IPW (Indo-Pacific Warmpool):")) $(@sprintf("%0.2f",savg_IPW)) K
          $(BOLD("WPW (West Pacific Warmpool):")) $(@sprintf("%0.2f",savg_WPW)) K
          $(BOLD("DRY (Dry Pacific):"))           $(@sprintf("%0.2f",savg_DRY)) K

        Average LAND $(BOLD(uppercase("SKIN TEMPERATURE"))) (1979-2019):
          $(BOLD("DTP (Deep Tropics):"))          $(@sprintf("%0.2f",lavg_DTP)) K
          $(BOLD("IPW (Indo-Pacific Warmpool):")) $(@sprintf("%0.2f",lavg_IPW)) K
          $(BOLD("WPW (West Pacific Warmpool):")) $(@sprintf("%0.2f",lavg_WPW)) K
        """
    end

end

plotskin(294:0.05:304,280:0.05:310,295:0.5:305,"both",verbose=true)
