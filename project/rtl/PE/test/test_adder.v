`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/07/13 14:06:51
// Design Name: 
// Module Name: test_adder
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


module test_adder;
    parameter bitwidth = 8;
    reg [bitwidth-1:0] a, b;
    reg signed [bitwidth:0] sa, sb; 
    wire [bitwidth:0] data;
    wire signed [bitwidth:0] sdata;
    initial begin
        a <= 0;
        b <= 0;
        #100 a <= 4; b <= 10;
        #100 a <= 20; b <= 2;
        #100 a <= 6; b<= 8;
        #100 a <= 200; b <= 34; 
        #100 sa<= -3; sb <= -4;
        #100 sa<= -3; sb <= 4;
        #100 sa<= 3; sb <= -4;
        #100 sa<= 3; sb <= 4;
        #100 sa<= 127; sb <= -255;
        #100 sa<= 38; sb <= -124;
        
    end
    n_bit_adder #(bitwidth) adder(.din1(a), .din2(b), .dout(data[bitwidth-1:0]), .carry(data[bitwidth]));
    n_bit_adder #(bitwidth+1) adder2(.din1(sa), .din2(sb), .dout(sdata), .carry());
     
endmodule
