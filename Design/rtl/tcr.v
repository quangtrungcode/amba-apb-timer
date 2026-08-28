module tcr(
	input wire sys_clk, sys_rst_n,
	input wire reg_wr_en, reg_rd_en,
	input wire [11:0] tim_paddr,
	input wire [3:0]  tim_pstrb,
	input wire [31:0] tim_pwdata,
	output reg timer_en, div_en,
	output reg [3:0] div_val,
	output wire [31:0] tim_prdata,
	output wire tim_pslverr
);

	wire tcr_sel, tcr_byte0_sel, tcr_byte1_sel, tcr_byte0_wr_en, tcr_byte1_wr_en;
	wire timer_en_pre, div_en_pre;
	wire [3:0] div_val_pre; 
	wire [31:0] tcr;

	assign tcr_sel = reg_wr_en & (tim_paddr == 12'h0);
	assign tcr_byte0_sel = tcr_sel & tim_pstrb[0];
	assign tcr_byte1_sel = tcr_sel & tim_pstrb[1];
	assign tcr_err = (tcr_byte1_sel & (tim_pwdata[11:8] > 8)) | 
			 (timer_en & tcr_byte1_sel & (tim_pwdata[11:8] != div_val)) |
			 (timer_en & tcr_byte0_sel & (tim_pwdata[1] != div_en));
	assign tim_pslverr = tcr_err;
	assign tcr_byte0_wr_en = tcr_byte0_sel & (!tcr_err);
	assign tcr_byte1_wr_en = tcr_byte1_sel & (!tcr_err);
	assign timer_en_pre = tcr_byte0_wr_en ? tim_pwdata[0] : timer_en;
	assign div_en_pre = tcr_byte0_wr_en ? tim_pwdata[1] : div_en;
	assign div_val_pre = tcr_byte1_wr_en ? tim_pwdata[11:8] : div_val;

	always @(posedge sys_clk or negedge sys_rst_n) begin
		if (!sys_rst_n) begin
			timer_en <= 1'b0;
			div_en   <= 1'b0;
			div_val  <= 4'b0001;
		end else begin
			timer_en <= timer_en_pre;
			div_en   <= div_en_pre;
			div_val  <= div_val_pre;
		end
	end
	
	assign tcr = {20'h0, div_val, 6'b0, div_en, timer_en};
	assign tim_prdata = reg_rd_en 
			  ? ((tim_paddr == 12'h0) ? tcr : 32'h0) 
			  : 32'h0;

endmodule	
