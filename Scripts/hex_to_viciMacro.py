#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Description : This script transform little endian code to big endian
Usage : ./hex_to_viciMacro.py input_file output_file
Author : Arthur Beretta
Date : 05/07/2018
Change History: Initial version

Long description : This script :
	- Open the first argument file (binary file)
	- Read and check the data in the file
	- Create a list each item being an instruction
	- Loop through the list and, for each instruction, create a text block that look like :

		apply h <instruction adresse> to singleCycCompTop:hostInstrMem_Add
		apply h <instruction> to singleCycCompTop:hostInstrMem_DatIn
		step clk by 1
		delay 100 ms"
	<instruction adresse being the hexadecimal value of a counter that increment by 1 at every loop

	- save the new instructions in a file name after the second argument (binary file)


"""

import sys


header_text = """; viciLab RISCV macro 
; Created by Arthur Beretta, Fearghal Morgan 
; July 2018

; =======================================================================================================
; Supported macro commands: 
;  ";" indicates comment, text in remainder of line is ignored. Line spaces supported. 
;  set/unset "signal name"
;  assert/deassert reset, e.g, assert reset, also supports signal names rst, Reset, Rst
;  start/stop clock (run clock forever until stop), also supports signal names clk, Clock, Clk
;  step clk by "number" (integer), number is no of clk cycles, e.g, step clk by 1. Also supports signal names clock, Clock, Clk
;
;  apply type nb to signal_name (where type = h (hex), b (binary, default if not included), d (decimal).
;  delay time unit (integer), unit is ms (msec) or s (second), default time = 1, default unit is s (sec)
;  delay (or sleep) => delay 1 second. delay 2 => delay 2 seconds
;  Example: delay 1s, delay 1, delay (all represent 1 second delay), also supports Delay, sleep, Sleep, wait, Wait
;
;  loop nb, create a loop for (i=0, i<nb_loop, i++)), nb is decimal
;  end loop (must be called to define the end of the loop). Loop forever is not implemented
; =======================================================================================================

; Include component signal data dictionary here for reference, and type (std_logic_vector (slv) with width, integer etc
; signal data dictionary 
; Inputs
;  clk			    System clock strobe, rising edge active
;  rst			    Synchronous reset signal. Assertion clears all registers, count=00
;  Host instruction interface can upload code to instruction mem
;   hostCtrlInstrMem :           std_logic;    --activate the upload interface
;   hostInstrMem_Load :          std_logic; 
;   hostInstrMem_LoadIndex :     std_logic_vector(1 downto 0);                     
;   hostInstrMem_LoadDat :       std_logic_vector(31 downto 0);
;   hostInstrMem_Add :           std_logic_vector(9 downto 0); 
;   hostInstrMem_DatIn :         std_logic_vector(31 downto 0);
;   hostInstrMem_Wr :            std_logic;                    
; output
;   hostInstrMem_DatOut :        std_logic_vector(31 downto 0);

; ===============================================================
; Assign default input signal values. Include top level component fifo16x8: with each signal assigned
unset singleCycCompTop:hostCtrlInstrMem				; Deassert inputs
unset singleCycCompTop:hostInstrMem_Wr
apply h 0 to singleCycCompTop:hostInstrMem_Add		
apply h 0 to singleCycCompTop:hostInstrMem_DatIn	

unset singleCycCompTop:clrAllBreakpoints                       -- synchronously load breakpoint memory array
unset singleCycCompTop:enableBreakpoints                       -- activate breakpointing function
unset singleCycCompTop:clrBreakEvent                           -- assert on run/debug start or on re-run after a breakpoint detection
apply h 0 to singleCycCompTop:breakAdd                         -- register array address
unset singleCycCompTop:breakWr                                 -- register array wr
apply h 0 to singleCycCompTop:breakDat                         -- register array data in

assert reset						; Toggle reset
delay 100ms
deassert reset
delay 100ms

set singleCycCompTop:hostCtrlInstrMem			
set singleCycCompTop:hostInstrMem_Wr"""

footer_text = """unset singleCycCompTop:hostCtrlInstrMem				; Deassert inputs
unset singleCycCompTop:hostInstrMem_Wr


set singleCycCompTop:runAll
"""

def main(arguments):

    if len(arguments) < 2:
        print("Error : not enough argument\nUsage : " + sys.argv[0] + "<input file> <ouput file>")
        exit(code=1)

    #open and read the code
    with open(arguments[0], mode="rb") as f:
        data = f.read()

    data_lenght = len(data)

    #print(data_lenght)

    #check if code is ok
    if (data_lenght % 4) != 0:
        print("Error : file is corrupted, it should be a multiple of 4 bytes long")
        exit(code=1)


    list_data = [data[i:i+4] for i in range(0, len(data), 4)]
    #print(list_data)
    output = ''
    count = 0
    #invert every bytes in the code
    for word in list_data:
        output = output + "\napply h " + format(count, 'x') + " to singleCycCompTop:hostInstrMem_Add\napply h " + word.hex() + " to singleCycCompTop:hostInstrMem_DatIn\nstep clk by 1\ndelay 100 ms\n"
        count = count + 1


    output = header_text + output + footer_text
    #print(data_to_write)
    with open(arguments[1], mode="w") as f:
        f.write(output)


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
