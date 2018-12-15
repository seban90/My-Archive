`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/08/04 13:44:17
// Design Name: 
// Module Name: top
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


module top(
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
       lcd_r,
       lcd_g,
       lcd_b,
       lcd_hsync,
       lcd_vsync,
       
`ifndef VGA_TEST
       mod,  
       bypass
`endif

    );
    `include "math.v"
    
    //localparam PIXEL = 640*480;
    localparam PIXEL = 320*240;
    parameter WIDTH = 28;
    parameter HEIGHT = 28;
    input clkMain,rstMain;
`ifndef VGA_TEST 
    input [2:0] mod;
    input bypass;
`endif
    output ca_xclk;
    output ca_sioc;
    inout ca_siod;
    input ca_pclk;
    output ca_pwdn;
    output ca_reset;
           
    input ca_href, ca_vsync;
    input [7:0] ca_data;
    output [3:0] lcd_r;
    output [3:0] lcd_g;
    output [3:0] lcd_b;
    output wire      lcd_hsync;
    output wire      lcd_vsync;
    
    wire frameValid;
    
   (* mark_debug = "true" *)  reg [18:0] waddr, raddr;
   (* mark_debug = "true" *)  wire clk25MHz, clk10MHz, clk160MHz;
   (* mark_debug = "true" *)  wire [11:0]rgb_i,rgb_o;
    (* mark_debug = "true" *) wire [15:0] rgb_buffer;
    (* mark_debug = "true" *) reg [15:0] sync_rgb_buffer;
   (* mark_debug = "true" *)  wire we, re, h_de, v_de;
	reg sync_pixel_ready;
    reg [clog2(WIDTH):0] x; 
    wire [clog2(WIDTH):0] filter_x, filter_y;
    
    reg [clog2(HEIGHT):0] y;

    wire [7:0] r, g, b;    
    assign rgb_i = sync_rgb_buffer[11:0];
    assign r = {4'b0, rgb_i[11:8]};
    assign g = {4'b0, rgb_i[7:4]};
    assign b = {4'b0, rgb_i[3:0]};
    
    assign we = done && pixelReady_o; //camera in_valid
    assign re = h_de && v_de;
  
   clock0 clk_manager (clk10MHz, clk160MHz, clk25MHz, clkMain);
    /////////////////////////////////////////////////////////////////
    
    vga_module  vga (   
        clk25MHz,
        rstMain,
        rgb_o,
        lcd_hsync,
        lcd_vsync,
        lcd_r,
        lcd_g,
        lcd_b,
        re,
        h_de, 
        v_de
    );
      
                    
    camera_module camera (  
        .clkMain(clk10MHz), 
        .rstMain(rstMain), 
        .ca_pclk(ca_pclk), 
        .ca_href(ca_href), 
        .ca_vsync(ca_vsync),
        .ca_data(ca_data), 
        .ca_siod(ca_siod), 
        .ca_sioc(ca_sioc), 
        .ca_xclk(ca_xclk),
        .ca_pwdn(ca_pwdn),
        .ca_reset(ca_reset),
        .data_o(rgb_buffer),
        .pixelReady_o(pixelReady_o),
        .done(done),
        .frameValid(frameValid)
    );
                    
    always@(posedge clk10MHz or negedge rstMain) begin
	if(~rstMain) begin
		sync_pixel_ready <= 0;
	end else begin
		sync_pixel_ready <= pixelReady_o;
		sync_rgb_buffer <= rgb_buffer;
	end
    end
    wire data_in_valid, data_out_valid;
    assign data_in_valid = (bypass)? we:data_out_valid;
    assign data_out_valid = (x >= 2 && y >= 2) ? 1 : 0;
    wire [11:0] feed_in_data;
    assign feed_in_data = (bypass)? rgb_i: {filter_data_out[19:16],filter_data_out[11:8],filter_data_out[3:0]};
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    wire [23:0] filter_data_out;
    reg [23:0] sync_filter_data_out;
    image_filter #(.BITWIDTH(8),.COLS(320),.ROWS(240)) Image_fiter (
        .clk(clk10MHz), 
        .fclk(clk160MHz), 
        .rst(rstMain), 
        .data_in_valid(data_in_valid), 
        .mod(mod), 
        .data_in({r,g,b}), 
        .data_out_valid(filter_out_valid), 
        .process_enable(), 
        .data_out(filter_data_out),
        .x(filter_x),
        .y(filter_y));
    always @ (filter_out_valid) begin
        if (filter_out_valid) sync_filter_data_out <= filter_data_out;
    end
    always @ (posedge clk10MHz or negedge rstMain) begin
        if (!rstMain) begin
            x <= 0; y <= 0;
        end else begin
            x <= filter_x; y <= filter_y;
        end
    end
    always @ (posedge clk10MHz or negedge rstMain) begin
    end
//TODO: Figure out the way gives address to memory deployed not enough to settle pixel.
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
     RAM ram  (
        .clka(clk10MHz),
        .wea(data_in_valid),
        .addra(waddr),
        .ena(1),
        .dina(feed_in_data),
        .douta(),
        .clkb(clk25MHz),
        .enb(re),
        .web(1'b0),
        .addrb(raddr),
        .dinb(),
        .doutb(rgb_o)
   );
   /*
    always@(posedge clk10MHz or negedge rstMain) begin
        if(~rstMain) begin
            x <= 0;
            y <= 0;
        end
        else begin
        if(we) begin
            if(x==WIDTH-1) begin
                x <= 0;
            if(y==HEIGHT-1)
                y <= 0;
            else
                y <= y + 1;
            end else 
                x <= x + 1;                
            end 
        end
    end
    */
    
  
   
    always @ (posedge clk25MHz or negedge rstMain) begin 
        if (~rstMain) begin
            //waddr <= 19'h7ffff;
            raddr <= 3;//PIXEL-4;
            //raddr <= 0;
        end
        else begin
           
            if (re) begin    
                if (raddr == PIXEL-1)
                    raddr <= 0;
                else
                    raddr <= raddr + 1'b1 ;
  
              end
       end
    end
  
    
    always@(*) begin
        //waddr = (y+240-14)*640+x+320-14;
        waddr = (y+240-120)*640+x+320-160;
        //waddr = y*640+x;
    end
    
                                       
endmodule
