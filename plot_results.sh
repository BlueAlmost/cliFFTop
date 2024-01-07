#!/bin/bash
pushd gnuplot > /dev/null
gnuplot -persist compare_speeds.gp
popd > /dev/null

