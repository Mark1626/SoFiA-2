# Changelog for simd-scifinder-neon branch

1. To compile Sofia with OMP on macs, added `OMP = -Xpreprocessor -fopenmp -lomp` flags in Makefile. Also, in compile.sh, replace `$1` with `$@` to accept all cmd arguments.

2. To compile Sofia with SIMD INTRINSICS, added `ARCH = -march=native` flag for x86_64 and `ARCH = -march=armv8-a+fp+simd+crc -DUSE_INTRINSICS` flag for arm64 architecture in Makefile. Also, in compile.sh, replace `$1` with `$@` to accept all cmd arguments. In compile.sh, add a `$@` while compiling `src/statistics_flt.c`, since we need to pass `-march` flags to this file.
