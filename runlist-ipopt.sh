#!/bin/bash

timelimit=300s

[ $# -lt 1 ] && echo "ERROR: Need list" && exit 1
[ ! -f $1 ] && echo "ERROR: $1 is not a file" && exit 1
list=$1

out=output-ipopt-$(basename $list .list)-$(date +"%Y-%m-%d--%H-%M")
[ -d $out ] && rm -rf $out/*
mkdir -p $out

cp $list $out

#LD_LIBRARY_PATH=~/Libraries/SuiteSparse/lib:$LD_LIBRARY_PATH

out=$PWD/$out
for problem in $(cat $list)
do
  echo "Running problem $problem"
  sifdecoder $problem > /dev/null
  gfortran -c *.f
  gfortran *.o -L$CUTEST/objects/$MYARCH/double -lcutest -lipopt -o run_cutest
  timeout $timelimit ./run_cutest &> $out/$problem.out
done

rm -f *.o ELFUN.f EXTER.f GROUP.f RANGE.f
