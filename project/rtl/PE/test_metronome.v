`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/07/10 11:12:01
// Design Name: 
// Module Name: test_metronome
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


module test_metronome;

    reg clk, rst;
    reg device_in_valid;
    
    reg [7:0] count;
    reg [2:0] sim_count;
    
    initial begin
        clk <= 0;
        rst <= 1;
        device_in_valid <= 0;
        
        #10 rst = 0;
        #50 rst = 1;
        
    end
    always #20 clk = ~clk; 
    always @ (posedge clk or negedge rst) begin
        if (!rst)
            count <= 8'hFF;
        else
            count <= count + 1'b1;
    end
    always @ (posedge clk or negedge rst) begin
        if (!rst)
            sim_count <=3'b111;
        else begin
            if (count == 100)
                sim_count = sim_count + 1'b1;
        end
    end
    always @ (sim_count) begin
        if (sim_count == 1)
            device_in_valid = 1;
        else if (sim_count == 4)
            device_in_valid = 0;
        else if (sim_count == 5)
            $finish;
    end
    metronome #(8) m0(clk, rst, device_in_valid, data_in_valid, data_out_valid);
    
endmodule
