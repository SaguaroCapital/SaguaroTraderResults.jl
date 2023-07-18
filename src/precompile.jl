using PrecompileTools

@setup_workload begin
    # Putting some things in `setup` can reduce the size of the
    # precompile file and potentially make loading faster.
    timestamps = DateTime(2020, 1, 1):Day(1):DateTime(2022, 7, 1) |> collect
    total_equity = [log(i) for i = 2:size(timestamps, 1)+1]
    equity_curve = DataFrame(total_equity = total_equity, timestamp = timestamps)

    @compile_workload begin
        # all calls in this block will be precompiled, regardless of whether
        # they belong to your package or not (on Julia 1.8 and higher)
        plot_tearsheet(equity_curve, equity_curve)
    end
end
