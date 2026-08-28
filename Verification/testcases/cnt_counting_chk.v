





task run_test;
    reg [31:0] read_tdr0, read_tdr1;
    reg [31:0] temp_tdr0, temp_tdr1;
    integer error_count;
    
    begin
        error_count = 0;
        
        $display("\n==============================================");
        $display("[%0t] [TEST START] PATTERN: cnt_counting_chk", $time);
        $display("==============================================");
        $display("[%0t] [INFO] Waiting for system reset to be released", $time);
        wait (sys_rst_n == 1'b1);
        @(posedge sys_clk);
        $display("[%0t] [INFO] System reset released", $time);
        $display("==============================================");

     
        
        
        
        $display("\n[%0t] [CASE 1] Boundary of TDR0 (32-bit Overflow)", $time);
        sys_rst_n = 0; repeat(3) @(posedge sys_clk); sys_rst_n = 1; @(posedge sys_clk);
        
        apb_write(12'h004, 32'hFFFF_FF00, 4'b1111); 
        apb_write(12'h008, 32'h0000_0000, 4'b1111); 
        apb_write(12'h000, 32'h0000_0001, 4'b1111); 
        
        repeat(253) @(posedge sys_clk); 
        
        apb_read(12'h008, read_tdr1); 
        apb_read(12'h004, read_tdr0); 
        
        if (read_tdr1 !== 32'h0000_0001) begin
            $display("[%0t] [FAIL] Case 1: Expected TDR1 = 1, Actual = %h", $time, read_tdr1); error_count = error_count + 1;
        end else $display("[%0t] [PASS] Case 1 successful. TDR1 = 1, TDR0 counts from beginning", $time);

        
        
        
        $display("\n[%0t] [CASE 2] Boundary of TDR0/TDR1 (64-bit Overflow)", $time);
        sys_rst_n = 0; repeat(3) @(posedge sys_clk); sys_rst_n = 1; @(posedge sys_clk);
        
        apb_write(12'h004, 32'hFFFF_FF00, 4'b1111); 
        apb_write(12'h008, 32'hFFFF_FFFF, 4'b1111); 
        apb_write(12'h000, 32'h0000_0001, 4'b1111); 
        
        repeat(253) @(posedge sys_clk);
        
        apb_read(12'h008, read_tdr1);
        if (read_tdr1 !== 32'h0000_0000) begin 
            $display("[%0t] [FAIL] Case 2: Expected TDR1 to wrap to 0, Actual = %h", $time, read_tdr1); error_count = error_count + 1;
        end else $display("[%0t] [PASS] Case 2 successful. TDR1 wrapped to 0, TDR0 counts from beginning", $time);

        
        
        
        $display("\n[%0t] [CASE 3] Update TDR0/TDR1 on the fly", $time);
        sys_rst_n = 0; repeat(3) @(posedge sys_clk); sys_rst_n = 1; @(posedge sys_clk);
        
        apb_write(12'h000, 32'h0000_0001, 4'b1111); 
        repeat(10) @(posedge sys_clk); 
        
        apb_write(12'h008, 32'hA5A5_A5A5, 4'b1111); 
        apb_write(12'h004, 32'h5555_5555, 4'b1111); 
        
        repeat(10) @(posedge sys_clk); 
        apb_read(12'h008, read_tdr1);
        apb_read(12'h004, read_tdr0);

        if (read_tdr1 !== 32'hA5A5_A5A5 && read_tdr0 !== 32'h5555_556C) begin
            $display("[%0t] [FAIL] Case 3: Update failed. Expected TDR1 = 1, Actual = %h", $time, read_tdr1); error_count = error_count + 1;
        end else $display("[%0t] [PASS] Case 3 successful. Dynamic Update works seamlessly.", $time);

        
        
        
        $display("\n[%0t] [CASE 4] Timer disabled and auto-cleared", $time);
        sys_rst_n = 0; repeat(3) @(posedge sys_clk); sys_rst_n = 1; @(posedge sys_clk);
        
        apb_write(12'h000, 32'h0000_0001, 4'b1111); 
        repeat(50) @(posedge sys_clk); 
        
        apb_write(12'h000, 32'h0000_0000, 4'b1111); 
        apb_read(12'h004, read_tdr0);
        
        if (read_tdr0 !== 32'h0000_0000) begin
            $display("[%0t] [FAIL] Case 4: Counter NOT cleared! Actual TDR0=%h", $time, read_tdr0); error_count = error_count + 1;
        end else $display("[%0t] [PASS] Case 4 successful. Counter strictly cleared to 0.", $time);

        
        
        
        $display("\n[%0t] [CASE 5] Resume counting with new div mode", $time);
        sys_rst_n = 0; repeat(3) @(posedge sys_clk); sys_rst_n = 1; @(posedge sys_clk);
        
        apb_write(12'h000, 32'h0000_0001, 4'b1111); 
        repeat(50) @(posedge sys_clk);


        apb_write(12'h000, 32'h0000_0000, 4'b1111); 
        
        apb_write(12'h004, 32'h0000_0000, 4'b1111); 
        apb_write(12'h008, 32'h0000_0000, 4'b1111); 
        
        
        
        apb_write(12'h000, 32'h0000_0203, 4'b1111); 
        
        apb_read(12'h004, temp_tdr0);
        repeat(9) @(posedge sys_clk);
        apb_read(12'h004, read_tdr0);
        
        if( (read_tdr0<<2)!== 16 && (temp_tdr0 > read_tdr0) ) begin
            $display("[%0t] [FAIL] Case 5: Counter did not resume!, read_tdr0 = %b", $time, read_tdr0); error_count = error_count + 1;
        end else $display("[%0t] [PASS] Case 5 successful. Counter resumed with new mode.", $time);

        
        
        
        $display("\n[%0t] [CASE 6] Counter continues after Interrupt", $time);
        sys_rst_n = 0; repeat(3) @(posedge sys_clk); sys_rst_n = 1; @(posedge sys_clk);
        apb_write(12'h00C, 32'h0000_0020, 4'b1111); 
        apb_write(12'h010, 32'h0000_0000, 4'b1111); 
        apb_write(12'h014, 32'h0000_0001, 4'b1111); 
        apb_write(12'h000, 32'h0000_0001, 4'b1111); 
        wait(tim_int == 1'b1);
        
        apb_read(12'h004, temp_tdr0);
        repeat(10) @(posedge sys_clk); 
        apb_read(12'h004, read_tdr0);  
        
        if ((read_tdr0 - temp_tdr0)!==14) begin
            $display("[%0t] [FAIL] Case 6: Counter STOPPED after Interrupt.", $time); error_count = error_count + 1;
        end else $display("[%0t] [PASS] Case 6 successful. Counter counting normally.", $time);

        
        
        
        $display("\n[%0t] [CASE 7] Counter continues after Overflow", $time);
        sys_rst_n = 0; repeat(3) @(posedge sys_clk); sys_rst_n = 1; @(posedge sys_clk);
        apb_write(12'h004, 32'hFFFF_FFF0, 4'b1111); 
        apb_write(12'h008, 32'hFFFF_FFFF, 4'b1111); 
        apb_write(12'h000, 32'h0000_0001, 4'b1111); 
        
        repeat(150) @(posedge sys_clk); 
        apb_read(12'h004, temp_tdr0);
        
        repeat(10) @(posedge sys_clk);
        apb_read(12'h004, read_tdr0);
        if ((read_tdr0 - temp_tdr0)!==14) begin
            $display("[%0t] [FAIL] Case 7: Counter STOPPED after overflow!", $time); error_count = error_count + 1;
        end else $display("[%0t] [PASS] Case 7 successful. Counter counting normally.", $time);

        
        
        
        $display("\n==============================================");
        if (error_count == 0) begin
            $display("[%0t] [TEST SUMMARY] PATTERN: cnt_counting_chk ---> PASSED", $time);
        end else begin
            $display("[%0t] [TEST SUMMARY] PATTERN: cnt_counting_chk ---> FAILED (Total errors: %0d)", $time, error_count);
        end
        $display("==============================================\n");
    end
endtask
