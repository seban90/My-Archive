`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/07/31 18:17:11
// Design Name: 
// Module Name: test_controller
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


module test_controller;
    reg clk, rst;
    reg [2:0] mod;
    wire [3:0] weight_addr;
    wire process_enable;
    
    initial begin
        clk <= 0; rst <= 1;
        
        #40 rst <= 0;
        #200 rst <= 1;
        #2000 mod = 3'b001;
        #3000 mod = 3'b010;
        #3000 mod = 3'b100;
    end
    
    always #(40) clk <= ~clk;
    
    controller c0(clk, rst, mod, weight_in_valid, weight_addr, process_enable);
endmodule
