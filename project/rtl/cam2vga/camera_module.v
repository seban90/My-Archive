`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2015/01/20 12:38:32
// Design Name: 
// Module Name: camera_module
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


module camera_module(
            clkMain, 
            rstMain, 
            ca_pclk, 
            ca_href, 
            ca_vsync,
            ca_data, 
            ca_siod, 
            ca_sioc, 
            ca_xclk,
            ca_pwdn,
            ca_reset,
            data_o,
            pixelReady_o,
            done,
            frameValid
    );
    
    input clkMain,rstMain;
    output ca_xclk;
    output ca_sioc;
    inout ca_siod;
    output ca_pwdn, ca_reset;
    input ca_href, ca_vsync, ca_pclk;
    input [7:0] ca_data;
    output [15:0] data_o;
    output pixelReady_o;
    output done, frameValid;
    
    wire done;
    wire ca_xclk;
    wire ca_reset;
    
    assign ca_reset=rstMain;
    assign ca_xclk=clkMain;
    
    
    RGB565Receive rgbreceive(.d_i(ca_data), .vsync_i(ca_vsync), .href_i(ca_href),
                                .pclk_i(ca_pclk), .rst_i(rstMain),.done(done), .pixelReady_o(pixelReady_o), .pixel_o(data_o),.frameValid(frameValid));
    
       
    CameraSetup set_up (        .clk_i(clkMain), 
                                .rst_i(rstMain), 
                                .done(done),
                                .sioc_o(ca_sioc), 
                                .siod_io(ca_siod)
                       );
    
endmodule
