`timescale 1ns/1ps

module test_bench ;
	reg sys_clk;
	reg sys_rst_n;
	reg tim_psel;
	reg tim_pwrite;
	reg tim_penable;
	reg [11:0] tim_paddr;
	reg [31:0] tim_pwdata;
	reg [3:0] tim_pstrb;
	reg dbg_mode;

	wire [31:0] tim_prdata;
	wire tim_pready;
	wire tim_pslverr;
	wire tim_int;


	timer_top dut (.*);

	initial begin
		sys_clk = 0;
		forever #5 sys_clk = ~sys_clk;
	end

	initial begin
		tim_psel = 0;
		tim_pwrite = 0;
		tim_penable = 0;
		tim_paddr = 0;
		tim_pwdata = 0;
		tim_pstrb = 0;
		dbg_mode = 0;	

		sys_rst_n = 0;
		#25;
		sys_rst_n = 1;
	end

`include "apb_tasks.v"
`include "run_test.v"
	initial begin
		run_test();
		#100;
		$finish;
	end
endmodule
