`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/07/13 13:44:07
// Design Name: 
// Module Name: n_bit_adder
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


module n_bit_adder(din1, din2, dout, carry);

    parameter BITWIDTH = 8;
    input [BITWIDTH-1:0] din1, din2;
    output [BITWIDTH-1:0] dout;
    output carry;
    
    wire [BITWIDTH-1:0] carry_tmp;
    
    genvar i;
    generate
        for (i=0;i<BITWIDTH;i=i+1)begin : N_BIT_ADDER
            if (i == 0)
                full_adder_structural FA(.din1(din1[i]), .din2(din2[i]), .cin(0), .sum(dout[i]), .cout(carry_tmp[i]));
            else
                full_adder_structural FA(.din1(din1[i]), .din2(din2[i]), .cin(carry_tmp[i-1]), .sum(dout[i]), .cout(carry_tmp[i]));
        end
    endgenerate
    assign carry = carry_tmp[BITWIDTH-1];
    
endmodule
