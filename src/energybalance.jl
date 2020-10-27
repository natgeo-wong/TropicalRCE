using NCDatasets
using PrettyTables
using Statistics

function sebextract(experiment::AbstractString, config::AbstractString)

    dfnc = joinpath(datadir(experiment,config,"OUT_STAT","RCE_DiConv-$(experiment).nc"))
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

    t,eb_sfc,sw_sfc,lw_sfc,sh_sfc,lh_sfc = ebextract(experiment,config)

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

        t,eb_sfc,sw_sfc,lw_sfc,sh_sfc,lh_sfc = ebextract(experiment,config[icon])

        tstep = round(Integer,(length(t) - 1) / (t[end] - t[1]))

        sebtable[icon,1] = parse(Float32,replace(replace(config[icon],"sst"=>""),"d"=>"."))
        sebtable[icon,2] = mean(reshape(sw_sfc,tstep,:)[:,(end-days+1):end]);
        sebtable[icon,3] = mean(reshape(lw_sfc,tstep,:)[:,(end-days+1):end]);
        sebtable[icon,4] = mean(reshape(sh_sfc,tstep,:)[:,(end-days+1):end]);
        sebtable[icon,5] = mean(reshape(lh_sfc,tstep,:)[:,(end-days+1):end]);
        sebtable[icon,6] = mean(reshape(eb_sfc,tstep,:)[:,(end-days+1):end]);

    end

    head = ["SST / K","Net SFC SW","Net SFC LW","Sensible","Latent","SFC Balance"];

    pretty_table(
        sebtable,head,
        alignment=[:c,:c,:c,:c,:c,:c,:l,:l],
        tf=compact
    );

end
