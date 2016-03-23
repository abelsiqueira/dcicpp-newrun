#!/bin/bash

mkdir -p lists
genlist=1

if [ ! -z "$genlist" ]; then
  # Generate fullrank list
  grep -i "Cholesky failed" output-dcicpp/*.out | cut -f1 -d: | while read i; \
    do basename $i .out; done | cat cutest.list - | sort | \
    uniq -u > lists/fullrank.list

  # Generate nolarge list
  maxv=5000
  maxc=5000
  for f in output-dcicpp/*.out; do awk -v maxv=$maxv -v maxc=$maxc \
    '/Number of Variables/ { v=$4 };/Number of Constraints/ { c=$4 };
    /Problem name/ { name=$3 }; END{ if (v  < maxv && c < maxc) print name  }' $f;
  done > lists/nolarge.list

  # Generate samef list
  julia samef.jl > lists/samef.list

  # Generate notsmall list
  awk '{ if ($3 >= 0.01) print $1 }' *.prof | sort -u > lists/notsmall.list

  # fullrank combinations
  for L in nolarge samef notsmall
  do
    cat lists/{fullrank,$L}.list | sort | uniq -d > lists/fullrank_$L.list
  done

  for L in samef notsmall
  do
    cat lists/{fullrank_nolarge,$L}.list | sort | uniq -d > \
      lists/fullrank_nolarge_$L.list
  done
fi

# Running perprof
xlabel="Performance Ratio (t)"
ylabel="Fraction of solved problems ($\mathcal{P}_s(t)$)"
cmd="perprof -f --semilog --tikz --black-and-white"

#names=("" "_algencan-dcicpp" "_ipopt-dcicpp")
#profs=("*.prof" "algencan.prof dcicpp.prof" "ipopt.prof dcicpp.prof")
names=("")
profs=("*.prof")

for i in $(seq 0 $((${#names[@]}-1)))
do
  #for comp in exitflag f_and_h
  for comp in exitflag
  do
    $cmd --compare $comp -o profile_${comp}_fullset${names[$i]} --xlabel "$xlabel" --ylabel \
      "$ylabel" ${profs[$i]}
    #for list in lists/{fullrank{,_nolarge},nolarge}.list
    for list in lists/*.list
    do
      name=profile_${comp}_$(basename $list .list)${names[$i]}
      $cmd --compare $comp --subset $list -o $name --xlabel "$xlabel" --ylabel \
        "$ylabel" ${profs[$i]}
    done
  done
done
