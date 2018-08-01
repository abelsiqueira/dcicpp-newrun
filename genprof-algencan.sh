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
    echo "$f d 1e20 1e20 1e20 1e20"
    continue
  fi

#  # Algencan time precision is 0.00
#  time=$(awk '{if ($25 == 0.0) print 0.005; else print $25}' $dir/$f.tabline)
  time=$(awk '/Elapsed time/ { t = $3 };
    END{ if (t == 0.0) { t = 0.00048828125 }; print t };' $dir/$f.out)

  sed 's/D/e/g' $dir/$f.tabline |  awk -v name=$f -v t=$time \
  '{ if ($2 < 1e-6 && $5 < 1e-6) conv="c"; else conv="d" };
    { print name, conv, t, $1, $2, $5 }' | sed 's/+200/e+20/g' |
      sed 's/-Infinity/-1e20/g'
done >> algencan.prof
# Annoying -310
sed -i 's/\([0-9]\)-310/\1e-310/g' algencan.prof
