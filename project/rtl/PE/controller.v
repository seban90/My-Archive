`timescale 1ns / 1ps

`define MOD_TYPE_A 3'b001
`define MOD_TYPE_B 3'b010
`define MOD_TYPE_C 3'b100

module controller(
    clk, rst, mod, bypass_control,ready, 
    weight_in_valid,
    enable, interrupt, bypass_signal, weight_address  
    );
    
    input clk, rst, bypass_control;
    input [2:0] mod;
    input ready, weight_in_valid;
    
    output reg interrupt;
    output reg enable;
    output reg bypass_signal;
    output [3:0] weight_address;
    
    reg mod_reg;
    always @ (posedge clk or negedge rst) begin
        if (!rst) mod_reg <= 0;
        else mod_reg <= mod;
    end
endmodule
