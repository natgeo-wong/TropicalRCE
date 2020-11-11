using Interpolations
using NCDatasets

function compileresavediurnalsfc(varname::AbstractString)

    tds = NCDataset(datadir("reanalysis/era5-TRPx0.25-$varname-sfc-hour.nc"))
    lon = tds["longitude"][:]*1; nlon = length(lon)
    lat = tds["latitude"][:]*1;  nlat = length(lat)
    var = tds[varname][:]*1;
    close(tds)

    for ilat = 1 : nlat, ilon = 1 : nlon

        t = collect(0:23) .+ lon[ilon]/15
        itp = interpolate(var[ilon,ilat,:],BSpline(Cubic()),Periodic())
        stp = scale(itp,t)
        etp = extrapolate(stp,Periodic())

        for it = 1 : 24
            var[ilon,ilat,it] = etp[it-1]
        end

    end

    fnc = datadir("reanalysis/era5-TRPx0.25-$varname-sfc-diurnal.nc")
    ds = NCDataset(fnc,"c",attrib = Dict(
        "Conventions"               => "CF-1.6",
        "history"                   => "2020-10-21 23:54:22 GMT by grib_to_netcdf-2.16.0: /opt/ecmwf/eccodes/bin/grib_to_netcdf -S param -o /cache/data4/adaptor.mars.internal-1603323636.0468726-6113-3-fb54412a-f0a5-4783-956d-46233705e403.nc /cache/tmp/fb54412a-f0a5-4783-956d-46233705e403-adaptor.mars.internal-1603323636.0477095-6113-1-tmp.grib",
    ))

    # Dimensions

    ds.dim["longitude"] = nlon
    ds.dim["latitude"]  = nlat
    ds.dim["hour"]      = 24

    # Declare variables

    nclon = defVar(ds,"longitude",Float32,("longitude",),attrib = Dict(
        "units"                     => "degrees_east",
        "long_name"                 => "longitude",
    ))

    nclat = defVar(ds,"latitude",Float32,("latitude",),attrib = Dict(
        "units"                     => "degrees_north",
        "long_name"                 => "latitude",
    ))

    nchr  = defVar(ds,"level",Int8,("hour",),attrib = Dict(
        "units"                     => "hours",
        "long_name"                 => "Hours past 00:00 (GMT)",
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

    ncvar = defVar(ds,varname,Int16,("longitude","latitude","hour"),attrib = varattribs)

    nclon[:] = lon
    nclat[:] = lat
    nchr[:]  = collect(0:23)
    ncvar[:] = var

    close(ds)

end

function compileresavediurnalpre(varname::AbstractString)

    tds = NCDataset(datadir("reanalysis/era5-TRPx0.25-$varname-hour.nc"))
    lon = tds["longitude"][:]*1; nlon = length(lon)
    lat = tds["latitude"][:]*1;  nlat = length(lat)
    lvl = tds["levels"][:]*1;    nlvl = length(lvl)
    var = tds[varname][:]*1;
    close(tds)

    for ilvl = 1 : nllvl, ilat = 1 : nlat, ilon = 1 : nlon

        t = collect(0:23) .+ lon[ilon]/15
        itp = interpolate(var[ilon,ilat,ilvl,:],BSpline(Cubic()),Periodic())
        stp = scale(itp,t)
        etp = extrapolate(stp,Periodic())

        for it = 1 : 24
            var[ilon,ilat,ilvl,it] = etp[it-1]
        end

    end

    fnc = datadir("reanalysis/era5-TRPx0.25-$varname-diurnal.nc")
    ds = NCDataset(fnc,"c",attrib = Dict(
        "Conventions"               => "CF-1.6",
        "history"                   => "2020-10-21 23:54:22 GMT by grib_to_netcdf-2.16.0: /opt/ecmwf/eccodes/bin/grib_to_netcdf -S param -o /cache/data4/adaptor.mars.internal-1603323636.0468726-6113-3-fb54412a-f0a5-4783-956d-46233705e403.nc /cache/tmp/fb54412a-f0a5-4783-956d-46233705e403-adaptor.mars.internal-1603323636.0477095-6113-1-tmp.grib",
    ))

    # Dimensions

    ds.dim["longitude"] = nlon
    ds.dim["latitude"]  = nlat
    ds.dim["hour"]      = 24

    # Declare variables

    nclon = defVar(ds,"longitude",Float32,("longitude",),attrib = Dict(
        "units"                     => "degrees_east",
        "long_name"                 => "longitude",
    ))

    nclat = defVar(ds,"latitude",Float32,("latitude",),attrib = Dict(
        "units"                     => "degrees_north",
        "long_name"                 => "latitude",
    ))

    nchr  = defVar(ds,"level",Int8,("hour",),attrib = Dict(
        "units"                     => "hours",
        "long_name"                 => "Hours past 00:00 (GMT)",
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

    ncvar = defVar(ds,varname,Int16,("longitude","latitude","hour"),attrib = varattribs)

    nclon[:] = lon
    nclat[:] = lat
    nchr[:]  = collect(0:23)
    ncvar[:] = var

    close(ds)

end
