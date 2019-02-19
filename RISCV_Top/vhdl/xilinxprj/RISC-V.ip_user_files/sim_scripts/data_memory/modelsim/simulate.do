onbreak {quit -f}
onerror {quit -f}

vsim -voptargs="+acc" -t 1ps -L xil_defaultlib -L secureip -lib xil_defaultlib xil_defaultlib.data_memory

do {wave.do}

view wave
view structure
view signals

do {data_memory.udo}

run -all

quit -force
