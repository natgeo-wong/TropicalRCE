using DrWatson
@quickactivate "TropicalRCE"

using PyCall
using LaTeXStrings
pplt = pyimport("proplot");

include(srcdir("common.jl"))
include(srcdir("reanalysis.jl"))
include(srcdir("SAM.jl"))

pplt.close(); f,axs = pplt.subplots(ncols=4,aspect=0.5,axwidth=1.5);

elvl,_,ocn_DTP = prereanalysis("cc_air",[15,-15,360,0])
slvl_DTP1M,cld_DTP1M = preextract("CLD","DTP1M","sst300d8")
slvl_DTP2M,cld_DTP2M = preextract("CLD","DTP2M","sst300d8")
axs[1].plot(ocn_DTP,elvl,c="k")
axs[1].plot(cld_DTP1M,slvl_DTP1M,label="SAM1MOM")
axs[1].plot(cld_DTP2M,slvl_DTP2M,label="M2005")
axs[1].format(title="DTP_OCN",xlim=(0,1))

_,_,ocn_IPW = prereanalysis("cc_air",[15,-15,180,90])
slvl_IPW1M,cld_IPW1M = preextract("CLD","IPW1M","sst301d9")
slvl_IPW2M,cld_IPW2M = preextract("CLD","IPW2M","sst301d9")
axs[2].plot(ocn_IPW,elvl,c="k")
axs[2].plot(cld_IPW1M,slvl_IPW1M,label="SAM1MOM")
axs[2].plot(cld_IPW2M,slvl_IPW2M,label="M2005")
axs[2].format(title="IPW_OCN",xlim=(0,1))

_,_,ocn_WPW = prereanalysis("cc_air",[5,-10,180,135])
slvl_WPW1M,cld_WPW1M = preextract("CLD","WPW1M","sst302d4")
slvl_WPW2M,cld_WPW2M = preextract("CLD","WPW2M","sst302d4")
axs[3].plot(ocn_WPW,elvl,c="k")
axs[3].plot(cld_WPW1M,slvl_WPW1M,label="SAM1MOM")
axs[3].plot(cld_WPW2M,slvl_WPW2M,label="M2005")
axs[3].format(title="WPW_OCN",xlim=(0,1))

_,_,ocn_DRY = prereanalysis("cc_air",[5,-5,275,180])
slvl_DRY1M,cld_DRY1M = preextract("CLD","DRY1M","sst299d7")
slvl_DRY2M,cld_DRY2M = preextract("CLD","DRY2M","sst299d7")
axs[4].plot(ocn_DRY,elvl,c="k")
axs[4].plot(cld_DRY1M,slvl_DRY1M,label="SAM1MOM")
axs[4].plot(cld_DRY2M,slvl_DRY2M,label="M2005")
axs[4].format(title="DRY_OCN",xlim=(0,1))

for ax in axs
    ax.format(
        abc=true,grid="on",ylim=(1000,70),
        xlabel="Cloud Fraction",ylabel="Pressure / hPa"
    )
end

mkpath(plotsdir("COMPARISON"))
f.savefig(plotsdir("COMPARISON/cld_air.png"),transparent=false,dpi=200)
