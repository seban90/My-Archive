//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2015/01/20 13:15:50
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
    );
    `include "math.v"
    
    localparam PIXEL = 640*480;
    parameter WIDTH = 28;
    parameter HEIGHT = 28;
    input clkMain,rstMain;
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
    
    //wire [clog2(640):0] X;
    //wire [clog2(480):0] Y;
    reg [clog2(WIDTH):0] x;
    reg [clog2(HEIGHT):0] y;
    wire [11:0] crop_pixel;
    wire crop_valid;
    wire [9:0] gray_pixel;
    wire [3:0] gray4;
    wire  gray_valid;
    wire frameValid;
    wire rgb_ice_o;
   (* mark_debug = "true" *)  reg [18:0] waddr, raddr;
   (* mark_debug = "true" *)  wire clk_dcm0;
   (* mark_debug = "true" *)  wire clk25MHz;
   (* mark_debug = "true" *)  wire [11:0]rgb_i,rgb_o;
    (* mark_debug = "true" *) wire [15:0] rgb_buffer;
    (* mark_debug = "true" *) reg [15:0] sync_rgb_buffer;
   (* mark_debug = "true" *)  wire we, re, h_de, v_de;
	reg sync_pixel_ready;
    
    
    assign rgb_i = sync_rgb_buffer[11:0];
    assign we = done && pixelReady_o;

    dcm0 dcm0(clkMain, clk10MHz, clk25MHz);
    
   assign re = h_de && v_de;
   
   //location_track l(.clk(clk), .rst(rst), .data_in_valid(we), .X(), .Y());
   
  crop #(320, 240, 28, 28) c(
           rstMain,
           clk10MHz,//ca_pclk,
           we,
           rgb_i,
           crop_valid,
           crop_pixel
   );
       
  rgb2invgray gray(clk10MHz, crop_pixel, crop_valid, gray_pixel, gray_valid); 
    
   assign gray4 = gray_pixel>>5;
   always@(posedge clk10MHz or negedge rstMain) begin
       if(~rstMain) begin
           x <= 0;
           y <= 0;
       end
       else begin
           if(crop_valid) begin
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
    //////////////////////////////////////////////////////////////
    
    
     dpram ram  (
     
                    .clka(clk10MHz),
                    .wea(gray_valid),
                    .addra(waddr),
		    .ena(gray_valid),
                    .dina({4'b0, gray4, 4'b0}),
                    .douta(),
                    .clkb(clk25MHz),
                    .enb(re),
                    .web(1'b0),
                    .addrb(raddr),
                    .dinb(),
                    .doutb(rgb_o)
   );
   


  
   
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
        waddr = (y+240-14)*640+x+320-14;
    end
    
    /*   
    always @ (posedge ca_pclk or negedge rstMain) begin 
        if (~rstMain) begin
            //waddr <= 19'h7ffff;
            //raddr <= 19'h7ffff;
            waddr <= PIXEL - 4;
    
        end
        else begin
           // if(we) begin
                if (waddr == WIDTH*HEIGHT-1) 
                    waddr <= 0;
                else 
                    //waddr <= waddr + 1'b1 ;
                    waddr <= y*WIDTH+x-4;
          //  end
        end
    end   
   */

    
    //assign test_pixel  = (waddr == PIXEL -1) ? 12'hfff : (waddr == 0) ? 12'hf00 : 0; 
                                   
    

                                       
endmodule
