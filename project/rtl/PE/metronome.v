`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/07/10 10:57:57
// Design Name: 
// Module Name: metronome
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


module metronome(
        fast_clk, rst, device_data_in_valid, data_in_valid, data_out_valid, last_count
    );
    input fast_clk, rst, device_data_in_valid;
    output data_out_valid,data_in_valid;
    output [clog2(BITWIDTH)+1:0] last_count;
    
    parameter BITWIDTH = 8;
    
    function integer clog2;
        input integer value;
        begin
        value = value - 1;
        for (clog2=0;value > 0;clog2=clog2+1)
            value = value >> 1;
        end
   endfunction
   
    reg [clog2(BITWIDTH)+1:0] count;
    always @ (posedge fast_clk or negedge rst) begin
        if (!rst)
            count <= 0;
        else begin
            if (device_data_in_valid) begin
                if (count == BITWIDTH-1) count <= 0;
                else count <= count + 1'b1;
            end
        end
    end
    assign data_in_valid = device_data_in_valid &&((count == 0) ? 1'b1 : 1'b0);
    assign data_out_valid = (count == (BITWIDTH-1)) ? 1'b1: 1'b0;
    assign last_count = count;
    
     
endmodule
