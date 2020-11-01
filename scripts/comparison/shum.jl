using DrWatson
@quickactivate "TropicalRCE"

using PyCall
using LaTeXStrings
pplt = pyimport("proplot");

include(srcdir("common.jl"))
include(srcdir("reanalysis.jl"))
include(srcdir("SAM.jl"))

pplt.close(); f,axs = pplt.subplots(ncols=4,aspect=0.5,axwidth=1.5);

elvl,_,ocn_DTP = prereanalysis("q_air",[15,-15,360,0])
slvl_DTP1M,shum_DTP1M = preextract("QV","DTP1M","sst300d8")
slvl_DTP2M,shum_DTP2M = preextract("QV","DTP2M","sst300d8")
axs[1].plot(ocn_DTP,elvl,c="k")
axs[1].plot(shum_DTP1M/1000,slvl_DTP1M,label="SAM1MOM")
axs[1].plot(shum_DTP2M/1000,slvl_DTP2M,label="M2005")
axs[1].format(title="DTP_OCN")

_,_,ocn_IPW = prereanalysis("q_air",[15,-15,180,90])
slvl_IPW1M,shum_IPW1M = preextract("QV","IPW1M","sst301d9")
slvl_IPW2M,shum_IPW2M = preextract("QV","IPW2M","sst301d9")
axs[2].plot(ocn_IPW,elvl,c="k")
axs[2].plot(shum_IPW1M/1000,slvl_IPW1M,label="SAM1MOM")
axs[2].plot(shum_IPW2M/1000,slvl_IPW2M,label="M2005")
axs[2].format(title="IPW_OCN")

_,_,ocn_WPW = prereanalysis("q_air",[5,-10,180,135])
slvl_WPW1M,shum_WPW1M = preextract("QV","WPW1M","sst302d4")
slvl_WPW2M,shum_WPW2M = preextract("QV","WPW2M","sst302d4")
axs[3].plot(ocn_WPW,elvl,c="k")
axs[3].plot(shum_WPW1M/1000,slvl_WPW1M,label="SAM1MOM")
axs[3].plot(shum_WPW2M/1000,slvl_WPW2M,label="M2005")
axs[3].format(title="WPW_OCN")

_,_,ocn_DRY = prereanalysis("q_air",[5,-5,275,180])
slvl_DRY1M,shum_DRY1M = preextract("QV","DRY1M","sst299d7")
slvl_DRY2M,shum_DRY2M = preextract("QV","DRY2M","sst299d7")
axs[4].plot(ocn_DRY,elvl,c="k")
axs[4].plot(shum_DRY1M/1000,slvl_DRY1M,label="SAM1MOM")
axs[4].plot(shum_DRY2M/1000,slvl_DRY2M,label="M2005")
axs[4].format(title="DRY_OCN")

for ax in axs
    ax.format(
        abc=true,grid="on",ylim=(1000,70),xscale="log",
        xlabel="Specific Humidity / kg kg**-1",ylabel="Pressure / hPa"
    )
end

mkpath(plotsdir("COMPARISON"))
f.savefig(plotsdir("COMPARISON/shum.png"),transparent=false,dpi=200)
