using DrWatson
@quickactivate "TropicalRCE"

using Dierckx
using NCDatasets
using Statistics

using PyCall
using LaTeXStrings
pplt = pyimport("proplot");

include(srcdir("reanalysis.jl"))

function tairreanalysis(coords::Vector{<:Real})

    ds = NCDataset(datadir("reanalysis/era5-TRPx0.25-t_air.nc"))

    lon = ds["longitude"][:]; nlon = length(lon)
    lat = ds["latitude"][:];  nlat = length(lat)
    lvl = ds["level"][:];     nlvl = length(lvl)
    var = ds["t_air"][:]*1

    long = ds["t_air"].attrib["long_name"]
    unit = ds["t_air"].attrib["units"]

    close(ds)

    ds = NCDataset(datadir("reanalysis/era5-TRPx0.25-lsm-sfc.nc"))
    lsm = ds["lsm"][:]*1
    close(ds)

    lprf,sprf = getmean(coords,var,lon,lat,nlvl,lsm)

    return lvl,lprf,sprf

end

function tairSAM(
    experiment::AbstractString, configuration::AbstractString,
    lvl::AbstractVector{<:Real};
    days::Integer=100
)

    rce = NCDataset(datadir(joinpath(
        experiment,configuration,"OUT_STAT",
        "RCE_DiConv-$(experiment).nc"
    )))

    p = rce["p"][:]; t = rce["time"][:]; t_air = rce["TABS"][:]

    close(rce)

    tstep = round(Integer,(length(t)-1)/(t[end]-t[1]))
    beg = days*tstep - 1
    t_air = dropdims(mean(t_air[:,(end-beg):end],dims=2),dims=2);
    lvl = lvl[lvl.>minimum(p)]
    spl = Spline1D(reverse(p),reverse(t_air))

    return lvl,spl(lvl)

end

elvl,_,ocn_WPW = tairreanalysis([5,-10,180,135])
slvl,sst301d0_WPW   = tairSAM("WPW2M","sst301d0",elvl)
ilvl = length(elvl) - length(slvl)

pplt.close(); f,axs = pplt.subplots(ncols=3,aspect=0.5,axwidth=1.5);

axs[1].plot(ocn_WPW,elvl,c="b")
axs[1].format(title="WPW_OCN")

axs[2].plot(sst301d0_WPW.-ocn_WPW[(1+i):end],slvl,c="b")
axs[2].format(xlim=(-10,10),title=L"SAM $-$ WPW_OCN")

for ax in axs
    ax.format(
        abc=true,grid="on",ylim=(1000,50),
        xlabel="Temperature / K",ylabel="Pressure / hPa"
    )
end

mkpath(plotsdir("COMPARISON"))
f.savefig(plotsdir("COMPARISON/t_air-WPW.png"),transparent=false,dpi=200)
