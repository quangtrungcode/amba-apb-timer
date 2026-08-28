module counter(
	input wire sys_clk, sys_rst_n,
	input wire [11:0] tim_paddr,
	input wire [3:0] tim_pstrb,
	input wire timer_en, reg_wr_en, reg_rd_en, cnt_en,
	input wire [31:0] tim_pwdata,
	output wire [63:0] cnt,
	output reg [31:0] tim_prdata
);

	reg [7:0] tdr0_7_0, tdr0_15_8, tdr0_23_16, tdr0_31_24, tdr1_7_0, tdr1_15_8, tdr1_23_16, tdr1_31_24;
	wire [7:0] tdr0_7_0_pre, tdr0_15_8_pre, tdr0_23_16_pre, tdr0_31_24_pre, tdr1_7_0_pre, tdr1_15_8_pre, tdr1_23_16_pre, tdr1_31_24_pre;
	wire tdr0_sel, tdr1_sel;
	wire [31:0] tdr0, tdr1;
	wire tdr0_byte0_wr_en, tdr0_byte1_wr_en, tdr0_byte2_wr_en, tdr0_byte3_wr_en, 
	     tdr1_byte0_wr_en, tdr1_byte1_wr_en, tdr1_byte2_wr_en, tdr1_byte3_wr_en;
	reg timer_en_1d;
	wire timer_pulse_out_n;
	wire [63:0] cnt_pre;
     	assign tdr0_sel = reg_wr_en & (tim_paddr == 12'h4);
	assign tdr1_sel = reg_wr_en & (tim_paddr == 12'h8);
	assign tdr0_byte0_wr_en = tdr0_sel & tim_pstrb[0];
	assign tdr0_byte1_wr_en = tdr0_sel & tim_pstrb[1];
	assign tdr0_byte2_wr_en = tdr0_sel & tim_pstrb[2];
	assign tdr0_byte3_wr_en = tdr0_sel & tim_pstrb[3];
	assign tdr1_byte0_wr_en = tdr1_sel & tim_pstrb[0];
	assign tdr1_byte1_wr_en = tdr1_sel & tim_pstrb[1];
	assign tdr1_byte2_wr_en = tdr1_sel & tim_pstrb[2];
	assign tdr1_byte3_wr_en = tdr1_sel & tim_pstrb[3];

	always @(posedge sys_clk or negedge sys_rst_n) begin
		if (!sys_rst_n) begin
			timer_en_1d <= 1'b0;
		end else begin
			timer_en_1d <= timer_en;
		end
	end
	
	assign timer_pulse_out_n = timer_en_1d & (!timer_en);
 	assign cnt_pre = cnt + 1'b1;
	assign tdr0_7_0_pre   = tdr0_byte0_wr_en ? tim_pwdata[7:0]   : timer_pulse_out_n ? 8'h0 : cnt_en ? (cnt_pre[7:0] )   : tdr0_7_0;  
	assign tdr0_15_8_pre  = tdr0_byte1_wr_en ? tim_pwdata[15:8]  : timer_pulse_out_n ? 8'h0 : cnt_en ? (cnt_pre[15:8] )  : tdr0_15_8; 
	assign tdr0_23_16_pre = tdr0_byte2_wr_en ? tim_pwdata[23:16] : timer_pulse_out_n ? 8'h0 : cnt_en ? (cnt_pre[23:16] ) : tdr0_23_16; 
	assign tdr0_31_24_pre = tdr0_byte3_wr_en ? tim_pwdata[31:24] : timer_pulse_out_n ? 8'h0 : cnt_en ? (cnt_pre[31:24] ) : tdr0_31_24; 
	assign tdr1_7_0_pre   = tdr1_byte0_wr_en ? tim_pwdata[7:0]   : timer_pulse_out_n ? 8'h0 : cnt_en ? (cnt_pre[39:32] )   : tdr1_7_0; 
	assign tdr1_15_8_pre  = tdr1_byte1_wr_en ? tim_pwdata[15:8]  : timer_pulse_out_n ? 8'h0 : cnt_en ? (cnt_pre[47:40] )  : tdr1_15_8; 
	assign tdr1_23_16_pre = tdr1_byte2_wr_en ? tim_pwdata[23:16] : timer_pulse_out_n ? 8'h0 : cnt_en ? (cnt_pre[55:48] ) : tdr1_23_16; 
	assign tdr1_31_24_pre = tdr1_byte3_wr_en ? tim_pwdata[31:24] : timer_pulse_out_n ? 8'h0 : cnt_en ? (cnt_pre[63:56] ) : tdr1_31_24; 

	always @(posedge sys_clk or negedge sys_rst_n) begin
		if (!sys_rst_n) begin
			tdr0_7_0   <= 8'h0; 
			tdr0_15_8  <= 8'h0;
			tdr0_23_16 <= 8'h0;
			tdr0_31_24 <= 8'h0;
			tdr1_7_0   <= 8'h0;
			tdr1_15_8  <= 8'h0;
			tdr1_23_16 <= 8'h0;
			tdr1_31_24 <= 8'h0;
		end else begin
			 tdr0_7_0   <=  tdr0_7_0_pre   ;
			 tdr0_15_8  <=  tdr0_15_8_pre  ;		
			 tdr0_23_16 <=  tdr0_23_16_pre ;
			 tdr0_31_24 <=  tdr0_31_24_pre ;
			 tdr1_7_0   <=  tdr1_7_0_pre   ;
			 tdr1_15_8  <=  tdr1_15_8_pre  ;
			 tdr1_23_16 <=  tdr1_23_16_pre ;
			 tdr1_31_24 <=  tdr1_31_24_pre ;
		 end
	end
	assign tdr0 = {tdr0_31_24, tdr0_23_16, tdr0_15_8, tdr0_7_0};
	assign tdr1 = {tdr1_31_24, tdr1_23_16, tdr1_15_8, tdr1_7_0};
	assign cnt  = {tdr1, tdr0};

	always @(*) begin
		tim_prdata = 32'h0;
		
		if (reg_rd_en) begin
			case (tim_paddr)
				12'h4: tim_prdata = tdr0;
				12'h8: tim_prdata = tdr1;
				default: tim_prdata = 32'h0;
			endcase
		end
	end
endmodule
