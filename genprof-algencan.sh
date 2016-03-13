#!/bin/bash

[ $# -lt 1 ] && echo "ERROR: Need dir" && exit 1
[ ! -d $1 ] && echo "ERROR: $1 is not a dir" && exit 1

list=cutest.list
dir=$1

# f is col1
# |h| is col2
# |gp| is col5

echo "---
algname: Algencan
col_name: 1
col_exit: 2
col_time: 3
col_fval: 4
col_primal: 5
col_dual: 6
---" > algencan.prof

for f in $(cat $list)
do
  if [ ! -f "$dir/$f.tabline" ]; then
    echo "$f d 1e20 1e20 1e20"
    continue
  fi
  if [ ! -f "$dir/$f.out" -o "$(wc -c <$dir/$f.out)" -ge 500000 ]; then
    time=$(awk '{if ($25 == 0.0) print 0.005; else print $25}' $dir/$f.tabline)
  else
    time=$(awk '/System/ { if ($4 == 0.0) print 0.0005; else print $4 }' $dir/$f.out)
    if [ -z "$time" ]; then
      time=$(awk '{if ($25 == 0.0) print 0.005; else print $25}' $dir/$f.tabline)
    fi
  fi
  sed 's/D/e/g' $dir/$f.tabline |  awk -v name=$f -v t=$time \
  '{ if ($2 < 1e-6 && $5 < 1e-6) conv="c"; else conv="d" };
    { print name, conv, t, $1, $2, $5 }' | sed 's/+200/e+20/g' |
      sed 's/-Infinity/-1e20/g'
done >> algencan.prof
