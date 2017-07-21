`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/07/07 18:10:39
// Design Name: 
// Module Name: pe_systolic
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


module pe_systolic(
    fast_clk,clk, rst, a, b, pass_a, pass_b, c, data_in_valid, data_out_valid
    );
    parameter BITWIDTH = 8;
    parameter FASTCLK = 10; //10ns
    //parameter 
    input fast_clk, data_in_valid;
    input clk;
    input rst;
    input [BITWIDTH-1:0] a, b;
    
    output [2*BITWIDTH-1:0] pass_a, pass_b;
    output [2*BITWIDTH-1:0] c;
    output data_out_valid;
    
    wire [2*BITWIDTH-1:0] mul;
    wire [2*BITWIDTH-1+2:0] sum;
    reg [2*BITWIDTH-1+2:0] sum_reg;
    
    assign pass_a = {8'b0, a};
    assign pass_b = {8'b0, b};
    
    //assign #(2*BITWIDTH*FASTCLK) mul =  a * b;
    assign data_out_valid = mul_out_valid;
    multiplier #(BITWIDTH) pe0(fast_clk, rst, mul_in_valid, a, b, mul_out_valid, mul);
    metronome #(BITWIDTH) met(fast_clk, rst,  data_in_valid, mul_in_valid, mul_out_valid); 
    
    assign sum = (mul_out_valid) ? mul + sum_reg : 0;
            
    always @ (posedge clk or negedge rst) begin
        if (!rst)
            sum_reg <= 0; 
        else begin
            if (mul_out_valid) begin
                sum_reg <= sum;
            end
        end
    end
    
    assign c = sum[2*BITWIDTH-1:0];
    
endmodule
