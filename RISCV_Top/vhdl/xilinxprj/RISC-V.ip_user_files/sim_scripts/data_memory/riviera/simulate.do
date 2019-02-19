onbreak {quit -force}
onerror {quit -force}

asim -t 1ps +access +r +m+data_memory -L xil_defaultlib -L secureip -O5 xil_defaultlib.data_memory

do {wave.do}

view wave
view structure

do {data_memory.udo}

run -all

endsim

quit -force