using DrWatson
@quickactivate "TropicalRCE"

using PyCall
using LaTeXStrings
pplt = pyimport("proplot");

include(srcdir("common.jl"))
include(srcdir("reanalysis.jl"))
include(srcdir("plot3D.jl"))

function sam3D(experiment::AbstractString,config::AbstractString;days::Integer=100)

    p,t,cld,_,_,_,_ = retrieve3Dvar(experiment,config)
    t,tstep,tshift = t2d(t); beg = days*tstep - 1
    cld  = diurnal(cld[:,(end-beg):end],tstep,tshift)
    mcld = mean(cld,dims=2)
    vcld = cld .- mcld
    mcld = dropdims(mcld,dims=2)

    return t,p,mcld,vcld

end

ds = NCDataset(datadir("reanalysis/era5-TRPx0.25-cc_air-diurnal.nc"))
lon = ds["longitude"][:]
lat = ds["latitude"][:]
lvl = ds["level"][:];    nlvl = length(lvl)
cca = ds["cc_air"][:]*100
close(ds)

ds = NCDataset(datadir("reanalysis/era5-TRPx0.25-lsm-sfc.nc"))
lsm = ds["lsm"][:]*1
close(ds)

occa_DTP = zeros(25,nlvl)

for it = 1 : 24
    _,occa_DTP[it,:] = getmean([15,-15,360,0],cca[:,:,:,it],lon,lat,nlvl,lsm)
end
_,occa_DTP[25,:] = getmean([15,-15,360,0],cca[:,:,:,1],lon,lat,nlvl,lsm)
mocca_DTP = mean(occa_DTP[1:24,:],dims=1)
vocca_DTP = occa_DTP .- mocca_DTP
mocca_DTP = dropdims(mocca_DTP,dims=1)

t,p_RCE,mocca_RCE,vocca_RCE = sam3D("Control2DHR","DTP1M")
_,p_LSV,mocca_LSV,vocca_LSV = sam3D("LSVert","DTP1M")
_,p_SHR,mocca_SHR,vocca_SHR = sam3D("Shear","DTP1M")
# _,p_WTG,mocca_WTG,vocca_WTG = sam3D("WTG","DTP1M")

arr = [[0,0,1,2,2,2,0,0],[3,4,4,4,5,6,6,6],[7,8,8,8,9,10,10,10]]
pplt.close(); f,axs = pplt.subplots(arr,aspect=0.5,axwidth=1,wspace=(0,0,0,nothing,0,0,0));
clvl = [-10,-5,-2,-1,-0.5,-0.2,0.2,0.5,1,2,5,10]

axs[1].plot(mocca_DTP[:],lvl)
c = axs[2].contourf(0:24,lvl,vocca_DTP',cmap="drywet",levels=clvl,extend="both")
axs[1].format(urtitle="ERA5",suptitle="Diurnal Cycle of Cloud Cover / %")

axs[3].plot(mocca_RCE[:],p_RCE)
axs[4].contourf(t,p_RCE,vocca_RCE,cmap="drywet",levels=clvl,extend="both")
axs[3].format(urtitle="RCE")

axs[5].plot(mocca_LSV[:],p_LSV)
axs[6].contourf(t,p_LSV,vocca_LSV,cmap="drywet",levels=clvl,extend="both")
axs[5].format(urtitle="LSVert")

axs[7].plot(mocca_SHR[:],p_SHR)
axs[8].contourf(t,p_SHR,vocca_SHR,cmap="drywet",levels=clvl,extend="both")
axs[7].format(urtitle="Shear")

# axs[9].plot(mocca_WTG[:],lvl)
# axs[10].contourf(t,p_WTG,vocca_WTG',cmap="drywet",levels=clvl,extend="both")
axs[9].format(urtitle="WTG")

for ii = 1 : 10
    axs[ii].format(ylim=(1000,10))
    if mod(ii,2) == 0
        axs[ii].format(xlim=(0,24),xlocator=4:4:20)
    else
        axs[ii].format(xlim=(0,25))
    end
end

f.colorbar(c,loc="r")
f.savefig(plotsdir("COMPARISON/cc_air-diurnal.png"),transparent=false,dpi=200)
