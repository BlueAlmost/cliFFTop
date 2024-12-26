# call this file using
# "gnuplot --persist filename.gp"

load "gnuplot_stuff/matplotlib_colors.gp"

set terminal qt size 800, 600
set terminal qt pos 400, 400

set datafile separator ','
set logscale y
set key top left
set xlabel 'log_2(N)'
set ylabel 'mean time'

# set xtics 1
# set ytics 1
# set mytics 1
set grid xtics ytics mytics

ptSize = 1.5
lw_a = 1.5
lw_b = 2.5

plot \
"results/rfft_lut.csv" using 9:2 with linespoints ls 3 lw lw_a \
pt 7 ps 1.5*ptSize title "rfft - lut", \
\
"results/fftw_zig.csv" using 9:2 with linespoints ls 82 lw lw_b \
pt 7 ps ptSize title "real fftw-zig"

