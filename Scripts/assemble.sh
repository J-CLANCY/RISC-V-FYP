#!/usr/bin/env bash

#Author : Arthur Beretta
#Description : This script generate every file needed to insert code into the riscV compiler from assembly code

ASSEMBLY=$1
OUTPUT=$2

if [ -z "$1" ]
  then
    echo "Error, no arguments"
    echo "Usage : compile.sh assembly_prog.s"
    exit 1
fi

#replace main by _start in assembly code, this give the linker the starting point in the program
#If there is no starting point, it will work but the linker will emit a warning
sed -i 's/main/_start/g' "$ASSEMBLY"

#assemble assembly code
riscv32-unknown-elf-as "$ASSEMBLY" -o "$OUTPUT.elf"

#link code, resolve jumps and branches address
riscv32-unknown-elf-ld "$OUTPUT.elf" -Ttext=0x0 -o "$OUTPUT.out"

#expose the real instructions by decompiling elf code
riscv32-unknown-elf-objdump -d "$OUTPUT.out" > "$OUTPUT.elf_dump"

#dump .text part of elf executable, there is a lot of thing in an ELF file, we only need the text
riscv32-unknown-elf-objcopy -O binary --only-section=.text "$OUTPUT.out" "$OUTPUT.hex_little"

#change hex from little endian to big endian
./little_to_big.py "$OUTPUT.hex_little" "$OUTPUT.hex_big"

#Create code for vivado test bench
./hex_to_TB.py "$OUTPUT.hex_big" "$OUTPUT.TB"

#create macro to load code into FPGA from viciLab
./hex_to_viciMacro.py "$OUTPUT.hex_big" "$OUTPUT.macro"
