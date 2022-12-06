#!/usr/bin/env bash

set -e
set -x

processor=`uname -m`
simdCase=AVX2
if [ $processor = "arm64" ]
then
    simdCase=ARM_NEON
fi
declare -a CASES=(GOLDEN $simdCase)

host=$1
parFile=$2
outputDir=bench/stat/$host/performance
mkdir -p $outputDir

AWK=awk

function pattern() {
  id=$1
  label=$2
  PATTERN="
  /Time elapsed us/ {
    time = \$(NF - 1);
    printf(\"%s %s %s\n\", $id, \"$label\", time);
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

      make clean
      make all BENCH_FLAGS="-DNAVX2 -DNARM_NEON -UN$case"

    # start time
      startTime=`gdate +%S%6N`;
      ./sofia bench/parsets/${parFile} >> $outputDir/${parFile}-${case}-result.txt 
    #end time
      endTime=`gdate +%S%6N`;

      diffMicroSeconds="$(($endTime-$startTime))"

      echo  >> $outputDir/${parFile}-${case}-result.txt 
      echo "Time elapsed us: $diffMicroSeconds us" >> $outputDir/${parFile}-${case}-result.txt 

      PATTERN=`pattern $i $case`
      ((i+=1))
      cat $outputDir/${parFile}-${case}-result.txt | $AWK "$PATTERN" >> $outputDir/${parFile}-stats.csv
done

echo "                                            \
  reset;                                          \
  set terminal png enhanced large; \
                                                        \
  set title \"Sofia Performance Benchmark\";                        \
  set xlabel \"Matrix Dim\";                             \
  set ylabel \"Time elapsed (us)\";                     \
  set yrange [0:500000];                 \
  unset key;                                      \
  set boxwidth 0.5;                                       \
  set style fill solid;                                \
                                                        \
  plot \"$outputDir/${parFile}-stats.csv\" using 1:3:xtic(2) with boxes; \
" | gnuplot > $outputDir/${parFile}-performance.png
