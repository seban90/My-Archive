`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Copyright by Seban Kim, all rights reserved.
//////////////////////////////////////////////////////////////////////////////////


module test_row_filter;
    function integer clog2;
        input integer value;
            begin
                value = value - 1;
                for (clog2=0;value > 0;clog2=clog2+1)
                    value = value >> 1;
            end
    endfunction
    

    reg clk, fast_clk, rst;
    wire fclk;
    localparam BITWIDTH = 8;
    localparam FASTCLK = 10;
    localparam CLK = 2*FASTCLK*BITWIDTH;
    reg [2:0] seq;
    reg [3:0] count;
    reg re;
    reg signed [BITWIDTH-1:0]  d1, d2, d3;
    wire signed [BITWIDTH-1:0]  dd1, dd2, dd3;
    wire [2*BITWIDTH-1:0] dout;
    initial begin
        clk <= 0; fast_clk <= 0; rst <= 1;
        re <= 0;
        #40 rst <= 0;
        #200 rst <= 1;
    end
    
    always #(CLK/2) clk = ~clk;
    always #(FASTCLK/2) fast_clk = ~fast_clk;
    assign fclk = ~fast_clk;
    
    always @ (posedge clk or negedge rst) begin
        if (!rst) seq <= 0;
        else begin
            if (count == 4'hf)
                seq <= seq + 1'b1;
        end
    end
    always @ (posedge clk or negedge rst) begin
        if (!rst) count <= 0;
        else count <= count + 1'b1;
    end
    always @ (seq) begin
        if (seq == 1) re = 1;
        else if (seq == 2) re = 0;
        else if (seq == 4) $finish;
    end
    always @ (count) begin
        case (count)
            0: begin
                d1 <= 4; d2 <= 3; d3 <= -3;
            end 
            1: begin
                d1 <= 2; d2 <= -5; d3 <= -3;
            end
            2: begin
                d1 <= 4; d2 <= 7; d3 <= -3;
            end 
            3: begin
                d1 <= 8; d2 <= 3; d3 <= -3;
            end            
        endcase
    end
    assign dd1 = (re) ? d1 : 0;
    assign dd2 = (re) ? d2 : 0;
    assign dd3 = (re) ? d3 : 0;
    wire [clog2(2*BITWIDTH)+1:0] last_count; 
    reg [clog2(2*BITWIDTH)+1:0] last_count2;
    always @(posedge fclk or negedge rst) begin
        if (!rst) last_count2 <= 0;
        else last_count2 <= last_count;
    end
    metronome_signed #(BITWIDTH) met0(fclk, rst, re, data_in_valid, out_valid, last_count);
    row_filter #(BITWIDTH) rf0(
        .clk(fclk), .rst(rst), 
        .data_in_valid(data_in_valid), 
        .din1(dd1), .din2(dd2), .din3(dd3), 
        .weight1(1), .weight2(2), .weight3(1), 
        .metronome(out_valid), 
        .data_out_valid(data_out_valid), 
        .last_count(last_count2), 
        .dout(dout)
    );
endmodule
