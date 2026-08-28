module interrupt(
	input wire sys_clk, sys_rst_n, reg_wr_en, reg_rd_en,
	input wire [11:0] tim_paddr,
	input wire [3:0] tim_pstrb,
	input wire [31:0] tim_pwdata,
	input wire [63:0] cnt, tcmp,
	output reg [31:0] tim_prdata,
	output wire tim_int
);
	wire tier_sel, tier_byte0_wr_en;
	wire tisr_sel, tisr_byte0_wr_en;
	wire int_en_pre, int_clr, int_set, int_st_pre, tier, tisr;
	reg int_en, int_st;
	
	assign tier_sel = reg_wr_en & (tim_paddr == 12'h14);
        assign tier_byte0_wr_en = tier_sel & tim_pstrb[0];
	assign tisr_sel = reg_wr_en & (tim_paddr == 12'h18);
        assign tisr_byte0_wr_en = tisr_sel & tim_pstrb[0];

	assign int_en_pre = tier_byte0_wr_en ? tim_pwdata[0] : int_en;

	assign int_clr = tisr_byte0_wr_en & (tim_pwdata[0] == 1) & (int_st == 1);
	assign int_set = (cnt == tcmp);
	assign int_st_pre = int_clr ? 1'b0 : (int_set ? 1'b1 : int_st);

	always @(posedge sys_clk or negedge sys_rst_n) begin
		if (!sys_rst_n) begin
			int_en <= 1'b0;
			int_st <= 1'b0;
		end else begin
			int_en <= int_en_pre;
			int_st <= int_st_pre;
		end
	end

	assign tim_int = int_en & int_st;

	assign tier = {31'b0, int_en};
	assign tisr = {31'b0, int_st};

	always @(*) begin
		tim_prdata = 32'h0;
		
		if (reg_rd_en) begin
			case (tim_paddr)
				12'h14: tim_prdata = tier;
				12'h18: tim_prdata = tisr;
				default: tim_prdata = 32'h0;
			endcase
		end
	end
endmodule
