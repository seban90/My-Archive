`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/07/07 17:55:40
// Design Name: 
// Module Name: filter_top
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


module filter3x3(
    clk, rst, data_in, weight, pad, data_out, ready, data_out_valid
    );
    parameter BITWIDTH = 8;
    input clk, rst, pad;
    input [2*BITWIDTH-1:0] data_in, weight;
    //input [BITWIDTH-1:0] weight;
    
    output ready, data_out_valid;
    output [2*BITWIDTH-1:0] data_out;
endmodule
