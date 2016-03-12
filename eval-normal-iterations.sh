#!/bin/bash

[ $# -lt 1 ] && echo "Need output dir" && exit 1

echo "Creating normal information"
for f in $1/*.out
do
  con=$(grep "Number of Con" $f | cut -f4 -d' ')
  [ -z "$con" -o "$con" == "0" ] && continue
  if grep Converged $f > /dev/null; then
    if grep nan $f > /dev/null; then
      continue
    fi
    name=$(basename $f .out)
    awk -v name=$name '/Number of Iterat/ {k = $5};
      /with <= 1/ {le = $8};
      /with = 1/ {eq = $8};
      /Average/ {avg = $7};
      END{print name, k, le, eq, avg};' $f
  fi
done > normal

echo "Plotting"
julia --depwarn=no normal_plot.jl
latexmk -pdf normal-0vs1-kgt1
latexmk -pdf hist
