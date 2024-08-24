#!/bin/bash

if [ $# -ne 1 ]; then
  echo "Usage: $0 <p>"
  exit 1
fi

p=$1

for (( n=1; n<=255; n++ ))
do
  result=$(( (2**n) % p ))
  if [ $result -eq 0 ]; then
    echo $p
    echo "2^$n % $p == 0"
    exit 0
  fi
done

echo "no numbers found"
