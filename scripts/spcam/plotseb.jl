using DrWatson
@quickactivate "TropicalRCE"
using Crayons.Box
using DelimitedFiles
using GeoRegions
using NCDatasets
using StatsBase

using PyCall
using LaTeXStrings
pplt = pyimport("proplot")

include(srcdir("common.jl"))

function plotfluxes(
    varname::AbstractString,
    bins::AbstractRange,
    lvls::AbstractArray,
    cmap::AbstractString,
    extd::AbstractString;
    verbose::Bool=false
)

    ds = NCDataset(datadir("SPCAM/$(varname).nc"))

    lon = ds["longitude"][:]
    lat = ds["latitude"][:]
    var = ds[varname][:]*1

    long = ds[varname].attrib["long_name"]
    unit = ds[varname].attrib["units"]

    close(ds)

    ds = NCDataset(datadir("SPCAM/LANDFRAC.nc"))
    lsm = ds["LANDFRAC"][:]*1
    close(ds)

    pbin = (bins[2:end].+bins[1:(end-1)])/2

    lbin_DTP,sbin_DTP,lavg_DTP,savg_DTP = bindatasfc([15,-15,360,0],bins,var,lon,lat,lsm)
    lbin_IPW,sbin_IPW,lavg_IPW,savg_IPW = bindatasfc([15,-15,180,90],bins,var,lon,lat,lsm)
    lbin_WPW,sbin_WPW,lavg_WPW,savg_WPW = bindatasfc([5,-10,180,135],bins,var,lon,lat,lsm)
    lbin_DRY,sbin_DRY,lavg_DRY,savg_DRY = bindatasfc([5,-5,275,180],bins,var,lon,lat,lsm)

    coord = readdlm(datadir("GLB-i.txt"),comments=true,comment_char='#')
    x = coord[:,1]; y = coord[:,2];

    DTP = prect(15,-15,0,360)
    WPW = prect(5,-10,135,180)
    IPW = prect(15,-15,90,180)
    DRY = prect(5,-5,180,275)

    pplt.close(); arr = [[1,1],[2,3]];
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

    axs[2].plot(pbin,lbin_DTP,c="b",lw=0.5); axs[2].plot([1,1]*lavg_DTP,[0.1,50],c="b")
    axs[2].plot(pbin,lbin_IPW,c="r",lw=0.5); axs[2].plot([1,1]*lavg_IPW,[0.1,50],c="r")
    axs[2].plot(pbin,lbin_WPW,c="k",lw=0.5); axs[2].plot([1,1]*lavg_WPW,[0.1,50],c="k")
    axs[2].format(
        xlim=(minimum(bins),maximum(bins)),ylim=(0.1,50),yscale="log",
        rtitle="Land",ylabel="Normalized Frequency"
    )

    axs[3].plot(pbin,sbin_DTP,c="b",lw=0.5); axs[3].plot([1,1]*savg_DTP,[0.1,50],c="b")
    axs[3].plot(pbin,sbin_IPW,c="r",lw=0.5); axs[3].plot([1,1]*savg_IPW,[0.1,50],c="r")
    axs[3].plot(pbin,sbin_WPW,c="k",lw=0.5); axs[3].plot([1,1]*savg_WPW,[0.1,50],c="k")
    axs[3].plot(pbin,sbin_DRY,c="k",lw=0.5,linestyle=":")
    axs[3].plot([1,1]*savg_DRY,[0.1,50],c="k",linestyle=":")
    axs[3].format(
        xlim=(minimum(bins),maximum(bins)),ylim=(0.1,50),yscale="log",
        rtitle="Ocean"
    )

    for ax in axs
        ax.format(abc=true,grid="on")
    end

    mkpath(plotsdir("SPCAM"))
    #f.savefig(plotsdir("SPCAM/$varname.png"),transparent=false,dpi=200)

    if verbose
        @info """Average OCEAN $(BOLD(uppercase(long))) (1979-2019):
          $(BOLD("DTP (Deep Tropics):"))          $(@sprintf("%0.2f",savg_DTP)) W m**-2
          $(BOLD("IPW (Indo-Pacific Warmpool):")) $(@sprintf("%0.2f",savg_IPW)) W m**-2
          $(BOLD("WPW (West Pacific Warmpool):")) $(@sprintf("%0.2f",savg_WPW)) W m**-2
          $(BOLD("DRY (Dry Pacific):"))           $(@sprintf("%0.2f",savg_DRY)) W m**-2

        Average LAND $(BOLD(uppercase(long))) (1979-2019):
          $(BOLD("DTP (Deep Tropics):"))          $(@sprintf("%0.2f",lavg_DTP)) W m**-2
          $(BOLD("IPW (Indo-Pacific Warmpool):")) $(@sprintf("%0.2f",lavg_IPW)) W m**-2
          $(BOLD("WPW (West Pacific Warmpool):")) $(@sprintf("%0.2f",lavg_WPW)) W m**-2
        """
    end

end

