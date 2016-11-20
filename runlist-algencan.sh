#!/bin/bash

[ $# -lt 1 ] && echo "ERROR: Need list" && exit 1
[ ! -f $1 ] && echo "ERROR: $1 is not a file" && exit 1
list=$1

algencan=$HOME/Libraries/algencan-3.1.0
timelimit="300s"

out=output-algencan-$(basename $list .list)-$(date +"%Y-%m-%d--%H-%M")
[ -d $out ] && rm -rf $out/*
mkdir -p $out

cp $list algencan.dat $out
cp $list $algencan
cp -f algencan.dat $algencan/bin/cutest/

out=$PWD/$out
old=$PWD

cd $algencan
for problem in $(cat $list)
do
  echo "Running $problem"
  rm -f /bin/cutest/algencan
  make algencan-cutest PROBNAME=$problem &> /dev/null
  cd $algencan/bin/cutest
  timeout $timelimit ./algencan &> $out/$problem.out 
  mv algencan-tabline.out $out/$problem.tabline
  cd ../..
done
cd $old
