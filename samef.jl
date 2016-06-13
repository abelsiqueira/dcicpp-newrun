tof(x) = typeof(parse(x)) == Float64 ? parse(x) : 1e20

function read_data(file)
  yaml = 0
  algname = ""
  algdata = Dict()
  for line in readlines(open(file))
    if contains(line, "---")
      yaml += 1
      continue
    elseif contains(line, "algname")
      algname = split(line)[2]
    end
    if yaml < 2
      continue
    end
    sline = split(line)
    problem = sline[1]
    push!(problems, problem)

    algdata[problem] = Dict("f"=>tof(sline[4]), "h"=>tof(sline[5]),
        "gp"=>tof(sline[6]))
  end
  return algdata, algname
end

function select_fbar_ftol(data, problems, solvers; fbar = 1e-3, ftol = 1e-6, htol = 1e-6,
    gptol = 1e-6)
  selection = []
  for p in problems
    conv_s = filter(s->(data[s][p]["h"] < htol && data[s][p]["gp"] < gptol),
      solvers)
    if length(conv_s) == 0
      continue
    end
    fs = [data[s][p]["f"] for s in conv_s]
    fmin, fmax = extrema(fs)
    if isnan(fmax) || isnan(fmin) || max(abs(fmin),abs(fmax)) == Inf
      continue
    end
    if fmax < fmin + ftol + fbar * max(abs(fmin),abs(fmax))
      push!(selection, p)
    end
  end
  return selection
end

function select_fmin_fmax(data, problems, solvers; ftol = 1e-1, htol = 1e-6, gptol = 1e-6)
  selection = []
  for p in problems
    conv_s = filter(s->(data[s][p]["h"] < htol && data[s][p]["gp"] < gptol),
      solvers)
    if length(conv_s) == 0
      continue
    end
    fs = [data[s][p]["f"] for s in conv_s]
    fmin, fmax = extrema(fs)
    if isnan(fmax) || isnan(fmin) || max(abs(fmin),abs(fmax)) == Inf
      continue
    end
    if (fmax - fmin) < ftol * (1 + max(abs(fmin),abs(fmax)))
      push!(selection, p)
    end
  end
  return selection
end

files = ["algencan.prof", "dcicpp.prof", "ipopt.prof"]

data = Dict()
problems = []


for file in files
  algdata, algname = read_data(file)
  data[algname] = algdata
end

problems = sort(unique(problems))
solvers = [string(x) for x in keys(data)]

#selection = select_fbar_ftol(data, problems, solvers)
selection = select_fmin_fmax(data, problems, solvers)

#println("# = $(length(selection))")
for p in selection
  println(p)
end
