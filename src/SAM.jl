using NCDatasets
using PrettyTables
using Statistics

function sfcextract(
    variable::AbstractString,
    experiment::AbstractString,
    config::AbstractString
)

    dfnc = joinpath(datadir(
        experiment,config,"OUT_STAT",
        "RCE_TropicalRCE-$(experiment).nc"
    ))
    rce = NCDataset(dfnc)
    t = rce["time"][:] .- 80; var = rce[variable][:]

    close(rce)


    return t,var

end

function sfcsummary(
    variable::AbstractString,
    experiment::AbstractString,
    control::AbstractString,
    config::AbstractVector{<:AbstractString},
    days::Integer=100
)

    nconfig = length(config)
    vartable = zeros(nconfig+1,3)
    tc,varc = sfcextract(variable,experiment,control)
    tstepc = round(Integer,(length(tc) - 1) / (tc[end] - tc[1]))
    varc = mean(reshape(varc,tstepc,:)[:,(end-days+1):end])

    vartable[1,1] = parse(Float32,replace(replace(control,"sst"=>""),"d"=>"."))
    vartable[1,2] = varc
    vartable[1,3] = 0

    for icon = 1 : nconfig

        t,var = sfcextract(variable,experiment,config[icon])

        tstep = round(Integer,(length(t) - 1) / (t[end] - t[1]))

        vartable[icon+1,1] = parse(Float32,replace(replace(config[icon],"sst"=>""),"d"=>"."))
        vartable[icon+1,2] = mean(reshape(var,tstep,:)[:,(end-days+1):end])
        vartable[icon+1,3] = mean(reshape(var,tstep,:)[:,(end-days+1):end]) - varc

    end

    head = ["SAM SST / K","$variable","Config - Control"];

    pretty_table(
        round.(vartable,digits=2),head,
        alignment=[:c,:c,:c],
        tf=compact
    );

end

function preextract(
    variable::AbstractString,
    experiment::AbstractString, configuration::AbstractString;
    days::Integer=100
)

    rce = NCDataset(datadir(joinpath(
        experiment,configuration,"OUT_STAT",
        "RCE_TropicalRCE-$(experiment).nc"
    )))

    p = rce["p"][:]; t = rce["time"][:]; var = rce[variable][:]

    close(rce)

    tstep = round(Integer,(length(t)-1)/(t[end]-t[1]))
    beg = days*tstep - 1
    var = dropdims(mean(var[:,(end-beg):end],dims=2),dims=2);

    return p,var

end

function preinterp(
    variable::AbstractString,
    experiment::AbstractString, configuration::AbstractString,
    lvl::AbstractVector{<:Real};
    days::Integer=100
)

    p,var = preextract(variable,experiment,configuration,days=days)
    lvl = lvl[lvl.>minimum(p)]
    spl = Spline1D(reverse(p),reverse(var))

    return lvl,spl(lvl)

end

function preinterp(
    data::AbstractVector{<:Real},
    slvl::AbstractVector{<:Real},
    lvl::AbstractVector{<:Real}
)

    lvl = lvl[lvl.>minimum(slvl)]
    spl = Spline1D(reverse(slvl),reverse(data))

    return lvl,spl(lvl)

end

function temp2esat(t::Real,p::Real)

    tb = t - 273.15
    if tb <= 0
        esat = exp(43.494 - 6545.8/(tb+278)) / (tb+868)^2
    else
        esat = exp(34.494 - 4924.99/(tb+237.1)) / (tb+105)^1.57
    end


    r = 0.622 * esat / max(esat,p-esat)
    return r / (1+r)

end

function rhumextract(
    experiment::AbstractString, configuration::AbstractString;
    days::Integer=100
)

    rce = NCDataset(datadir(joinpath(
        experiment,configuration,"OUT_STAT",
        "RCE_TropicalRCE-$(experiment).nc"
    )))

    p = rce["p"][:]; t = rce["time"][:]; q = rce["QV"][:]/10;
    rh = zeros(size(q)); t_air = rce["TABS"][:]

    close(rce)

    for it = 1 : length(t), ilvl = 1 : length(p)

        rh[ilvl,it] = q[ilvl,it] / temp2esat(t_air[ilvl,it],p[ilvl]*100)

    end

    tstep = round(Integer,(length(t)-1)/(t[end]-t[1]))
    beg = days*tstep - 1
    rh = dropdims(mean(rh[:,(end-beg):end],dims=2),dims=2);

    return p,rh

