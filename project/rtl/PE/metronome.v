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
        fast_clk, rst, device_data_in_valid, data_in_valid, data_out_valid
    );
    input fast_clk, rst, device_data_in_valid;
    output data_out_valid,data_in_valid;
    
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
        if (!rst) begin
            //count <= 2^(1<<BITWIDTH); //Test and modify to meet timing
            count <= 0;
        end
        else begin
            if (device_data_in_valid) begin
                count <= count + 1'b1;
                if (count == BITWIDTH-1) //Test and modify to meet timing
                //if (count == BITWIDTH) //Test and modify to meet timing
                    count <= 0;
            end
        end
    end
    assign data_in_valid = device_data_in_valid &&((count == 0) ? 1'b1 : 1'b0);
    assign data_out_valid = (count == (BITWIDTH-1)) ? 1'b1: 1'b0;
    //assign data_out_valid = count == 0;
     
endmodule
