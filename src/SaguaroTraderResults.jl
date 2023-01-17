
module SaguaroTraderResults

using DataFrames
using Dates
using Plots
using Measures
using Statistics

include("calculations.jl")
include("plots.jl")

export
    # calculations
    pct_change,
    total_return,
    cagr,
    cumulative_return,
    sharpe_ratio,
    sortino_ratio,
    drawdowns,
    maximum_drawdown_duration,

    # plots
    plot_equity,
    plot_drawdown,
    plot_monthly_returns,
    plot_yearly_returns,
    plot_statistics,
    plot_tearsheet

end
