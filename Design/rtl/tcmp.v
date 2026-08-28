module tcmp(
	input wire sys_clk, sys_rst_n,
	input wire [11:0] tim_paddr,
	input wire [3:0] tim_pstrb,
	input wire reg_wr_en, reg_rd_en, 
	input wire [31:0] tim_pwdata,
	output wire [63:0] tcmp,
	output reg [31:0] tim_prdata
);

	reg [7:0] tcmp0_7_0, tcmp0_15_8, tcmp0_23_16, tcmp0_31_24, tcmp1_7_0, tcmp1_15_8, tcmp1_23_16, tcmp1_31_24;
	wire [7:0] tcmp0_7_0_pre, tcmp0_15_8_pre, tcmp0_23_16_pre, tcmp0_31_24_pre, tcmp1_7_0_pre, tcmp1_15_8_pre, tcmp1_23_16_pre, tcmp1_31_24_pre;
	wire tcmp0_sel, tcmp1_sel;
	wire [31:0] tcmp0;
	wire [31:0] tcmp1;
	wire tcmp0_byte0_wr_en, tcmp0_byte1_wr_en, tcmp0_byte2_wr_en, tcmp0_byte3_wr_en, 
	     tcmp1_byte0_wr_en, tcmp1_byte1_wr_en, tcmp1_byte2_wr_en, tcmp1_byte3_wr_en;
	
     	assign tcmp0_sel = reg_wr_en & (tim_paddr == 12'h0C);
	assign tcmp1_sel = reg_wr_en & (tim_paddr == 12'h10);
	assign tcmp0_byte0_wr_en = tcmp0_sel & tim_pstrb[0];
	assign tcmp0_byte1_wr_en = tcmp0_sel & tim_pstrb[1];
	assign tcmp0_byte2_wr_en = tcmp0_sel & tim_pstrb[2];
	assign tcmp0_byte3_wr_en = tcmp0_sel & tim_pstrb[3];
	assign tcmp1_byte0_wr_en = tcmp1_sel & tim_pstrb[0];
	assign tcmp1_byte1_wr_en = tcmp1_sel & tim_pstrb[1];
	assign tcmp1_byte2_wr_en = tcmp1_sel & tim_pstrb[2];
	assign tcmp1_byte3_wr_en = tcmp1_sel & tim_pstrb[3];

	
	assign tcmp0_7_0_pre   = tcmp0_byte0_wr_en ? tim_pwdata[7:0]   : tcmp0_7_0;  
	assign tcmp0_15_8_pre  = tcmp0_byte1_wr_en ? tim_pwdata[15:8]  : tcmp0_15_8; 
	assign tcmp0_23_16_pre = tcmp0_byte2_wr_en ? tim_pwdata[23:16] : tcmp0_23_16; 
	assign tcmp0_31_24_pre = tcmp0_byte3_wr_en ? tim_pwdata[31:24] : tcmp0_31_24; 
	assign tcmp1_7_0_pre   = tcmp1_byte0_wr_en ? tim_pwdata[7:0]   : tcmp1_7_0; 
	assign tcmp1_15_8_pre  = tcmp1_byte1_wr_en ? tim_pwdata[15:8]  : tcmp1_15_8; 
	assign tcmp1_23_16_pre = tcmp1_byte2_wr_en ? tim_pwdata[23:16] : tcmp1_23_16; 
	assign tcmp1_31_24_pre = tcmp1_byte3_wr_en ? tim_pwdata[31:24] : tcmp1_31_24; 

	always @(posedge sys_clk or negedge sys_rst_n) begin
		if (!sys_rst_n) begin
			tcmp0_7_0   <= 8'hFF; 
			tcmp0_15_8  <= 8'hFF;
			tcmp0_23_16 <= 8'hFF;
			tcmp0_31_24 <= 8'hFF;
			tcmp1_7_0   <= 8'hFF;
			tcmp1_15_8  <= 8'hFF;
			tcmp1_23_16 <= 8'hFF;
			tcmp1_31_24 <= 8'hFF;
		end else begin
			 tcmp0_7_0   <=  tcmp0_7_0_pre   ;
			 tcmp0_15_8  <=  tcmp0_15_8_pre  ;		
			 tcmp0_23_16 <=  tcmp0_23_16_pre ;
			 tcmp0_31_24 <=  tcmp0_31_24_pre ;
			 tcmp1_7_0   <=  tcmp1_7_0_pre   ;
			 tcmp1_15_8  <=  tcmp1_15_8_pre  ;
			 tcmp1_23_16 <=  tcmp1_23_16_pre ;
			 tcmp1_31_24 <=  tcmp1_31_24_pre ;
		 end
	end
	assign tcmp0 = {tcmp0_31_24, tcmp0_23_16, tcmp0_15_8, tcmp0_7_0};
	assign tcmp1 = {tcmp1_31_24, tcmp1_23_16, tcmp1_15_8, tcmp1_7_0};
	assign tcmp  = {tcmp1, tcmp0};

	always @(*) begin
		tim_prdata = 32'h0;
		
		if (reg_rd_en) begin
			case (tim_paddr)
				12'h0C: tim_prdata = tcmp0;
				12'h10: tim_prdata = tcmp1;
				default: tim_prdata = 32'h0;
			endcase
		end
	end
endmodule

