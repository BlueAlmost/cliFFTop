#!/bin/bash

FILES="../bin/*"
N_REP=5000

# benchmark zig code
for f in $FILES
do
   echo $f
   G="./results/$(basename $f).csv"
   echo $G
   hyperfine --warmup 5 --runs 11 -P m 10 15 "$f $N_REP {m}" --export-csv $G
done





