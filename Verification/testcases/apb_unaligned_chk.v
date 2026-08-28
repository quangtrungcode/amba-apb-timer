





task run_test;
    reg [31:0] read_data;
    integer error_count;
    
    
    localparam ADDR_TDR0      = 12'h004;
    localparam ADDR_UNALIGNED = 12'h001; 

    
    localparam DATA_SETUP     = 32'h1234_5678;
    localparam DATA_UNALIGNED = 32'hDEAD_BEEF;
    localparam DATA_ZERO      = 32'h0000_0000;

    begin
        error_count = 0;
        
        $display("\n=======================================================");
        $display("[%0t] [TEST START] PATTERN: apb_unaligned_chk", $time);
        $display("=======================================================");

        wait (sys_rst_n == 1'b1);
        @(posedge sys_clk);

        
        
        
        $display("\n[%0t] [CASE 46] Not aligned access", $time);
        
        
        sys_rst_n = 1'b0; repeat(2) @(posedge sys_clk); sys_rst_n = 1'b1; @(posedge sys_clk);
        
        
        
        
        apb_write(ADDR_TDR0, DATA_SETUP, 4'b1111);
        apb_read(ADDR_TDR0, read_data);
        
        if (read_data !== DATA_SETUP) begin
            $display("[%0t] [FAIL] Step 1: Setup TDR0 failed. Exp %h | Act %h", $time, DATA_SETUP, read_data);
            error_count = error_count + 1;
        end else begin
            $display("[%0t] [PASS] Step 1: Setup TDR0 successful (Data: %h).", $time, read_data);
        end

        
        
        
        $display("[%0t] Step 2: Issuing unaligned write to 0x001...", $time);
        apb_write(ADDR_UNALIGNED, DATA_UNALIGNED, 4'b1111);

        
        
        
        
        apb_read(ADDR_UNALIGNED, read_data);
        
        if (read_data !== DATA_ZERO) begin
            $display("[%0t] [FAIL] Step 3: Unaligned read failed. Exp %h | Act %h", $time, DATA_ZERO, read_data);
            error_count = error_count + 1;
        end else begin
            $display("[%0t] [PASS] Step 3: Unaligned read securely returned %h.", $time, read_data);
        end

        
        
        
        
        apb_read(ADDR_TDR0, read_data);
        
        if (read_data !== DATA_SETUP) begin
            $display("[%0t] [FAIL] Step 4: TDR0 was corrupted! Exp %h | Act %h", $time, DATA_SETUP, read_data);
            error_count = error_count + 1;
        end else begin
            $display("[%0t] [PASS] Step 4: TDR0 successfully retained original data (%h).", $time, read_data);
        end


        
        
        
        $display("\n=======================================================");
        if (error_count == 0) begin
            $display("[%0t] [TEST SUMMARY] PATTERN: apb_unaligned_chk ---> PASSED", $time);
        end else begin
            $display("[%0t] [TEST SUMMARY] PATTERN: apb_unaligned_chk ---> FAILED (Total errors: %0d)", $time, error_count);
        end
        $display("=======================================================\n");
    end
endtask
