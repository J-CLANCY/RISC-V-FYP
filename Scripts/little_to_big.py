#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Description : This script transform little endian code to big endian
Usage : ./little_to_big.py input_file output_file
Author : Arthur Beretta
Date : 05/07/2018
Change History: Initial version

Long description : This script :
	- Open the first argument file (binary file)
	- Read and check the data in the file
	- Create a list each item being an instruction
	- Loop through the list and, for each instruction, tranform the little endian to big endian
	- save the new instructions in a file name after the second argument (binary file)

"""

import os
import sys

def main(arguments):

    if len(arguments) < 2:
        print("Error : not enough argument\nUsage : " + sys.argv[0] + "<input file> <output file>")
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

    #invert every bytes in the code
    for index, word in enumerate(list_data):
        list_data[index] = word[::-1]
        #print(list_data[index])

    #print(data)

    data_to_write = b''

    for item in list_data:
        data_to_write += item


    #print(data_to_write)
    with open(arguments[1], mode="wb") as f:
        f.write(data_to_write)


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
