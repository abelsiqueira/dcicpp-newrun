#!/bin/bash

# Check if exit flag on $2 is correct with max($5,$6) < 1e-6

[ $# -lt 1 ] && echo "ERROR: Need prof file" && exit 1
[ ! -f $1 ] && echo "ERROR: $1 is not a file" && exit 1

prof=$1

awk 'BEGIN{ yaml = 0};
  { if ($0 == "---") { yaml += 1; next} };
  function max(a,b) { if (a > b) return a; else return b };
  { if (yaml < 2) next };
  { if (max($5,$6) < 1e-6 && $2 == "d")
      print $1, $2, "should be c";
    else if (max($5,$6) >= 1e-6 && $2 == "c")
      print $1, $2, "should be d"; }' $prof