function plotfluxes(
    bins::AbstractRange,
    lvls::AbstractArray,
    cmap::AbstractString,
    extd::AbstractString;
    verbose::Bool=false
)

    ds = NCDataset(datadir("SPCAM/FSNS.nc"))
    lon = ds["longitude"][:]
    lat = ds["latitude"][:]
    SW = ds["FSNS"][:]*1; close(ds)

    ds = NCDataset(datadir("SPCAM/FLNS.nc"))
    LW = ds["FLNS"][:]*-1; close(ds)

    ds = NCDataset(datadir("SPCAM/SHFLX.nc"))
    SH = ds["SHFLX"][:]*-1; close(ds)

    ds = NCDataset(datadir("SPCAM/LHFLX.nc"))
    LH = ds["LHFLX"][:]*-1; close(ds)
    var = SW .+ LW .+ SH .+ LH

    ds = NCDataset(datadir("SPCAM/LANDFRAC.nc"))
    lsm = ds["LANDFRAC"][:]*1
    close(ds)

    pbin = (bins[2:end].+bins[1:(end-1)])/2

    lbin_DTP,sbin_DTP,lavg_DTP,savg_DTP = bindatasfc([15,-15,360,0],bins,var,lon,lat,lsm)
    lbin_IPW,sbin_IPW,lavg_IPW,savg_IPW = bindatasfc([15,-15,180,90],bins,var,lon,lat,lsm)
    lbin_WPW,sbin_WPW,lavg_WPW,savg_WPW = bindatasfc([5,-10,180,135],bins,var,lon,lat,lsm)
    lbin_DRY,sbin_DRY,lavg_DRY,savg_DRY = bindatasfc([5,-5,275,180],bins,var,lon,lat,lsm)

    coord = readdlm(datadir("GLB-i.txt"),comments=true,comment_char='#')
    x = coord[:,1]; y = coord[:,2];

    DTP = prect(15,-15,0,360)
    WPW = prect(5,-10,135,180)
    IPW = prect(15,-15,90,180)
    DRY = prect(5,-5,180,275)

    pplt.close(); arr = [[1,1],[2,3]];
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
        suptitle="SURFACE ENERGY BALANCE / W m**-2"
    )
    f.colorbar(c1,loc="r")

    axs[2].plot(pbin,lbin_DTP,c="b",lw=0.5); axs[2].plot([1,1]*lavg_DTP,[0.1,50],c="b")
    axs[2].plot(pbin,lbin_IPW,c="r",lw=0.5); axs[2].plot([1,1]*lavg_IPW,[0.1,50],c="r")
    axs[2].plot(pbin,lbin_WPW,c="k",lw=0.5); axs[2].plot([1,1]*lavg_WPW,[0.1,50],c="k")
    axs[2].format(
        xlim=(minimum(bins),maximum(bins)),ylim=(0.1,50),yscale="log",
        rtitle="Land",ylabel="Normalized Frequency"
    )

    axs[3].plot(pbin,sbin_DTP,c="b",lw=0.5); axs[3].plot([1,1]*savg_DTP,[0.1,50],c="b")
    axs[3].plot(pbin,sbin_IPW,c="r",lw=0.5); axs[3].plot([1,1]*savg_IPW,[0.1,50],c="r")
    axs[3].plot(pbin,sbin_WPW,c="k",lw=0.5); axs[3].plot([1,1]*savg_WPW,[0.1,50],c="k")
    axs[3].plot(pbin,sbin_DRY,c="k",lw=0.5,linestyle=":")
    axs[3].plot([1,1]*savg_DRY,[0.1,50],c="k",linestyle=":")
    axs[3].format(
        xlim=(minimum(bins),maximum(bins)),ylim=(0.1,50),yscale="log",
        rtitle="Ocean"
    )

    for ax in axs
        ax.format(abc=true,grid="on")
    end

    mkpath(plotsdir("SPCAM"))
    f.savefig(plotsdir("SPCAM/SEB.png"),transparent=false,dpi=200)

    if verbose
        @info """Average OCEAN SURFACE ENERGY BALANCE (1979-2019):
          $(BOLD("DTP (Deep Tropics):"))          $(@sprintf("%0.2f",savg_DTP)) W m**-2
          $(BOLD("IPW (Indo-Pacific Warmpool):")) $(@sprintf("%0.2f",savg_IPW)) W m**-2
          $(BOLD("WPW (West Pacific Warmpool):")) $(@sprintf("%0.2f",savg_WPW)) W m**-2
          $(BOLD("DRY (Dry Pacific):"))           $(@sprintf("%0.2f",savg_DRY)) W m**-2

        Average LAND SURFACE ENERGY BALANCE (1979-2019):
          $(BOLD("DTP (Deep Tropics):"))          $(@sprintf("%0.2f",lavg_DTP)) W m**-2
          $(BOLD("IPW (Indo-Pacific Warmpool):")) $(@sprintf("%0.2f",lavg_IPW)) W m**-2
          $(BOLD("WPW (West Pacific Warmpool):")) $(@sprintf("%0.2f",lavg_WPW)) W m**-2
        """
    end

end

# compilesfceb()
plotfluxes("FSNS",100:2:300,100:10:300,"Reds","max",verbose=true)
# plotfluxes("FLNS",-150:2:0,-100:10:0,"Blues_r","min",verbose=true)
# plotfluxes("SHFLX",-75:0,-75:5:0,"Blues_r","min",verbose=true)
# plotfluxes("LHFLX",-250:5:0,-250:10:0,"Blues_r","min",verbose=true)
plotfluxes(-200:5:200,-150:20:150,"RdBu_r","both",verbose=true)
