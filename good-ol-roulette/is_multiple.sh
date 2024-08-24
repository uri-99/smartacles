#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: $0 <p>"
    exit 1
fi

p=$1

for (( n=1; n<=255; n++ ))
do
    n_mod_8=$(echo "$n % 8" | bc)
    if [ $n_mod_8 -eq 0 ]; then
        a=$(echo "((2^$n)-1) % ($p-1)" | bc)
        if [ $a -eq 0 ]; then
            echo $n
            exit 0
        fi
    fi
done

echo "no numbers found"
