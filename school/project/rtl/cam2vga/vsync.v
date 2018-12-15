////////////////////////////////////////////////////////////////////////////////
// company		: huins
// engineer		: kim nam woo
// create date	:   07/09/04
//
// project name	:  easysoc
// design name	:   easy_vga   
// module name	:   vsync
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


module vsync(clk,reset,v_count,fpga_de,fpga_v_sync);
    
    input clk;
    input reset;
    
    output [15:0] v_count;
    output fpga_de;
    output fpga_v_sync;

     localparam VD = 480; // vertical display area
       localparam VF = 33;  // v. front (top) border
       localparam VB = 10;  // v. back (bottom) border
       localparam VR = 2;   // v. retrace
   
       reg [15:0] v_count;
       reg fpga_de;
       reg fpga_v_sync;
       
       // debug code initial
       initial
       begin
           v_count = 16'd0;
           fpga_de = 1'b0;
           fpga_v_sync = 1'b1;
       end
       
       // process
       always@(posedge clk or posedge reset)
       begin
           // reset
           if(reset)
           begin
               v_count = 16'd0;
               fpga_de = 1'b0;
               fpga_v_sync = 1'b0;
           end
   //////////////////////////////////////////////////////        
           // v_sync end
           else if(v_count == (VR+VB+VD+VF-1))
           begin
               fpga_de = 1'b0;
               fpga_v_sync = 1'b0;
               v_count = 16'd0;
           end
           
           // v_sync
           else if(v_count == (VR-1))
           begin
               fpga_v_sync = 1'b1;
               v_count = v_count + 1'b1;
           end
   //////////////////////////////////////////////////////        
           // v_sync de start
           else if(v_count == (VR+VF-1)) //34
           begin
               fpga_de = 1'b1;
               v_count = v_count + 1'b1;
           end
           
           // v_sync de end
           else if(v_count == VR+VF+VD-1) //514    //34+144 VR+VF+VD-1
           begin
               fpga_de = 1'b0;
               v_count = v_count + 1'b1;
           end
           
           else
           begin
               v_count = v_count + 1'b1;
           end
           
       end
   
       
   endmodule
