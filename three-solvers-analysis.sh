#!/bin/bash

[ $# -lt 3 ] && echo "Need three arguments: DCICPP's, ALGENCAN's and IPOPT's output dir." && exit 1

dcicpp=$1
algencan=$2
ipopt=$3

list1=$(basename $dcicpp/*.list)
list2=$(basename $algencan/*.list)
list3=$(basename $ipopt/*.list)

if [ "$list1" != "$list2" -o "$list1" != "$list2" ]; then
  echo "$1, $2 and $3 have to run the same problems"
  exit 1
fi

out=analysis-three-solvers-$(basename $list1 .list)-$(date +"%Y-%m-%d--%H-%M")
mkdir $out

./genprof-dcicpp.sh $dcicpp
./genprof-algencan.sh $algencan
./genprof-ipopt.sh $ipopt

julia samef.jl > $out/samef.list

mv dcicpp.prof $out/
mv algencan.prof $out/
mv ipopt.prof $out/

cp $dcicpp/$list1 $out/
cp anycon.list equ-free.list ineq-or-bounds.list nolarge.list $out/

grep -l -i cholesky $dcicpp/*.out | while read i; do basename $i .out; done > $out/cholfail.list

cd $out

sort cholfail.list $list1 | uniq -u > cholok.list

# Create nolarge subset
for l in cholok anycon equ-free ineq-or-bounds
do
  sort nolarge.list $l.list | uniq -d > nolarge-$l.list
done

# Creating samef subset
for l in nolarge cholok nolarge-cholok anycon equ-free ineq-or-bounds \
          nolarge-anycon nolarge-equ-free nolarge-ineq-or-bounds
do
  sort samef.list $l.list | uniq -d > samef-$l.list
done

pp="perprof --compare exitflag --tikz dcicpp.prof algencan.prof ipopt.prof --semilog --black-and-white"

$pp -o perf
for l in nolarge cholok nolarge-cholok anycon equ-free ineq-or-bounds \
          nolarge-anycon nolarge-equ-free nolarge-ineq-or-bounds
do
  $pp -o perf-$l --subset $l.list
  $pp -o perf-samef-$l --subset samef-$l.list
done
