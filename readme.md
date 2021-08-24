You know that game everyone plays when watching the Superbowl? Where you buy a square for a dollar and then if the two last digits of the score at the end of the quarter end up corresponding to your square you win some money?

The numbers assigned to the rows and columns are typically randomly generated after all the squares are purchased, so the best squares like (0,0), (7,0) and (0,7), can't be knowingly purchased. 

The random assignment prevents there from being any strategy involved with the selection of any one square. However, when purchasing multiple squares, you have the choice to buy your additional squares in a common row or column. 

This project attempts to see what sort of statistical edge you might be able to glean from strategically purchasing multiple squares at your next Superbowl party.

## Data

### Model
Our ideal model determines, for both teams, the probability distribution over the following 5 possible outcomes:
 - ABCD - Different final digits for each quarter *(e.g. 0,7,14,21)*
 - AABC - 2 quarters share a final digit *(e.g. 0,10,17,23)*
 - AABB - 2 pairs of quarters share a final digit *(e.g. 0,7,17,20)*
 - AAAB - 3 quarters share a final digit *(e.g. 7,10,17,17)*
 - AAAA - All 4 quarters share a final digit *(e.g. 0,10,10,20)*

To simplify the problem we will use only the predicted final score as input to the model. This will cause us to miss any distinctive scoring characteristics (maybe this team never scores in the 3rd quarter) but we should capture the bulk of the predictive power. The best predictive data we will have should come from the Vegas betting line, which [theoretically](https://en.wikipedia.org/wiki/Efficient-market_hypothesis) does all the modeling and predictive work for us. We will use the Over/Under and the spread to back out the implied point totals for both teams and use that as model inputs.

The historic data we will need to build the model thus looks something like (using the [2020 Superbowl](https://www.pro-football-reference.com/boxscores/202102070tam.htm) as an example):

| GameID       | Team | O/U  | Spread | Q1 | Q2 | Q3 | End | Implied Total | ABCD  | AABC  | AABB  | AAAB  | AAAA  |
|--------------|------|------|--------|----|----|----|-----|---------------|-------|-------|-------|-------|-------|
| 202102070tam | tam  | 54.5 | 3      | 7  | 21 | 31 | 31  | 25.75         | false | false | false | true  | false |
| 202102070tam | kan  | 54.5 | -3     | 3  | 6  | 9  | 9   | 28.75         | false | true  | false | false | false |

### Scraping

For some reason I could not find quarter-by-quarter scores of all historic NFL games as a tidy dataset anywhere. An excellent site [https://www.pro-football-reference.com](https://www.pro-football-reference.com) has all the desired information embedded in webpages that we can scrape.

Pro-football-reference has quarter-by-quarter scores available going back to [1920](https://www.pro-football-reference.com/boxscores/192009260rii.htm) and Vegas lines with a recorded spread and over/under going back to [1979](https://www.pro-football-reference.com/teams/det/1979_lines.htm). We will scrape all the games from 1979 to the present day.

In Julia webscraping can be done with the help of [HTTP.jl](https://github.com/JuliaWeb/HTTP.jl), [Gumbo.jl](https://github.com/JuliaWeb/Gumbo.jl), and [Cascadia.jl](https://github.com/Algocircle/Cascadia.jl). 

The scraping is performed in two passes, one to gather all the quarter scores and one to append all the Vegas lines. 

To gather the quarter scores we follow [this algorithm](https://github.com/jacobwood27/017_nflsquares/blob/main/scrape_scores.jl):
 - For each year in 1979-2020 (in parallel):
   - Read [https://www.pro-football-reference.com/years/\$YEAR/](https://www.pro-football-reference.com/years/1979/)
   - Find the weeks games were played from the Week Summaries buttons halfway down the page
   - For each week:
     - Read [https://www.pro-football-reference.com/years/\$YEAR/week_\$WEEK.htm](https://www.pro-football-reference.com/years/1979/week_1.htm)
     - Find all the "Final" Links for the displayed games
     - For each game:
       - Read [https://www.pro-football-reference.com/boxscores/\$GAMEID.htm](https://www.pro-football-reference.com/boxscores/197909010tam.htm)
       - Find the first 3 quarter scores and the final score (ignore 4th quarter and overtime)
       - Write a line into the resulting .csv file for both teams

To append the 

## Proof of Concept

### With 2 Squares

### With 3 Squares

### With 4 Squares

## Completed Tool

