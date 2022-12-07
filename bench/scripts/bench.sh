#!/usr/bin/env bash

set -e
set -x

processor=`uname -m`
simdCase=AVX
if [ $processor = "arm64" ]
then
    simdCase=NEON
fi
declare -a CASES=(GOLDEN $simdCase)

host=$1
parFile=$2
outputDir=bench/stat/$host/performance
mkdir -p $outputDir
FLAG=""

AWK=awk

function pattern() {
  id=$1
  label=$2
  PATTERN="
  /Time elapsed ms/ {
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
    if [ $case = "AVX" ]
    then
        FLAG="ARCH=-march=native"
    elif [ $case = "NEON" ]
    then 
        FLAG="ARCH=-march=armv8-a+fp+simd+crc"
      fi
      rm -f $outputDir/${parFile}-${case}-result.txt
      
      echo "Running ${case}" >> $outputDir/${parFile}-${case}-result.txt 

      make clean
      make all "OMP=-Xpreprocessor -fopenmp -lomp" $FLAG

    # start time
      startTime=`gdate +%s%3N`;
      ./sofia bench/parsets/${parFile} >> $outputDir/${parFile}-${case}-result.txt 
    #end time
      endTime=`gdate +%s%3N`;

      diffMicroSeconds="$(($endTime-$startTime))"

      echo  >> $outputDir/${parFile}-${case}-result.txt 
      echo "Time elapsed ms: $diffMicroSeconds ms" >> $outputDir/${parFile}-${case}-result.txt 

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
  set ylabel \"Time elapsed (ms)\";                     \
  set yrange [0:1000];                 \
  unset key;                                      \
  set boxwidth 0.5;                                       \
  set style fill solid;                                \
                                                        \
  plot \"$outputDir/${parFile}-stats.csv\" using 1:3:xtic(2) with boxes; \
" | gnuplot > $outputDir/${parFile}-performance.png
