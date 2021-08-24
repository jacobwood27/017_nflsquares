using CSV, DataFrames, StatsPlots, Statistics

df = CSV.read("processed_scores.csv", DataFrame)

#Remove games where the OU wasn't set 
delete!(df, df.OU .< 1.0)

#One hot encode the quarter results
df[!,"1111"] .= false
df[!,"211"] .= false
df[!,"22"] .= false
df[!,"31"] .= false
df[!,"4"] .= false
for row in eachrow(df)
    qs = [mod(row.q1,10), mod(row.q2,10), mod(row.q3,10), mod(row.final,10)]
    uq = unique(qs)
    if length(uq) == 1
        row["4"] = true
    elseif length(uq) == 4
        row["1111"] = true
    elseif length(uq) == 3
        row["211"] = true
    else
        v1 = uq[1]
        if count(qs.==v1) == 2
            row["22"] = true
        else
            row["31"] = true
        end
    end
end



# Histogram of actual total
histogram(df.final)

# Histogram of implied score 
histogram(df.imp_tot)

# Marginal Histogram
histogram2d(df.final, df.imp_tot,
    xlabel="Actual Final [points]",
    ylabel="Predicted Final [points]",
    xlim=[0,65],
    ylim=[0,65],
    bins=0:65)
# marginalkde(df.final, df.imp_tot)

# Generic scatter
plot(df.imp_tot, df.final, seriestype = :scatter)
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
rngs = 10:2:30

y1111 = []
y211 = []
y22 = []
y31 = []
y4 = []
for i in 2:length(rngs)

    i = (df.imp_tot .> rngs[i-1]) .& (df.imp_tot .<= rngs[i])

    n1111 = count(df[i,"1111"])
    n211 = count(df[i,"211"])
    n22 = count(df[i,"22"])
    n31 = count(df[i,"31"])
    n4 = count(df[i,"4"])
    tot = count(i)

    push!(y1111,n1111/tot)
    push!(y211,n211/tot)
    push!(y22,n22/tot)
    push!(y31,n31/tot)
    push!(y4,n4/tot)

end
areaplot(11:2:29, [
    y1111+y211+y22+y31+y4,
    y1111+y211+y22+y31,
    y1111+y211+y22,
    y1111+y211,
    y1111],
    label = ["AAAA" "AAAB" "AABB" "AABC" "ABCD"],
    legend = :right)


plot(11:2:29, [y4,y31,y22,y211,y1111], 
    label = ["AAAA" "AAAB" "AABB" "AABC" "ABCD"],
    linewidth=2, legend=:topleft)



