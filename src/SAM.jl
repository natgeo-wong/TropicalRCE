using NCDatasets
using PrettyTables
using Statistics

function sfcextract(experiment::AbstractString, config::AbstractString)

    dfnc = joinpath(datadir(experiment,config,"OUT_STAT","RCE_DiConv-$(experiment).nc"))
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
    days::Integer=100)

    nconfig = length(config)
    vartable = zeros(nconfig,3)
    tc,varc = sebextract(variable,experiment,control)
    tstepc = round(Integer,(length(t) - 1) / (t[end] - t[1]))
    varc = mean(reshape(varc,tstep,:)[:,(end-days+1):end])

    for icon = 1 : nconfig

        t,var = sebextract(experiment,config[icon])

        tstep = round(Integer,(length(t) - 1) / (t[end] - t[1]))

        vartable[icon+1,1] = parse(Float32,replace(replace(config[icon],"sst"=>""),"d"=>"."))
        vartable[icon+1,2] = mean(reshape(var,tstep,:)[:,(end-days+1):end])
        vartable[icon+1,3] = mean(reshape(var,tstep,:)[:,(end-days+1):end]) - varc

    end

    head = ["SAM SST / K","$variable","Config - Control"];

    pretty_table(
        round.(sebtable,digits=2),head,
        alignment=[:c,:c,:c],
        tf=compact
    );

end
