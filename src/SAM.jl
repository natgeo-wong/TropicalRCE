using NCDatasets
using PrettyTables
using Statistics

function sfcextract(
    variable::AbstractString,
    experiment::AbstractString,
    config::AbstractString
)

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
