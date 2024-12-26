# call this file using
# "gnuplot --persist filename.gp"

load "gnuplot_stuff/matplotlib_colors.gp"

set terminal qt size 800, 600
set terminal qt pos 200, 200

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
"results/reference.csv" using 9:2 with linespoints ls 1 lw lw_a \
pt 7 ps ptSize title "reference fft", \
\
"results/cooley_tukey_inplace_wlong.csv" using 9:2 with linespoints ls 2 lw lw_a \
pt 7 ps ptSize title "cooley-tukey inplace wlong", \
\
"results/cooley_tukey_recursive.csv" using 9:2 with linespoints ls 7 lw lw_a \
pt 7 ps ptSize title "cooley-tukey recursive", \
\
"results/mixed_radix.csv" using 9:2 with linespoints ls 4 lw lw_a \
pt 7 ps ptSize title "mixed radix", \
\
"results/rfft_no_lut.csv" using 9:2 with linespoints ls 5 lw lw_a \
pt 7 ps ptSize title "rfft - no lut", \
\
"results/rfft_lut.csv" using 9:2 with linespoints ls 3 lw lw_a \
pt 7 ps 1.5*ptSize title "rfft - lut", \
\
"results/rfft_sorensen_no_lut.csv" using 9:2 with linespoints ls 8 lw lw_a \
pt 7 ps ptSize title "rfft - sorensen - no lut", \
\
"results/rfft_sorensen_lut.csv" using 9:2 with linespoints ls 9 lw lw_a \
pt 7 ps ptSize title "rfft - sorensen - lut", \
\
"results/fftw_zig.csv" using 9:2 with linespoints ls 82 lw lw_b \
pt 7 ps ptSize title "real fftw-zig"

