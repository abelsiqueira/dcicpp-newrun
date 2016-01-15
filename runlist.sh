#!/bin/bash

[ -z "$1" ] && echo "Needs lists" && exit 1

mkdir -p output
rm -f output/*
outdir=output
olddir=$(pwd)
list=$olddir/$1
cp $list $outdir/
cp dcicpp.spc $outdir/

# Now to outdir
cd $outdir

date > run-time

for problem in $(cat $list)
do
  rundcicpp -D $problem > $problem.out
done

rm -f *.f *.d
cd $olddir
