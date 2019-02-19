#!/usr/bin/env bash

C_CODE=$1
OUTPUT=$2

if [ -z "$1" ]
  then
    echo "Error, no arguments"
    echo "Usage : compile.sh <assembly_prog.c> <output_name>"
    exit 1
fi



#create assembly code
riscv32-unknown-elf-gcc -S -fomit-frame-pointer $C_CODE -o "$OUTPUT.S"

./assemble.sh "$OUTPUT.S" "$OUTPUT"
