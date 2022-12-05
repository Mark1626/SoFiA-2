# Makefile for the compilation of SoFiA 2
#
# Usage examples:
#   make                                        for GCC or Clang without OpenMP
#   make OMP=-fopenmp                           for GCC or Clang with OpenMP
#   make OMP=-fopenmp OPT="-O3 -march=native"   for SIMD optimization, if available in host
#   make CC=icc OPT=-O3 OMP=-openmp             for Intel C Compiler with OpenMP (not tested)
#   make clean                                  remove object files after compilation
#   make DEBUG=1                                for debug mode (no compiler optimisations)

UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Linux)
	OMP += -fopenmp
else ifeq ($(UNAME_S),Darwin)
	OMP += -Xpreprocessor -fopenmp -lomp
endif

processor := $(shell uname -m)
ifeq ($(processor),$(filter $(processor),aarch64 arm64))
    ARCH_C_FLAGS += -march=armv8-a+fp+simd+crc 
else ifeq ($(processor),$(filter $(processor),i386 x86_64))
    ARCH_C_FLAGS += -march=native 
endif


SRC = src/Array_dbl.c \
      src/Array_siz.c \
      src/Catalog.c \
      src/common.c \
      src/DataCube.c \
      src/Flagger.c \
      src/Header.c \
      src/LinkerPar.c \
      src/Map.c \
      src/Matrix.c \
      src/Parameter.c \
      src/Path.c \
      src/Source.c \
      src/Stack.c \
      src/statistics_dbl.c \
      src/statistics_flt.c \
      src/String.c \
      src/Table.c \
      src/WCS.c

OBJ = $(SRC:.c=.o)

TEST = tests/test_LinkerPar.c

TEST_OBJ = $(TEST:.c=.o)

# OPENMP = -fopenmp
# OMP     = -Xpreprocessor -fopenmp -lomp
OPT     = --std=c99 --pedantic -Wall -Wextra -Wshadow -Wno-unknown-pragmas -Wno-unused-function -Wfatal-errors -O3
LIBS    = -lm -lwcs
CC      = gcc
CFLAGS += $(OPT) $(OMP) $(ARCH_C_FLAGS)

ifdef DEBUG
OPT     = -g -O0 -fsanitize=address
endif

all:	sofia

sofia:	$(OBJ)
	$(CC) $(CFLAGS) -o sofia sofia.c $(OBJ) $(LIBS) $(BENCH_FLAGS)

unittest:	$(OBJ) $(TEST_OBJ)
	$(CC) $(CFLAGS) -o unittest tests/unittest.c $(TEST_OBJ) $(OBJ) $(LIBS) `pkg-config --cflags --libs check` $(BENCH_FLAGS)

clean:
	rm -rf $(OBJ) $(TEST_OBJ)
