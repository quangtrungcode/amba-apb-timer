





task run_test;
    reg [31:0] read_data0;
    reg [31:0] read_data1;
    integer error_count;
    
    
    localparam ADDR_TCR  = 12'h000;
    localparam ADDR_TDR0 = 12'h004;
    localparam ADDR_TDR1 = 12'h008; 

    
    localparam DATA_A = 32'hDEAD_BEEF;
    localparam DATA_B = 32'hCAFE_BABE;
    localparam DATA_C = 32'h1234_5678;
    localparam DATA_D = 32'h8765_4321;

    begin
        error_count = 0;
        
        $display("\n=======================================================");
        $display("[%0t] [TEST START] PATTERN: apb_multiple_access", $time);
        $display("=======================================================");

        wait (sys_rst_n == 1'b1);
        @(posedge sys_clk);

        
        
        
        $display("\n[%0t] [CASE 44] Multiple access: WW-RR", $time);
        
        
        sys_rst_n = 1'b0; repeat(2) @(posedge sys_clk); sys_rst_n = 1'b1; @(posedge sys_clk);
        
        
        apb_write(ADDR_TDR0, DATA_A, 4'b1111);
        apb_write(ADDR_TDR1, DATA_B, 4'b1111);
        
        
        apb_read(ADDR_TDR0, read_data0);
        apb_read(ADDR_TDR1, read_data1);
        
        
        if (read_data0 !== DATA_A) begin
            $display("[%0t] [FAIL] ID 44 (TDR0): Exp %h | Act %h", $time, DATA_A, read_data0);
            error_count = error_count + 1;
        end else begin
            $display("[%0t] [PASS] ID 44 (TDR0): WW-RR data matches perfectly.", $time);
        end
        
        if (read_data1 !== DATA_B) begin
            $display("[%0t] [FAIL] ID 44 (TDR1): Exp %h | Act %h", $time, DATA_B, read_data1);
            error_count = error_count + 1;
        end else begin
            $display("[%0t] [PASS] ID 44 (TDR1): WW-RR data matches perfectly.", $time);
        end


        
        
        
        $display("\n[%0t] [CASE 45] Multiple access: WRWR", $time);
        
        
        sys_rst_n = 1'b0; repeat(2) @(posedge sys_clk); sys_rst_n = 1'b1; @(posedge sys_clk);
        
        
        apb_write(ADDR_TDR0, DATA_C, 4'b1111);
        apb_read(ADDR_TDR0, read_data0);
        
        
        apb_write(ADDR_TDR1, DATA_D, 4'b1111);
        apb_read(ADDR_TDR1, read_data1);
        
        
        if (read_data0 !== DATA_C) begin
            $display("[%0t] [FAIL] ID 45 (TDR0): Exp %h | Act %h", $time, DATA_C, read_data0);
            error_count = error_count + 1;
        end else begin
            $display("[%0t] [PASS] ID 45 (TDR0): WRWR data matches perfectly.", $time);
        end
        
        if (read_data1 !== DATA_D) begin
            $display("[%0t] [FAIL] ID 45 (TDR1): Exp %h | Act %h", $time, DATA_D, read_data1);
            error_count = error_count + 1;
        end else begin
            $display("[%0t] [PASS] ID 45 (TDR1): WRWR data matches perfectly.", $time);
        end


        
        
        
        $display("\n=======================================================");
        if (error_count == 0) begin
            $display("[%0t] [TEST SUMMARY] PATTERN: apb_multiple_access ---> PASSED", $time);
        end else begin
            $display("[%0t] [TEST SUMMARY] PATTERN: apb_multiple_access ---> FAILED (Total errors: %0d)", $time, error_count);
        end
        $display("=======================================================\n");
    end
endtask
