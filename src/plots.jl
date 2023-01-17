
const saguaro_lightgreen = RGBA(6 / 255, 188 / 255, 132 / 255)
const saguaro_darkgreen = RGBA(27 / 255, 79 / 255, 70 / 255)
const saguaro_gray = RGBA(70 / 255, 83 / 255, 89 / 255)

####################################################################
# Equity curve
####################################################################
function plot_equity(
    equity_curve_strategy::DataFrame,
    equity_curve_benchmark::DataFrame;
    title::String = "Strategy vs Benchmark Tearsheet",
    date_col = :timestamp,
    value_col = :total_equity,
    strategy_label::String = "Strategy",
    benchmark_label::String = "Benchmark",
)
    cum_return = cumulative_return(equity_curve_benchmark[:, value_col])
    plt_returns = plot(
        equity_curve_benchmark[:, date_col],
        cum_return,
        linecolor = saguaro_gray,
        label = benchmark_label,
        dpi = 500,
        bottom_margin = 5mm,
        left_margin = 8mm,
        legend = true,
    )

    cum_return = cumulative_return(equity_curve_strategy[:, value_col])
    plot!(
        plt_returns,
        equity_curve_strategy[:, date_col],
        cum_return,
        label = strategy_label,
        linecolor = saguaro_lightgreen,
    )

    hline!(
        plt_returns,
        [1.0],
        line = :dash,
        linecolor = :black,
        label = false,
        z_order = :back,
    )
    plot!(
        plt_returns,
        ylabel = "Cumulative Return",
        legend = :topleft,
        title = title,
        xformatter = x -> x,
    )
    amin, amax = Plots.axis_limits(plt_returns[1], :x)
    ticks, labels = optimize_datetime_ticks(amin, amax; k_min = 10, k_max = 15)
    plot!(plt_returns, xticks = (ticks, [i[1:4] for i in labels]), xrotation = 45)
    return plt_returns
end


####################################################################
# Drawdown curve
####################################################################
function plot_drawdown(
    equity_curve_strategy::DataFrame;
    date_col = :timestamp,
    value_col = :total_equity,
)
    drawdown_pct = drawdowns(equity_curve_strategy[:, value_col]) .* 100
    plt_drawdown = plot(
        legend = :none,
        dpi = 500,
        size = (1000, 300),
        left_margin = 18mm,
        bottom_margin = 14mm,
    )
    areaplot!(
        plt_drawdown,
        equity_curve_strategy[:, date_col],
        drawdown_pct,
        color = RGBA(1.0, 0, 0, 0.6),
    )
    plot!(
        plt_drawdown,
        equity_curve_strategy[:, date_col],
        drawdown_pct,
        label = "Drawdown",
        linecolor = "black",
        linewidth = 2,
    )
    plot!(plt_drawdown, xlabel = "Date", ylabel = "Drawdown (%)")
    hline!(plt_drawdown, [0.0], linecolor = "black", linewidth = 2, label = false)
    plot!(plt_drawdown, yaxis = (formatter = y -> "$y%"), ylims = :round)
    amin, amax = Plots.axis_limits(plt_drawdown[1], :x)
    ticks, labels = optimize_datetime_ticks(amin, amax; k_min = 10, k_max = 15)
    plot!(plt_drawdown, xticks = (ticks, [i[1:4] for i in labels]), xrotation = 45)
    return plt_drawdown
end


####################################################################
# Monthly returns
####################################################################
function plot_monthly_returns(
    df_equity_curve::DataFrame,
    date_col = :timestamp,
    value_col = :total_equity,
)
    sort!(df_equity_curve, date_col)
    years = Year.(df_equity_curve[:, date_col])
    unique_years = [i.value for i in unique(years)]
    months = Month.(df_equity_curve[:, date_col])
    unique_months = collect(1:12)
    month_labels = [Dates.monthabbr(i) for i in unique_months]
    pct_returns = zeros(size(unique_months, 1), size(unique_years, 1))
    for i in eachindex(unique_years)
        for j in eachindex(unique_months)
            y = unique_years[i] |> Year
            m = unique_months[j] |> Month
            df_equity_curve_subset = df_equity_curve[(years.==y).&(months.==m), :]
            if size(df_equity_curve_subset, 1) > 0
                pct_returns[j, i] =
                    (
                        df_equity_curve_subset[end, value_col] -
                        df_equity_curve_subset[begin, value_col]
                    ) / df_equity_curve_subset[begin, value_col]
            end
        end
    end
    plt = heatmap(
        month_labels,
        unique_years,
        pct_returns,
        legend = :none,
        yticks = unique_years,
        color = cgrad([:red, :white, RGBA(6 / 255, 188 / 255, 132 / 255)]),
    )
    plot!(plt, dpi = 500, size = (500, 500), left_margin = 15mm, bottom_margin = 6mm)
    plot!(
        plt,
        xlabel = "Month",
        ylabel = "Year",
        title = "Monthly Returns (%)",
        titlefontsize = 8,
    )
    return plt
