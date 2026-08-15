module Wrapper(
    input MOSI,
    input SS_n,
    input clk,
    input rst_n,
    output MISO
);

wire [9:0] rx_data_wire;
wire rx_valid_wire;
wire [7:0] tx_data_wire;
wire tx_valid_wire;

SPI spi(MOSI, clk, clk, rst_n, SS_n, tx_valid_wire, tx_data_wire ,MISO, rx_valid_wire, rx_data_wire);
RAM ram(rx_data_wire, clk, rst_n, rx_valid_wire, tx_data_wire, tx_valid_wire);
endmodule





