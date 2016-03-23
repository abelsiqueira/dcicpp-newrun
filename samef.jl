files = ["algencan.prof", "dcicpp.prof", "ipopt.prof"]

data = Dict()
problems = []

fbar = 1e-3
ftol = 1e-6
htol = 1e-6
gptol = 1e-6

tof(x) = typeof(parse(x)) == Float64 ? parse(x) : 1e20

for file in files
  yaml = 0
  algname = ""
  for line in readlines(open(file))
    if contains(line, "---")
      yaml += 1
      continue
    elseif contains(line, "algname")
      algname = split(line)[2]
      data[algname] = Dict()
    end
    if yaml < 2
      continue
    end
    sline = split(line)
    problem = sline[1]
    push!(problems, problem)

    data[algname][problem] = Dict("f"=>tof(sline[4]), "h"=>tof(sline[5]),
        "gp"=>tof(sline[6]))
  end
end

problems = sort(unique(problems))
solvers = keys(data)

for p in problems
  fbest = Inf
  for s in solvers
    this = data[s][p]
    if this["h"] < htol && this["gp"] < gptol && this["f"] < fbest
      fbest = this["f"]
    end
  end
  if fbest == Inf
    continue
  end
  select = true
  for s in solvers
    this = data[s][p]
    if this["h"] < htol && this["gp"] < gptol &&
        this["f"] > fbest + fbar*abs(fbest) + ftol
      select = false
      break
    end
  end
  if select
    println(p)
  end
end
