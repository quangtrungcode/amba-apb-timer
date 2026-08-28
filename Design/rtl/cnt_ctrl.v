module cnt_ctrl(
	input wire sys_clk, sys_rst_n,
	input wire [3:0] div_val,
	input wire timer_en, div_en, reg_wr_en, reg_rd_en, dbg_mode,
	input wire [3:0] tim_pstrb,
	input wire [31:0] tim_pwdata,
	input wire [11:0] tim_paddr,
	output wire [31:0] tim_prdata,
	output wire cnt_en
);
	reg [7:0] limit, int_cnt;
	wire [7:0] int_cnt_pre;
	wire cnt_rst, ctrl_mode_other, halt_en, thcsr_sel, thcsr_byte0_wr_en, halt_req_pre;
	wire [31:0] thcsr;
	reg halt_req, halt_ack;
	always @(*) begin
		case (div_val) 
			4'h1: limit = 1;
			4'h2: limit = 3;
			4'h3: limit = 7;
			4'h4: limit = 15;
			4'h5: limit = 31;
			4'h6: limit = 63;
			4'h7: limit = 127;
			4'h8: limit = 255;
			default: limit = 0;
	       endcase
       end
 
      assign thcsr_sel = reg_wr_en & (tim_paddr == 12'h1C);
      assign thcsr_byte0_wr_en = thcsr_sel & tim_pstrb[0];
      assign halt_req_pre = thcsr_byte0_wr_en ? tim_pwdata[0] : halt_req;
      always @(posedge sys_clk or negedge sys_rst_n) begin
		if (!sys_rst_n) begin
			halt_req <= 1'b0;
		end else begin
			halt_req <= halt_req_pre;
		end
      end
      assign halt_en = halt_req & dbg_mode;
      always @(posedge sys_clk or negedge sys_rst_n) begin
		if (!sys_rst_n) begin
			halt_ack <= 1'b0;
		end else begin
			halt_ack <= halt_en;
		end
      end

      assign cnt_rst = (int_cnt == limit) | (!timer_en) | (!div_en);
      assign ctrl_mode_other = timer_en & div_en & (div_val != 0);
      assign ctrl_mode_0 = timer_en & div_en & (div_val == 0);
      assign int_cnt_pre = halt_en 
      			  ? int_cnt 
       		          : (cnt_rst ? 8'h0 : (ctrl_mode_other ? (int_cnt + 1) : int_cnt)); 

      	always @(posedge sys_clk or negedge sys_rst_n) begin
		if (!sys_rst_n) begin
			int_cnt <= 8'h0;
		end else begin
			int_cnt <= int_cnt_pre;
		end
        end

	assign cnt_en = halt_en 
		      ? 1'b0 
		      : ((timer_en & !div_en) | ctrl_mode_0 | (ctrl_mode_other & (int_cnt == limit)));
	assign thcsr = {30'b0, halt_ack, halt_req};
	assign tim_prdata = reg_rd_en ? ((tim_paddr == 12'h1C) ? thcsr : 32'h0) : 32'h0;
endmodule
