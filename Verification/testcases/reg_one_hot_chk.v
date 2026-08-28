





task run_test;
    reg [31:0] read_data;
    integer error_count;
    begin
        error_count = 0;
        
        $display("\n==============================================");
        $display("[%0t] [TEST START] PATTERN: reg_1hot_chk", $time);
        $display("==============================================");
        
        $display("[%0t] [INFO] Waiting for system reset to be released", $time);
        wait (sys_rst_n == 1'b1);
        @(posedge sys_clk);
        $display("[%0t] [INFO] System reset released", $time);
        $display("==============================================");

        
        
        
        
        $display("[%0t] [INFO] Writing distinct values to all registers...", $time);
        apb_write(12'h000, 32'h0000_0500, 4'b1111); 
        apb_write(12'h004, 32'h1111_1111, 4'b1111); 
        apb_write(12'h008, 32'h2222_2222, 4'b1111); 
        apb_write(12'h00C, 32'h3333_3333, 4'b1111); 
        apb_write(12'h010, 32'h4444_4444, 4'b1111); 
        apb_write(12'h014, 32'h0000_0001, 4'b1111); 
        apb_write(12'h01C, 32'h0000_0001, 4'b1111); 

        
        
        
        $display("[%0t] [INFO] Reading back and comparing...", $time);
        
        
        apb_read(12'h000, read_data);
        if (read_data !== 32'h0000_0500) begin
            $display("[%0t] [FAIL] TCR read mismatch. Exp: 0500, Act: %h", $time, read_data); error_count = error_count + 1;
        end else $display("[%0t] [PASS] TCR data retained.", $time);

        
        apb_read(12'h004, read_data);
        if (read_data !== 32'h1111_1111) begin
            $display("[%0t] [FAIL] TDR0 read mismatch. Exp: 1111_1111, Act: %h", $time, read_data); error_count = error_count + 1;
        end else $display("[%0t] [PASS] TDR0 data retained.", $time);

        
        apb_read(12'h008, read_data);
        if (read_data !== 32'h2222_2222) begin
            $display("[%0t] [FAIL] TDR1 read mismatch. Exp: 2222_2222, Act: %h", $time, read_data); error_count = error_count + 1;
        end else $display("[%0t] [PASS] TDR1 data retained.", $time);

        
        apb_read(12'h00C, read_data);
        if (read_data !== 32'h3333_3333) begin
            $display("[%0t] [FAIL] TCMP0 read mismatch. Exp: 3333_3333, Act: %h", $time, read_data); error_count = error_count + 1;
        end else $display("[%0t] [PASS] TCMP0 data retained.", $time);

        
        apb_read(12'h010, read_data);
        if (read_data !== 32'h4444_4444) begin
            $display("[%0t] [FAIL] TCMP1 read mismatch. Exp: 4444_4444, Act: %h", $time, read_data); error_count = error_count + 1;
        end else $display("[%0t] [PASS] TCMP1 data retained.", $time);

        
        apb_read(12'h014, read_data);
        if (read_data !== 32'h0000_0001) begin
            $display("[%0t] [FAIL] TIER read mismatch. Exp: 0001, Act: %h", $time, read_data); error_count = error_count + 1;
        end else $display("[%0t] [PASS] TIER data retained.", $time);

        
        apb_read(12'h01C, read_data);
        if (read_data !== 32'h0000_0001) begin
            $display("[%0t] [FAIL] THCSR read mismatch. Exp: 0001, Act: %h", $time, read_data); error_count = error_count + 1;
        end else $display("[%0t] [PASS] THCSR data retained.", $time);

        
        
        
        $display("==============================================");
        if (error_count == 0) begin
            $display("[%0t] [TEST SUMMARY] PATTERN: reg_1hot_chk ---> PASSED", $time);
        end else begin
            $display("[%0t] [TEST SUMMARY] PATTERN: reg_1hot_chk ---> FAILED (Total errors: %0d)", $time, error_count);
        end
        $display("==============================================\n");
    end
endtask
