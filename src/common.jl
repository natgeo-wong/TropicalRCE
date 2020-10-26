prect(N::Real,S::Real,W::Real,E::Real) = [W,E,E,W,W],[S,S,N,N,S]

function ncoffsetscale(data::AbstractArray)

    dmax = maximum(data[.!ismissing.(data)])
    dmin = minimum(data[.!ismissing.(data)])
    scale = (dmax-dmin) / 65533;
    offset = (dmax+dmin-scale) / 2;

    return scale,offset

end
