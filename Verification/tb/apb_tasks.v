task apb_read;
	input [11:0] addr;
	output [31:0] data;
	begin
		@(posedge sys_clk);
		#1;
		tim_psel = 1'b1;
		tim_pwrite = 1'b0;
		tim_paddr = addr;
		tim_penable = 1'b0;

		@(posedge sys_clk);
		#1;
		tim_penable = 1'b1;

		wait(tim_pready == 1'b1);
		#1;
		data = tim_prdata;

		@(posedge sys_clk);
		#1;
		tim_penable = 1'b0;
		tim_psel    = 1'b0;
	end
endtask

task apb_write;
    input [11:0] addr;
    input [31:0] data;
    input [3:0]  strb;
    begin
        
        @(posedge sys_clk);
        #1;
        tim_psel = 1'b1;
        tim_pwrite = 1'b1;
        tim_paddr = addr;
        tim_pwdata = data;
        tim_pstrb = strb;           
        tim_penable = 1'b0;

       
        @(posedge sys_clk);
        #1;
        tim_penable = 1'b1;

       
        wait(tim_pready == 1'b1);

        @(posedge sys_clk);
        #1;        tim_penable = 1'b0;
        tim_psel = 1'b0;
    end
endtask


task apb_write_err;
    input  [11:0] addr;
    input  [31:0] data;
    input  [3:0]  strb;
    output        err;   

    begin
        
        @(posedge sys_clk);
        tim_psel    = 1'b1;
        tim_pwrite  = 1'b1;
        tim_paddr   = addr;
        tim_pwdata  = data;
        tim_pstrb   = strb;
        tim_penable = 1'b0;

       
        @(posedge sys_clk);
        tim_penable = 1'b1;

      
        wait (tim_pready == 1'b1);
        err = tim_pslverr;

       
        @(posedge sys_clk);
        tim_psel    = 1'b0;
        tim_penable = 1'b0;
        tim_pwrite  = 1'b0;
        tim_paddr   = 12'h0;
        tim_pwdata  = 32'h0;
        tim_pstrb   = 4'h0;
    end
endtask


task apb_read_err;
    input  [11:0] addr;
    output [31:0] data;
    output        err;

    begin
        @(posedge sys_clk);
        tim_psel    = 1'b1;
        tim_pwrite  = 1'b0;
        tim_paddr   = addr;
        tim_penable = 1'b0;

        @(posedge sys_clk);
        tim_penable = 1'b1;

        wait (tim_pready == 1'b1);
        data = tim_prdata;
        err  = tim_pslverr; 

        @(posedge sys_clk);
        tim_psel    = 1'b0;
        tim_penable = 1'b0;
        tim_paddr   = 12'h0;
    end
endtask
