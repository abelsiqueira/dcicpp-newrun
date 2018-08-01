#!/bin/bash

[ $# -lt 1 ] && echo "Need profile" && exit 1

awk 'BEGIN{ y = 0 };
  /---/ { y += 1; next };
  { if (y < 2) { next; }};
  { if ($3 < 0.1) { print $1 } };' $1
