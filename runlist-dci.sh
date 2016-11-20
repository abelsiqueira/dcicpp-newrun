#!/bin/bash

[ -z "$1" ] && echo "Needs lists" && exit 1

olddir=$(pwd)
list=$olddir/$1

outdir=output-dci-$(basename $list .list)-$(date +"%Y-%m-%d--%H:%M")
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
cp dci.spc $outdir/

# Now to outdir
cd $outdir

date > run-time

N=$(wc -l $list | awk '{print $1}')
i=1
for problem in $(cat $list)
do
  printf "%4d/$N %8s :" $i $problem
  runcutest -p dci -D $problem &> $problem.out
  ef=$(grep -A2 Summary $problem.out | tail -n 1)
  echo $ef
  i=$((i+1))
done

rm -f *.f *.d
cd $olddir
