using Dates
using Glob
using NCDatasets
using Statistics
using StatsBase

include(srcdir("common.jl"))

function camcompilesfc(varname::AbstractString)

    dfol = datadir("SPCAM/raw")
    fncs = glob("perp_feb.cam2.h0.*.nc",dfol)
    lfnc = length(fncs)

    tds = NCDataset(fncs[1])
    lon = tds["lon"][:]; nlon = length(lon)
    lat = tds["lat"][:]; nlat = length(lat)
    var = zeros(nlon,nlat)

    for ifnc = 1 : lfnc
        ds   = NCDataset(fncs[ifnc])
        var += ds[varname][:,:,1]*1
    end

    var = var / lfnc

    fnc = datadir("SPCAM/$varname.nc")
    if isfile(fnc)
        @info "$(Dates.now()) - Stale NetCDF file $(fnc) detected.  Overwriting ..."
        rm(fnc);
    end

    ds  = NCDataset(fnc,"c",attrib = Dict(
        "Conventions" => "CF-1.6",
        "history"     => "Created on $(Dates.now())"
    ))

    ds.dim["longitude"] = length(lon)
    ds.dim["latitude"]  = length(lat)

    scale,offset = ncoffsetscale(var)

    nclon = defVar(ds,"longitude",Float32,("longitude",),attrib = Dict(
        "units"     => "degrees_east",
        "long_name" => "longitude",
    ))

    nclat = defVar(ds,"latitude",Float32,("latitude",),attrib = Dict(
        "units"     => "degrees_north",
        "long_name" => "latitude",
    ))

    varattribs = Dict(
        "scale_factor"  => scale,
        "add_offset"    => offset,
        "_FillValue"    => Int16(-32767),
        "missing_value" => Int16(-32767),
        "units"         => tds[varname].attrib["units"],
        "long_name"     => tds[varname].attrib["long_name"],
        "cell_method"   => "time: mean"
    )

    ncvar = defVar(ds,varname,Int16,("longitude","latitude"),attrib = varattribs)

    nclon[:] = lon
    nclat[:] = lat
    ncvar[:] = var

    close(ds)

    close(tds)

end

function camcompilepre(varname::AbstractString)

    dfol = datadir("SPCAM/raw")
    fncs = glob("perp_feb.cam2.h0.*.nc",dfol)
    lfnc = length(fncs)

    tds = NCDataset(fncs[1])
    lon = tds["lon"][:]; nlon = length(lon)
    lat = tds["lat"][:]; nlat = length(lat)
    lvl = tds["lev"][:]; nlvl = length(lvl)
    var = zeros(nlon,nlat,nlvl)
    pre = zeros(nlon,nlat)

    for ifnc = 1 : lfnc
        ds   = NCDataset(fncs[ifnc])
        var += ds[varname][:,:,:,1]*1
        pre += ds["PS"][:,:,1]*1
    end

    var = var / lfnc
    pre = pre / lfnc

    fnc = datadir("SPCAM/$varname.nc")
    if isfile(fnc)
        @info "$(Dates.now()) - Stale NetCDF file $(fnc) detected.  Overwriting ..."
        rm(fnc);
    end

    ds  = NCDataset(fnc,"c",attrib = Dict(
        "Conventions" => "CF-1.6",
        "history"     => "Created on $(Dates.now())"
    ))

    ds.dim["longitude"] = length(lon)
    ds.dim["latitude"]  = length(lat)
    ds.dim["level"]     = length(lvl)

    scale,offset = ncoffsetscale(var)

    nclon = defVar(ds,"longitude",Float32,("longitude",),attrib = Dict(
        "units"     => "degrees_east",
        "long_name" => "longitude",
    ))

    nclat = defVar(ds,"latitude",Float32,("latitude",),attrib = Dict(
        "units"     => "degrees_north",
        "long_name" => "latitude",
    ))

    nclvl = defVar(ds,"level",Float32,("level",),attrib = Dict(
        "long_name"     => "hybrid level at midpoints (1000*(A+B))",
        "units"         => "level",
        "positive"      => "down",
        "standard_name" => "atmosphere_hybrid_sigma_pressure_coordinate",
        "formula_terms" => "a: hyam b: hybm p0: P0 ps: PS",
    ))

    ncpre = defVar(ds,"pressure",Float32,("longitude","latitude",),attrib = Dict(
        "units"       => "Pa",
        "long_name"   => "Surface pressure",
        "cell_method" => "time: mean",
    ))

    varattribs = Dict(
        "scale_factor"  => scale,
        "add_offset"    => offset,
        "_FillValue"    => Int16(-32767),
        "missing_value" => Int16(-32767),
        "units"         => tds[varname].attrib["units"],
        "long_name"     => tds[varname].attrib["long_name"],
        "cell_method"   => "time: mean"
    )

    ncvar = defVar(ds,varname,Int16,("longitude","latitude","level"),attrib = varattribs)

    nclon[:] = lon
    nclat[:] = lat
    nclvl[:] = lvl
    ncpre[:] = pre
    ncvar[:] = var

    close(ds)

    close(tds)

end
