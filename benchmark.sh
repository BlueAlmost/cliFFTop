#!/bin/bash

FILES="bin/*"
N_REP=5000

for f in $FILES
do
   echo $f
   G="results/$(basename $f).csv"
   echo $G
   hyperfine --warmup 5 --runs 11 -P m 8 15 "$f $N_REP {m}" --export-csv $G
done


