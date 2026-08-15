module SPI(
    input MOSI,
    input clk,
    input SCK,
    input rst,
    input SS_n,
    input tx_valid, 
    input [7:0] tx_data,
    output reg MISO,
    output reg rx_valid,
    output reg [9:0] rx_data
);

parameter IDLE = 3'b000;
parameter CHK_CMD = 3'b001;
parameter WRITE = 3'b010;
parameter READ_DATA = 3'b011;
parameter READ_ADD = 3'b100;

(* fsm_encoding = "one_hot" *)
reg [2:0] cs, ns;
reg rd_addr_flag; 

always @(posedge clk or negedge rst) begin
    if(~rst) 
        cs <= IDLE;
    else
        cs <= ns;    
end

always @(*) begin
    case(cs)
        IDLE:
            ns = (SS_n) ? IDLE : CHK_CMD;
        CHK_CMD:
            ns = (SS_n) ? IDLE : (~MOSI) ? WRITE : (rd_addr_flag) ? READ_DATA : READ_ADD;
        WRITE:
            ns = (SS_n) ? IDLE : WRITE;
        READ_DATA:
            ns = (SS_n) ? IDLE : READ_DATA;
        READ_ADD:
            ns = (SS_n) ? IDLE : READ_ADD;
        default:    
            ns = IDLE;
    endcase
end

///////////////////////////////////////////////////////////////////////////////////////////
reg [3:0] counter;
reg [9:0] shift_reg;

always @(posedge clk or negedge rst) begin
    if (~rst) begin
        rx_data <= 10'b0;
        rx_valid <= 1'b0;
        MISO <= 1'b0;
        counter <= 4'b0;
        shift_reg <= 10'b0;
        rd_addr_flag <= 1'b0;
    end
    else begin
        case (cs)
            IDLE: begin
                counter <= 4'b0;
                rx_valid <= 1'b0;
                MISO <= 1'b0;
            end

            CHK_CMD: begin
                shift_reg <= {shift_reg[8:0], MOSI};
                counter <= 4'd1; 
                
                if (MOSI == 1'b1 && rd_addr_flag == 1'b1) begin
                    rx_data <= 10'b11_0000_0000;
                    rx_valid <= 1'b1;
                end else begin
                    rx_valid <= 1'b0;
                end
            end

            WRITE: begin
                shift_reg <= {shift_reg[8:0], MOSI}; 
                counter <= counter + 1'b1;
                if (counter == 4'd9) begin 
                    rx_data <= {shift_reg[8:0], MOSI}; 
                    rx_valid <= 1'b1;                  
                    counter <= 4'b0; 
                end 
                else begin
                    rx_valid <= 1'b0; 
                end
            end
            
            READ_ADD: begin
                shift_reg <= {shift_reg[8:0], MOSI}; 
                counter <= counter + 1'b1;
                if (counter == 4'd9) begin 
                    rx_data <= {shift_reg[8:0], MOSI}; 
                    rx_valid <= 1'b1;                  
                    counter <= 4'b0;
                    rd_addr_flag <= 1'b1; 
                end 
                else begin
                    rx_valid <= 1'b0; 
                end
            end

            READ_DATA: begin
                counter <= counter + 1'b1;
                if (counter >= 4'd2 && counter <= 4'd9) begin
                    MISO <= tx_data[4'd9 - counter]; 
                end else begin
                    MISO <= 1'b0;
                end
                rx_valid <= 1'b0; 
                if (counter == 4'd9) begin
                    rd_addr_flag <= 1'b0;
                    counter <= 4'b0;
                end
            end

            default: begin
                rx_valid <= 1'b0;
                counter <= 4'b0;
            end
        endcase
    end
end
endmodule