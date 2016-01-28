using Winston

lines = readlines(open("normal"))
n = length(lines)
x = zeros(n)
y = zeros(n)
z = zeros(n)
w = zeros(n)
K = zeros(n)
kgt1 = Int[]

for i = 1:n
  vline = split(lines[i])
  k = parse(Int, vline[2])
  eq1 = parse(Int, vline[4])
  eq0 = parse(Int, vline[3]) - eq1
  gt1 = k - eq0 - eq1
  if k > 1
    push!(kgt1, i)
  end
  x[i] = eq1*100/k
  y[i] = gt1*100/k
  z[i] = (eq1+eq0)*100/k
  w[i] = eq0*100/k
  K[i] = k
end

r = 3
maxr = maximum(K)
minr = 0.5

# Normal iterations per iteration
p = FramedPlot()
grid(p, true)
for i = 1:n
  R = max(K[i]*r/maxr, minr)
  t = linspace(0, 2pi, ceil(20*R))
  add(p, Curve(x[i]+cos(t)*R, y[i]+sin(t)*R))
end

for s = [20 40 60 80 100]
  t = linspace(0, s, s)
  add(p, Curve(t, s-t, linestyle="dashed"))
end
setattr(p, "xlabel", "iterations with one restoration (%)")
setattr(p, "ylabel", "iterations with more than one restoration (%)")
savefig(p, "normal.png", "width", 1000, "height", 1000)

p = FramedPlot()
grid(p, true)
for i = kgt1
  R = max(K[i]*r/maxr, minr)
  t = linspace(0, 2pi, ceil(20*R))
  add(p, Curve(x[i]+cos(t)*R, y[i]+sin(t)*R))
end

for s = [20 40 60 80 100]
  t = linspace(0, s, s)
  add(p, Curve(t, s-t, linestyle="dashed"))
end
setattr(p, "xlabel", "iterations with one restoration (%)")
setattr(p, "ylabel", "iterations with more than one restoration (%)")
savefig(p, "normal-kgt1.png", "width", 1000, "height", 1000)

p = FramedPlot()
grid(p, true)
for i = 1:n
  R = max(K[i]*r/maxr, minr)
  t = linspace(0, 2pi, ceil(20*R))
  add(p, Curve(x[i]+cos(t)*R, w[i]+sin(t)*R))
end

for s = [20 40 60 80 100]
  t = linspace(0, s, s)
  add(p, Curve(t, s-t, linestyle="dashed"))
end
setattr(p, "xlabel", "iterations with one restoration (%)")
setattr(p, "ylabel", "iterations with more than one restoration (%)")
savefig(p, "normal-0vs1.png", "width", 1000, "height", 1000)

p = FramedPlot()
grid(p, true)
for i = kgt1
  R = max(K[i]*r/maxr, minr)
  t = linspace(0, 2pi, ceil(20*R))
  add(p, Curve(x[i]+cos(t)*R, w[i]+sin(t)*R))
end

for s = [20 40 60 80 100]
  t = linspace(0, s, s)
  add(p, Curve(t, s-t, linestyle="dashed"))
end
setattr(p, "xlabel", "iterations with one restoration (%)")
setattr(p, "ylabel", "iterations with more than one restoration (%)")
savefig(p, "normal-0vs1-kgt1.png", "width", 1000, "height", 1000)

q = FramedPlot()
grid(q, true)
h = linspace(-0.01, 100.01, 11)
H = [sum(h[i] .<= z .< h[i+1]) for i = 1:length(h)-1]
Hx = [sum(h[i] .<= x .< h[i+1]) for i = 1:length(h)-1]
for i = 1:length(H)
  x = [h[i]; h[i+1]]
  y = [1; 1]*H[i]
  add(q, FillBelow(x, y, color="lightgray"))
  add(q, Curve(x, y))
end

add(q, Curve([1;1]*h[1], [0 H[1]]))
add(q, Curve([1;1]*h[end], [0 H[end]]))
for i = 1:length(H)-1
  add(q, Curve([1;1]*h[i+1], [H[i] H[i+1]]))
end
setattr(q, "xlabel", "iterations with one or less restorations (%)")
setattr(q, "ylabel", "iterations")
savefig(q, "normal-hist.png", "width", 640, "height", 480)
