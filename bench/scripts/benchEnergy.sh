#!/usr/bin/env bash

set -e
set -x

declare -a CASES=(GOLDEN AVX)

host=$1
parFile=$2
outputDir=bench/stat/$host/energy
mkdir -p $outputDir

AWK=awk

function pattern() {
  id=$1
  label=$2
  PATTERN="
  /energy-pkg/ {
    energy = \$1;
  }
  /seconds time elapsed/ {
    time = \$1;
    printf(\"%s %s %s %s\n\", $id, \"$label\", energy, time);
  }
  "
  echo $PATTERN
}

i=0

rm -f $outputDir/${parFile}-stats.csv
for case in ${CASES[@]}
do  
      rm -f $outputDir/${parFile}-${case}-result.txt
      
      echo "Running ${case}" >> $outputDir/${parFile}-${case}-result.txt 

      make all BENCH_FLAGS="-DNGOLDEN -DNAVX -UN$method"

      perf stat -e power/energy-pkg/ ./sofia bench/parsets/${parFile} &>> $outputDir/${parFile}-${case}-result.txt 

      PATTERN=`pattern $i $case`
      ((i+=1))
      cat $outputDir/${parFile}-${case}-result.txt | $AWK "$PATTERN" >> $outputDir/${parFile}-stats.csv
done

echo "                                            \
  reset;                                          \
  set terminal png enhanced large; \
                                                        \
  set title \"Sofia Benchmark\";                        \
  set xlabel \"Matrix Dim\";                             \
  set ylabel \"Joules\";                     \
  set yrange [0:500];                 \
  unset key;                                      \
  set boxwidth 0.5;                                       \
  set style fill solid;                                \
                                                        \
  plot \"$outputDir/${parFile}-stats.csv\" using 1:3:xtic(2) with boxes; \
" | gnuplot > $outputDir/${parFile}-performance.png
