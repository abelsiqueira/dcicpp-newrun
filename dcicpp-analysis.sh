#!/bin/bash

[ $# -lt 2 ] && echo "Need two DCICPP output dirs" && exit 1

dcicpp1=$1
dcicpp2=$2

list1=$(basename $dcicpp1/*.list)
list2=$(basename $dcicpp2/*.list)

if [ "$list1" != "$list2" ]; then
  echo "$1 and $2 have to run the same problems"
  exit 1
fi

out=analysis-dcicpp-twice-$(basename $list1 .list)-$(date +"%Y-%m-%d--%H-%M")
mkdir $out

./genprof-dcicpp.sh $dcicpp1
sed -i 's/algname: dcicpp/algname: dcicpp 1/g' dcicpp.prof
mv dcicpp.prof $out/dcicpp1.prof

./genprof-dcicpp.sh $dcicpp2
sed -i 's/algname: dcicpp/algname: dcicpp 2/g' dcicpp.prof
mv dcicpp.prof $out/dcicpp2.prof

cp $dcicpp1/$list1 $out/
cp nolarge.list $out/

grep -l -i cholesky $dcicpp1/*.out | while read i; do basename $i .out; done > $out/cholfail.list

cd $out

sort cholfail.list $list1 | uniq -u > cholok.list

sort cholok.list nolarge.list | uniq -d > nolarge-cholok.list

pp="perprof --tikz dcicpp1.prof dcicpp2.prof --semilog --black-and-white"

$pp -o perf
for l in nolarge cholok nolarge-cholok
do
  $pp -o perf-$l --subset $l.list
done
