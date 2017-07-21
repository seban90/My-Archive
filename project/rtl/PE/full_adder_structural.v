`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/07/13 13:44:07
// Design Name: 
// Module Name: full_adder_structural
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


module full_adder_structural(din1, din2, cin, sum, cout);
    
    input din1, din2, cin;
    output sum, cout;
    
    wire s_tmp, c_tmp1, c_tmp2;
    
    half_adder_structural ha1(.din1(din1), .din2(din2),.sum(s_tmp),.carry(c_tmp1));
    half_adder_structural ha2(.din1(s_tmp), .din2(cin), .sum(sum), .carry(c_tmp2));
    or (cout, c_tmp1, c_tmp2);
      
endmodule
