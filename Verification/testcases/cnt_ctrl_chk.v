





task run_test;
    reg [31:0] val1, val2;
    integer error_count;
    integer apb_overhead;
    integer wait_time;
    integer actual_diff, expected_diff;
    integer i;
    
    
    integer ids [0:10];
    reg [3:0] div_vals [0:10];
    reg div_ens [0:10];
    integer expected_divs [0:10];
    reg [31:0] tcr_data;
    
    begin
        error_count = 0;
        
        
        ids[0] = 28; div_ens[0] = 0; div_vals[0] = 0; expected_divs[0] = 1;
        ids[1] = 29; div_ens[1] = 1; div_vals[1] = 0; expected_divs[1] = 1;
        ids[2] = 30; div_ens[2] = 1; div_vals[2] = 1; expected_divs[2] = 2;
        ids[3] = 31; div_ens[3] = 1; div_vals[3] = 2; expected_divs[3] = 4;
        ids[4] = 32; div_ens[4] = 1; div_vals[4] = 3; expected_divs[4] = 8;
        ids[5] = 33; div_ens[5] = 1; div_vals[5] = 4; expected_divs[5] = 16;
        ids[6] = 34; div_ens[6] = 1; div_vals[6] = 5; expected_divs[6] = 32;
        ids[7] = 35; div_ens[7] = 1; div_vals[7] = 6; expected_divs[7] = 64;
        ids[8] = 36; div_ens[8] = 1; div_vals[8] = 7; expected_divs[8] = 128;
        ids[9] = 37; div_ens[9] = 1; div_vals[9] = 8; expected_divs[9] = 256;
        ids[10]= 38; div_ens[10]= 0; div_vals[10]= 2; expected_divs[10]= 1; 

        $display("\n=======================================================");
        $display("[%0t] [TEST START] PATTERN: cnt_ctrl_chk", $time);
        $display("=======================================================");

        wait (sys_rst_n == 1'b1);
        @(posedge sys_clk);
        
        
        
        
        $display("[%0t] [INFO] Calibrating APB Read overhead...", $time);
        apb_write(12'h000, 32'h0000_0001, 4'b1111); 
        
        apb_read(12'h004, val1);
        repeat(100) @(posedge sys_clk);
        apb_read(12'h004, val2);
        
        
        actual_diff = val2 - val1;
        apb_overhead = actual_diff - 100; 
        
        
        wait_time = 2560 - apb_overhead; 
        
        $display("[%0t] [INFO] APB Overhead = %0d cycles. Adjusted Wait Time = %0d", $time, apb_overhead, wait_time);
        $display("-------------------------------------------------------");

        
        
        for (i = 0; i < 11; i = i + 1) begin
            
            apb_read(12'h000, tcr_data);
            tcr_data = tcr_data & 32'hFFFF_FFFE; 
            apb_write(12'h000, tcr_data, 4'b1111); 
            
            
            apb_write(12'h004, 32'h0000_0000, 4'b1111); 
            
            
            tcr_data = (div_vals[i] << 8) | (div_ens[i] << 1) | 1'b1;
            apb_write(12'h000, tcr_data, 4'b1111);
            
            
         
        
            
            
            apb_read(12'h004, val1);
            repeat(wait_time) @(posedge sys_clk);
            apb_read(12'h004, val2);
            
            
            actual_diff = val2 - val1;
            expected_diff = 2560 / expected_divs[i];
            
            if (actual_diff !== expected_diff) begin
                $display("[%0t] [FAIL] ID %0d | div_en=%b, div_val=%0d | Exp diff: %0d, Act: %0d", 
                         $time, ids[i], div_ens[i], div_vals[i], expected_diff, actual_diff);
                error_count = error_count + 1;
            end else begin
                $display("[%0t] [PASS] ID %0d | div_en=%b, div_val=%0d | Freq=clk/%0d (Diff=%0d)", 
                         $time, ids[i], div_ens[i], div_vals[i], expected_divs[i], actual_diff);
            end
        end

        
        
        
        $display("=======================================================");
        if (error_count == 0) begin
            $display("[%0t] [TEST SUMMARY] PATTERN: cnt_ctrl_chk ---> PASSED", $time);
        end else begin
            $display("[%0t] [TEST SUMMARY] PATTERN: cnt_ctrl_chk ---> FAILED (Total errors: %0d)", $time, error_count);
        end
        $display("=======================================================\n");
    end
endtask
