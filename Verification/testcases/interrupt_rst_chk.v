





task run_test;
    reg [31:0] read_data;
    integer error_count;
    
    
    localparam ADDR_TCR  = 12'h000;
    localparam ADDR_CMP0 = 12'h00C;
    localparam ADDR_CMP1 = 12'h010; 
    localparam ADDR_TIER = 12'h014;
    localparam ADDR_TISR = 12'h018;

    begin
        error_count = 0;
        
        $display("\n=======================================================");
        $display("[%0t] [TEST START] PATTERN: interrupt_rst_chk", $time);
        $display("=======================================================");

        wait (sys_rst_n == 1'b1);
        @(posedge sys_clk);

        $display("\n[%0t] [CASE 48] Checking Interrupt Behavior across Reset", $time);
        
        
        
        
        $display("[%0t] Step 1: Setting timer to work normally...", $time);
        
        
        sys_rst_n = 1'b0; repeat(2) @(posedge sys_clk); sys_rst_n = 1'b1; @(posedge sys_clk);
        apb_write(ADDR_CMP1, 32'h0000_0000, 4'b1111); 
        apb_write(ADDR_CMP0, 32'h0000_00FF, 4'b1111); 
        apb_write(ADDR_TIER, 32'h0000_0001, 4'b1111); 
        apb_write(ADDR_TCR,  32'h0000_0001, 4'b1111); 
        
        
        
        
        $display("[%0t] Step 2: Waiting for interrupt to assert...", $time);
        
        
        repeat(300) @(posedge sys_clk); 
        
        apb_read(ADDR_TISR, read_data);
        if (read_data[0] !== 1'b1 || tim_int !== 1'b1) begin
            $display("[%0t] [FAIL] Step 2: Interrupt failed to assert! TISR=%b, tim_int=%b", $time, read_data[0], tim_int);
            error_count = error_count + 1;
        end else begin
            $display("[%0t] [PASS] Step 2: Interrupt asserted normally before reset.", $time);
        end

        
        
        
        $display("[%0t] Step 3: Asserting Hardware Reset (sys_rst_n = 0)...", $time);
        
        sys_rst_n = 1'b0; 
        
        
        @(posedge sys_clk);
        if (tim_int !== 1'b0) begin
            $display("[%0t] [FAIL] Step 3: Output tim_int was NOT cleared immediately by reset!", $time);
            error_count = error_count + 1;
        end else begin
            $display("[%0t] [PASS] Step 3: Output tim_int cleared immediately on reset.", $time);
        end
        
        repeat(4) @(posedge sys_clk); 
        sys_rst_n = 1'b1; 
        @(posedge sys_clk);
        
        
        apb_read(ADDR_TISR, read_data);
        if (read_data[0] !== 1'b0) begin
            $display("[%0t] [FAIL] Step 3: TISR was NOT cleared after reset!", $time);
            error_count = error_count + 1;
        end else begin
            $display("[%0t] [PASS] Step 3: TISR register confirmed clean after reset.", $time);
        end

        
        
        
        $display("[%0t] Step 4: Re-configuring timer after reset...", $time);
        
        
	apb_write(ADDR_CMP1, 32'h0000_0000, 4'b1111); 
        apb_write(ADDR_CMP0, 32'h0000_0050, 4'b1111); 
        apb_write(ADDR_TIER, 32'h0000_0001, 4'b1111); 
        
        
        
        
        $display("[%0t] Step 5: Enabling timer again...", $time);
        
        apb_write(ADDR_TCR,  32'h0000_0001, 4'b1111);
        
        
        repeat(100) @(posedge sys_clk); 
        
        apb_read(ADDR_TISR, read_data);
        if (read_data[0] !== 1'b1 || tim_int !== 1'b1) begin
            $display("[%0t] [FAIL] Step 5: Post-reset interrupt failed! TISR=%b, tim_int=%b", $time, read_data[0], tim_int);
            error_count = error_count + 1;
        end else begin
            $display("[%0t] [PASS] Step 5: Interrupt successfully asserted again after reset (Recovery OK!).", $time);
        end


        
        
        
        $display("\n=======================================================");
        if (error_count == 0) begin
            $display("[%0t] [TEST SUMMARY] PATTERN: interrupt_rst_chk ---> PASSED", $time);
        end else begin
            $display("[%0t] [TEST SUMMARY] PATTERN: interrupt_rst_chk ---> FAILED (Total errors: %0d)", $time, error_count);
        end
        $display("=======================================================\n");
    end
endtask
