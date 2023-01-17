
@testset "Calculations" begin
    timestamps = DateTime(2020, 1, 1):Day(1):DateTime(2022, 7, 1) |> collect
    total_equity = [log(i) for i = 2:size(timestamps, 1)+1]
    equity_curve = DataFrame(total_equity = total_equity, timestamp = timestamps)

    pct_change_equity = pct_change(equity_curve.total_equity)
    @test size(equity_curve, 1) == (size(pct_change_equity, 1) + 1)

    @test isapprox(total_return(equity_curve.total_equity), 9.83605035505807)
    @test isapprox(cagr(equity_curve.total_equity, 252), 0.009112915892897755)
    cum_returns = cumulative_return(equity_curve.total_equity)
    @test cum_returns[1] == 1.0
    @test cum_returns[end] == total_return(equity_curve.total_equity)

    # sharpe/sortino ratios
    example_pct_change = [0.1, -0.1, 0.2, -0.15]
    @test isapprox(sharpe_ratio(example_pct_change, 4), 0.15132998169159553)
    @test isapprox(sortino_ratio(example_pct_change, 4), 0.7071067811865479)

    # drawdowns
    example_equity = [1.0, 1.5, 2.0, 1.9, 1.8, 1.8, 1.9, 2.1, 2.5, 2.4, 2.2, 2.5, 2.6]
    d = drawdowns(example_equity)
    @test sum(d .> 0.0) == 0
    @test sum(d .== 0.0) == 7
    @test maximum_drawdown_duration(d) == 4
end