end

####################################################################
# Yearly returns
####################################################################
function plot_yearly_returns(
    df_equity_curve::DataFrame,
    date_col = :timestamp,
    value_col = :total_equity,
)
    sort!(df_equity_curve, date_col)
    years = Year.(df_equity_curve[:, date_col])
    unique_years = [i.value for i in unique(years)]
    pct_returns = zeros(size(unique_years, 1))
    for i in eachindex(unique_years)
        y = unique_years[i] |> Year
        df_equity_curve_subset = df_equity_curve[(years.==y), :]
        if size(df_equity_curve_subset, 1) > 0
            pct_returns[i] =
                (
                    df_equity_curve_subset[end, value_col] -
                    df_equity_curve_subset[begin, value_col]
                ) / df_equity_curve_subset[begin, value_col]
        end
    end
    plt = bar(
        unique_years,
        pct_returns .* 100.0,
        legend = :none,
        color = RGBA(27 / 255, 79 / 255, 70 / 255),
    )
    plot!(plt, dpi = 500, size = (500, 500), left_margin = 12mm, bottom_margin = 12mm)
    plot!(
        plt,
        xlabel = "Year",
        ylabel = "Returns (%)",
        title = "Yearly Returns (%)",
        titlefontsize = 8,
        xrotation = 45,
        xticks = unique_years,
        xlim = (unique_years[begin] - 0.5, unique_years[end] + 0.5),
    )
    return plt
end