end

function sebextract(experiment::AbstractString, config::AbstractString)

    dfnc = joinpath(datadir(
        experiment,config,"OUT_STAT",
        "RCE_TropicalRCE-$(experiment).nc"
    ))
    rce = NCDataset(dfnc)
    t  = rce["time"][:] .- 80

    sw_sfc = rce["SWNS"][:]
    lw_sfc = rce["LWNS"][:]
    sh_sfc = rce["SHF"][:]
    lh_sfc = rce["LHF"][:]
    eb_sfc = sw_sfc .- (lw_sfc .+ sh_sfc .+ lh_sfc)

    close(rce)


    return t,eb_sfc,sw_sfc,lw_sfc,sh_sfc,lh_sfc

end

function sebsummary(experiment::AbstractString, config::AbstractString, days::Integer=100)

    t,eb_sfc,sw_sfc,lw_sfc,sh_sfc,lh_sfc = sebextract(experiment,config)

    tstep = round(Integer,(length(t) - 1) / (t[end] - t[1]))

    eb_sfc = mean(reshape(eb_sfc,tstep,:)[:,(end-days+1):end]);
    sw_sfc = mean(reshape(sw_sfc,tstep,:)[:,(end-days+1):end]);
    lw_sfc = mean(reshape(lw_sfc,tstep,:)[:,(end-days+1):end]);
    sh_sfc = mean(reshape(sh_sfc,tstep,:)[:,(end-days+1):end]);
    lh_sfc = mean(reshape(lh_sfc,tstep,:)[:,(end-days+1):end]);

    @info """We calculate the surface energy balance for:
      $(BOLD("Experiment:"))    $(uppercase(experiment))
      $(BOLD("Configuration:")) $(uppercase(config))

    The following are the summarized statistics for the last $days days at the surface:
      $(BOLD("Overall Balance:"))    $eb_sfc
      $(BOLD("Shortwave Flux:"))     $sw_sfc
      $(BOLD("Longwave Flux:"))      $lw_sfc
      $(BOLD("Sensible Heat Flux:")) $sh_sfc
      $(BOLD("Latent Heat Flux:"))   $lh_sfc
    """

end

function sebsummary(
    experiment::AbstractString,
    config::AbstractVector{<:AbstractString},
    days::Integer=100)

    nconfig = length(config)
    sebtable = zeros(nconfig,6)

    for icon = 1 : nconfig

        t,eb_sfc,sw_sfc,lw_sfc,sh_sfc,lh_sfc = sebextract(experiment,config[icon])

        tstep = round(Integer,(length(t) - 1) / (t[end] - t[1]))

        sebtable[icon,1] = parse(Float32,replace(replace(config[icon],"sst"=>""),"d"=>"."))
        sebtable[icon,2] = mean(reshape(sw_sfc,tstep,:)[:,(end-days+1):end]);
        sebtable[icon,3] = mean(reshape(lw_sfc,tstep,:)[:,(end-days+1):end]) * -1;
        sebtable[icon,4] = mean(reshape(sh_sfc,tstep,:)[:,(end-days+1):end]) * -1;
        sebtable[icon,5] = mean(reshape(lh_sfc,tstep,:)[:,(end-days+1):end]) * -1;
        sebtable[icon,6] = mean(reshape(eb_sfc,tstep,:)[:,(end-days+1):end]);

    end

    head = ["SST / K","Net SFC SW","Net SFC LW","Sensible","Latent","SFC Balance"];

    pretty_table(
        round.(sebtable,digits=2),head,
        alignment=[:c,:c,:c,:c,:c,:c],
        tf=compact
    );

end
