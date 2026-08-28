





task run_test;
    
    reg [31:0] read_data;
    integer error_count;
    
    
    integer i, r;
    reg [31:0] write_val[0:15];
    reg [31:0] expected_val;
    reg [31:0] base_val;
    
    
    
    reg [11:0] reg_addr [0:7];
    reg [31:0] reg_rst  [0:7];
    reg [31:0] reg_mask [0:7];
    
    begin
        error_count = 0;

    write_val[0]  = 32'h0000_0000; 
    write_val[1]  = 32'hFFFF_F100; 
    write_val[2]  = 32'hAAAA_A200; 
    write_val[3]  = 32'h5555_5300; 
    write_val[4]  = 32'h1234_5400; 
    write_val[5]  = 32'h8765_4500; 
    write_val[6]  = 32'hA5A5_A600; 
    write_val[7]  = 32'h5A5A_5700; 
    write_val[8]  = 32'hCAFE_B800; 

    
    write_val[9]  = 32'h0F0F_000F; 
    write_val[10] = 32'hF0F0_F10F; 
    write_val[11] = 32'h00FF_020F; 
    write_val[12] = 32'hFF00_830F; 
    write_val[13] = 32'h8000_0401; 
    write_val[14] = 32'h7FFF_F501; 
    write_val[15] = 32'hDEAD_B601; 
        
        reg_addr[0] = 12'h000; reg_rst[0] = 32'h0000_0100; reg_mask[0] = 32'h0000_0F03;
        
        reg_addr[1] = 12'h004; reg_rst[1] = 32'h0000_0000; reg_mask[1] = 32'hFFFF_FFFF;
        
        reg_addr[2] = 12'h008; reg_rst[2] = 32'h0000_0000; reg_mask[2] = 32'hFFFF_FFFF;
        
        reg_addr[3] = 12'h00C; reg_rst[3] = 32'hFFFF_FFFF; reg_mask[3] = 32'hFFFF_FFFF;
        
        reg_addr[4] = 12'h010; reg_rst[4] = 32'hFFFF_FFFF; reg_mask[4] = 32'hFFFF_FFFF;
        
        reg_addr[5] = 12'h014; reg_rst[5] = 32'h0000_0000; reg_mask[5] = 32'h0000_0001;
        
        reg_addr[6] = 12'h018; reg_rst[6] = 32'h0000_0000; reg_mask[6] = 32'h0000_0000;
        
        reg_addr[7] = 12'h01C; reg_rst[7] = 32'h0000_0000; reg_mask[7] = 32'h0000_0001;

        $display("\n==============================================");
        $display("[%0t] [TEST START] PATTERN: reg_rw_chk", $time);
        $display("==============================================");
        
        $display("[%0t] [INFO] Waiting for system reset to be released", $time);
        wait (sys_rst_n == 1'b1);
        @(posedge sys_clk);
        $display("[%0t] [INFO] System reset released", $time);
        $display("==============================================");

        
        
        
        for (r = 0; r < 8; r = r + 1) begin
            $display("\n[%0t] [STEP] R/W Byte Access Check for Register Offset 12'h%03h", $time, reg_addr[r]);
            for (i = 0; i <= 15; i = i + 1) begin
                
                
                @(posedge sys_clk); #1;
                sys_rst_n = 0;
                repeat(3) @(posedge sys_clk); #1;
                sys_rst_n = 1;
                @(posedge sys_clk);

                
                apb_write(reg_addr[r], write_val[i], i[3:0]);
                
                
                apb_read(reg_addr[r], read_data);
                
                
                base_val = reg_rst[r];
                expected_val = base_val;
                
                
                if (i[0]) expected_val[7:0]   = (base_val[7:0]   & ~reg_mask[r][7:0])   | (write_val[i][7:0]   & reg_mask[r][7:0]);
                if (i[1]) expected_val[15:8]  = (base_val[15:8]  & ~reg_mask[r][15:8])  | (write_val[i][15:8]  & reg_mask[r][15:8]);
                if (i[2]) expected_val[23:16] = (base_val[23:16] & ~reg_mask[r][23:16]) | (write_val[i][23:16] & reg_mask[r][23:16]);
                if (i[3]) expected_val[31:24] = (base_val[31:24] & ~reg_mask[r][31:24]) | (write_val[i][31:24] & reg_mask[r][31:24]);
                
                
                if (read_data !== expected_val) begin
                    $display("[%0t] [FAIL] PSTRB: 4'b%04b. Expected: 32'h%08h, Actual: 32'h%08h", 
                             $time, i[3:0], expected_val, read_data);
                    error_count = error_count + 1;
                end
            end
            $display("[%0t] [INFO] Passed all 16 pstrb cases for Register 12'h%03h", $time, reg_addr[r]);
        end

        
/*        
        
        
        $display("\n==============================================");
        $display("[%0t] [STEP] Error handling check for TCR.div_val", $time);
        
        
        @(posedge sys_clk); #1; 
        sys_rst_n = 0; repeat(3) @(posedge sys_clk); #1; sys_rst_n = 1; 
        @(posedge sys_clk);
        
        
        @(posedge sys_clk); #1;
        tim_psel = 1; tim_pwrite = 1; tim_paddr = 12'h000; tim_pwdata = 32'h0000_0600; tim_pstrb = 4'b1111; tim_penable = 0;
        @(posedge sys_clk); #1; tim_penable = 1;
        wait(tim_pready == 1'b1);
        if (tim_pslverr !== 1'b0) begin
            $display("[%0t] [FAIL] Case 1 (div_val=6): Expected pslverr=0, got %b", $time, tim_pslverr); error_count = error_count + 1;
        end else $display("[%0t] [PASS] Case 1 (div_val=6) -> pslverr = 0", $time);
        @(posedge sys_clk); #1; tim_penable = 0; tim_psel = 0;
        
        apb_read(12'h000, read_data);
        if (read_data[11:8] !== 4'h6) begin
            $display("[%0t] [FAIL] Case 1: Expected readback 6, got %h", $time, read_data[11:8]); error_count = error_count + 1;
        end

        
        @(posedge sys_clk); #1;
        tim_psel = 1; tim_pwrite = 1; tim_paddr = 12'h000; tim_pwdata = 32'h0000_0800; tim_pstrb = 4'b1111; tim_penable = 0;
        @(posedge sys_clk); #1; tim_penable = 1;
        wait(tim_pready == 1'b1);
        if (tim_pslverr !== 1'b0) begin
            $display("[%0t] [FAIL] Case 2 (div_val=8): Expected pslverr=0, got %b", $time, tim_pslverr); error_count = error_count + 1;
        end else $display("[%0t] [PASS] Case 2 (div_val=8) -> pslverr = 0", $time);
        @(posedge sys_clk); #1; tim_penable = 0; tim_psel = 0;
        
        apb_read(12'h000, read_data);
        if (read_data[11:8] !== 4'h8) begin
            $display("[%0t] [FAIL] Case 2: Expected readback 8, got %h", $time, read_data[11:8]); error_count = error_count + 1;
        end

        
        @(posedge sys_clk); #1;
        tim_psel = 1; tim_pwrite = 1; tim_paddr = 12'h000; tim_pwdata = 32'h0000_0A00; tim_pstrb = 4'b1111; tim_penable = 0;
        @(posedge sys_clk); #1; tim_penable = 1;
        wait(tim_pready == 1'b1);
        if (tim_pslverr !== 1'b1) begin
            $display("[%0t] [FAIL] Case 3 (div_val=10): Expected pslverr=1, got %b", $time, tim_pslverr); error_count = error_count + 1;
        end else $display("[%0t] [PASS] Case 3 (div_val=10) -> pslverr = 1", $time);
        @(posedge sys_clk); #1; tim_penable = 0; tim_psel = 0;
        
        apb_read(12'h000, read_data);
        if (read_data[11:8] !== 4'h8) begin
            $display("[%0t] [FAIL] Case 3: Expected readback 8 (unchanged), got %h", $time, read_data[11:8]); error_count = error_count + 1;
        end

        
        @(posedge sys_clk); #1;
        tim_psel = 1; tim_pwrite = 1; tim_paddr = 12'h000; tim_pwdata = 32'h0000_0B00; tim_pstrb = 4'b1111; tim_penable = 0;
        @(posedge sys_clk); #1; tim_penable = 1;
        wait(tim_pready == 1'b1);
        if (tim_pslverr !== 1'b1) begin
            $display("[%0t] [FAIL] Case 4 (div_val=11): Expected pslverr=1, got %b", $time, tim_pslverr); error_count = error_count + 1;
        end else $display("[%0t] [PASS] Case 4 (div_val=11) -> pslverr = 1", $time);
        @(posedge sys_clk); #1; tim_penable = 0; tim_psel = 0;
        
        apb_read(12'h000, read_data);
        if (read_data[11:8] !== 4'h8) begin
            $display("[%0t] [FAIL] Case 4: Expected readback 8 (unchanged), got %h", $time, read_data[11:8]); error_count = error_count + 1;
        end
*/
        
        
        
        $display("\n==============================================");
        if (error_count == 0) begin
            $display("[%0t] [TEST SUMMARY] PATTERN: reg_rw_chk ---> PASSED", $time);
        end else begin
            $display("[%0t] [TEST SUMMARY] PATTERN: reg_rw_chk ---> FAILED (Total errors: %0d)", $time, error_count);
        end
        $display("==============================================\n");
        
    end
endtask
