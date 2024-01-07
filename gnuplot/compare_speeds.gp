# call this file using
# "gnuplot --persist filename.gp"

load "matplotlib_colors.gp"

set datafile separator ','
set logscale y
set key top left
set xlabel 'log_2(N)'
set ylabel 'mean time'

# set xtics 1
# set ytics 1
# set mytics 1
set grid xtics ytics mytics

ptSize = 0.4
lineWidth = 1

plot \
"../results/reference.csv" using 9:2 with linespoints ls 1 lw lineWidth \
pt 7 ps ptSize title "reference fft", \
"../results/cooley_tukey_inplace_wlong.csv" using 9:2 with linespoints ls 2 lw lineWidth \
pt 7 ps ptSize title "cooley-tukey inplace", \
"../results/cooley_tukey_recursive.csv" using 9:2 with linespoints ls 3 lw lineWidth \
pt 7 ps ptSize title "cooley-tukey recursive", \
"../results/mixed_radix.csv" using 9:2 with linespoints ls 4 lw lineWidth \
pt 7 ps ptSize title "mixed radix", \
"../results/rfft_no_lut.csv" using 9:2 with linespoints ls 5 lw lineWidth \
pt 7 ps ptSize title "rfft - no lut", \
"../results/rfft_lut.csv" using 9:2 with linespoints ls 6 lw lineWidth \
pt 2 ps 2*ptSize title "rfft - lut", \
"../results/rfft_sorensen_no_lut.csv" using 9:2 with linespoints ls 7 lw lineWidth \
pt 7 ps ptSize title "rfft - sorensen - no lut", \
"../results/rfft_sorensen_lut.csv" using 9:2 with linespoints ls 9 lw lineWidth \
pt 7 ps ptSize title "rfft - sorensen - lut"
