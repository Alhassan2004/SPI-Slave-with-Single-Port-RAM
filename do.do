vlib work
vlog RAM.v tb.v SPI.v Wrapper.v
vsim -voptargs=+acc work.tb

# 4. Add formatted waves (To match the exact look of your image)
add wave -noupdate -color White -label clk /tb/clk
add wave -noupdate -color White -label rst_n /tb/rst_n
add wave -noupdate -color White -label MOSI /tb/MOSI
add wave -noupdate -color White -label SS_n /tb/SS_n
add wave -noupdate -color White -label MISO /tb/MISO

add wave -noupdate -radix hexadecimal -color Cyan -label tx_data /tb/dut/tx_data_wire
add wave -noupdate -radix hexadecimal -color Cyan -label rx_data /tb/dut/rx_data_wire
add wave -noupdate -color Cyan -label rx_valid /tb/dut/rx_valid_wire
add wave -noupdate -color Cyan -label tx_valid /tb/dut/tx_valid_wire

run -all
wave zoom full

