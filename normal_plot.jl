lines = readlines(open("normal"))
n = length(lines)
eq1 = zeros(Int, n)
eq0 = zeros(Int, n)
gt1 = zeros(Int, n)
veq1 = zeros(n)
veq0 = zeros(n)
vgt1 = zeros(n)
vle1 = zeros(n)
avg = zeros(n)
K = zeros(n)
kgt1 = Int[]

intervals = [round(i//5,1) for i = -1:10]
push!(intervals, 100)

gridround(x) = round(Int, x)
radius(x) = round(log10(x)+0.3, 3)

for i = 1:n
  vline = split(lines[i])
  k = parse(Int, vline[2])
  eq1[i] = parse(Int, vline[4])
  eq0[i] = parse(Int, vline[3]) - eq1[i]
  gt1[i] = k - eq0[i] - eq1[i]
  avg[i] = parse(vline[5])
  if k > 1
    push!(kgt1, i)
  end
  veq1[i] = gridround(eq1[i]*100/k)
  vgt1[i] = gridround(gt1[i]*100/k)
  vle1[i] = gridround((eq1[i]+eq0[i])*100/k)
  veq0[i] = gridround(eq0[i]*100/k)
  K[i] = k
end

points = Any[]
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

# Counting grid lines
# On 100%
on100 = 0
on100left = 0
below80 = 0
for i = kgt1
  x, y = veq1[i], veq0[i]
  if x + y == 100
    on100 += 1
    if y >= x
      on100left += 1
    end
  elseif x + y <= 80
    below80 += 1
  end
end

open("sizes.dat","w") do f
  write(f, "i,x,r\n")
  for (i,x) in enumerate(round(Int, logspace(0,log10(maximum(hist2d)),4)) )
    write(f, "$i,$x,$(radius(x))\n")
  end
end

open("normal-0vs1-kgt1.dat","w") do f
  write(f, "x,y,r\n")
  for (i,point) in enumerate(points)
    R = radius(hist2d[i])
    write(f, "$(point[1]),$(point[2]),$R\n")
  end
end

lkgt1 = length(kgt1)
seq0 = sum(eq0[kgt1])
seq1 = sum(eq1[kgt1])
sgt1 = sum(gt1[kgt1])
sk = sum(K[kgt1])
println("Number of kgt1 points: $lkgt1")
println("On 100%: $on100 ($(round(100*on100/lkgt1,2)))")
println(" → Upper half: $on100left ($(round(100*on100left/on100,2)))")
println("Below 80%: $below80 ($(round(100*below80/lkgt1,2)))")
println("0 normal: $seq0 $sk ($(round(100*seq0/sk, 2)))")
println("1 normal: $seq1 $sk ($(round(100*seq1/sk, 2)))")
println("> 1 normal: $sgt1 $sk ($(round(100*sgt1/sk, 2)))")

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
