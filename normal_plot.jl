lines = readlines(open("normal"))
n = length(lines)
veq1 = zeros(n)
veq0 = zeros(n)
vgt1 = zeros(n)
vle1 = zeros(n)
avg = zeros(n)
K = zeros(n)
kgt1 = Int[]

intervals = [round(i//5,1) for i = -1:10]
push!(intervals, 100)

d = 0

for i = 1:n
  vline = split(lines[i])
  k = parse(Int, vline[2])
  eq1 = parse(Int, vline[4])
  eq0 = parse(Int, vline[3]) - eq1
  gt1 = k - eq0 - eq1
  avg[i] = parse(vline[5])
  if k > 1
    push!(kgt1, i)
  end
  veq1[i] = round(eq1*100/k, d)
  vgt1[i] = round(gt1*100/k, d)
  vle1[i] = round((eq1+eq0)*100/k, d)
  veq0[i] = round(eq0*100/k, d)
  K[i] = k
end

points = Tuple{Float64,Float64}[]
hist2d = Int[]
for i = kgt1
  p = (veq1[i], veq0[i])
  j = find(p .== points)
  if length(j) > 0
    j = j[1]
    hist2d[j] += 1
  else
    push!(points, p)
    push!(hist2d, 1)
  end
end

minr = 0.5

open("normal-0vs1-kgt1.dat","w") do f
  write(f, "x,y,r\n")
  for (i,point) in enumerate(points)
    R = round(log(hist2d[i]+1)*0.5,3)
    write(f, "$(point[1]),$(point[2]),$R\n")
  end
end

open("hist.dat","w") do f
  e, counts = hist(avg[kgt1], intervals)
  counts[2] += counts[1]
  write(f, "i,I,n\n")
  for i = 2:length(counts)
    if i == 2
      name = "[0.0,0.2]"
    elseif i == length(counts)
      name = " > 2.0"
    else
      name = "($(intervals[i]),$(intervals[i+1])]"
    end
    write(f, "$(i-1),\"$name\",$(counts[i])\n")
  end
end
