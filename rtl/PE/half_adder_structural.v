`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/07/13 13:44:07
// Design Name: 
// Module Name: half_adder_sturctural
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


module half_adder_structural(din1, din2, sum, carry);

    input din1, din2;
    output sum, carry;
     
    xor (sum, din1, din2);
    and (carry, din1, din2);
     
endmodule
