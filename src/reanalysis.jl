using NCDatasets
using Statistics
using StatsBase

prect(N::Real,S::Real,W::Real,E::Real) = [W,E,E,W,W],[S,S,N,N,S]

function ncoffsetscale(data::AbstractArray)

    dmax = maximum(data[.!ismissing.(data)])
    dmin = minimum(data[.!ismissing.(data)])
    scale = (dmax-dmin) / 65533;
    offset = (dmax+dmin-scale) / 2;

    return scale,offset

end

function compilesavesfc(varname::AbstractString)

    tds = NCDataset(datadir("reanalysis/era5-TRPx0.25-sfc.nc"))
    var = dropdims(mean(tds[varname][:]*1,dims=3),dims=3)
    lon = tds["longitude"][:]*1
    lat = tds["latitude"][:]*1

    fnc = datadir("reanalysis/era5-TRPx0.25-$varname-sfc.nc")
    ds = NCDataset(fnc,"c",attrib = Dict(
        "Conventions"               => "CF-1.6",
        "history"                   => "2020-10-21 23:54:22 GMT by grib_to_netcdf-2.16.0: /opt/ecmwf/eccodes/bin/grib_to_netcdf -S param -o /cache/data4/adaptor.mars.internal-1603323636.0468726-6113-3-fb54412a-f0a5-4783-956d-46233705e403.nc /cache/tmp/fb54412a-f0a5-4783-956d-46233705e403-adaptor.mars.internal-1603323636.0477095-6113-1-tmp.grib",
    ))

    # Dimensions

    ds.dim["longitude"] = length(lon)
    ds.dim["latitude"]  = length(lat)

    # Declare variables

    nclon = defVar(ds,"longitude",Float32,("longitude",),attrib = Dict(
        "units"                     => "degrees_east",
        "long_name"                 => "longitude",
    ))

    nclat = defVar(ds,"latitude",Float32,("latitude",),attrib = Dict(
        "units"                     => "degrees_north",
        "long_name"                 => "latitude",
    ))

    scale,offset = ncoffsetscale(var)

    varattribs = Dict(
        "scale_factor"  => scale,
        "add_offset"    => offset,
        "_FillValue"    => Int16(-32767),
        "missing_value" => Int16(-32767),
        "units"         => tds[varname].attrib["units"],
        "long_name"     => tds[varname].attrib["long_name"],
    )

    if haskey(tds[varname].attrib,"standard_name")
        varattribs["standard_name"] = tds[varname].attrib["standard_name"]
    end

    ncvar = defVar(ds,varname,Int16,("longitude","latitude"),attrib = varattribs)

    nclon[:] = lon
    nclat[:] = lat
    ncvar[:] = var

    close(ds)

    close(tds)

end

function compilesavepre(varname::AbstractString)

    tds = NCDataset(datadir("reanalysis/$varname/era5-TRPx0.25-$varname-1979.nc"))
    lon = tds["longitude"][:]*1
    lat = tds["latitude"][:]*1
    lvl = tds["level"][:]*1

    var = zeros(length(lon),length(lat),length(lvl))
    vnc = replace(varname,"_air"=>"")

    for yr = 1979 : 2019
        yds  = NCDataset(datadir("reanalysis/$varname/era5-TRPx0.25-$varname-$(yr).nc"))
        var += dropdims(mean(yds[vnc][:]*1,dims=4),dims=4)
        close(yds)
    end

    var = var / 41

    fnc = datadir("reanalysis/era5-TRPx0.25-$varname.nc")
    ds = NCDataset(fnc,"c",attrib = Dict(
        "Conventions"               => "CF-1.6",
        "history"                   => "2020-10-21 23:54:22 GMT by grib_to_netcdf-2.16.0: /opt/ecmwf/eccodes/bin/grib_to_netcdf -S param -o /cache/data4/adaptor.mars.internal-1603323636.0468726-6113-3-fb54412a-f0a5-4783-956d-46233705e403.nc /cache/tmp/fb54412a-f0a5-4783-956d-46233705e403-adaptor.mars.internal-1603323636.0477095-6113-1-tmp.grib",
    ))

    # Dimensions

    ds.dim["longitude"] = length(lon)
    ds.dim["latitude"]  = length(lat)
    ds.dim["level"]     = length(lvl)

    # Declare variables

    nclon = defVar(ds,"longitude",Float32,("longitude",),attrib = Dict(
        "units"                     => "degrees_east",
        "long_name"                 => "longitude",
    ))

    nclat = defVar(ds,"latitude",Float32,("latitude",),attrib = Dict(
        "units"                     => "degrees_north",
        "long_name"                 => "latitude",
    ))

    ncpre = defVar(ds,"level",Int32,("level",),attrib = Dict(
        "units"                     => "millibars",
        "long_name"                 => "pressure_level",
    ))

    scale,offset = ncoffsetscale(var)

    varattribs = Dict(
        "scale_factor"  => scale,
        "add_offset"    => offset,
        "_FillValue"    => Int16(-32767),
        "missing_value" => Int16(-32767),
        "units"         => tds[vnc].attrib["units"],
        "long_name"     => tds[vnc].attrib["long_name"],
    )

    if haskey(tds[vnc].attrib,"standard_name")
        varattribs["standard_name"] = tds[vnc].attrib["standard_name"]
    end

    ncvar = defVar(ds,varname,Int16,("longitude","latitude","level"),attrib = varattribs)

    nclon[:] = lon
    nclat[:] = lat
    ncpre[:] = lvl
    ncvar[:] = var

    close(ds)

    close(tds)

