cli***FFT***op contains a small collection of ffts written in zig

***Features:***

* Routines for complex-valued data, as well as strictly real-valued data.
* Support f32, f64 data types.
* Includes bash script for running benchmarks (requires hyperfine), result csv will be written to "results" directory. (Note: repository contains csv results from a test machine.  These will be overwritten by results for your test machine when running this bash script.)
* In the examples directory, is a zig wrapper for calling the fftw library is included (requires system library for fftw, if desired to be run.)  Comment out appropriate lines in examples/build.zig, and benchmarking/gnuplot_stuff/compare_speeds.gp if no fftw.
* Includes bash script for plotting benchmark results (requires gnuplot).
* A motivation here was for audio processing (strictly real valued data).

***Example of benchmarking results:***

