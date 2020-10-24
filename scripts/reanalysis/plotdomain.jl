using DrWatson
@quickactivate "TropicalRCE"

using PyCall
using LaTeXStrings
pplt = pyimport("proplot");

include(srcdir("reanalysis.jl"))

DTP = prect(15,-15,0,360)
WPW = prect(5,-10,135,180)
IPW = prect(15,-15,90,180)
DRY = prect(5,-5,180,275)

coord = readdlm(datadir("GLB-i.txt"),comments=true,comment_char='#')
x = coord[:,1]; y = coord[:,2];

pplt.close(); f,axs = pplt.subplots(nrows=1,aspect=6,axwidth=6,sharey=0);

axs[1].plot(x,y,c="k",lw=0.2)
axs[1].plot(DTP[1],DTP[2],c="b",lw=1)
axs[1].plot(IPW[1],IPW[2],c="r",lw=1)
axs[1].plot(WPW[1],WPW[2],c="k",lw=1)
axs[1].plot(DRY[1],DRY[2],c="k",lw=1,linestyle="--")

axs[1].text(6  , 5,"DTP",verticalalignment="center",backgroundcolor="gray4")
axs[1].text(155, 3,"WPW",verticalalignment="center",backgroundcolor="gray4")
axs[1].text(95,-15,"IPW",verticalalignment="center",backgroundcolor="gray4")
axs[1].text(190,-5,"DRY",verticalalignment="center",backgroundcolor="gray4")

axs[1].format(
    xlim=(0,360),xlocator=0:60:360,
    ylim=(-30,30),ylocator=-30:10:30
)

mkpath(plotsdir("REANALYSIS"))
f.savefig(plotsdir("REANALYSIS/domain.png"),transparent=false,dpi=200)
