





task run_test;
    
    reg [31:0] read_data;
    integer error_count;
    integer i;
    
    
    reg [11:0] reg_addr [0:7];
    reg [31:0] reg_exp  [0:7];
    
    begin
        error_count = 0;
        
        
        reg_addr[0] = 12'h000; reg_exp[0] = 32'h0000_0100; 
        reg_addr[1] = 12'h004; reg_exp[1] = 32'h0000_0000; 
        reg_addr[2] = 12'h008; reg_exp[2] = 32'h0000_0000; 
        reg_addr[3] = 12'h00C; reg_exp[3] = 32'hFFFF_FFFF; 
        reg_addr[4] = 12'h010; reg_exp[4] = 32'hFFFF_FFFF; 
        reg_addr[5] = 12'h014; reg_exp[5] = 32'h0000_0000; 
        reg_addr[6] = 12'h018; reg_exp[6] = 32'h0000_0000; 
        reg_addr[7] = 12'h01C; reg_exp[7] = 32'h0000_0000; 

        $display("\n==============================================");
        $display("[%0t] [TEST START] PATTERN: reg_init_chk", $time);
        $display("==============================================");
        
        
        $display("[%0t] [INFO] Waiting for system reset to be released", $time);
        wait (sys_rst_n == 1'b1);
        @(posedge sys_clk);
        $display("[%0t] [INFO] System reset released", $time);
        $display("----------------------------------------------");

        
        for (i = 0; i < 8; i = i + 1) begin
            
            apb_read(reg_addr[i], read_data);
            
            
            if (read_data !== reg_exp[i]) begin
                $display("[%0t] [FAIL] Offset 12'h%03h | Expected: 32'h%08h, Actual: 32'h%08h", 
                         $time, reg_addr[i], reg_exp[i], read_data);
                error_count = error_count + 1;
            end else begin
                $display("[%0t] [PASS] Offset 12'h%03h matches Reset Value 32'h%08h", 
                         $time, reg_addr[i], reg_exp[i]);
            end
        end

        
        
        
        $display("==============================================");
        if (error_count == 0) begin
            $display("[%0t] [TEST SUMMARY] PATTERN: reg_init_chk ---> PASSED", $time);
        end else begin
            $display("[%0t] [TEST SUMMARY] PATTERN: reg_init_chk ---> FAILED (Total errors: %0d)", $time, error_count);
        end
        $display("==============================================\n");
    end
endtask
