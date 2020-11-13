using NCDatasets
using NumericalIntegration
using Statistics

using PyCall
using LaTeXStrings
pplt = pyimport("proplot");

function retrievevar(
    variable::AbstractString,
    experiment::AbstractString,
    config::AbstractString
)

    rce = NCDataset(datadir(joinpath(
        experiment,config,"OUT_STAT",
        "RCE_TropicalRCE-$(experiment).nc"
    )))
    var = rce[variable][:]*1
    close(rce)

    return var

end

function temp2qsat(t::Real,p::Real)

    tb = t - 273.15
    if tb <= 0
        esat = exp(43.494 - 6545.8/(tb+278)) / (tb+868)^2
    else
        esat = exp(34.494 - 4924.99/(tb+237.1)) / (tb+105)^1.57
    end


    r = 0.622 * esat / max(esat,p-esat)
    return r / (1+r)

end

function plotsample(
    experiment::AbstractString, config::AbstractString;
    dbeg::Integer, dend::Integer
)

    p    = retrievevar("p",experiment,config)
    t    = retrievevar("time",experiment,config) .- 80; nt = length(t)
    cld  = retrievevar("CLD",experiment,config)*100
    qv   = retrievevar("QV",experiment,config)/1000
    tair = retrievevar("TABS",experiment,config)
    prcp = retrievevar("PREC",experiment,config)
    insl = retrievevar("SWNS",experiment,config)

    rh = zeros(size(qv,1)+1,nt)
    for it = 1 : nt, ilvl = 1 : length(p)

        rh[ilvl,it] = qv[ilvl,it] / temp2qsat(tair[ilvl,it],p[ilvl]*100)

    end

    pvec = vcat(0,reverse(p)); pint = integrate(pvec,ones(length(p)+1))
    csf = zeros(nt)
    for it = 1 : nt
        csf[it] = integrate(pvec,@view rh[:,it]) / pint
    end

    arr = [[0,1,1,0],[2,2,3,3]]
    pplt.close(); f,axs = pplt.subplots(arr,axwidth=4,aspect=2,sharex=2)

    prcp = dropdims(mean(reshape(prcp,24,:),dims=2),dims=2)[:]
    insl = dropdims(mean(reshape(insl,24,:),dims=2),dims=2)[:]

    axs[1].scatter(mod.((0:23).+12.5,24),prcp)
    ax2 = axs[1].twinx()
    ax2.scatter(mod.((0:23).+12.5,24),insl,c="r")

    axs[2].contourf(t,p,tair,levels=150:10:300);
    axs[2].format(ylabel="Pressure / hPa")

    axs[3].contourf(t,p,cld,levels=0:10:100);
    axs[3].format(ylabel="Pressure / hPa")

    axs[1].format(suptitle="$(uppercase(experiment)) | $(uppercase(config))");

    for ax in axs; ax.format(xlim=(0,24)) end

    if !isdir(plotsdir("SAM-SAMPLE")); mkpath(plotsdir("SAM-SAMPLE")) end
    f.savefig(plotsdir("SAM-SAMPLE/$experiment-$config.png"),transparent=false,dpi=200)

end

plotsample("Shear","DTP1M",dbeg=195,dend=200)
