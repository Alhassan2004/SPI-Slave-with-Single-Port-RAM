module RAM(
    input [9:0] din,
    input clk,
    input rst,
    input rx_valid,
    output reg [7:0] dout,
    output reg tx_valid
);

parameter MEM_DEPTH = 256;
parameter ADDR_SIZE = 8;

reg [ADDR_SIZE-1:0] write_addr;
reg [ADDR_SIZE-1:0] read_addr;
reg [7:0] mem [MEM_DEPTH-1:0];

always @(posedge clk or negedge rst) begin
    if(~rst) begin
        dout <= 8'b0;
        tx_valid <= 1'b0;
        write_addr <= 8'b0;
        read_addr <= 8'b0;
    end
    else if(rx_valid) begin 
        tx_valid <= 1'b0; 
        case(din[9:8])
            2'b00:
                write_addr <= din[7:0];
            2'b01:
                mem[write_addr] <= din[7:0];
            2'b10:
                read_addr <= din[7:0];
            2'b11: begin
                dout <= mem[read_addr];
                tx_valid <= 1'b1;
            end
        endcase
    end
    else begin

        tx_valid <= 1'b0; 
    end
end
endmodule

