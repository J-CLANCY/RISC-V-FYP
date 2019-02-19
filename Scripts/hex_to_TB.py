#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Description : This script generate codes lines that can be inserted into vivado test bench
Author : Arthur Beretta
Date : 05/07/2018
Change History: Initial version

Long description : This script :
	- Open the first argument file
	- Read and check the data in the file
	- Create a list each item being an instruction
	- Loop through the list and create a string like that :
		- "XXXXXXXX", "XXXXXXXX", "XXXXXXXX", ...	the XXXXXXXX being each instruction
	- save the string in a file name after the second argument

"""

import os
import sys

def main(arguments):

    if len(arguments) < 2:
        print("Error : not enough argument\nUsage : " + sys.argv[0] + "<input file> <output_file>")
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
        if (count % 8) == 0:
            output = output + '\nX"' + word.hex() + '", '
        else:
            output = output + 'X"' + word.hex() + '", '

        count = count + 1
            #print(list_data[index])

    #print(data)

    #print(output)
    #print(data_to_write)
    with open(arguments[1], mode="w") as f:
        f.write(output)


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
