`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/07/07 18:43:26
// Design Name: 
// Module Name: test_pe_systolic
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module test_pe_systolic;

    reg clk, rst, fast_clk;
    parameter BITWIDTH = 8;
    
    localparam FAST_CLK = 10; 
    localparam CLK = BITWIDTH*FAST_CLK;
    
    reg[31:0] addr;
    reg in_valid;
    reg[BITWIDTH-1:0] a, b;
    wire [BITWIDTH-1:0] pa, pb;
    wire [2*BITWIDTH-1:0] c;
    wire data_out_valid;
    initial begin
        clk = 0; rst=1; fast_clk=0;
        #20 rst=0;
        #100 rst=1;
    end
    
    always #(CLK/2) clk = ~clk;
    always #(FAST_CLK/2) fast_clk = ~fast_clk;
    
    always @ (posedge clk) begin
        if (!rst)
            addr <= 0;
        else begin
            addr <= addr + 1;
            if (addr == 7)
                $finish;
        end
    end
    
    always @ (addr) begin
        if (addr == 1)
            in_valid = 1;
        else if (addr == 5)
            in_valid = 0;
    end
    
    always @ (addr) begin
        case (addr) 
            0: begin a = 8'd0; b=8'd0; end
            1: begin a = 8'd4; b=8'd1; end
            2: begin a = 8'd1; b=8'd1; end
            3: begin a = 8'd2; b=8'd1; end
            4: begin a = 8'd3; b=8'd1; end
            default: begin a = 8'd0; b=8'd0; end
        endcase
    end
    
    pe_systolic #(BITWIDTH, FAST_CLK) inst0(~fast_clk,clk, rst, a,b, pa, pb, c,in_valid, data_out_valid);
    
endmodule
