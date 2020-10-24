using DrWatson
@quickactivate "TropicalRCE"
using GeoRegions

using PyCall
using LaTeXStrings
pplt = pyimport("proplot");

include(srcdir("reanalysis.jl"))

function plotwair()

    ds = NCDataset(datadir("reanalysis/era5-TRPx0.25-w_air.nc"))

    lon = ds["longitude"][:]; nlon = length(lon)
    lat = ds["latitude"][:];  nlat = length(lat)
    lvl = ds["level"][:];     nlvl = length(lvl)
    var = ds["w_air"][:]*1

    long = ds["w_air"].attrib["long_name"]
    unit = ds["w_air"].attrib["units"]

    close(ds)

    ds = NCDataset(datadir("reanalysis/era5-TRPx0.25-z_air.nc"))
    zlvl = ds["level"][:]
    zair = ds["z_air"][:]*1
    close(ds)

    ds = NCDataset(datadir("reanalysis/era5-TRPx0.25-lsm-sfc.nc"))
    lsm = ds["lsm"][:]*1
    close(ds)

    lprf_DTP,sprf_DTP = getmean([20,-20,270,60],var,lon,lat,nlvl,lsm)
    lprf_IPW,sprf_IPW = getmean([15,-15,180,90],var,lon,lat,nlvl,lsm)
    lprf_WPW,sprf_WPW = getmean([5,-10,180,135],var,lon,lat,nlvl,lsm)
    lprf_DRY,sprf_DRY = getmean([5,-5,275,180],var,lon,lat,nlvl,lsm)

    pplt.close(); f,axs = pplt.subplots(ncols=2,aspect=0.5,axwidth=2);

    axs[1].plot(lprf_DTP,lvl,c="b")
    axs[1].plot(lprf_IPW,lvl,c="r")
    axs[1].plot(lprf_WPW,lvl,c="k")
    # axs[1].plot(lprf_DRY,lvl,c="k",linestyle=":")
    axs[1].format(xlim=(-0.075,0.075),title="Land")

    axs[2].plot(sprf_DTP,lvl,c="b")
    axs[2].plot(sprf_IPW,lvl,c="r")
    axs[2].plot(sprf_WPW,lvl,c="k")
    axs[2].plot(sprf_DRY,lvl,c="k",linestyle=":")
    axs[2].format(xlim=(-0.075,0.075),title=L"Ocean")

    for ax in axs
        ax.format(
            abc=true,grid="on",ylim=(1000,100),
            xlabel=L"Vertical Velocity / Pa s$^{-1}$",ylabel="Pressure / hPa"
        )
    end

    mkpath(plotsdir("REANALYSIS"))
    f.savefig(plotsdir("REANALYSIS/w_air.png"),transparent=false,dpi=200)


end

function plottair()

    ds = NCDataset(datadir("reanalysis/era5-TRPx0.25-t_air.nc"))

    lon = ds["longitude"][:]; nlon = length(lon)
    lat = ds["latitude"][:];  nlat = length(lat)
    lvl = ds["level"][:];     nlvl = length(lvl)
    var = ds["t_air"][:]*1

    long = ds["t_air"].attrib["long_name"]
    unit = ds["t_air"].attrib["units"]

    close(ds)

    ds = NCDataset(datadir("reanalysis/era5-TRPx0.25-z_air.nc"))
    zlvl = ds["level"][:]
    zair = ds["z_air"][:]*1
    close(ds)

    ds = NCDataset(datadir("reanalysis/era5-TRPx0.25-lsm-sfc.nc"))
    lsm = ds["lsm"][:]*1
    close(ds)

    lprf_DTP,sprf_DTP = getmean([20,-20,270,60],var,lon,lat,nlvl,lsm)
    lprf_IPW,sprf_IPW = getmean([15,-15,180,90],var,lon,lat,nlvl,lsm)
    lprf_WPW,sprf_WPW = getmean([5,-10,180,135],var,lon,lat,nlvl,lsm)
    lprf_DRY,sprf_DRY = getmean([5,-5,275,180],var,lon,lat,nlvl,lsm)

    pplt.close(); f,axs = pplt.subplots(ncols=3,aspect=0.5,axwidth=2);

    axs[1].plot(sprf_DTP,lvl,c="b")
    axs[1].format(title="DTP_OCN",xlim=(190,310))

    axs[2].plot(lprf_DTP.-sprf_DTP,lvl,c="b")
    axs[2].plot(lprf_IPW.-sprf_DTP,lvl,c="r")
    axs[2].plot(lprf_WPW.-sprf_DTP,lvl,c="k")
    axs[2].format(xlim=(-3,3),title=L"Land $-$ DTP_OCN")

    axs[3].plot(sprf_IPW.-sprf_DTP,lvl,c="r")
    axs[3].plot(sprf_WPW.-sprf_DTP,lvl,c="k")
    axs[3].plot(sprf_DRY.-sprf_DTP,lvl,c="k",linestyle=":")
    axs[3].format(xlim=(-3,3),title=L"Ocean $-$ DTP_OCN")

    for ax in axs
        ax.format(
            abc=true,grid="on",ylim=(1000,100),
            xlabel="Temperature / K",ylabel="Pressure / hPa"
        )
    end

    mkpath(plotsdir("REANALYSIS"))
    f.savefig(plotsdir("REANALYSIS/t_air.png"),transparent=false,dpi=200)


end

plotwair(); plottair()
