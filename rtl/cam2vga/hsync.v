////////////////////////////////////////////////////////////////////////////////
// company		: huins
// engineer		: kim nam woo
// create date	:   07/09/04
//
// project name	:  easysoc
// design name	:   easy_vga   
// module name	:   hsync
//
// dependencies	:
//		product 		: EasySoC V1.2
//		synthesis tool 	: altera quartus-ii 7.1
// 		target device	: ep2c50f672c8
//
// description	: easy_vga
//
// additional comments:
// 
////////////////////////////////////////////////////////////////////////////////


module hsync(clk,reset,h_count,fpga_de,fpga_h_sync);
    
    input clk;
    input reset;
    
    output [15:0] h_count;
    output fpga_de;
    output fpga_h_sync;
    
    localparam HD = 640; // horizontal display area
    localparam HF = 48 ; // h. front (left) border
    localparam HB = 16 ; // h. back (right) border
    localparam HR = 96 ; // h. retrace
	
	reg [15:0] h_count;
    reg fpga_de;
    reg fpga_h_sync;
    
        // debug code initial
    initial
    begin
        h_count = 16'd0;
        fpga_h_sync = 1'b1;
        fpga_de = 1'b0;
    end
    
    // process
    always@(posedge clk or posedge reset)
    begin
        // reset
        if(reset)
        begin
            h_count = 16'd0;
            fpga_h_sync = 1'b0;
            fpga_de = 1'b0;
        end
        
//////////////////////////////////////////////////
        // h_sync end
        else if(h_count == (HR+HB+HD+HF-1)) //799
        begin
            h_count = 10'd0;
            fpga_h_sync = 1'b0;
            fpga_de = 1'b0;
        end
        
        // h_sync
        else if(h_count == (HR-1)) //95
        begin
            fpga_h_sync = 1'b1;
            h_count = h_count + 1'b1;
        end

//////////////////////////////////////////////////        
        // h_sync de start
        else if(h_count == (HR+HF-1)) //143
        begin
            fpga_de = 1'b1;
            h_count = h_count + 1'b1;
        end
        
        // h_sync de end
        else if(h_count == HR+HF+HD-1) //143+176 = 319 HR+HF+HD-1
        begin
            fpga_de = 1'b0;
            h_count = h_count + 1'b1;
        end
        
        else
        begin
            h_count = h_count + 1'b1;
        end
        
    end
    
endmodule
