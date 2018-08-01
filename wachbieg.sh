#!/bin/bash

# Testing WACHBIEG for various a,b
# The original values for a,b were -1 and 0.5

#values=$(seq -2.0 0.01 2.0)
values=$(seq -1.0 1.0)
f=$MASTSIF/WACHBIEG.SIF

for a in $values
do
  for b in $values
  do
    #fval=$(echo "scale=4; if ($a>=0) { a=-1000; } else { a=$a; a=sqrt(-a); }; if (a>$b) { f=a; } else { f=$b; }; f" | bc)
    #echo "----- a=$a ---- b=$b ---- f=$fval ------------------------------"
    sed -i 's/\(RE A\s\+\)[0-9.-]*/\1'$a'/g' $f
    sed -i 's/\(RE B\s\+\)[0-9.-]*/\1'$b'/g' $f
    rundcicpp -D WACHBIEG &> /tmp/tmp
    ef=$(grep EXIT /tmp/tmp)
    echo "a=$a, b=$b, $ef"
    #grep "f(x)" /tmp/tmp
    #grep Normal /tmp/tmp
    #grep Rest /tmp/tmp
  done
done

sed -i 's/\(RE A\s\+\)[0-9.-]*/\1-1.0/g' $f
sed -i 's/\(RE B\s\+\)[0-9.-]*/\10.5/g' $f
