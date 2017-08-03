`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//          Copyright by Seban Kim
//////////////////////////////////////////////////////////////////////////////////

module image_filter(clk, fclk, rst, data_in_valid, mod, data_in, data_out_valid, process_enable, data_out,x,y);
/*
image_filter #(.BITWIDTH(BITWIDTH),.COLS(COLS),.ROWS(ROWS)) Image_fiter (
    .clk(), 
    .fclk(), 
    .rst(), 
    .data_in_valid(), 
    .mod(), 
    .data_in(), 
    .data_out_valid(), 
    .process_enable(), 
    .data_out(),
    .x(),
    .y());
*/
    parameter BITWIDTH = 8;
    parameter COLS = 640;
    parameter ROWS = 480;
    
    function integer clog2;
                input integer value;
                begin
                    value = value - 1;
                    for (clog2=0;value>0;clog2=clog2+1)
                        value = value >> 1;
                end
    endfunction
            
    input clk, fclk, rst, data_in_valid;
    input [BITWIDTH-1:0] data_in;
    input [2:0] mod;
    output data_out_valid, process_enable;
    output [BITWIDTH-1:0] data_out;
    output [clog2(COLS):0] x;
    output [clog2(ROWS):0] y;
    wire [3:0] weight_addr;
    reg [BITWIDTH-1:0] weight_a[0:8], weight_b[0:8], weight_c[0:8];
    wire [BITWIDTH-1:0] a, b, c, weight;
    wire weight_in_valid;
    initial begin
        //3x3 gaussian filter
        weight_a[0] <= 8'h10;  weight_a[1] <= 8'h20; weight_a[2] <= 8'h10;
        weight_a[3] <= 8'h20;  weight_a[4] <= 8'h40; weight_a[5] <= 8'h20;
        weight_a[6] <= 8'h10;  weight_a[7] <= 8'h20; weight_a[8] <= 8'h10;     
        // 3x3 - not defined yet
        weight_b[0] <= 8'h10;  weight_b[1] <= 8'h20; weight_b[2] <= 8'h10;
        weight_b[3] <= 8'h20;  weight_b[4] <= 8'h40; weight_b[5] <= 8'h20;
        weight_b[6] <= 8'h10;  weight_b[7] <= 8'h20; weight_b[8] <= 8'h10;
        // 3x3 - not defined yet
        weight_c[0] <= 8'h10;  weight_c[1] <= 8'h20; weight_c[2] <= 8'h10;
        weight_c[3] <= 8'h20;  weight_c[4] <= 8'h40; weight_c[5] <= 8'h20;
        weight_c[6] <= 8'h10;  weight_c[7] <= 8'h20; weight_c[8] <= 8'h10;
        
    end
    
    assign a = weight_a[weight_addr];
    assign b = weight_b[weight_addr];
    assign c = weight_c[weight_addr];
    
    assign weight =  (mod == 3'b001) ? a : (mod == 3'b010)? b: (mod == 3'b100) ?  c:0;
    
    controller control(clk, rst, mod, weight_in_valid, weight_addr, process_enable);
    filter2d #(.BITWIDTH(BITWIDTH),.COLS(COLS),.ROWS(ROWS)) inst(
            .clk(clk), 
            .fclk(fclk), 
            .rst(rst), 
            .process_enable(process_enable),
            .data_in_valid(data_in_valid),
            .weight_in_valid(weight_in_valid),
            .data_in(data_in),
            .weight_addr(weight_addr),
            .weight_data(weight),
            .data_out(data_out),
            .data_out_valid(data_out_valid),
            .cols(x),
            .rows(y)
        );
endmodule
