





task run_test;
    reg [31:0] read_data;
    integer error_count;
    
    
    localparam ADDR_TCR  = 12'h000;
    localparam ADDR_TDR0 = 12'h004;
    localparam ADDR_CMP0 = 12'h00C; 
    localparam ADDR_CMP1 = 12'h010; 
    localparam ADDR_TIER = 12'h014; 
    localparam ADDR_TISR = 12'h018; 

    begin
        error_count = 0;
        
        $display("\n=======================================================");
        $display("[%0t] [TEST START] PATTERN: interrupt_chk", $time);
        $display("=======================================================");

        wait (sys_rst_n == 1'b1);
        @(posedge sys_clk);

        
        
        
        $display("\n[%0t] [CASE 49] interrupt pending: Set condition", $time);
        sys_rst_n = 1'b0; repeat(2) @(posedge sys_clk); sys_rst_n = 1'b1; @(posedge sys_clk);
        apb_write(ADDR_CMP1, 32'h0000_0000, 4'b1111);
        apb_write(ADDR_CMP0, 32'h0000_00FF, 4'b1111); 
        apb_write(ADDR_TCR,  32'h0000_0001, 4'b1111); 
        
        repeat(256) @(posedge sys_clk); 
        
        apb_read(ADDR_TISR, read_data);
        if (read_data[0] !== 1'b1 || tim_int !== 1'b0) begin
            $display("[%0t] [FAIL] ID 49: Exp TISR=1, tim_int=0 | Act TISR=%b, tim_int=%b", $time, read_data[0], tim_int);
            error_count = error_count + 1;
        end else $display("[%0t] [PASS] ID 49: Pending set correctly, output not asserted.", $time);


        
        
        
        $display("\n[%0t] [CASE 50] interrupt pending: Clear condition", $time);
        sys_rst_n = 1'b0; repeat(2) @(posedge sys_clk); sys_rst_n = 1'b1; @(posedge sys_clk);
        apb_write(ADDR_CMP1, 32'h0000_0000, 4'b1111);
        apb_write(ADDR_CMP0, 32'h0000_00FF, 4'b1111);
        apb_write(ADDR_TCR,  32'h0000_0001, 4'b1111);
        repeat(256) @(posedge sys_clk); 
        
        
        apb_write(ADDR_TISR, 32'h0000_0000, 4'b1111); 
        apb_read(ADDR_TISR, read_data);
        if (read_data[0] !== 1'b1) begin
            $display("[%0t] [FAIL] ID 50.1: Write 0 to TISR altered the state!", $time); error_count = error_count + 1;
        end else $display("[%0t] [PASS] ID 50.1: Write 0 ignored.", $time);
        
        
        apb_write(ADDR_TISR, 32'h0000_0001, 4'b1111); 
        apb_read(ADDR_TISR, read_data);
        if (read_data[0] !== 1'b0) begin
            $display("[%0t] [FAIL] ID 50.2: Write 1 to TISR failed to clear!", $time); error_count = error_count + 1;
        end else $display("[%0t] [PASS] ID 50.2: Write 1 cleared TISR successfully.", $time);


        
        
        
        $display("\n[%0t] [CASE 51] interrupt pending: Manual condition", $time);
        sys_rst_n = 1'b0; repeat(2) @(posedge sys_clk); sys_rst_n = 1'b1; @(posedge sys_clk);
        apb_write(ADDR_CMP1, 32'h0000_0000, 4'b1111);

        apb_write(ADDR_CMP0, 32'hA55A_0403, 4'b1111); 
        apb_write(ADDR_TDR0, 32'hA55A_0403, 4'b1111); 
        
        
     
        
        apb_read(ADDR_TISR, read_data);
        if (read_data[0] !== 1'b1 || tim_int !== 1'b0) begin
            $display("[%0t] [FAIL] ID 51: Exp TISR=1, tim_int=0 | Act TISR=%b, tim_int=%b", $time, read_data[0], tim_int);
            error_count = error_count + 1;
        end else $display("[%0t] [PASS] ID 51: Manual trigger works.", $time);


        
        
        
        $display("\n[%0t] [CASE 52] interrupt enable: Set condition", $time);
        sys_rst_n = 1'b0; repeat(2) @(posedge sys_clk); sys_rst_n = 1'b1; @(posedge sys_clk);
        apb_write(ADDR_CMP1, 32'h0000_0000, 4'b1111);

        apb_write(ADDR_CMP0, 32'h0000_00FF, 4'b1111);
        apb_write(ADDR_TIER, 32'h0000_0001, 4'b1111); 
        apb_write(ADDR_TCR,  32'h0000_0001, 4'b1111);
        
        repeat(256) @(posedge sys_clk); 
        
        apb_read(ADDR_TISR, read_data);
        if (read_data[0] !== 1'b1 || tim_int !== 1'b1) begin
            $display("[%0t] [FAIL] ID 52: Exp TISR=1, tim_int=1 | Act TISR=%b, tim_int=%b", $time, read_data[0], tim_int);
            error_count = error_count + 1;
        end else $display("[%0t] [PASS] ID 52: Interrupt asserted to output port.", $time);


        
        
        
        $display("\n[%0t] [CASE 53] interrupt enable: Clear condition", $time);
        sys_rst_n = 1'b0; repeat(2) @(posedge sys_clk); sys_rst_n = 1'b1; @(posedge sys_clk);
        apb_write(ADDR_CMP1, 32'h0000_0000, 4'b1111);

        apb_write(ADDR_CMP0, 32'h0000_00FF, 4'b1111);
        apb_write(ADDR_TIER, 32'h0000_0001, 4'b1111);
        apb_write(ADDR_TCR,  32'h0000_0001, 4'b1111);
        repeat(256) @(posedge sys_clk); 
        
        
        apb_write(ADDR_TISR, 32'h0000_0000, 4'b1111);
        apb_read(ADDR_TISR, read_data);
        if (read_data[0] !== 1'b1 || tim_int !== 1'b1) begin
            $display("[%0t] [FAIL] ID 53.1: Write 0 affected enabled interrupt!", $time); error_count = error_count + 1;
        end else $display("[%0t] [PASS] ID 53.1: Write 0 ignored, output remains asserted.", $time);
        
        
        apb_write(ADDR_TISR, 32'h0000_0001, 4'b1111);
        apb_read(ADDR_TISR, read_data);
        if (read_data[0] !== 1'b0 || tim_int !== 1'b0) begin
            $display("[%0t] [FAIL] ID 53.2: Write 1 failed to deassert output!", $time); error_count = error_count + 1;
        end else $display("[%0t] [PASS] ID 53.2: Output deasserted successfully.", $time);


        
        
        
        $display("\n[%0t] [CASE 54] interrupt enable: Manual condition", $time);
        sys_rst_n = 1'b0; repeat(2) @(posedge sys_clk); sys_rst_n = 1'b1; @(posedge sys_clk);
        apb_write(ADDR_CMP1, 32'h0000_0000, 4'b1111);

        apb_write(ADDR_CMP0, 32'hA55A_0403, 4'b1111);
        apb_write(ADDR_TIER, 32'h0000_0001, 4'b1111); 
        apb_write(ADDR_TDR0, 32'hA55A_0403, 4'b1111); 
        
      
        
        apb_read(ADDR_TISR, read_data);
        if (read_data[0] !== 1'b1 || tim_int !== 1'b1) begin
            $display("[%0t] [FAIL] ID 54: Exp TISR=1, tim_int=1 | Act TISR=%b, tim_int=%b", $time, read_data[0], tim_int);
            error_count = error_count + 1;
        end else $display("[%0t] [PASS] ID 54: Manual trigger + Enable works.", $time);


        
        
        
        $display("\n[%0t] [CASE 55] Mask condition", $time);
        sys_rst_n = 1'b0; repeat(2) @(posedge sys_clk); sys_rst_n = 1'b1; @(posedge sys_clk);
        apb_write(ADDR_CMP1, 32'h0000_0000, 4'b1111);

        apb_write(ADDR_CMP0, 32'h0000_00FF, 4'b1111);
        apb_write(ADDR_TIER, 32'h0000_0001, 4'b1111); 
        apb_write(ADDR_TCR,  32'h0000_0001, 4'b1111);
        repeat(256) @(posedge sys_clk); 
        
        
        apb_write(ADDR_TIER, 32'h0000_0000, 4'b1111); 
        
        apb_read(ADDR_TISR, read_data);
        if (read_data[0] !== 1'b1 || tim_int !== 1'b0) begin
            $display("[%0t] [FAIL] ID 55: Mask failed. Act TISR=%b, tim_int=%b", $time, read_data[0], tim_int);
            error_count = error_count + 1;
        end else $display("[%0t] [PASS] ID 55: Interrupt properly masked (tim_int=0, TISR=1).", $time);


        
        
        
        $display("\n[%0t] [CASE 56] Once asserted, interrupt must be kept", $time);
        sys_rst_n = 1'b0; repeat(2) @(posedge sys_clk); sys_rst_n = 1'b1; @(posedge sys_clk);
        
        
        apb_write(ADDR_CMP1, 32'h0000_0000, 4'b1111);

        apb_write(ADDR_CMP0, 32'h0000_00FF, 4'b1111);
        apb_write(ADDR_TIER, 32'h0000_0001, 4'b1111); 
        apb_write(ADDR_TCR,  32'h0000_0001, 4'b1111);
        repeat(256) @(posedge sys_clk); 
        
        
        apb_write(ADDR_TCR, 32'h0000_0000, 4'b1111);
        
        
        apb_read(ADDR_TISR, read_data);
        if (read_data[0] !== 1'b1 || tim_int !== 1'b1) begin
            $display("[%0t] [FAIL] ID 56: Interrupt lost after timer disabled!", $time);
            error_count = error_count + 1;
        end else $display("[%0t] [PASS] ID 56: Interrupt state retained correctly.", $time);


        
        
        
        $display("\n=======================================================");
        if (error_count == 0) begin
            $display("[%0t] [TEST SUMMARY] PATTERN: interrupt_chk ---> PASSED", $time);
        end else begin
            $display("[%0t] [TEST SUMMARY] PATTERN: interrupt_chk ---> FAILED (Total errors: %0d)", $time, error_count);
        end
        $display("=======================================================\n");
    end
endtask
