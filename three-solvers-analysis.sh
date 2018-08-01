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

# Generate .prof files
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

# Creating cholok
sort cholfail.list $list1 | uniq -u > cholok.list

# Create list of too-fast problems
awk '{if (NF == 6 && $3 <= 0.0001) print $1}' *.prof | sort -u > too-fast.list
sort too-fast.list cutest.list | uniq -u > not-too-fast.list

pp="perprof -f --compare exitflag --tikz dcicpp.prof algencan.prof ipopt.prof --semilog --black-and-white"

# Specific subsets
sort nolarge.list cholok.list | uniq -d > nolarge-cholok.list
# No large, cholok, not too fast
sort nolarge-cholok.list not-too-fast.list | uniq -d > nolarge-cholok-not-too-fast.list
sort nolarge-cholok.list anycon.list | uniq -d > nolarge-cholok-anycon.list
sort nolarge-cholok.list equ-free.list | uniq -d > nolarge-cholok-equ-free.list
sort nolarge-cholok.list ineq-or-bounds.list | uniq -d > nolarge-cholok-ineq-or-bounds.list

lists="nolarge-cholok nolarge-cholok-not-too-fast nolarge-cholok-anycon nolarge-cholok-equ-free nolarge-cholok-ineq-or-bounds"

# Create nolarge subset
#for l in cholok anycon equ-free ineq-or-bounds
#do
#  sort nolarge.list $l.list | uniq -d > nolarge-$l.list
#done

# Creating samef subset
for l in $lists
do
  sort samef.list $l.list | uniq -d > samef-$l.list
done

$pp -o perf
for l in $lists
do
  $pp -o perf-$l --subset $l.list
  $pp -o perf-samef-$l --subset samef-$l.list
done
