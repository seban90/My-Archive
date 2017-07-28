`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//         Copyright by Seban Kim, All rights reserved.    
//////////////////////////////////////////////////////////////////////////////////
`define INIT 1'b0
`define READY 1'b1


module filter2d(
    clk, fclk, rst, 
    data_in_valid, 
    data_in, weight_in, 
    weight_in_valid,
    interrupt,
    data_out, 
    data_out_valid,
    ready,
    request,
    weight_addr
    );
    function integer clog2;
        input integer value;
        begin
            value = value -1;
            for (clog2=0;value >0;clog2=clog2+1)
                value = value >> 1;
        end
    endfunction
    parameter BITWIDTH = 8;
    parameter ROWS = 800;
    parameter COLS = 600;
    input clk, fclk, rst, data_in_valid;
    input [BITWIDTH-1:0] data_in;
    input signed [BITWIDTH-1:0] weight_in;
    input wire weight_in_valid; // set input later.
    input wire interrupt; //set input later
    
    output [BITWIDTH-1:0] data_out;
    output data_out_valid;
    output reg ready; //set output later
    output reg request; //set output later
    output [3:0] weight_addr;
    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    //         Finite State Machine decides filter to process the data............  fetching weight data  
    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    reg state, next_state;
    
    reg signed [BITWIDTH-1:0] weight_reg[0:9];
    
    
    always @ (state or weight_addr or interrupt) begin
        case(state)
        `INIT: begin
            ready <= 0;
            request <= 1;
            if (weight_addr == 8) begin //enough?
                next_state <= `READY;
            end
        end

        `READY: begin
            ready <= 1;
            request <= 0;
            if (interrupt)
                next_state <= `INIT;
        end
        endcase
    end
    always @ (posedge clk or negedge rst) begin
        if (!rst) state <= `INIT;
        else state <= next_state;
    end
    always @(posedge clk) begin
        if (weight_in_valid)
            weight_reg[weight_addr] <= weight_in;
    end
    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    //         Even though this deals with data as signed number, the output value is unsigned charecter    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    reg [BITWIDTH*(COLS-1)-1:0] linebuffer1;
    reg [BITWIDTH*COLS-1:0] linebuffer2;
    reg [BITWIDTH*3-1:0] pixel_buffer;
    
    //TODO:: Make sure linebuffer
    
	always @ (posedge clk or negedge rst) begin
        if (!rst || interrupt) begin
            linebuffer1 <= 0;
            linebuffer2 <= 0;
            pixel_buffer <= 0;
        end
        else if (data_in_valid) begin
            linebuffer1 <= {linebuffer1[BITWIDTH*(COLS-2)-1:0], data_in};
            linebuffer2 <= {linebuffer2[BITWIDTH*(COLS-1)-1:0], linebuffer1[BITWIDTH*(COLS-1)-1:BITWIDTH*(COLS-2)]};
            pixel_buffer <= {pixel_buffer[BITWIDTH*2-1:0], linebuffer2[BITWIDTH*COLS-1:BITWIDTH*(COLS-1)]};
        end
    end
    
    wire [clog2(2*BITWIDTH)+1:0] last_count;
    reg [clog2(2*BITWIDTH)+1:0] last_count2;
    
    metronome_signed #(BITWIDTH) met0(fclk, rst, data_in_valid, metronome_in_valid, metronome_out_valid, last_count);
    always @ (posedge fclk or negedge rst) begin
        if (!rst || interrupt) last_count2 <= 0;
        else last_count2 <= last_count;
    end
    row_filter #(BITWIDTH) rf0(
        .clk(fclk), .rst(rst), 
        .data_in_valid(metronome_in_valid), 
        .din1(data_in), .din2(linebuffer1[0]), .din3(linebuffer), 
        .weight1(), .weight2(), .weight3(), 
        .metronome(), 
        .data_out_valid(), 
        .last_count(), 
        .dout()
    );   
endmodule
