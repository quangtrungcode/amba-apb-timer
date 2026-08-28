





task run_test;
    reg [31:0] read_data;
    integer error_count;
    begin
        error_count = 0;
        
        $display("\n==============================================");
        $display("[%0t] [TEST START] PATTERN: reg_reserved_chk", $time);
        $display("==============================================");

        $display("[%0t] [INFO] Waiting for system reset to be released", $time);
        wait (sys_rst_n == 1'b1);
        @(posedge sys_clk);
        $display("[%0t] [INFO] System reset released", $time);
        $display("==============================================");
        
     
        
        
        
        
        apb_write(12'h020, 32'hFFFF_FFFF, 4'b1111);
        
        apb_read(12'h020, read_data);
        
        if (read_data !== 32'h0000_0000) begin
            $display("[%0t] [FAIL] Reserved Addr 12'h020 read mismatch! Exp: 0, Act: %h", $time, read_data);
            error_count = error_count + 1;
        end else begin
            $display("[%0t] [PASS] Reserved Addr 12'h020 correctly enforced RAZ/WI (Read: 0)", $time);
        end

        
        
        
        apb_write(12'hFFC, 32'hFFFF_FFFF, 4'b1111);
        apb_read(12'hFFC, read_data);
        
        if (read_data !== 32'h0000_0000) begin
            $display("[%0t] [FAIL] Reserved Addr 12'hFFC read mismatch! Exp: 0, Act: %h", $time, read_data);
            error_count = error_count + 1;
        end else begin
            $display("[%0t] [PASS] Reserved Addr 12'hFFC correctly enforced RAZ/WI (Read: 0)", $time);
        end

        
        
        
        $display("==============================================");
        if (error_count == 0) begin
            $display("[%0t] [TEST SUMMARY] PATTERN: reg_reserved_chk ---> PASSED", $time);
        end else begin
            $display("[%0t] [TEST SUMMARY] PATTERN: reg_reserved_chk ---> FAILED (Total errors: %0d)", $time, error_count);
        end
        $display("==============================================\n");
    end
endtask
