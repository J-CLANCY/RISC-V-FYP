onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib instruction_memory_opt

do {wave.do}

view wave
view structure
view signals

do {instruction_memory.udo}

run -all

quit -force
