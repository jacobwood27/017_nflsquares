using HTTP
using Gumbo
using Cascadia
using DataFrames, CSV

YEARS = 1979:2020
# YEARS = 1979

# open("quarter_scores.csv","w") do io
#     write(io, "year,week,id,team,opp,q1,q2,q3,final\n")
#     for y in YEARS
#         url = "https://www.pro-football-reference.com/years/$y/"
#         r = HTTP.get(url)
#         h = parsehtml(String(r.body))
#         tmp = eachmatch(Selector(".section_content"), h.root) 
#         tmp = eachmatch(Selector("[href#=(years/$y/week)]"), tmp[1])
#         for t in tmp 
#             url = "https://www.pro-football-reference.com$(t.attributes["href"])"
#             println(url)
#             r = HTTP.get(url)
#             h = parsehtml(String(r.body))
#             tm = eachmatch(Selector(".right.gamelink"), h.root)
#             for s in tm
#                 url = "https://www.pro-football-reference.com$(s.children[1].attributes["href"])"
#                 r = HTTP.get(url)
#                 h = parsehtml(String(r.body))
#                 tbl = eachmatch(Selector(".linescore.nohover.stats_table.no_freeze"), h.root)
#                 team1 = split(tbl[1].children[2].children[1].children[2].children[1].attributes["href"],"/")[3]
#                 s1 = tbl[1].children[2].children[1].children[3:end]
#                 team2 = split(tbl[1].children[2].children[2].children[2].children[1].attributes["href"],"/")[3]
#                 s2 = tbl[1].children[2].children[2].children[3:end]
#                 dt = s.children[1].attributes["href"][12:19]
#                 id = s.children[1].attributes["href"][12:22]
#                 wk = split(t.attributes["href"],"_")[2][1:end-4]

#                 write(io, "$(dt[1:4]),$wk,$id,$team1,$team2,$(s1[1][1].text),$(s1[2][1].text),$(s1[3][1].text),$(s1[end][1].text)\n")
#                 write(io, "$(dt[1:4]),$wk,$id,$team2,$team1,$(s2[1][1].text),$(s2[2][1].text),$(s2[3][1].text),$(s2[end][1].text)\n")
#             end
#         end
#     end
# end

df = CSV.read("quarter_scores.csv", DataFrame)

# Make cumulative
df.q2 .= df.q1 .+ df.q2
df.q3 .= df.q2 .+ df.q3

df[!,"spread"] .= NaN
df[!,"OU"]     .= NaN

#Get vegas lines
for row in eachrow(df)
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
        end
    end
end

df