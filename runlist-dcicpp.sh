#!/bin/bash

[ -z "$1" ] && echo "Needs lists" && exit 1

timelimit="30s"
olddir=$(pwd)
list=$olddir/$1

outdir=output-dcicpp-$(basename $list .list)-$(date +"%Y-%m-%d--%H:%M")
aux=$outdir
p=1
while [ -d $aux ]
do
  p=$((p+1))
  aux=$outdir-$p
done
outdir=$aux
mkdir $outdir

cp $list $outdir/
cp dcicpp.spc $outdir/

# Now to outdir
cd $outdir

date > run-time

N=$(wc -l $list | awk '{print $1}')
i=1
for problem in $(cat $list)
do
  printf "%4d/$N %8s :" $i $problem
  timeout $timelimit rundcicpp -D $problem &> $problem.out
  #rundcicppclean -D $problem &> $problem.out
  ef=$(grep EXIT $problem.out | cut -d: -f2)
  echo $ef
  i=$((i+1))
done

rm -f *.f *.d
cd $olddir
