#!/bin/bash

[ $# -lt 1 ] && echo "ERROR: Need dir" && exit 1
[ ! -d $1 ] && echo "ERROR: $1 is not a dir" && exit 1

list=cutest.list
dir=$1

# f is col1
# |h| is col2
# |gp| is col5

echo "---
algname: IpOpt
col_name: 1
col_exit: 2
col_time: 3
col_fval: 4
col_primal: 5
col_dual: 6
---" > ipopt.prof

for f in $(cat $list)
do
  if [ -z "$(grep "Total CPU" $dir/$f.out)" ]; then
    echo "$f d 1e20 1e20 1e20 1e20"
    continue
  fi
  awk -v name=$f 'BEGIN{f=1e20; h=1e20; gp=1e20}; /Objective../ {f = $3};
    /Constraint vio/ {h = $4}; /Dual infea/ {gp = $4};
    /Total CPU secs in IPOPT/ {t = $10};
    /Total CPU secs in NLP/ {t = t + $9};
    END{ if (h < 1e-6 && gp < 1e-6) conv = "c"; else conv = "d";
    if (t == 0.0) t = 0.0005;
      print name, conv, t, f, h, gp }' $dir/$f.out
done >> ipopt.prof
