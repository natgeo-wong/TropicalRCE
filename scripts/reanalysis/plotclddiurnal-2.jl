using DrWatson
@quickactivate "TropicalRCE"
using Interpolations
using NCDatasets
using StatsBase

using PyCall
using LaTeXStrings
pplt = pyimport("proplot");

include(srcdir("reanalysis.jl"))

ds = NCDataset(datadir("reanalysis/era5-TRPx0.25-cc_air-hour.nc"))

lon = ds["longitude"][481]
lat = ds["latitude"][121]
cca = ds["cc_air"][400,121,10,:]*1
t   = (0:23) .+ lon/15

close(ds)

itp = interpolate(cca,BSpline(Cubic(Periodic(OnGrid()))))
stp = scale(itp,t)
etp = extrapolate(stp,Periodic())

cca1 = vcat(cca,cca[1])
itp1 = interpolate(cca1,BSpline(Cubic(Periodic(OnGrid()))))
stp1 = scale(itp1,(0:24) .+ lon/15)
etp1 = extrapolate(stp1,Periodic())

cca_1 = etp[0:48]
cca_2 = etp1[0:48]

pplt.close(); f,axs = pplt.subplots(axwidth=6,aspect=6)
# axs[1].plot(t,cca,c="r",lw=10)
# axs[1].plot(vcat(t.-24,t,t.+24),vcat(cca,cca,cca),lw=5)
# axs[1].plot(0:48,cca_1)
axs[1].plot(0:24,vcat(cca[17:end],cca[1:17]) .- cca_2[1:25],lw=1,c="k")
axs[1].format(xlim=(0,48))
f.savefig(plotsdir("REANALYSIS/cc_air-ts.png"),transparent=false,dpi=200)
