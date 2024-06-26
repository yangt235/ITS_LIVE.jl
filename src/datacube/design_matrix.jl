"""
    design_matrix(t1,t2, model [optional])

create design matrix for discrete interval data

# Example
```julia
julia> D, tD, M = design_matrix(t1,t2, model [optional])
```

# Arguments
   - `t1::Vector{DateTime}`: start DateTime of descrete interval 
   - `t2::Vector{DateTime}`: end DateTime of descrete interval 
   - `model::String = "sinusoidal_interannual"`:

# Author
Alex Gardner
Jet Propulsion Laboratory, California Institute of Technology, Pasadena, California
February 23, 2022

Chad A. Greene [inspiration Matlab code]
Jet Propulsion Laboratory, California Institute of Technology, Pasadena, California
January 1, 2022
"""

function design_matrix(t1::Vector{DateTime}, t2::Vector{DateTime}, model::String = "sinusoidal_interannual")
    # Convert datenums to decimal years:
    yr1 = ITS_LIVE.decimalyear(t1)
    yr2 = ITS_LIVE.decimalyear(t2)

    if (model == "sinusoidal_interannual") || (model == "sinusoidal") || (model == "interannual")

    M, tM = ITS_LIVE.annual_matrix(t1,t2)
    yr = ITS_LIVE.decimalyear(tM)

    hasdata = vec(sum(M,dims=1).>0);
    yr = yr[hasdata];
    M = M[:,hasdata];

    if model == "interannual"
        D = M; #hcat(M);
    elseif model == "sinusoidal"
        D = hcat((cos.(2*pi*yr1) - cos.(2*pi*yr2)) ./ (2*pi), (sin.(2*pi*yr2) - sin.(2*pi*yr1))./(2*pi), M);
    else
        # Displacement Design matrix: (these are displacements! not velocities, so this matrix is just the definite integral wrt time of a*sin(2*pi*yr)+b*cos(2*pi*yr)+c.
        N = ((sin.(2*pi*yr2) - sin.(2*pi*yr1))./(2*pi));
        N = mapslices(row->(N).*row,float(M.>0), dims=1);

        P = (cos.(2*pi*yr1) - cos.(2*pi*yr2)) ./ (2*pi);
        P = mapslices(row->(P).*row,float(M.>0), dims=1);

        D = hcat(P, N, M);
    end

    tD  = Dates.DateTime.(round.(Int,yr),7,1)
    return D, tD, M
end
    error("$model is not a design matrix model option")
end