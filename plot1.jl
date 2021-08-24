using CSV, DataFrames, Plots, Statistics


df = CSV.read("processed_scores.csv", DataFrame)

# Histogram of actual total
histogram(df.final,
    bins = -0.5:62.5,
    xlabel = "Points",
    ylabel = "Counts",
    linewidth=0,
    label = "Actual")

# Histogram of implied score 
stephist!(df.imp_tot,
    bins = -0.5:62.5,
    linewidth=2,
    label = "Predicted")

savefig("score_histogram.png")

# Marginal Histogram
histogram2d(df.imp_tot, df.final,
    xlabel="Predicted [points]",
    ylabel="Actual [points]",
    xlim=[-0.5,63],
    ylim=[-0.5,63],
    bins=-0.5:62.5,
    aspect_ratio=:equal,
    colorbar_title="Counts")
X = zeros(length(df.imp_tot),2)
X[:,1] = df.imp_tot
X[:,2] .= 1.0
c = X\df.final
plot!(x->c[1]*x+c[2], 
    linewidth=2,
    label="Regression")
savefig("score_heatmap.png")
# marginalkde(df.final, df.imp_tot)

# Generic scatter
plot(collect(df.imp_tot), collect(df.final), seriestype = :scatter, smooth=true)
plot!(x->x,0,60,color=:red)

# Histograms at some key slices
rngs = [
    [10,15],
    [15,20],
    [20,25],
    [25,30],
    [30,35]
]
p = plot()
for rng in rngs
    i = (df.imp_tot .> rng[1]) .& (df.imp_tot .<= rng[2])
    density!(p, df.final[i], linewidth=2)
end
p



# One hot encode binned expectation
rngs = 8:2:32

y = zeros(Float64, 0,5)
for i in 2:length(rngs)

    idx = (df.imp_tot .> rngs[i-1]) .& (df.imp_tot .<= rngs[i])

    tot = count(idx)

    y = vcat(y, [count(df[idx,"ABCD"])/tot,
            count(df[idx,"AABC"])/tot,
            count(df[idx,"AABB"])/tot,
            count(df[idx,"AAAB"])/tot,
            count(df[idx,"AAAA"])/tot
            ]')

end

areaplot(rngs[1]+1:2:rngs[end], y,
    label = ["ABCD" "AABC" "AABB" "AAAB" "AAAA"],
    legend = :right,
    xlabel = "Predicted [points]",
    ylabel = "Fraction of Games w/ Outcome",
)
savefig("outcome_fill.png")

#Expectation as score goes to inf
AAAAe = binomial(4,0)   * (0.1*0.1*0.1)
AAABe = binomial(4,1)   * (0.9*0.1*0.1)
AABBe = binomial(4,2)/2 * (0.9*0.1*0.1)
AABCe = binomial(4,2)   * (0.9*0.8*0.1)
ABCDe = binomial(4,4)   * (0.9*0.8*0.7)

plot(rngs[1]+1:2:rngs[end], y, 
    label = ["ABCD" "AABC" "AABB" "AAAB" "AAAA"],
    linewidth=3, 
    legend=:topleft,
    xlabel = "Predicted [points]",
    ylabel = "Fraction of Games w/ Outcome",
)
# plot!(repeat([rngs[end]],5), [AAAAe, AAABe, AABBe, AABCe, ABCDe], st=:scatter)
savefig("outcome_line.png")


using Interpolations
labs = ["ABCD" "AABC" "AABB" "AAAB" "AAAA"]
ep = 25.75
for i in 1:5
    lab = labs[i]
    xk = rngs[1]+1:2:rngs[end]
    yk = y[:,i]
    int = LinearInterpolation(xk,yk)
    println(lab, ": ", int(ep))
end