end

function compilesfceb()

    tds  = NCDataset(datadir("reanalysis/era5-TRPx0.25-sfc.nc"))
    lon  = tds["longitude"][:]*1
    lat  = tds["latitude"][:]*1
    close(tds)

    tds = NCDataset(datadir("reanalysis/era5-TRPx0.25-ssr-sfc.nc"))
    ssr = tds["ssr"][:]*1
    close(tds)
    tds = NCDataset(datadir("reanalysis/era5-TRPx0.25-str-sfc.nc"))
    str = tds["str"][:]*1
    close(tds)
    tds = NCDataset(datadir("reanalysis/era5-TRPx0.25-sshf-sfc.nc"))
    shf = tds["sshf"][:]*1
    close(tds)
    tds = NCDataset(datadir("reanalysis/era5-TRPx0.25-slhf-sfc.nc"))
    lhf = tds["slhf"][:]*1
    close(tds)

    seb = ssr .+ str .+ shf .+ lhf

    fnc = datadir("reanalysis/era5-TRPx0.25-seb-sfc.nc")
    ds = NCDataset(fnc,"c",attrib = Dict(
        "Conventions"               => "CF-1.6",
        "history"                   => "2020-10-21 23:54:22 GMT by grib_to_netcdf-2.16.0: /opt/ecmwf/eccodes/bin/grib_to_netcdf -S param -o /cache/data4/adaptor.mars.internal-1603323636.0468726-6113-3-fb54412a-f0a5-4783-956d-46233705e403.nc /cache/tmp/fb54412a-f0a5-4783-956d-46233705e403-adaptor.mars.internal-1603323636.0477095-6113-1-tmp.grib",
    ))

    # Dimensions

    ds.dim["longitude"] = length(lon)
    ds.dim["latitude"]  = length(lat)

    # Declare variables

    nclon = defVar(ds,"longitude",Float32,("longitude",),attrib = Dict(
        "units"                     => "degrees_east",
        "long_name"                 => "longitude",
    ))

    nclat = defVar(ds,"latitude",Float32,("latitude",),attrib = Dict(
        "units"                     => "degrees_north",
        "long_name"                 => "latitude",
    ))

    scale,offset = ncoffsetscale(seb)

    varattribs = Dict(
        "scale_factor"  => scale,
        "add_offset"    => offset,
        "_FillValue"    => Int16(-32767),
        "missing_value" => Int16(-32767),
        "units"         => "J m**-2",
        "long_name"     => "Surface net energy balance",
        "standard_name" => "surface_net_downward_energy_flux",
    )

    ncvar = defVar(ds,"seb",Int16,("longitude","latitude"),attrib = varattribs)

    nclon[:] = lon
    nclat[:] = lat
    ncvar[:] = seb

    close(ds)

end

function bindatasfc(coords,bins,var,lon,lat,lsm)

    tlon,tlat,rinfo = regiongridvec(coords,lon,lat);
    rvar = regionextractgrid(var,rinfo)
    rlsm = regionextractgrid(lsm,rinfo)

    lvar = rvar[rlsm.>0.5]; lvar = lvar[.!ismissing.(lvar)]; lvar = lvar[.!isnan.(lvar)]
    svar = rvar[rlsm.<0.5]; svar = svar[.!ismissing.(svar)]; svar = svar[.!isnan.(svar)]

    lbin = fit(Histogram,lvar,bins).weights; lbin = lbin ./ sum(lbin) * (length(bins) - 1)
    sbin = fit(Histogram,svar,bins).weights; sbin = sbin ./ sum(sbin) * (length(bins) - 1)

    return lbin,sbin,mean(lvar),mean(svar)

end

function getmean(coords,var,lon,lat,nlvl,lsm)

    tlon,tlat,rinfo = regiongridvec(coords,lon,lat);
    rvar = regionextractgrid(var,rinfo)
    rlsm = regionextractgrid(lsm,rinfo)
    sprf = zeros(nlvl); lprf = zeros(nlvl)

    for ilvl = 1 : nlvl

        ivar = rvar[:,:,ilvl]
        lavg = ivar[rlsm.>0.5]; lavg = lavg[.!ismissing.(lavg)]; lavg = lavg[.!isnan.(lavg)]
        savg = ivar[rlsm.<0.5]; savg = savg[.!ismissing.(savg)]; savg = savg[.!isnan.(savg)]
        lprf[ilvl] = mean(lavg)
        sprf[ilvl] = mean(savg)

    end

    return lprf,sprf

end
