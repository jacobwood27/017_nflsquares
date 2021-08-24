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

function get_outcome(P)
    roll = rand()
    if roll < P[1]
        return ABCD()
    elseif roll < P[1] + P[2]
        return AABC()
    elseif roll < P[1] + P[2] + P[3]
        return AABB()
    elseif roll < P[1] + P[2] + P[3] + P[4]
        return AAAB()
    else 
        return AAAA()
    end
end

function sim(coords, P1, P2; N=10000000)
    winnings = Threads.Atomic{Int}(0)
    payoff = 25
    Threads.@threads for i = 1:N

        t1 = get_outcome(P1)
        t2 = get_outcome(P2)

        for j=1:4
            for c in coords
                if t1[j]==c[1] && t2[j]==c[2]
                    Threads.atomic_add!(winnings, payoff)
                    break
                end
            end
        end 

    end

    println()
    println("After $N runs:")
    println("Expected return on \$$(length(coords)) = \$$(winnings[]/N)")
    println()

    return winnings[]/length(coords)/N
end

## 1 square
P1 = [0.14, 0.48, 0.13, 0.22, 0.03]
P2 = [0.19, 0.46, 0.11, 0.21, 0.03]
C = [(4,8)]
sim(C, P1, P2)

## 2 squares
P1 = [0.14, 0.48, 0.13, 0.22, 0.03]
P2 = [0.19, 0.46, 0.11, 0.21, 0.03]
C = [   [(1,1), (1,2)],
        [(1,1), (2,1)],
        [(1,1), (2,2)]
    ]
[sim(c, P1, P2) for c in C]

## 3 squares
P1 = [0.14, 0.48, 0.13, 0.22, 0.03]
P2 = [0.19, 0.46, 0.11, 0.21, 0.03]
C = [   [(1,1), (1,2), (1,3)],
        [(1,1), (1,2), (2,3)],
        [(1,1), (1,2), (2,1)],
        [(1,1), (2,1), (3,2)],
        [(1,1), (2,1), (3,1)],
        [(1,1), (2,2), (3,3)],
    ]
[sim(c, P1, P2) for c in C]
