





task run_test;
    reg [31:0] read_tcr;
    reg [31:0] write_data;
    reg caught_pslverr;
    integer error_count;
    
    begin
        error_count = 0;
        
        $display("\n=======================================================");
        $display("[%0t] [TEST START] PATTERN: reg_err_chk", $time);
        $display("=======================================================");

        wait (sys_rst_n == 1'b1);
        @(posedge sys_clk);

        
        
        
        $display("\n[%0t] [CASE 1] Check div_val boundary (limit 8)", $time);
        
        
        sys_rst_n = 1'b0; repeat(2) @(posedge sys_clk); sys_rst_n = 1'b1; @(posedge sys_clk);
        
        
        apb_write_err(12'h000, 32'h0000_0600, 4'b1111, caught_pslverr);
        apb_read(12'h000, read_tcr);
        if (read_tcr[11:8] !== 4'h6 || caught_pslverr !== 1'b0) begin
            $display("[%0t] [FAIL] Step 1.1: Exp div_val=6, err=0 | Act div_val=%0d, err=%b", $time, read_tcr[11:8], caught_pslverr); error_count = error_count + 1;
        end else $display("[%0t] [PASS] Step 1.1: Write div_val = 6 successful.", $time);

        
        apb_write_err(12'h000, 32'h0000_0800, 4'b1111, caught_pslverr);
        apb_read(12'h000, read_tcr);
        if (read_tcr[11:8] !== 4'h8 || caught_pslverr !== 1'b0) begin
            $display("[%0t] [FAIL] Step 1.2: Exp div_val=8, err=0 | Act div_val=%0d, err=%b", $time, read_tcr[11:8], caught_pslverr); error_count = error_count + 1;
        end else $display("[%0t] [PASS] Step 1.2: Write div_val = 8 successful.", $time);

        
        apb_write_err(12'h000, 32'h0000_0A00, 4'b1111, caught_pslverr);
        apb_read(12'h000, read_tcr);
        
        if (read_tcr[11:8] !== 4'h8 || caught_pslverr !== 1'b1) begin 
            $display("[%0t] [FAIL] Step 1.3: Exp div_val=8, err=1 | Act div_val=%0d, err=%b", $time, read_tcr[11:8], caught_pslverr); error_count = error_count + 1;
        end else $display("[%0t] [PASS] Step 1.3: Write div_val = 10 rejected correctly.", $time);

        
        apb_write_err(12'h000, 32'h0000_0B00, 4'b1111, caught_pslverr);
        apb_read(12'h000, read_tcr);
        if (read_tcr[11:8] !== 4'h8 || caught_pslverr !== 1'b1) begin
            $display("[%0t] [FAIL] Step 1.4: Exp div_val=8, err=1 | Act div_val=%0d, err=%b", $time, read_tcr[11:8], caught_pslverr); error_count = error_count + 1;
        end else $display("[%0t] [PASS] Step 1.4: Write div_val = 11 rejected correctly.", $time);


        
        
        
        $display("\n[%0t] [CASE 2] Change div_en when timer_en = 1", $time);
        
        
        sys_rst_n = 1'b0; repeat(2) @(posedge sys_clk); sys_rst_n = 1'b1; @(posedge sys_clk);
        
        
        write_data = 32'h0000_0102; 
        apb_write(12'h000, write_data, 4'b1111);
        
        
        write_data = write_data | 32'h0000_0001; 
        apb_write(12'h000, write_data, 4'b1111);
        
        
        write_data = write_data & 32'hFFFF_FFFD; 
        apb_write_err(12'h000, write_data, 4'b1111, caught_pslverr);
        
        
        apb_read(12'h000, read_tcr);
        if (read_tcr[1] !== 1'b1 || caught_pslverr !== 1'b1) begin
            $display("[%0t] [FAIL] Case 2: Exp div_en=1, err=1 | Act div_en=%b, err=%b", $time, read_tcr[1], caught_pslverr); error_count = error_count + 1;
        end else $display("[%0t] [PASS] Case 2: Illegal div_en change blocked.", $time);


        
        
        
        $display("\n[%0t] [CASE 3] Change div_val when timer_en = 1", $time);
        
        
        sys_rst_n = 1'b0; repeat(2) @(posedge sys_clk); sys_rst_n = 1'b1; @(posedge sys_clk);
        
        
        write_data = 32'h0000_0100;
        apb_write(12'h000, write_data, 4'b1111);
        
        
        write_data = write_data | 32'h0000_0001; 
        apb_write(12'h000, write_data, 4'b1111);
        
        
        write_data = (write_data & 32'hFFFF_F0FF) | 32'h0000_0300; 
        apb_write_err(12'h000, write_data, 4'b1111, caught_pslverr);
        
        
        apb_read(12'h000, read_tcr);
        if (read_tcr[11:8] !== 4'h1 || caught_pslverr !== 1'b1) begin
            $display("[%0t] [FAIL] Case 3: Exp div_val=1, err=1 | Act div_val=%0d, err=%b", $time, read_tcr[11:8], caught_pslverr); error_count = error_count + 1;
        end else $display("[%0t] [PASS] Case 3: Illegal div_val change blocked.", $time);


        
        
        
        $display("\n[%0t] [CASE 4] Change div_val>8, div_en simultaneously when timer_en=1", $time);
        
        
        sys_rst_n = 1'b0; repeat(2) @(posedge sys_clk); sys_rst_n = 1'b1; @(posedge sys_clk);
        
        
        write_data = 32'h0000_0102; 
        apb_write(12'h000, write_data, 4'b1111);
        
        
        write_data = write_data | 32'h0000_0001; 
        apb_write(12'h000, write_data, 4'b1111);
        
        
        write_data = (write_data & 32'hFFFF_F0FD) | 32'h0000_0900;
        apb_write_err(12'h000, write_data, 4'b1111, caught_pslverr);
        
        
        apb_read(12'h000, read_tcr);
        if (read_tcr[11:8] !== 4'h1 || read_tcr[1] !== 1'b1 || caught_pslverr !== 1'b1) begin
            $display("[%0t] [FAIL] Case 4: Exp div_val=1, div_en=1, err=1 | Act div_val=%0d, div_en=%b, err=%b", 
                     $time, read_tcr[11:8], read_tcr[1], caught_pslverr);
            error_count = error_count + 1;
        end else $display("[%0t] [PASS] Case 4: Multiple illegal changes blocked.", $time);

        
        
        
        $display("\n=======================================================");
        if (error_count == 0) begin
            $display("[%0t] [TEST SUMMARY] PATTERN: reg_err_chk ---> PASSED", $time);
        end else begin
            $display("[%0t] [TEST SUMMARY] PATTERN: reg_err_chk ---> FAILED (Total errors: %0d)", $time, error_count);
        end
        $display("=======================================================\n");
    end
endtask
