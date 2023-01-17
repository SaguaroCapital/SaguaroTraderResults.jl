
function pct_change(input::AbstractVector{<:Number})
    res =
        [i == 1 ? missing : (input[i] - input[i-1]) / input[i-1] for i in eachindex(input)]
    res = Vector{Float64}([i for i in skipmissing(res)])
    return res
end

function total_return(equity::AbstractVector)
    return equity[end] / equity[begin]
end

function cagr(equity::AbstractVector, n_periods::Real)
    return (equity[end] / equity[begin])^(1 / n_periods) - 1
end

function cumulative_return(equity::AbstractVector)
    return equity ./ equity[begin]
end

function sharpe_ratio(pct_change::AbstractVector, periods::Int = 252)
    return sqrt(periods) * mean(pct_change) / std(pct_change)
end

function sortino_ratio(pct_change::AbstractVector, periods::Int = 252)
    return sqrt(periods) * mean(pct_change) / std(pct_change[pct_change.<0.0])
end

function drawdowns(equity::AbstractVector)
    drawdown = zeros(size(equity, 1))
    max_val = equity[1]
    for ix in eachindex(equity)
        current_val = @inbounds equity[ix]
        if current_val > max_val
            max_val = current_val
        end
        drawdown[ix] = (current_val - max_val) / max_val
    end
    return drawdown
end

function maximum_drawdown_duration(drawdown::AbstractVector)
    max_duration = 0
    current_duration = 0
    for ix in eachindex(drawdown)
        current_drawdown = @inbounds drawdown[ix]
        if current_drawdown == 0.0
            current_duration = 0
        else
            current_duration += 1
            if current_duration > max_duration
                max_duration = current_duration
            end
        end
    end
    return max_duration
end

"""
```julia
total_return(equity::AbstractVector)
```

Calculate the total return of an equity

Parameters
----------
- `equity::AbstractVector` vector of equity

Returns
-------
- `Float64`: Total return
"""
total_return

"""
```julia
cagr(equity::DataFrame, n_periods::Real)
```

Calculate the total return of an equity

Parameters
----------
- `equity::DataFrame`
- `n_periods::Real`

Returns
-------
- `Float64`: CAGR
"""
cagr

"""
```julia
cumulative_return(equity::AbstractVector)
```

Cumlative returns

Parameters
----------
- `equity::AbstractVector` vector of equity

Returns
-------
- `Vector{Float64}`: cumulative return for all periods
"""
cumulative_return

"""
```julia
sharpe_ratio(pct_change::AbstractVector, periods::Int = 252)
```

Sharpe ratio using a risk free return of 0.0

Parameters
----------
- `pct_change::DataFrame`

Returns
-------
- `Float64`
"""
sharpe_ratio


"""
```julia
sortino_ratio(pct_change::AbstractVector, periods::Int = 252)
```

Sortino ratio using a risk free return of 0.0

Parameters
----------
- `pct_change::DataFrame`

Returns
-------
- `Float64`
"""
sortino_ratio

"""
```julia
drawdowns(equity::AbstractVector)
```

Size of the drawdown at every timepoint

Parameters
----------
- `equity::DataFrame`

Returns
-------
- `Vector{Float64}`
"""
drawdowns

"""
```julia
maximum_drawdown_duration(drawdown::AbstractVector)
```

Maximum drawdown duration

Parameters
----------
- `drawdown::DataFrame`

Returns
-------
- `Float64`
"""
maximum_drawdown_duration

