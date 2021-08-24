using StatsBase

function ABCD()
    x = sample(1:10, 4, replace=false)
    return [x[1],x[2],x[3],x[4]]
end

function AABC()
    x = sample(1:10, 3, replace=false)
    return [x[1],x[1],x[2],x[3]]
end

function AABB()
    x = sample(1:10, 2, replace=false)
    return [x[1],x[1],x[2],x[2]]
end

function AAAB()
    x = sample(1:10, 2, replace=false)
    return [x[1],x[1],x[1],x[2]]
end

function AAAA()
    x = sample(1:10, 1, replace=false)
    return [x[1],x[1],x[1],x[1]]
end

function get_outcome1()
    roll = rand()
    if roll < 0.12
        return ABCD()
    elseif roll < 0.56
        return AABC()
    elseif roll < 0.71
        return AABB()
    elseif roll < 0.85
        return AAAB()
    else 
        return AAAA()
    end
end

function get_outcome2()
    roll = rand()
    if roll < 0.12
        return ABCD()
    elseif roll < 0.56
        return AABC()
    elseif roll < 0.71
        return AABB()
    elseif roll < 0.85
        return AAAB()
    else 
        return AAAA()
    end
end

function sim(coords; N=1000000)
    winnings = Threads.Atomic{Int}(0)
    num_wins = Threads.Atomic{Int}(0)
    payoff = 25
    Threads.@threads for i = 1:N
        game_win = false
        if mod(100*i//N,1)==0
            println(100*i/N,"%")
        end
        t1 = get_outcome1()
        t2 = get_outcome2()

        for j=1:4
            for c in coords
                if t1[j]==c[1] && t2[j]==c[2]
                    Threads.atomic_add!(winnings, payoff)
                    if !game_win
                        Threads.atomic_add!(num_wins, 1)
                        game_win = true
                    end
                    break
                end
            end
        end 

    end

    println()
    println("After $N runs:")
    println("Expected return on \$$(length(coords)) = \$$(winnings[]/N)")
    println()

    return winnings[]/length(coords)/N, num_wins[]/N
end

r1, w1 = sim([[1,1],[1,2],[1,3],[1,4]])
r2, w2 = sim([[1,1],[2,1],[3,1],[4,1]])
r3, w3 = sim([[1,1],[1,2],[2,1],[2,2]])
r4, w4 = sim([[1,1],[2,2],[3,3],[4,4]])

println([r1,r2,r3,r4])
println([w1,w2,w3,w4])