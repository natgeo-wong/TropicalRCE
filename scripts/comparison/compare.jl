using DrWatson
@quickactivate "TropicalRCE"

using PyCall
using LaTeXStrings
pplt = pyimport("proplot");

include(srcdir("common.jl"))
include(srcdir("reanalysis.jl"))
include(srcdir("SAM.jl"))

svar = "TABS"; evar = "t_air"

pplt.close(); f,axs = pplt.subplots(
    ncols=8,aspect=0.5,axwidth=1.5,
    hspace=[0,nothing,0,nothing,0,nothing,0]
);

elvl,_,ocn_DTP = prereanalysis(evar,[15,-15,360,0])
_,DTP_2DH = preinterp(svar,"Control2DHR","DTP1M",elvl)
_,DTP_LSV = preinterp(svar,"LSVert","DTP1M",elvl)
_,DTP_SHR = preinterp(svar,"Shear","DTP1M",elvl)
axs[1].plot(ocn_DTP,elvl,c="k"); axs[1].format(title="DTP_OCN")
axs[2].plot(DTP1M_2DH.-ocn_DTP,elvl)
axs[2].plot(DTP1M_LSV.-ocn_DTP,elvl)
axs[2].plot(DTP1M_SHR.-ocn_DTP,elvl)
axs[2].format(title="SAM - DTP_OCN")

_,_,ocn_IPW = prereanalysis(evar,[15,-15,180,90])
_,IPW_2DH = preinterp(svar,"Control2DHR","IPW1M",elvl)
_,IPW_LSV = preinterp(svar,"LSVert","IPW1M",elvl)
_,IPW_SHR = preinterp(svar,"Shear","IPW1M",elvl)
axs[3].plot(ocn_IPW,elvl,c="k"); axs[3].format(title="IPW_OCN")
axs[4].plot(IPW1M_2DH.-ocn_IPW,elvl)
axs[4].plot(IPW1M_LSV.-ocn_IPW,elvl)
axs[4].plot(IPW1M_SHR.-ocn_IPW,elvl)
axs[4].format(title="SAM - IPW_OCN")

_,_,ocn_WPW = prereanalysis(evar,[5,-10,180,135])
_,WPW_2DH = preinterp(svar,"Control2DHR","WPW1M",elvl)
_,WPW_LSV = preinterp(svar,"LSVert","WPW1M",elvl)
_,WPW_SHR = preinterp(svar,"Shear","WPW1M",elvl)
axs[5].plot(ocn_WPW,elvl,c="k"); axs[5].format(title="WPW_OCN")
axs[6].plot(WPW1M_2DH.-ocn_WPW,elvl)
axs[6].plot(WPW1M_LSV.-ocn_WPW,elvl)
axs[6].plot(WPW1M_SHR.-ocn_WPW,elvl)
axs[6].format(title="SAM - WPW_OCN")

_,_,ocn_DRY = prereanalysis(evar,[5,-5,275,180])
_,DRY_2DH = preinterp(svar,"Control2DHR","DRY1M",elvl)
_,DRY_LSV = preinterp(svar,"LSVert","DRY1M",elvl)
_,DRY_SHR = preinterp(svar,"Shear","DRY1M",elvl)
axs[7].plot(ocn_DRY,elvl,c="k"); axs[7].format(title="DRY_OCN")
axs[8].plot(DRY1M_2DH.-ocn_DRY,elvl)
axs[8].plot(DRY1M_LSV.-ocn_DRY,elvl)
axs[8].plot(DRY1M_SHR.-ocn_DRY,elvl)
axs[8].format(title="SAM - DRY_OCN")

for ii = 1 : 2 : 8
    axs[ii].format(
        abc=true,grid="on",ylim=(1000,70),
        xlim=(180,310),xlabel="Temperature / K",
        ylabel="Pressure / hPa"
    )
    axs[ii+1].format(
        abc=true,grid="on",ylim=(1000,70),
        xlim=(-10,10),xlabel="Temperature / K",
        ylabel="Pressure / hPa"
    )
end

mkpath(plotsdir("COMPARISON"))
f.savefig(plotsdir("COMPARISON/$(evar)_comparison.png"),transparent=false,dpi=200)
