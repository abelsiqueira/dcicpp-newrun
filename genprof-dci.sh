#!/bin/bash

# Half of the minimum nonzero value: 3.90625e-3/2 = 0.001953125 = 2^-9
mintime=0.001953125

[ -z "$1" ] && echo "ERROR Need dir" && exit 1
[ ! -d $1 ] && echo "ERROR $1 is not a dir" && exit 1

list=$(basename $1/*.list)
dir=$1

echo "---
algname: dci
col_name: 1
col_exit: 2
col_time: 3
col_fval: 4
col_primal: 5
col_dual: 6
---" > dci.prof

function badline() {
  printf "%-8s d %+12.8e %+12.8e %+12.8e %+12.8e\n" $f 1e20 1e20 1e20 1e20
}

for f in $(cat $dir/$list)
do
  if [ ! -f $dir/$f.out ]; then
    badline
  elif [ ! -z "$(grep 'AAt is almost singular' $dir/$f.out)" ]; then
    badline
  elif [ ! -z "$(grep 'Increase' $dir/$f.out)" ]; then
    badline
  else
    sed 's/-NaN/1e20/g' $dir/$f.out | sed 's/NaN/1e20/g' | awk -v name=$f \
      -v mintime=$mintime \
      '/f\(x/ {f = $3}; /h\(x/ {h = $3 }; /gp\(x/ {gp = $3}; /Elapsed time/ {t = $4};
      END{ if (h > 1e-6 || gp > 1e-6) conv="d"; else conv="c";
        if (t == 0) t = mintime;
        printf "%-8s %s %+12.8e %+12.8e %+12.8e %+12.8e\n", name, conv, t, f, h, gp }'
  fi
done >> dci.prof
