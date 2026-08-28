





task run_test;
    
    reg [31:0] val_cnt1, val_cnt2;
    reg [31:0] val_thcsr;
    integer error_count;
    integer diff;
    
    
    
    integer WAIT_CYCLES;
    integer EXPECTED_DIFF; 

    begin
        error_count = 0;
        WAIT_CYCLES = 10;
        EXPECTED_DIFF = 14; 
        
        $display("\n==============================================");
        $display("[%0t] [TEST START] PATTERN: halt_mode_chk", $time);
        $display("==============================================");

        $display("[%0t] [INFO] Waiting for system reset to be released", $time);
        wait (sys_rst_n == 1'b1);
        @(posedge sys_clk);
        $display("[%0t] [INFO] System reset released", $time);
        $display("==============================================");

/*        
        
        
        $display("\n[%0t] [CASE 1] dbg_mode = 0, halt_req = 0", $time);
        
       
        
        
        dbg_mode = 0;
        apb_write(12'h01C, 32'h0000_0000, 4'b1111); 
        apb_write(12'h000, 32'h0000_0001, 4'b1111); 
        
        
        repeat(WAIT_CYCLES) @(posedge sys_clk);
        apb_read(12'h01C, val_thcsr);
        apb_read(12'h004, val_cnt1);
        
        
        repeat(WAIT_CYCLES) @(posedge sys_clk);
        apb_read(12'h004, val_cnt2);
        
        
        diff = val_cnt2 - val_cnt1;
        if (val_thcsr[1] !== 1'b0) begin
            $display("[%0t] [FAIL] Case 1: Expected halt_ack = 0, Actual = %b", $time, val_thcsr[1]); error_count = error_count + 1;
        end
        if (diff !== EXPECTED_DIFF) begin
            $display("[%0t] [FAIL] Case 1: Expected diff = %0d, Actual = %0d", $time, EXPECTED_DIFF, diff); error_count = error_count + 1;
        end else $display("[%0t] [PASS] Case 1 successful (halt_ack=0, diff=%0d)", $time, diff);

        
        
        
        $display("\n[%0t] [CASE 2] dbg_mode = 0, halt_req = 1", $time);
       
        
        
        dbg_mode = 0;
        apb_write(12'h01C, 32'h0000_0001, 4'b1111); 
        apb_write(12'h000, 32'h0000_0001, 4'b1111); 
        
        
        repeat(WAIT_CYCLES) @(posedge sys_clk);
        apb_read(12'h01C, val_thcsr);
        apb_read(12'h004, val_cnt1);
        repeat(WAIT_CYCLES) @(posedge sys_clk);
        apb_read(12'h004, val_cnt2);
        
        diff = val_cnt2 - val_cnt1;
        if (val_thcsr[1] !== 1'b0) begin
            $display("[%0t] [FAIL] Case 2: Expected halt_ack = 0, Actual = %b", $time, val_thcsr[1]); error_count = error_count + 1;
        end
        if (diff !== EXPECTED_DIFF) begin
            $display("[%0t] [FAIL] Case 2: Expected diff = %0d, Actual = %0d", $time, EXPECTED_DIFF, diff); error_count = error_count + 1;
        end else $display("[%0t] [PASS] Case 2 successful (halt_ack=0, diff=%0d)", $time, diff);
*/
        
        
        
        $display("\n[%0t] [CASE 3] dbg_mode = 1, halt_req = 0", $time);
       
        
        
        dbg_mode = 1;
        apb_write(12'h01C, 32'h0000_0000, 4'b1111); 
        apb_write(12'h000, 32'h0000_0001, 4'b1111); 
        
        
        repeat(WAIT_CYCLES) @(posedge sys_clk);
        apb_read(12'h01C, val_thcsr);
        apb_read(12'h004, val_cnt1);
        repeat(WAIT_CYCLES) @(posedge sys_clk);
        apb_read(12'h004, val_cnt2);
        
        diff = val_cnt2 - val_cnt1;
        if (val_thcsr[1] !== 1'b0) begin
            $display("[%0t] [FAIL] Case 3: Expected halt_ack = 0, Actual = %b", $time, val_thcsr[1]); error_count = error_count + 1;
        end
        if (diff !== EXPECTED_DIFF) begin
            $display("[%0t] [FAIL] Case 3: Expected diff = %0d, Actual = %0d", $time, EXPECTED_DIFF, diff); error_count = error_count + 1;
        end else $display("[%0t] [PASS] Case 3 successful (halt_ack=0, diff=%0d)", $time, diff);

        
        
        
        $display("\n[%0t] [CASE 4] dbg_mode = 1, halt_req = 1", $time);
       
        
        
        dbg_mode = 1;
        apb_write(12'h01C, 32'h0000_0001, 4'b1111); 
        apb_write(12'h000, 32'h0000_0001, 4'b1111); 
        
        
        repeat(WAIT_CYCLES) @(posedge sys_clk);
        apb_read(12'h01C, val_thcsr);
        apb_read(12'h004, val_cnt1);
        repeat(WAIT_CYCLES) @(posedge sys_clk);
        apb_read(12'h004, val_cnt2);
        
        diff = val_cnt2 - val_cnt1;
        if (val_thcsr[1] !== 1'b1) begin
            $display("[%0t] [FAIL] Case 4: Expected halt_ack = 1, Actual = %b", $time, val_thcsr[1]); error_count = error_count + 1;
        end
        if (diff !== 0) begin  
            $display("[%0t] [FAIL] Case 4: Expected diff = 0, Actual = %0d", $time, diff); error_count = error_count + 1;
        end else $display("[%0t] [PASS] Case 4 successful (halt_ack=1, diff=0 - Timer is halted)", $time);

        
        
        
        $display("\n[%0t] [CASE 5] Normal -> Halt -> Normal", $time);
     
        
        
        dbg_mode = 1;
        apb_write(12'h01C, 32'h0000_0000, 4'b1111);
        apb_write(12'h000, 32'h0000_0001, 4'b1111);
        
        repeat(WAIT_CYCLES) @(posedge sys_clk);
        apb_read(12'h01C, val_thcsr);
        if (val_thcsr[1] !== 1'b0) begin $display("[%0t] [FAIL] Case 5 (Bước 2): halt_ack != 0", $time); error_count = error_count + 1; end
        apb_read(12'h004, val_cnt1);
        
        repeat(WAIT_CYCLES) @(posedge sys_clk);
        apb_read(12'h004, val_cnt2);
        diff = val_cnt2 - val_cnt1;
        if (diff !== EXPECTED_DIFF) begin $display("[%0t] [FAIL] Case 5 (Bước 3): diff != %0d", $time, EXPECTED_DIFF); error_count = error_count + 1; end
        else $display("[%0t] [PASS] Case 5 (Normal 1) successful", $time);
        
        
        repeat(WAIT_CYCLES) @(posedge sys_clk);
        dbg_mode = 1;
        apb_write(12'h01C, 32'h0000_0001, 4'b1111); 
        
        repeat(WAIT_CYCLES) @(posedge sys_clk);
        apb_read(12'h01C, val_thcsr);
        if (val_thcsr[1] !== 1'b1) begin $display("[%0t] [FAIL] Case 5 (Bước 5): halt_ack != 1", $time); error_count = error_count + 1; end
        apb_read(12'h004, val_cnt1);
        
        repeat(WAIT_CYCLES) @(posedge sys_clk);
        apb_read(12'h004, val_cnt2);
        diff = val_cnt2 - val_cnt1;
        if (diff !== 0) begin $display("[%0t] [FAIL] Case 5 (Bước 6): diff != 0", $time); error_count = error_count + 1; end
        else $display("[%0t] [PASS] Case 5 (Halt) successful", $time);
        
        
        repeat(WAIT_CYCLES) @(posedge sys_clk);
        dbg_mode = 1;
        apb_write(12'h01C, 32'h0000_0000, 4'b1111); 
        
        repeat(WAIT_CYCLES) @(posedge sys_clk);
        apb_read(12'h01C, val_thcsr);
        if (val_thcsr[1] !== 1'b0) begin $display("[%0t] [FAIL] Case 5 (Bước 8): halt_ack != 0", $time); error_count = error_count + 1; end
        apb_read(12'h004, val_cnt1);
        
        repeat(WAIT_CYCLES) @(posedge sys_clk);
        apb_read(12'h004, val_cnt2);
        diff = val_cnt2 - val_cnt1;
        if (diff !== EXPECTED_DIFF) begin $display("[%0t] [FAIL] Case 5 (Bước 9): diff != %0d", $time, EXPECTED_DIFF); error_count = error_count + 1; end
        else $display("[%0t] [PASS] Case 5 (Normal 2) successful", $time);

        
        
        
        $display("\n==============================================");
        if (error_count == 0) begin
            $display("[%0t] [TEST SUMMARY] PATTERN: halt_mode_chk ---> PASSED", $time);
        end else begin
            $display("[%0t] [TEST SUMMARY] PATTERN: halt_mode_chk ---> FAILED (Total errors: %0d)", $time, error_count);
        end
        $display("==============================================\n");
    end
endtask
