using DrWatson
@quickactivate "TropicalRCE"

using PyCall
using LaTeXStrings
pplt = pyimport("proplot");

include(srcdir("common.jl"))
include(srcdir("reanalysis.jl"))
include(srcdir("SAM.jl"))

svar = "TABS"; evar = "t_air"

pplt.close(); f,axs = pplt.subplots(ncols=4,aspect=0.5,axwidth=1.5);

elvl,_,ocn_DTP = prereanalysis(evar,[15,-15,360,0])
_,DTP1M_3DLR = preinterp(svar,"Control3D","DTP1M",elvl)
_,DTP2M_3DLR = preinterp(svar,"Control3D","DTP2M",elvl)
_,DTP1M_2DLR = preinterp(svar,"Control2D","DTP1M",elvl)
_,DTP2M_2DLR = preinterp(svar,"Control2D","DTP2M",elvl)
_,DTP1M_2DHR = preinterp(svar,"Control2DHR","DTP1M",elvl)
_,DTP2M_2DHR = preinterp(svar,"Control2DHR","DTP2M",elvl)
axs[1].plot(ocn_DTP,elvl,c="k")
axs[1].plot(DTP1M_3DLR.-ocn_DTP,elvl,c="b")
axs[1].plot(DTP1M_2DLR.-ocn_DTP,elvl,c="b",linestyle="--")
axs[1].plot(DTP1M_2DHR.-ocn_DTP,elvl,c="b",linestyle=":")
axs[1].plot(DTP2M_3DLR.-ocn_DTP,elvl,c="r")
axs[1].plot(DTP2M_2DLR.-ocn_DTP,elvl,c="r",linestyle="--")
axs[1].plot(DTP2M_2DHR.-ocn_DTP,elvl,c="r",linestyle=":")
axs[1].format(title="SAM - DTP_OCN")

_,_,ocn_IPW = prereanalysis(evar,[15,-15,180,90])
_,IPW1M_3DLR = preinterp(svar,"Control3D","IPW1M",elvl)
_,IPW2M_3DLR = preinterp(svar,"Control3D","IPW2M",elvl)
_,IPW1M_2DLR = preinterp(svar,"Control2D","IPW1M",elvl)
_,IPW2M_2DLR = preinterp(svar,"Control2D","IPW2M",elvl)
_,IPW1M_2DHR = preinterp(svar,"Control2DHR","IPW1M",elvl)
_,IPW2M_2DHR = preinterp(svar,"Control2DHR","IPW2M",elvl)
axs[2].plot(ocn_IPW,elvl,c="k")
axs[2].plot(IPW1M_3DLR.-ocn_IPW,elvl,c="b")
axs[2].plot(IPW1M_2DLR.-ocn_IPW,elvl,c="b",linestyle="--")
axs[2].plot(IPW1M_2DHR.-ocn_IPW,elvl,c="b",linestyle=":")
axs[2].plot(IPW2M_3DLR.-ocn_IPW,elvl,c="r")
axs[2].plot(IPW2M_2DLR.-ocn_IPW,elvl,c="r",linestyle="--")
axs[2].plot(IPW2M_2DHR.-ocn_IPW,elvl,c="r",linestyle=":")
axs[2].format(title="SAM - IPW_OCN")

_,_,ocn_WPW = prereanalysis(evar,[5,-10,180,135])
_,WPW1M_3DLR = preinterp(svar,"Control3D","WPW1M",elvl)
_,WPW2M_3DLR = preinterp(svar,"Control3D","WPW2M",elvl)
_,WPW1M_2DLR = preinterp(svar,"Control2D","WPW1M",elvl)
_,WPW2M_2DLR = preinterp(svar,"Control2D","WPW2M",elvl)
_,WPW1M_2DHR = preinterp(svar,"Control2DHR","WPW1M",elvl)
_,WPW2M_2DHR = preinterp(svar,"Control2DHR","WPW2M",elvl)
axs[3].plot(ocn_WPW,elvl,c="k")
axs[3].plot(WPW1M_3DLR.-ocn_WPW,elvl,c="b")
axs[3].plot(WPW1M_2DLR.-ocn_WPW,elvl,c="b",linestyle="--")
axs[3].plot(WPW1M_2DHR.-ocn_WPW,elvl,c="b",linestyle=":")
axs[3].plot(WPW2M_3DLR.-ocn_WPW,elvl,c="r")
axs[3].plot(WPW2M_2DLR.-ocn_WPW,elvl,c="r",linestyle="--")
axs[3].plot(WPW2M_2DHR.-ocn_WPW,elvl,c="r",linestyle=":")
axs[3].format(title="SAM - WPW_OCN")

_,_,ocn_DRY = prereanalysis(evar,[5,-5,275,180])
_,DRY1M_3DLR = preinterp(svar,"Control3D","DRY1M",elvl)
_,DRY2M_3DLR = preinterp(svar,"Control3D","DRY2M",elvl)
_,DRY1M_2DLR = preinterp(svar,"Control2D","DRY1M",elvl)
_,DRY2M_2DLR = preinterp(svar,"Control2D","DRY2M",elvl)
_,DRY1M_2DHR = preinterp(svar,"Control2DHR","DRY1M",elvl)
_,DRY2M_2DHR = preinterp(svar,"Control2DHR","DRY2M",elvl)
axs[4].plot(ocn_DRY,elvl,c="k")
axs[4].plot(DRY1M_3DLR.-ocn_DRY,elvl,c="b")
axs[4].plot(DRY1M_2DLR.-ocn_DRY,elvl,c="b",linestyle="--")
axs[4].plot(DRY1M_2DHR.-ocn_DRY,elvl,c="b",linestyle=":")
axs[4].plot(DRY2M_3DLR.-ocn_DRY,elvl,c="r")
axs[4].plot(DRY2M_2DLR.-ocn_DRY,elvl,c="r",linestyle="--")
axs[4].plot(DRY2M_2DHR.-ocn_DRY,elvl,c="r",linestyle=":")
axs[4].format(title="SAM - DRY_OCN")

for ax in axs
    ax.format(
        abc=true,grid="on",ylim=(1000,70),
        xlim=(-10,10),xlabel="Temperature / K",
        ylabel="Pressure / hPa"
    )
end

mkpath(plotsdir("SAM_CONFIG"))
f.savefig(plotsdir("SAM_CONFIG/$(evar)_comparison.png"),transparent=false,dpi=200)
