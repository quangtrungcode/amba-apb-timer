





task run_test;
    reg [31:0] read_data;
    integer error_count;
    
    
    localparam ADDR_TCR  = 12'h000;
    localparam ADDR_TDR0 = 12'h004;
    localparam ADDR_CMP0 = 12'h00C; 
    localparam ADDR_TIER = 12'h014;
    localparam ADDR_TISR = 12'h018;

    
    
    localparam RST_VAL_TCR  = 32'h0000_0100;
    localparam RST_VAL_TDR0 = 32'h0000_0000;
    
    
    localparam RST_VAL_CMP0 = 32'hFFFF_FFFF; 
    
    localparam RST_VAL_TIER = 32'h0000_0000;
    localparam RST_VAL_TISR = 32'h0000_0000;

    begin
        error_count = 0;
        
        $display("\n=======================================================");
        $display("[%0t] [TEST START] PATTERN: reg_rst_chk", $time);
        $display("=======================================================");

        
        wait (sys_rst_n == 1'b1);
        @(posedge sys_clk);

        $display("\n[%0t] [CASE 47] Checking Register Reset Behavior", $time);
        
        
        
        
        $display("[%0t] Step 1: Setting timer to work normally...", $time);
        
        apb_write(ADDR_CMP0, 32'h0000_00FF, 4'b1111); 
        apb_write(ADDR_TIER, 32'h0000_0001, 4'b1111); 
        
        
        apb_write(ADDR_TCR, 32'h0000_0003, 4'b1111);  
        
        
        repeat (256) @(posedge sys_clk); 
        
        
        
        
        $display("[%0t] Step 2: Asserting Hardware Reset (sys_rst_n = 0)...", $time);
        
        sys_rst_n = 1'b0; 
        repeat(5) @(posedge sys_clk); 
        sys_rst_n = 1'b1; 
        @(posedge sys_clk);
        
        
        
        
        $display("[%0t] Step 3: Checking initial values...", $time);
        
        
        apb_read(ADDR_TCR, read_data);
        if (read_data !== RST_VAL_TCR) begin 
            $display("[%0t] [FAIL] TCR initial value wrong. Exp %h | Act %h", $time, RST_VAL_TCR, read_data); 
            error_count = error_count + 1; 
        end else $display("[%0t] [PASS] TCR reset correctly.", $time);
        
        
        apb_read(ADDR_TDR0, read_data);
        if (read_data !== RST_VAL_TDR0) begin 
            $display("[%0t] [FAIL] TDR0 initial value wrong. Exp %h | Act %h", $time, RST_VAL_TDR0, read_data); 
            error_count = error_count + 1; 
        end else $display("[%0t] [PASS] TDR0 reset correctly.", $time);
        
        
        apb_read(ADDR_CMP0, read_data);
        if (read_data !== RST_VAL_CMP0) begin 
            $display("[%0t] [FAIL] CMP0 initial value wrong. Exp %h | Act %h", $time, RST_VAL_CMP0, read_data); 
            error_count = error_count + 1; 
        end else $display("[%0t] [PASS] CMP0 reset correctly.", $time);
        
        
        apb_read(ADDR_TIER, read_data);
        if (read_data !== RST_VAL_TIER) begin 
            $display("[%0t] [FAIL] TIER initial value wrong. Exp %h | Act %h", $time, RST_VAL_TIER, read_data); 
            error_count = error_count + 1; 
        end else $display("[%0t] [PASS] TIER reset correctly.", $time);
        
        
        apb_read(ADDR_TISR, read_data);
        if (read_data !== RST_VAL_TISR) begin 
            $display("[%0t] [FAIL] TISR initial value wrong. Exp %h | Act %h", $time, RST_VAL_TISR, read_data); 
            error_count = error_count + 1; 
        end else $display("[%0t] [PASS] TISR reset correctly.", $time);

        
        
        
        $display("\n=======================================================");
        if (error_count == 0) begin
            $display("[%0t] [TEST SUMMARY] PATTERN: reg_rst_chk ---> PASSED", $time);
        end else begin
            $display("[%0t] [TEST SUMMARY] PATTERN: reg_rst_chk ---> FAILED (Total errors: %0d)", $time, error_count);
        end
        $display("=======================================================\n");
    end
endtask
