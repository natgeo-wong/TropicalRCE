using DrWatson
@quickactivate "TropicalRCE"

using PyCall
using LaTeXStrings
pplt = pyimport("proplot");

include(srcdir("common.jl"))
include(srcdir("reanalysis.jl"))
include(srcdir("SAM.jl"))

svar = "CLD"; evar = "cc_air"
# svar = "QV"; evar = "q_air"
# svar = "TABS"; evar = "t_air"

pplt.close(); f,axs = pplt.subplots(ncols=4,aspect=0.5,axwidth=1.5);

elvl,_,ocn_DTP = prereanalysis(evar,[15,-15,360,0])
slvl_DTP1M_3DLR,DTP1M_3DLR = preextract(svar,"Control3D","DTP1M")
slvl_DTP2M_3DLR,DTP2M_3DLR = preextract(svar,"Control3D","DTP2M")
slvl_DTP1M_2DLR,DTP1M_2DLR = preextract(svar,"Control2D","DTP1M")
slvl_DTP2M_2DLR,DTP2M_2DLR = preextract(svar,"Control2D","DTP2M")
slvl_DTP1M_2DHR,DTP1M_2DHR = preextract(svar,"Control2DHR","DTP1M")
slvl_DTP2M_2DHR,DTP2M_2DHR = preextract(svar,"Control2DHR","DTP2M")
axs[1].plot(ocn_DTP,elvl,c="k")
axs[1].plot(DTP1M_3DLR,slvl_DTP1M_3DLR,c="b")
axs[1].plot(DTP1M_2DLR,slvl_DTP1M_2DLR,c="b",linestyle="--")
axs[1].plot(DTP1M_2DHR,slvl_DTP1M_2DHR,c="b",linestyle=":")
axs[1].plot(DTP2M_3DLR,slvl_DTP2M_3DLR,c="r")
axs[1].plot(DTP2M_2DLR,slvl_DTP2M_2DLR,c="r",linestyle="--")
axs[1].plot(DTP2M_2DHR,slvl_DTP2M_2DHR,c="r",linestyle=":")
axs[1].format(title="DTP_OCN")

_,_,ocn_IPW = prereanalysis(evar,[15,-15,180,90])
slvl_IPW1M_3DLR,IPW1M_3DLR = preextract(svar,"Control3D","IPW1M")
slvl_IPW2M_3DLR,IPW2M_3DLR = preextract(svar,"Control3D","IPW2M")
slvl_IPW1M_2DLR,IPW1M_2DLR = preextract(svar,"Control2D","IPW1M")
slvl_IPW2M_2DLR,IPW2M_2DLR = preextract(svar,"Control2D","IPW2M")
slvl_IPW1M_2DHR,IPW1M_2DHR = preextract(svar,"Control2DHR","IPW1M")
slvl_IPW2M_2DHR,IPW2M_2DHR = preextract(svar,"Control2DHR","IPW2M")
axs[2].plot(ocn_IPW,elvl,c="k")
axs[2].plot(IPW1M_3DLR,slvl_IPW1M_3DLR,c="b")
axs[2].plot(IPW1M_2DLR,slvl_IPW1M_2DLR,c="b",linestyle="--")
axs[2].plot(IPW1M_2DHR,slvl_IPW1M_2DHR,c="b",linestyle=":")
axs[2].plot(IPW2M_3DLR,slvl_IPW2M_3DLR,c="r")
axs[2].plot(IPW2M_2DLR,slvl_IPW2M_2DLR,c="r",linestyle="--")
axs[2].plot(IPW2M_2DHR,slvl_IPW2M_2DHR,c="r",linestyle=":")
axs[2].format(title="IPW_OCN")

_,_,ocn_WPW = prereanalysis(evar,[5,-10,180,135])
slvl_WPW1M_3DLR,WPW1M_3DLR = preextract(svar,"Control3D","WPW1M")
slvl_WPW2M_3DLR,WPW2M_3DLR = preextract(svar,"Control3D","WPW2M")
slvl_WPW1M_2DLR,WPW1M_2DLR = preextract(svar,"Control2D","WPW1M")
slvl_WPW2M_2DLR,WPW2M_2DLR = preextract(svar,"Control2D","WPW2M")
slvl_WPW1M_2DHR,WPW1M_2DHR = preextract(svar,"Control2DHR","WPW1M")
slvl_WPW2M_2DHR,WPW2M_2DHR = preextract(svar,"Control2DHR","WPW2M")
axs[3].plot(ocn_WPW,elvl,c="k")
axs[3].plot(WPW1M_3DLR,slvl_WPW1M_3DLR,c="b")
axs[3].plot(WPW1M_2DLR,slvl_WPW1M_2DLR,c="b",linestyle="--")
axs[3].plot(WPW1M_2DHR,slvl_WPW1M_2DHR,c="b",linestyle=":")
axs[3].plot(WPW2M_3DLR,slvl_WPW2M_3DLR,c="r")
axs[3].plot(WPW2M_2DLR,slvl_WPW2M_2DLR,c="r",linestyle="--")
axs[3].plot(WPW2M_2DHR,slvl_WPW2M_2DHR,c="r",linestyle=":")
axs[3].format(title="WPW_OCN")

_,_,ocn_DRY = prereanalysis(evar,[5,-5,275,180])
slvl_DRY1M_3DLR,DRY1M_3DLR = preextract(svar,"Control3D","DRY1M")
slvl_DRY2M_3DLR,DRY2M_3DLR = preextract(svar,"Control3D","DRY2M")
slvl_DRY1M_2DLR,DRY1M_2DLR = preextract(svar,"Control2D","DRY1M")
slvl_DRY2M_2DLR,DRY2M_2DLR = preextract(svar,"Control2D","DRY2M")
slvl_DRY1M_2DHR,DRY1M_2DHR = preextract(svar,"Control2DHR","DRY1M")
slvl_DRY2M_2DHR,DRY2M_2DHR = preextract(svar,"Control2DHR","DRY2M")
axs[4].plot(ocn_DRY,elvl,c="k")
axs[4].plot(DRY1M_3DLR,slvl_DRY1M_3DLR,c="b")
axs[4].plot(DRY1M_2DLR,slvl_DRY1M_2DLR,c="b",linestyle="--")
axs[4].plot(DRY1M_2DHR,slvl_DRY1M_2DHR,c="b",linestyle=":")
axs[4].plot(DRY2M_3DLR,slvl_DRY2M_3DLR,c="r")
axs[4].plot(DRY2M_2DLR,slvl_DRY2M_2DLR,c="r",linestyle="--")
axs[4].plot(DRY2M_2DHR,slvl_DRY2M_2DHR,c="r",linestyle=":")
axs[4].format(title="DRY_OCN")

for ax in axs
    ax.format(
        abc=true,grid="on",ylim=(1000,70),
        xlim=(0.01,1),xscale="log",xlabel="Cloud Fraction",
        #xlim=(0.001,20),xscale="log",xlabel="Specific Humidity / g kg**-1",
        #xlim=(180,310),xlabel="Temperature / K",
        ylabel="Pressure / hPa"
    )
end

mkpath(plotsdir("SAM_CONFIG"))
f.savefig(plotsdir("SAM_CONFIG/$(evar).png"),transparent=false,dpi=200)
