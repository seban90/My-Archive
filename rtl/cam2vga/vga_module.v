////////////////////////////////////////////////////////////////////////////////
// company		: INU
// engineer		: Kim se ban
// create date	: 15/01/08
//
// project name	:  VGA
// design name	:  VGA
// module name	:  VGA
//
// dependencies	:
//		product 		: EasyFPGA-COMBO2 Rev2.1
//		synthesis tool 	: altera quartus-ii 7.2
// 		target device	: ep2c50f672c8
//
// description	: easy_vga
//
// additional comments:
// 
////////////////////////////////////////////////////////////////////////////////

module vga_module (	    clk,
					   reset_button,
					   data_in,
					   lcd_hsync,
					   lcd_vsync,
					   lcd_r,
					   lcd_g,
					   lcd_b,
					   re,
					   h_de, 
					   v_de,
					   					
);
    

	input                      clk, reset_button;
	input  [11:0]              data_in;
	input                       re;
	output                     lcd_hsync, lcd_vsync;
	output [3:0]               lcd_r, lcd_g, lcd_b;
	output                     h_de, v_de;
    
    		
	wire reset;
	wire h_de, v_de;	   				 // horizental and vertical debug signal
	
	wire [3:0] r, g, b;

	wire [11:0] data_in, data_out; 
	//wire [11:0] data_out_buffer;
    wire re;
	

	assign reset = ~reset_button;
	
	

	assign r = data_out[11:8];
	assign g = data_out[7:4];
	assign b = data_out[3:0];
	assign lcd_r = r;
	assign lcd_g = g;
	assign lcd_b = b;

	hsync h1(clk,reset,h_count,h_de,lcd_hsync);
	vsync v1(lcd_hsync,reset,v_count,v_de,lcd_vsync);
	
	
	  
	assign data_out = (re)? data_in : 0; 	//3 - state buffer		
	  
endmodule

