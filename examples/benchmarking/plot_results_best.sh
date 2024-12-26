#!/bin/bash
# pushd gnuplot > /dev/null

export -n SESSION_MANAGER
gnuplot -persist gnuplot_stuff/compare_speeds_best.gp


# popd > /dev/null
