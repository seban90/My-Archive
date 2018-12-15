`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/07/10 11:50:23
// Design Name: 
// Module Name: test_mul
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


module test_mul;
function integer clog2;
        input integer value;
        begin
        value = value - 1;
        for (clog2=0;value > 0;clog2=clog2+1)
            value = value >> 1;
        end
   endfunction
   
    reg clk, rst, fast_clk;
    localparam FAST_CLK = 10; 
    localparam CLK = 8*FAST_CLK;
    parameter BITWIDTH = 8;
    
    reg re;
    
    reg [BITWIDTH-1:0] din1, din2;
    wire [BITWIDTH-1:0] dout;
    
    initial begin
        clk = 0; fast_clk = 0; rst = 1;
        #40 rst = 0;
        #200 rst = 1;
    end
    
    always #(CLK/2) clk = ~clk;
    always #(FAST_CLK/2) fast_clk = ~fast_clk;
    
    reg [9:0] r_addr;
    always @ (posedge clk or negedge rst) begin
        if (!rst)
            r_addr <= 10'h3_FF;
        else
            r_addr <= r_addr + 1'b1;
    end
    
    always @ (r_addr) begin
        if (r_addr == 0) begin
            re = 0;
            din1 = 0;
            din2 = 0;
        end
        if (r_addr == 1) begin
            re = 1;
            din1 = 4;
            din2 = 4;
        end
        if (r_addr == 2) begin
            din1 = 4;
            din2 = 5;
        end
        if (r_addr == 3) begin
            //re = 0;
            din1 = 35;
            din2 = 2;
        end
        if (r_addr == 4) begin
            re = 0;
        end
        if (r_addr == 10) begin
            re = 1;
            din1 = 3;
            din2 = 64;
        end
        if (r_addr == 12) begin
            din1 = 13;
            din2 = 14;
        end
        if (r_addr == 13) re = 0;
    end
    wire fclk;
    assign fclk = ~fast_clk;
    wire [clog2(BITWIDTH)+1:0] last_count;
   
    //metronome #(BITWIDTH) m0 (~fast_clk, rst, re, data_in_valid, data_out_valid);
    metronome #(BITWIDTH) m0 (fclk, rst, re, data_in_valid, data_out_valid, last_count);
    multiplier #(BITWIDTH) m1 (fclk, rst, data_in_valid, din1, din2, data_out_valid, last_count, dout);
    
     
endmodule
