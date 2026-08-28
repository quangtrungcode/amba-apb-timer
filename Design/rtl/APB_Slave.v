module APB_Slave(
	input wire sys_clk, sys_rst_n, tim_psel, tim_pwrite, tim_penable,
	output reg reg_wr_en, reg_rd_en,
	output wire tim_pready
);
	wire reg_wr_en_pre;
	wire reg_rd_en_pre;

	assign reg_wr_en_pre = (!reg_wr_en) & tim_psel & tim_pwrite & tim_penable;
	assign reg_rd_en_pre = (!reg_rd_en) & tim_psel & (!tim_pwrite) & tim_penable;

	always @(posedge sys_clk or negedge sys_rst_n) begin
		if (!sys_rst_n) begin
			reg_wr_en <= 1'b0;
			reg_rd_en <= 1'b0;
		end else begin
			reg_wr_en <= reg_wr_en_pre;
			reg_rd_en <= reg_rd_en_pre;
		end
	end

	assign tim_pready = reg_wr_en | reg_rd_en;


endmodule
