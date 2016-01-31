#!/bin/bash

[ $# -lt 1 ] && echo "Need output dir" && exit 1

echo "Creating normal information"
for f in $1/*.out
do
  con=$(grep "Number of Con" $f | cut -f4 -d' ')
  [ -z "$con" -o "$con" == "0" ] && continue
  if grep Converged $f > /dev/null; then
    k=$(grep "Number of Iterat" $f | cut -f5 -d' ')
    le=$(grep "with <= 1" $f | cut -f8 -d' ')
    eq=$(grep "with = 1" $f | cut -f8 -d' ')
    avg=$(grep "Average" $f | cut -f7 -d' ')
    echo "$f $k $le $eq $avg $c"
  fi
done > normal

echo "Plotting"
#julia --depwarn=no normal_plot.jl
