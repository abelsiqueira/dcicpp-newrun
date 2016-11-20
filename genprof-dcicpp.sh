#!/bin/bash

[ -z "$1" ] && echo "ERROR Need dir" && exit 1
[ ! -d $1 ] && echo "ERROR $1 is not a dir" && exit 1

list=$(basename $1/*.list)
dir=$1

echo "---
algname: dcicpp
col_name: 1
col_exit: 2
col_time: 3
col_fval: 4
col_primal: 5
col_dual: 6
---" > dcicpp.prof

for f in $(cat $dir/$list)
do
  if [ -z "$(grep EXIT $dir/$f.out)" ]; then
    echo "$f d 1e20 1e20 1e20 1e20"
  else
    sed 's/-nan/1e20/g' $dir/$f.out | sed 's/nan/1e20/g' | awk -v name=$f \
      '/f\(x/ {f = $3}; /c\(x/ {h = $3 }; /g\(x/ {gp = $5}; /Elapsed Time/ {t = $4};
      END{ if (h > 1e-6 || gp > 1e-6) conv="d"; else conv="c";
        print name, conv, t, f, h, gp }'
  fi
done >> dcicpp.prof
