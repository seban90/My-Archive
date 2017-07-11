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
    fast_clk, rst, data_in_valid, din1, din2, data_out_valid, dout
    );
    parameter BITWIDTH=8;
    input fast_clk, rst, data_in_valid;
    input data_out_valid;
    input [BITWIDTH-1:0] din1, din2;
    output [2*BITWIDTH-1:0] dout;
    
    //wire [2*BITWIDTH-1:0] tmp_buf[BITWIDTH-1:0];
    
    reg [BITWIDTH-1:0] m_cand, m_lier;
    wire [BITWIDTH-1:0] mul_tmp, add_tmp;
    reg [2*BITWIDTH-1:0] out_buf;
    wire [2*BITWIDTH-1:0] tmp;

    always @ (din1 or din2) begin
        if (data_in_valid) begin
            m_cand <= din1;
            m_lier <= din2;
        end
    end
    //always @ (posedge fast_clk or negedge rst) begin
    always @ (posedge fast_clk) begin
         m_lier = {1'b0, m_lier[BITWIDTH-1:1]}; 
    end
    assign mul_tmp = (m_lier[0]) ? m_cand:0;
    assign tmp = (mul_tmp << BITWIDTH) + out_buf; 
    always @ (posedge fast_clk or negedge rst) begin
        if (!rst || data_out_valid) out_buf <= 0;
        else out_buf <= {1'b0, tmp[2*BITWIDTH-1:1]}; 
    end
    
    assign dout = (data_out_valid)? out_buf>>1:0;
endmodule
