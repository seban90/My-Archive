`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/07/10 10:30:54
// Design Name: 
// Module Name: muliplier
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


module multiplier(
    fast_clk, rst, data_in_valid, din1, din2, data_out_valid, last_count, dout
    );
    function integer clog2;
       input integer value;
       
       begin  
          value = value-1;
          for (clog2=0; value>0; clog2=clog2+1)
             value = value>>1;
       end  
       
    endfunction
    parameter BITWIDTH=8;
    input fast_clk, rst, data_in_valid;
    input data_out_valid;
    input [BITWIDTH-1:0] din1, din2;
    input [clog2(BITWIDTH)+1:0] last_count;
    output [2*BITWIDTH-1:0] dout;
    
    //wire [2*BITWIDTH-1:0] tmp_buf[BITWIDTH-1:0];
    
    reg [BITWIDTH-1:0] m_cand, m_lier;
    wire [BITWIDTH-1:0] mul_tmp;//, add_tmp;
    reg [2*BITWIDTH-1:0] out_buf;
    wire [2*BITWIDTH-1:0] tmp;
    //
    wire sel; reg pass;
    reg [clog2(BITWIDTH)-1:0] bit_sel;
    //
    initial pass <= 0;
    
    always @ (din1 or din2) begin
        if (data_in_valid) begin
            m_cand <= din1;
            m_lier <= din2;
        end
    end
    always @ (data_in_valid) begin
        if (data_in_valid)
            pass <= 1;
    end    
    
    assign sel = (data_in_valid)? m_lier[0] : m_lier[last_count];
    assign mul_tmp = (sel) ? m_cand : 0;
    assign tmp = (pass) ? (mul_tmp << BITWIDTH) + out_buf: 0;
     
    always @ (posedge fast_clk or negedge rst) begin
        if (!rst || data_out_valid) out_buf <= 0;
        else out_buf <= {1'b0, tmp[2*BITWIDTH-1:1]}; 
    end
    
    assign dout = (data_out_valid)? out_buf>>1:0;
endmodule
