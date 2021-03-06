using HTTP
using Gumbo
using Cascadia
using DataFrames, CSV

df = CSV.read("quarter_scores.csv", DataFrame)

df[!,"spread"] .= NaN
df[!,"OU"]     .= NaN

#Get vegas lines
for row in eachrow(df)
    println(row)
    if isnan(row.spread)
        url = "https://www.pro-football-reference.com/teams/$(row.team)/$(row.year)_lines.htm"
        r = HTTP.get(url)
        h = parsehtml(String(r.body))
        tmp = eachmatch(Selector(".table_container"), h.root)[1]
        tbl_rows = tmp.children[1].children[4].children
        for tr in tbl_rows
            spread = parse(Float64, tr.children[3].children[1].text)
            ou = parse(Float64, tr.children[4].children[1].text)
            gameid = tr.children[5].children[1].attributes["href"][12:end-4]
            for r2 in eachrow(df)
                if r2.id==gameid && r2.team==row.team
                    r2.spread = spread
                    r2.OU = ou
                end
            end
        end
    end
end

#Sort by date
sort!(df, :id)

#Remove games where the OU wasn't set 
delete!(df, df.OU .< 1.0)

#Calc implied total
df[!,"imp_tot"] .= (df.OU ./ 2) .- (df.spread ./ 2)

# Make cumulative
df.q2 .= df.q1 .+ df.q2
df.q3 .= df.q2 .+ df.q3

#One hot encode the quarter results
df[!,"ABCD"] .= false
df[!,"AABC"] .= false
df[!,"AABB"] .= false
df[!,"AAAB"] .= false
df[!,"AAAA"] .= false
for row in eachrow(df)
    qs = [mod(row.q1,10), mod(row.q2,10), mod(row.q3,10), mod(row.final,10)]
    uq = unique(qs)
    if length(uq) == 1
        row["AAAA"] = true
    elseif length(uq) == 4
        row["ABCD"] = true
    elseif length(uq) == 3
        row["AABC"] = true
    else
        v1 = uq[1]
        if count(qs.==v1) == 2
            row["AABB"] = true
        else
            row["AAAB"] = true
        end
    end
end

CSV.write("processed_scores.csv",df)