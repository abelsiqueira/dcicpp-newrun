#!/bin/bash

mkdir -p lists

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

# fullrank_nolarge
cat lists/{fullrank,nolarge}.list | sort | uniq -d > lists/fullrank_nolarge.list

# Running perprof
xlabel="Performance Ratio (t)"
ylabel="Fraction of solved problems ($\mathcal{P}_s(t)$)"
cmd="perprof -f --semilog --tikz *.prof --black-and-white"

for comp in exitflag f_and_h
do
  $cmd --compare $comp -o profile_${comp}_fullset --xlabel "$xlabel" --ylabel \
    "$ylabel"
  for list in lists/{fullrank{,_nolarge},nolarge}.list
  do
    name=profile_${comp}_$(basename $list .list)
    $cmd --compare $comp --subset $list -o $name --xlabel "$xlabel" --ylabel \
      "$ylabel"
  done
done
