module tb();
    reg MOSI;
    reg SS_n;
    reg clk;
    reg rst_n;
    wire MISO;

    integer i;
    integer errors;
    reg [7:0] received_data;
    reg [10:0] temp_data; 

    Wrapper dut (
        .MOSI(MOSI),
        .SS_n(SS_n),
        .clk(clk),
        .rst_n(rst_n),
        .MISO(MISO)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        errors = 0;
        MOSI = 0;
        SS_n = 1;
        rst_n = 0;

        #15;
        rst_n = 1;
        #20;

        $display("\nTEST 1: WRITE ADDRESS FF");
        temp_data = 11'b0_00_11111111;
        
        @(negedge clk);
        SS_n = 0;
        
        for (i = 10; i >= 0; i = i - 1) begin
            MOSI = temp_data[i];
            @(negedge clk);
        end
        
        SS_n = 1;
        MOSI = 0;
        #20;

        if (dut.spi.rx_data !== 10'h0FF) begin
            $display("ERROR: WRITE ADDRESS | Expected: 0FF, Got: %0h", dut.spi.rx_data);
            errors = errors + 1;
        end else begin 
            $display("PASS: WRITE ADDRESS (rx_data = %0h)", dut.spi.rx_data);
        end

        $display("\nTEST 2: WRITE DATA 7D");
        temp_data = 11'b0_01_01111101;
        
        @(negedge clk);
        SS_n = 0;
        
        for (i = 10; i >= 0; i = i - 1) begin
            MOSI = temp_data[i];
            @(negedge clk);
        end
        
        SS_n = 1;
        MOSI = 0;
        #20;
        
        if (dut.spi.rx_data !== 10'h17D) begin
            $display("ERROR: WRITE DATA | Expected: 17D, Got: %0h", dut.spi.rx_data);
            errors = errors + 1;
        end else begin 
            $display("PASS: WRITE DATA (rx_data = %0h)", dut.spi.rx_data);
        end
        
        if (dut.ram.mem[8'hFF] !== 8'h7D) begin
            $display("ERROR: RAM WRITE | Expected: 7D, Got: %0h", dut.ram.mem[8'hFF]);
            errors = errors + 1;
        end else begin 
            $display("PASS: RAM WRITE (RAM[FF] = %0h)", dut.ram.mem[8'hFF]);
        end

        $display("\nTEST 3: READ ADDRESS FF");
        temp_data = 11'b1_10_11111111;
        
        @(negedge clk);
        SS_n = 0;
        
        for (i = 10; i >= 0; i = i - 1) begin
            MOSI = temp_data[i];
            @(negedge clk);
        end
        
        SS_n = 1;
        MOSI = 0;
        #20;
        
        if (dut.spi.rx_data !== 10'h2FF) begin
            $display("ERROR: READ ADDRESS | Expected: 2FF, Got: %0h", dut.spi.rx_data);
            errors = errors + 1;
        end else begin 
            $display("PASS: READ ADDRESS (rx_data = %0h)", dut.spi.rx_data);
        end

        $display("\nTEST 4: READ DATA");
        temp_data = 11'b1_11_00000000;
        received_data = 8'b0;
        
        @(negedge clk);
        SS_n = 0;
        
        for (i = 10; i >= 0; i = i - 1) begin
            MOSI = temp_data[i]; 
            
            @(negedge clk); 
            if (i <= 7) begin
                received_data[i] = MISO; 
            end
        end
        
        SS_n = 1;
        MOSI = 0;
        #20;
        
        if (received_data !== 8'h7D) begin
            $display("ERROR: MISO DATA | Expected: 7D, Got: %0h", received_data);
            errors = errors + 1;
        end else begin 
            $display("PASS: MISO DATA = %0h", received_data);
        end

        if (errors == 0)
            $display("            ALL TESTS PASSED SUCCESSFULLY!    ");
        else
            $display("            TEST FAILED WITH %0d ERRORS", errors);
       
        
        $stop;
    end
endmodule