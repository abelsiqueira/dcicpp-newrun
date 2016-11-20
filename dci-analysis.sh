#!/bin/bash

[ $# -lt 2 ] && echo "Need two arguments: DCI output dir and DCICPP output dir." && exit 1

dci=$1
dcicpp=$2

list1=$(basename $dci/*.list)
list2=$(basename $dcicpp/*.list)

if [ "$list1" != "$list2" ]; then
  echo "$1 and $2 did not run the same problems"
  exit 1
fi

out=analysis-dci-dcicpp-$(basename $list1 .list)-$(date +"%Y-%m-%d--%H-%M")
mkdir $out

./genprof-dci.sh $dci 
./genprof-dcicpp.sh $dcicpp

mv dci.prof $out/
mv dcicpp.prof $out/

cp $dci/$list1 $out/

# Exceptions on DCI (AAt singular, increase nmax, etc.)
cd $out

grep "e+20.*e+20.*e+20.*e+20" dci.prof | awk '{print $1}' > dci-fail.list
sort dci-fail.list $list1 | uniq -u > dci-good.list

perprof --tikz -o perf dci.prof dcicpp.prof --semilog
perprof --tikz -o perf-dci-good --subset dci-good.list dci.prof dcicpp.prof --semilog