####################################################################
# Statistics
####################################################################
function plot_statistics(
    total_equity_strategy::AbstractVector,
    total_equity_benchmark::AbstractVector,
)
    # get statistics
    returns_strategy = pct_change(total_equity_strategy)
    returns_bench = pct_change(total_equity_benchmark)

    total_return_strategy = total_return(total_equity_strategy)
    total_return_bench = total_return(total_equity_benchmark)

    sharpe_strategy = sharpe_ratio(returns_strategy)
    sharpe_bench = sharpe_ratio(returns_bench)

    sortino_strategy = sortino_ratio(returns_strategy)
    sortino_bench = sortino_ratio(returns_bench)

    cagr_strategy = cagr(total_equity_strategy, 17)
    cagr_bench = cagr(total_equity_benchmark, 17)

    drawdowns_strategy = drawdowns(total_equity_strategy)
    max_drawdown_strategy = minimum(drawdowns_strategy)
    max_drawdown_dur_strategy = maximum_drawdown_duration(drawdowns_strategy)
    drawdowns_bench = drawdowns(total_equity_benchmark)
    max_drawdown_bench = minimum(drawdowns_bench)
    max_drawdown_dur_bench = maximum_drawdown_duration(drawdowns_bench)


    # generate plot
    plt_stats = plot(
        xlim = (0, 10.5),
        ylim = (4.5, 10),
        dpi = 500,
        size = (1000, 500),
        axis = nothing,
        border = :none,
    )
    annotate!(plt_stats, 0.2, 9, text("Total Return", 12, :left))
    annotate!(plt_stats, 0.2, 8.25, text("CAGR", 12, :left))
    annotate!(plt_stats, 0.2, 7.5, text("Sharpe Ratio", 12, :left))
    annotate!(plt_stats, 0.2, 6.75, text("Sortino Ratio", 12, :left))
    annotate!(plt_stats, 0.2, 6, text("Max Drawdown", 12, :left))
    annotate!(plt_stats, 0.2, 5.25, text("Max Drawdown Duration", 12, :left))

    annotate!(plt_stats, 6.8, 9.7, text("Strategy", 12, :right))
    annotate!(
        plt_stats,
        6.8,
        9,
        text("$(round((total_return_strategy - 1.0) * 100; digits=2))%", 12, :right),
    )
    annotate!(
        plt_stats,
        6.8,
        8.25,
        text("$(round(cagr_strategy * 100; digits=2))%", 12, :right),
    )
    annotate!(plt_stats, 6.8, 7.5, text("$(round(sharpe_strategy; digits=2))", 12, :right))
    annotate!(
        plt_stats,
        6.8,
        6.75,
        text("$(round(sortino_strategy; digits=2))", 12, :right),
    )
    annotate!(
        plt_stats,
        6.8,
        6,
        text("($(round(abs(max_drawdown_strategy * 100); digits=2))%)", 12, :right),
    )
    annotate!(plt_stats, 6.8, 5.25, text("$max_drawdown_dur_strategy Days", 12, :right))


    annotate!(plt_stats, 9.5, 9.7, text("Benchmark", 12, :right))
    annotate!(
        plt_stats,
        9.5,
        9,
        text("$(round((total_return_bench - 1.0) * 100; digits=2))%", 12, :right),
    )
    annotate!(
        plt_stats,
        9.5,
        8.25,
        text("$(round(cagr_bench * 100; digits=2))%", 12, :right),
    )
    annotate!(plt_stats, 9.5, 7.5, text("$(round(sharpe_bench; digits=2))", 12, :right))
    annotate!(plt_stats, 9.5, 6.75, text("$(round(sortino_bench; digits=2))", 12, :right))
    annotate!(
        plt_stats,
        9.5,
        6,
        text("($(round(abs(max_drawdown_bench * 100); digits=2))%)", 12, :right),
    )
    annotate!(plt_stats, 9.5, 5.25, text("$max_drawdown_dur_bench Days", 12, :right))

    y = [9.95 9.375 8.625 7.875 7.125 6.375 5.625 4.875]
    plot!(plt_stats, [0.1, 10.0], [y; y], lw = 2, color = saguaro_gray, legend = false)

    x = [0.1 4.75 7.5 10.0]
    plot!(plt_stats, [x; x], [4.875, 9.95], lw = 2, color = saguaro_gray, legend = false)

    return plt_stats

end

"""
```julia
plot_tearsheet(
    strategy_equity_curve::DataFrame,
    benchmark_equity_curve::DataFrame;
    title::String = "Strategy vs Benchmark Tearsheet",
)
```

Plot a tearsheet of backtesting results compared to a benchmark. 

The DataFrame has to have the following columns:
- 
- `total_equity`: total portfolio value

Parameters
----------
- `strategy_equity_curve::DataFrame`
- `benchmark_equity_curve::DataFrame`
- `title::String`
"""
function plot_tearsheet(
    strategy_equity_curve::DataFrame,
    benchmark_equity_curve::DataFrame;
    title::String = "Strategy vs Benchmark Tearsheet",
)

    plt_equity = plot_equity(strategy_equity_curve, benchmark_equity_curve; title = title)
    plt_drawdown = plot_drawdown(strategy_equity_curve)
    plt_monthly = plot_monthly_returns(strategy_equity_curve)
    plt_yearly = plot_yearly_returns(strategy_equity_curve)
    plt_stats = plot_statistics(
        strategy_equity_curve.total_equity,
        benchmark_equity_curve.total_equity,
    )


    l = @layout([a{0.325h}; b{0.175h}; c{0.45w} d{0.5w}; e{0.65w,1.0h} _])

    plt_tearsheet = plot(
        plt_equity,
        plt_drawdown,
        plt_monthly,
        plt_yearly,
        plt_stats,
        layout = l,
        dpi = 500,
        size = (1000, 1400),
        left_margin = 23mm,
        right_margin = 3mm,
    )

    return plt_tearsheet
end

function plot_tearsheet(
    strategy_trading_session,
    benchmark_trading_session;
    title::String = "Strategy vs Benchmark Tearsheet",
)
    plt_tearsheet = plot_tearsheet(
        strategy_trading_session.equity_curve,
        benchmark_trading_session.equity_curve,
        title = title,
    )

    return plt_tearsheet
end

