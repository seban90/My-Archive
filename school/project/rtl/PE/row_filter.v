`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//         Copyright by Seban Kim, All rights reserved. 
//////////////////////////////////////////////////////////////////////////////////


module row_filter(
    clk, rst, data_in_valid, din1, din2, din3, weight1, weight2, weight3,weight_int, metronome, data_out_valid, last_count, dout
    );
    /*
    row_filter #(BITWIDTH) rf0(
        .clk(), .rst(), 
        .data_in_valid(), 
        .din1(), .din2(), .din3(), 
        .weight1(), .weight2(), .weight3(), 
        .weight_int(),
        .metronome(), 
        .data_out_valid(), 
        .last_count(), 
        .dout()
        );
    */
    function integer clog2;
        input integer value;
            begin
                value = value - 1;
                for (clog2=0;value > 0;clog2=clog2+1)
                    value = value >> 1;
            end
    endfunction
    
    parameter BITWIDTH = 8;
    input clk, rst, data_in_valid;
    input [BITWIDTH-1:0] din1, din2, din3;
    input [BITWIDTH-1:0] weight1, weight2, weight3;
    input weight_int;
    input [clog2(BITWIDTH)+1:0] last_count;
    input metronome;
    
    output data_out_valid;
    output [2*BITWIDTH-1:0] dout;
    
    wire [2*BITWIDTH-1:0] tmp1, tmp2, tmp3; 
    signed_multiplier #(BITWIDTH) inst0(
            .clk(clk), 
            .rst(rst), 
            .data_in_valid(data_in_valid), 
            .a(din1), 
            .b(weight1),
            .weight_int(weight_int),
            .metronome_data_out_valid(metronome),
            .last_count(last_count), 
            .data_out_valid(data_out_valid),
            .dout(tmp1)
    );
    signed_multiplier #(BITWIDTH) inst1(
            .clk(clk), 
            .rst(rst), 
            .data_in_valid(data_in_valid), 
            .a(din2), 
            .b(weight2),
            .weight_int(weight_int),
            .metronome_data_out_valid(metronome),
            .last_count(last_count), 
            .data_out_valid(),
            .dout(tmp2)
    );  
    signed_multiplier #(BITWIDTH) inst2(
            .clk(clk), 
            .rst(rst), 
            .data_in_valid(data_in_valid), 
            .a(din3), 
            .b(weight3),
            .weight_int(weight_int),
            .metronome_data_out_valid(metronome),
            .last_count(last_count), 
            .data_out_valid(),
            .dout(tmp3)
    );
    wire [2*BITWIDTH-1:0] add_tmp; 
    wire [2*BITWIDTH-1:0] add_out;
    n_bit_adder #(2*BITWIDTH) nba0 (tmp1, tmp2, add_tmp,);
    n_bit_adder #(2*BITWIDTH) nba1 (tmp3, add_tmp, add_out,);
    assign dout = add_out; 
endmodule
