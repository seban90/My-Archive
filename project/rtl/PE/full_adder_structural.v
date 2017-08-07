`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 
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
