task run_test;
	reg [31:0] rdata;
	reg [31:0] expected_value;
	integer error_count;
	begin
		error_count = 0;
		wait(sys_rst_n == 1'b1);
		@(posedge sys_clk);
		$display("CASE 1");
		sys_rst_n = 0; repeat(3) @(posedge sys_clk); sys_rst_n = 1; 
		@(posedge sys_clk);
		apb_write(12'h0, 32'h0000_0203, 4'b1111);
		apb_read(12'h0, rdata);
		expected_value = 32'h0000_0203;
		if (rdata !== expected_value) begin
			error_count = error_count + 1;
			$display("[%0t] [FAIL] Expected:%h, Actual:%h", $time, expected_value, rdata);
		end else begin
			$display("PASS");
		end

		$display("CASE 2");
    		sys_rst_n = 0; repeat(3) @(posedge sys_clk); sys_rst_n = 1; 
		@(posedge sys_clk);
		#1;
		tim_psel = 0;
		tim_pwrite = 1;
		tim_paddr = 12'h0;
		tim_pwdata = 32'hFFFF_FFFF;
		@(posedge sys_clk);
		#1;
		tim_penable = 1;
		repeat(2)@(posedge sys_clk);
		#1;
		tim_psel = 0;
		tim_penable = 0;
		@(posedge sys_clk);
		apb_read(12'h0, rdata);
		expected_value = 32'h 0000_0100;
		if (rdata !== expected_value) begin
			error_count = error_count + 1;
			$display("[%0t] [FAIL] Expected:%h, Actual:%h", $time, expected_value, rdata);
		end else begin
			$display("PASS");
		end

		$display("CASE 3");
    		sys_rst_n = 0; repeat(3) @(posedge sys_clk); sys_rst_n = 1; 
		@(posedge sys_clk);
		#1;
		tim_psel = 1;
		tim_pwrite = 1;
		tim_paddr = 12'h0;
		tim_pwdata = 32'hFFFF_FFFF;
		@(posedge sys_clk);
		#1;
		tim_penable = 0;
		repeat(2)@(posedge sys_clk);
		#1;
		tim_psel = 0;
		tim_penable = 0;
		@(posedge sys_clk);
		apb_read(12'h0, rdata);
		expected_value = 32'h 0000_0100;
		if (rdata !== expected_value) begin
			error_count = error_count + 1;
			$display("[%0t] [FAIL] Expected:%h, Actual:%h", $time, expected_value, rdata);
		end else begin
			$display("PASS");
		end


		$display("CASE 4");
    		sys_rst_n = 0; repeat(3) @(posedge sys_clk); sys_rst_n = 1;
	        apb_write (12'h0, 32'h0000_0203, 4'b1111);	
		@(posedge sys_clk);
		#1;
		tim_psel = 0;
		tim_pwrite = 0;
		tim_paddr = 12'h0;
		@(posedge sys_clk);
		#1;
		tim_penable = 1;
		@(posedge sys_clk);
		#1;
                rdata = tim_prdata;
		@(posedge sys_clk);
		#1;
		tim_psel = 0;
		tim_penable = 0;
		@(posedge sys_clk);
		expected_value = 32'h 0000_0000;
		if (rdata !== expected_value) begin
			error_count = error_count + 1;
			$display("[%0t] [FAIL] Expected:%h, Actual:%h", $time, expected_value, rdata);
		end else begin
			$display("PASS");
		end

		$display("CASE 5");
    		sys_rst_n = 0; repeat(3) @(posedge sys_clk); sys_rst_n = 1;
	        apb_write (12'h0, 32'h0000_0203, 4'b1111);	
		@(posedge sys_clk);
		#1;
		tim_psel = 1;
		tim_pwrite = 0;
		tim_paddr = 12'h0;
		@(posedge sys_clk);
		#1;
		tim_penable = 0;
		@(posedge sys_clk);
		#1;
                rdata = tim_prdata;
		@(posedge sys_clk);
		#1;
		tim_psel = 0;
		tim_penable = 0;
		@(posedge sys_clk);
		expected_value = 32'h 0000_0000;
		if (rdata !== expected_value) begin
			error_count = error_count + 1;
			$display("[%0t] [FAIL] Expected:%h, Actual:%h", $time, expected_value, rdata);
		end else begin
			$display("PASS");
		end


		$display("CASE 6");
    		sys_rst_n = 0; repeat(3) @(posedge sys_clk); sys_rst_n = 1; 
		@(posedge sys_clk);
		#1;
		tim_psel = 1;
		tim_paddr = 12'h0;
		tim_pwdata = 32'hFFFF_FFFF;
		@(posedge sys_clk);
		#1;
		tim_penable = 1;
		if (tim_pready !== 1'b0) begin
			error_count = error_count + 1;
			$display("[%0t] [FAIL] Expected:%b, Actual:%b", $time, 1'b0, tim_pready);
		end else begin
			$display("PASS");
		end
		@(posedge sys_clk);
		#1;
		if (tim_pready !== 1'b1) begin
			error_count = error_count + 1;
			$display("[%0t] [FAIL] Expected:%b, Actual:%b", $time, 1'b1, tim_pready);
		end else begin
			$display("PASS");
		end

        $display("\n==============================================");
        if (error_count == 0) begin
            $display("[%0t] [TEST SUMMARY] PATTERN: apb_protocol_chk ---> PASSED", $time);
        end else begin
            $display("[%0t] [TEST SUMMARY] PATTERN: apb_protocol_chk ---> FAILED (Total errors: %0d)", $time, error_count);
        end
        $display("==============================================\n");
    end
endtask
