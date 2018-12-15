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
    input [3*BITWIDTH-1:0] data_in;
    input [2:0] mod;
    output data_out_valid, process_enable;
    output [3*BITWIDTH-1:0] data_out;
    output [clog2(COLS):0] x;
    output [clog2(ROWS):0] y;
    wire [3:0] weight_addr;
    wire [BITWIDTH-1:0] data_r, data_g, data_b;
    wire [BITWIDTH-1:0] data_r_out, data_g_out, data_b_out;
    
    reg [BITWIDTH:0] weight_a[0:8], weight_b[0:8], weight_c[0:8];
    wire [BITWIDTH:0] a, b, c, weight;
    wire weight_in_valid;
    initial begin
        //3x3 gaussian filter
        weight_a[0] <= 9'h010;  weight_a[1] <= 9'h020; weight_a[2] <= 9'h010;
        weight_a[3] <= 9'h020;  weight_a[4] <= 9'h040; weight_a[5] <= 9'h020;
        weight_a[6] <= 9'h010;  weight_a[7] <= 9'h020; weight_a[8] <= 9'h010;     
        // 3x3 - Sharpness filter
        weight_b[0] <= 9'h0e4;  weight_b[1] <= 9'h0e4; weight_b[2] <= 9'h0e4;
        weight_b[3] <= 9'h0e4;  weight_b[4] <= 9'h100; weight_b[5] <= 9'h0e4;
        weight_b[6] <= 9'h0e4;  weight_b[7] <= 9'h0e4; weight_b[8] <= 9'h0e4;
        // 3x3 - Laplacian filter - Edge detect
        weight_c[0] <= 9'h0e0;  weight_c[1] <= 9'h0e0; weight_c[2] <= 9'h0e0;
        weight_c[3] <= 9'h0e0;  weight_c[4] <= 9'h100; weight_c[5] <= 9'h0e0;
        weight_c[6] <= 9'h0e0;  weight_c[7] <= 9'h0e0; weight_c[8] <= 9'h0e0;
        
    end
    
    assign a = weight_a[weight_addr];
    assign b = weight_b[weight_addr];
    assign c = weight_c[weight_addr];
    assign data_r = data_in[3*BITWIDTH-1:2*BITWIDTH];
    assign data_g = data_in[2*BITWIDTH-1:BITWIDTH];
    assign data_b = data_in[BITWIDTH-1:0];
    
    assign weight =  (mod == 3'b001) ? a : (mod == 3'b010)? b: (mod == 3'b100) ?  c:0;
    
    //wire [clog2(COLS):0] g_x, b_x;
    //w/ire [clog2(ROWS):0] g_y, b_y;
    
    controller control(clk, rst, mod, weight_in_valid, weight_addr, process_enable);
    filter2d #(.BITWIDTH(BITWIDTH),.COLS(COLS),.ROWS(ROWS)) inst_r(
            .clk(clk), 
            .fclk(fclk), 
            .rst(rst), 
            .process_enable(process_enable),
            .data_in_valid(data_in_valid),
            .weight_in_valid(weight_in_valid),
            .data_in(data_r),
            .weight_addr(weight_addr),
            .weight_data(weight[BITWIDTH-1:0]),
            .int(weight[BITWIDTH]),
            .data_out(data_r_out),
            .data_out_valid(data_out_valid),
            .cols(x),
            .rows(y)
        );
    filter2d #(.BITWIDTH(BITWIDTH),.COLS(COLS),.ROWS(ROWS)) inst_g(
            .clk(clk), 
            .fclk(fclk), 
            .rst(rst), 
            .process_enable(process_enable),
            .data_in_valid(data_in_valid),
            .weight_in_valid(weight_in_valid),
            .data_in(data_g),
            .weight_addr(weight_addr),
            .weight_data(weight[BITWIDTH-1:0]),
            .int(weight[BITWIDTH]),
            .data_out(data_g_out),
            .data_out_valid(),
            .cols(),
            .rows()
            );
    filter2d #(.BITWIDTH(BITWIDTH),.COLS(COLS),.ROWS(ROWS)) inst_b(
            .clk(clk), 
            .fclk(fclk), 
            .rst(rst), 
            .process_enable(process_enable),
            .data_in_valid(data_in_valid),
            .weight_in_valid(weight_in_valid),
            .data_in(data_b),
            .weight_addr(weight_addr),
            .weight_data(weight[BITWIDTH-1:0]),
            .int(weight[BITWIDTH]),
            .data_out(data_b_out),
            .data_out_valid(),
            .cols(),
            .rows()
    );
    assign data_out = {data_r_out, data_g_out, data_b_out};
endmodule
