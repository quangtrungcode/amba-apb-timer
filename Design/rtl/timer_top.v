module timer_top (
	input wire sys_clk,
	input wire sys_rst_n,
	input wire tim_psel,
	input wire tim_pwrite,
	input wire tim_penable,
	input wire [11:0] tim_paddr,
	input wire [31:0] tim_pwdata,
	input wire [3:0] tim_pstrb,
	input wire dbg_mode,

	output wire [31:0] tim_prdata,
	output wire tim_pready,
	output wire tim_pslverr,
	output wire tim_int
);

	wire reg_wr_en;
	wire reg_rd_en;

	wire timer_en;
	wire div_en;
	wire [3:0] div_val;

	wire cnt_en;

	wire [63:0] cnt_wire;
	wire [63:0] tcmp_wire;

	wire [31:0] prdata_cnt_ctrl;
	wire [31:0] prdata_counter;
	wire [31:0] prdata_interrupt;
	wire [31:0] prdata_tcmp;
	wire [31:0] prdata_tcr;

	APB_Slave u_APB_Slave (
		.sys_clk (sys_clk),
		.sys_rst_n (sys_rst_n),
		.tim_psel (tim_psel),
		.tim_pwrite (tim_pwrite),
		.tim_penable (tim_penable),
		.reg_wr_en (reg_wr_en),
		.reg_rd_en (reg_rd_en),
		.tim_pready (tim_pready)
	);

	tcr u_tcr (
		.sys_clk (sys_clk),
		.sys_rst_n (sys_rst_n),
		.reg_wr_en (reg_wr_en),
		.reg_rd_en (reg_rd_en),
		.tim_paddr (tim_paddr),
		.tim_pstrb (tim_pstrb),
		.tim_pwdata (tim_pwdata),
		.timer_en (timer_en),
		.div_en (div_en),
		.div_val (div_val),
		.tim_prdata (prdata_tcr),
		.tim_pslverr (tim_pslverr)
	);

	cnt_ctrl u_cnt_ctrl (
		.sys_clk (sys_clk),
		.sys_rst_n (sys_rst_n),
		.reg_wr_en (reg_wr_en),
		.reg_rd_en (reg_rd_en),
		.tim_paddr (tim_paddr),
		.tim_pstrb (tim_pstrb),
		.tim_pwdata (tim_pwdata),
		.timer_en (timer_en),
		.div_en (div_en),
		.div_val (div_val),
		.tim_prdata (prdata_cnt_ctrl),
		.dbg_mode (dbg_mode),
		.cnt_en (cnt_en)
	);

	counter u_counter (
		.sys_clk (sys_clk),
		.sys_rst_n (sys_rst_n),
		.reg_wr_en (reg_wr_en),
		.reg_rd_en (reg_rd_en),
		.tim_paddr (tim_paddr),
		.tim_pstrb (tim_pstrb),
		.tim_pwdata (tim_pwdata),
		.timer_en (timer_en),
		.tim_prdata (prdata_counter),
		.cnt_en (cnt_en),
		.cnt (cnt_wire)
	);

	tcmp u_tcmp (
		.sys_clk (sys_clk),
		.sys_rst_n (sys_rst_n),
		.reg_wr_en (reg_wr_en),
		.reg_rd_en (reg_rd_en),
		.tim_paddr (tim_paddr),
		.tim_pstrb (tim_pstrb),
		.tim_pwdata (tim_pwdata),
		.tim_prdata (prdata_tcmp),
		.tcmp (tcmp_wire)
	);

	interrupt u_interrupt (
		.sys_clk (sys_clk),
		.sys_rst_n (sys_rst_n),
		.reg_wr_en (reg_wr_en),
		.reg_rd_en (reg_rd_en),
		.tim_paddr (tim_paddr),
		.tim_pstrb (tim_pstrb),
		.tim_pwdata (tim_pwdata),
		.cnt (cnt_wire),
		.tcmp (tcmp_wire),
		.tim_prdata (prdata_interrupt),
		.tim_int (tim_int)
	);

	assign tim_prdata = prdata_cnt_ctrl |
			    prdata_counter  |
			    prdata_interrupt|
			    prdata_tcmp     |
			    prdata_tcr;
endmodule
