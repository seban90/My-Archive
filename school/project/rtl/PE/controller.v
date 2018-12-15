`timescale 1ns / 1ps

`define MOD_TYPE_A 3'b001
`define MOD_TYPE_B 3'b010
`define MOD_TYPE_C 3'b100

`define INITIALIZE  2'b00
`define READY       2'b01
`define DONE        2'b10
/////////////////////////////////////////////////////////////////////////////////////////////////
//
//           Finite State Machine: to control filter, 3 states are required
//      1st - INITIALIZE: set filters and weight registers to 0
//      2nd - READY: make weights registers in filter ready to process; 9cycles required
//      3rd - DONE: Processing enabled
//
/////////////////////////////////////////////////////////////////////////////////////////////////
module controller(clk, rst, mod, weight_in_valid, weight_addr, process_enable);
    input clk, rst;
    input [2:0] mod;
    
    output reg weight_in_valid, process_enable;
    output [3:0] weight_addr;
    
    reg [2:0] mod_reg;
    reg [1:0] state, next_state;
    reg [3:0] count;
    reg init_count;
    always @ (posedge clk) mod_reg <= mod;
    always @ (posedge clk or negedge rst) begin
        if(!rst) state <= `INITIALIZE;
        else state <= next_state;
    end
    
    always @ (state or mod_reg or count or mod) begin
        case(state)
            `INITIALIZE: begin
                if (mod_reg == `MOD_TYPE_A || mod_reg == `MOD_TYPE_B || mod_reg == `MOD_TYPE_C)
                    next_state <= `READY;
                process_enable <= 0;
                weight_in_valid <= 0;
                init_count <= 0;
            end
            `READY: begin
                if (mod != mod_reg) next_state <= `INITIALIZE;
                else begin
                    weight_in_valid <= 1;
                    if (count == 8) begin
                        next_state <= `DONE;
                        init_count <= 1;
                    end
                end
            end
            `DONE: begin
                if (mod != mod_reg) next_state <= `INITIALIZE;
                else begin
                    init_count <= 0;
                    weight_in_valid <= 0;
                    process_enable <= 1;
                end
            end
            default: next_state <= `INITIALIZE;
        endcase
    end
    always @ (posedge clk or negedge rst) begin
        if (!rst || init_count) count <= 0;
        else if (weight_in_valid) count <= count + 1'b1;
    end
    assign weight_addr = count;
    
endmodule
