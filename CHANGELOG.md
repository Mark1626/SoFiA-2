# Changelog for simd-scifinder-neon branch

1. To compile Sofia with OMP on macs, added `OMP = -Xpreprocessor -fopenmp -lomp` flags in Makefile. Also, in compile.sh, replace `$1` with `$@` to accept all cmd arguments.

2. To compile Sofia with SIMD INTRINSICS, added `ARCH = -march=native` flag for x86_64 and `ARCH = -march=armv8-a+fp+simd+crc -DUSE_INTRINSICS` flag for arm64 architecture in Makefile. Also, in compile.sh, replace `$1` with `$@` to accept all cmd arguments. In compile.sh, add a `$@` while compiling `src/statistics_flt.c`, since we need to pass `-march` flags to this file.

3. In `src/DataCube.c`, added NEON instructions inside `DataCube_boxcar_filter` and `DataCube_gaussian_filter` functions. A macro `USE_INTRINSICS` has been defined to enable or disable the use of NEON intrinsics in application.

4. In `src/statistics_flt.c`, `filter_gauss_2d_flt_neon` `filter_boxcar_1d_flt_neon` and `filter_nan_neon` functions are added. Corresponding declaration are added in `src/statistics_flt.h`
