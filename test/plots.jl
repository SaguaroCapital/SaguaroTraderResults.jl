
@testset "Plots" begin
    # just testing that the plot doesn't throw errors
    timestamps = DateTime(2020, 1, 1):Day(1):DateTime(2022, 7, 1) |> collect
    total_equity = rand(size(timestamps, 1))
    equity_curve = DataFrame(total_equity = total_equity, timestamp = timestamps)
    plot_tearsheet(equity_curve, equity_curve)
end
