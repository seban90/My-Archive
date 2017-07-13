`define INIT 1'b0
`define READY 1'b1

//////////////////////////////////////////////////////////////////////////////////////////////////////////
//           This filter unrolls pixels to process convolution.
//           Seban Kim, SoC lab
//////////////////////////////////////////////////////////////////////////////////////////////////////////

module filter3x3(clk, fast_clk, rst, data_in_valid, din, weight_in_valid, weight, weight_addr, dout, dout_valid, ready);

	parameter BITWIDTH = 8;
	parameter ROWS = 480;
	parameter COLS = 640;
	input clk, fast_clk, rst, data_in_valid, weight_in_valid;
	input [BITWIDTH-1:0] din, weight;
	input [3:0] weight_addr;
	
	output [BITWIDTH-1:0] dout;
	output dout_valid;
	output reg ready;
	
	reg [BITWIDTH-1:0] weight_register[0:9];
	reg  state, next_state;
	reg [BITWIDTH*COLS-1:0] linebuffer1, linebuffer2;
    reg [BITWIDTH*3-1:0] pixel_buffer;
    wire [BITWIDTH-1:0] weight1, weight2, weight3, weight4, weight5, weight6, weight7, weight8, weight9;
    wire [2*BITWIDTH-1:0] mul1, mul2, mul3, mul4, mul5, mul6, mul7, mul8, mul9;
    wire [BITWIDTH:0] add1, add2, add3, add4;
    wire [BITWIDTH+1:0] add5, add6;
    wire [BITWIDTH+2:0] add7;
    wire [BITWIDTH+3:0] add8;
	always @ (posedge clk) begin
	   if (weight_in_valid)
	       weight_register[weight_addr] <= weight;
	end
	
	always @ (state) begin
	   case (state)
	       `INIT: begin
	           ready <= 0;
	           if (weight_addr == 10)
	               next_state <= `READY;
	       end
	       `READY: begin
	           ready  <= 1'b1;
	           if (weight_addr == 10)
	               next_state <= `READY;
	           else next_state <= `INIT;
	       end 
	   endcase
	end
    
    
	always @ (posedge clk or negedge rst) begin
		if (!rst)
			state <= `INIT;
		else
			state <= next_state;
	end
	
	//Line-buffer 3x3 filter needs 2 line-buffers
	always @ (posedge clk or negedge rst) begin
		if (!rst) begin
			linebuffer1 <= 0;
			linebuffer2 <= 0;
			pixel_buffer <= 0;
		end
		else if (data_in_valid) begin
			linebuffer1 <= {linebuffer1[BITWIDTH*(COLS-1)-1:0], din};
			linebuffer2 <= {linebuffer2[BITWIDTH*(COLS-1)-1:0], linebuffer1[BITWIDTH*COLS-1:BITWIDTH*(COLS-1)]};
			pixel_buffer <= {pixel_buffer[BITWIDTH*2-1:0], linebuffer2[BITWIDTH*COLS-1:BITWIDTH*(COLS-1)]};
		end
	end
	
	
	
	
	assign weight1 = weight_register[8]; assign weight2 = weight_register[7];assign weight3 = weight_register[6];	
	assign weight4 = weight_register[5]; assign weight5 = weight_register[4];assign weight6 = weight_register[3];
	assign weight7 = weight_register[2]; assign weight8 = weight_register[1];assign weight9 = weight_register[0];
	
	metronome #(BITWIDTH) met (
            .fast_clk(fast_clk), 
            .rst(rst), 
            .device_data_in_valid(ready), 
            .data_in_valid(metronome_in_valid), 
            .data_out_valid(metronome_out_valid)
        );
    
	multiplier MUL0(.fast_clk(fast_clk),.rst(rst),.data_in_valid(metronome_in_valid), .din1(din), .din2(weight1), .data_out_valid(metronome_out_valid), .dout(mul1));
	multiplier MUL1(.fast_clk(fast_clk),.rst(rst),.data_in_valid(metronome_in_valid), .din1(linebuffer1[2*BITWIDTH-1:BITWIDTH]), .din2(weight2), .data_out_valid(metronome_out_valid), .dout(mul2));
	multiplier MUL2(.fast_clk(fast_clk),.rst(rst),.data_in_valid(metronome_in_valid), .din1(linebuffer1[3*BITWIDTH-1:2*BITWIDTH]), .din2(weight3), .data_out_valid(metronome_out_valid), .dout(mul3));
	multiplier MUL3(.fast_clk(fast_clk),.rst(rst),.data_in_valid(metronome_in_valid), .din1(linebuffer2[BITWIDTH-1:0]), .din2(weight4), .data_out_valid(metronome_out_valid), .dout(mul4));
	multiplier MUL4(.fast_clk(fast_clk),.rst(rst),.data_in_valid(metronome_in_valid), .din1(linebuffer2[2*BITWIDTH-1:BITWIDTH]), .din2(weight5), .data_out_valid(metronome_out_valid), .dout(mul5));
	multiplier MUL5(.fast_clk(fast_clk),.rst(rst),.data_in_valid(metronome_in_valid), .din1(linebuffer2[3*BITWIDTH-1:2*BITWIDTH]), .din2(weight6), .data_out_valid(metronome_out_valid), .dout(mul6));
	multiplier MUL6(.fast_clk(fast_clk),.rst(rst),.data_in_valid(metronome_in_valid), .din1(pixel_buffer[BITWIDTH-1:0]), .din2(weight7), .data_out_valid(metronome_out_valid), .dout(mul7));
	multiplier MUL7(.fast_clk(fast_clk),.rst(rst),.data_in_valid(metronome_in_valid), .din1(pixel_buffer[2*BITWIDTH-1:BITWIDTH]), .din2(weight8), .data_out_valid(metronome_out_valid), .dout(mul8));
	multiplier MUL8(.fast_clk(fast_clk),.rst(rst),.data_in_valid(metronome_in_valid), .din1(pixel_buffer[3*BITWIDTH-1:2*BITWIDTH]), .din2(weight9), .data_out_valid(metronome_out_valid), .dout(mul9));
	
	n_bit_adder #(BITWIDTH+1) n1(.din1(mul1[2*BITWIDTH-1:BITWIDTH]), .din2(mul2[2*BITWIDTH-1:BITWIDTH]), .dout(add1[BITWIDTH-1:0]), .carry(add1[BITWIDTH]));
	n_bit_adder #(BITWIDTH+1) n2(.din1(mul3[2*BITWIDTH-1:BITWIDTH]), .din2(mul4[2*BITWIDTH-1:BITWIDTH]), .dout(add2[BITWIDTH-1:0]), .carry(add2[BITWIDTH]));
	n_bit_adder #(BITWIDTH+1) n3(.din1(mul5[2*BITWIDTH-1:BITWIDTH]), .din2(mul6[2*BITWIDTH-1:BITWIDTH]), .dout(add3[BITWIDTH-1:0]), .carry(add3[BITWIDTH]));
	n_bit_adder #(BITWIDTH+1) n4(.din1(mul7[2*BITWIDTH-1:BITWIDTH]), .din2(mul8[2*BITWIDTH-1:BITWIDTH]), .dout(add4[BITWIDTH-1:0]), .carry(add4[BITWIDTH]));
	n_bit_adder #(BITWIDTH+2) n5(.din1(add1), .din2(add2), .dout(add5[BITWIDTH:0]), .carry(add5[BITWIDTH+1]));
	n_bit_adder #(BITWIDTH+2) n6(.din1(add3), .din2(add4), .dout(add6[BITWIDTH:0]), .carry(add6[BITWIDTH+1]));
	n_bit_adder #(BITWIDTH+3) n7(.din1(add5), .din2(add6), .dout(add7[BITWIDTH+1:0]), .carry(add7[BITWIDTH+2]));
	n_bit_adder #(BITWIDTH+4) n8(.din1(add7), .din2(mul9[2*BITWIDTH-1:0]), .dout(add8[BITWIDTH+2:0]), .carry(add7[BITWIDTH+3]));
	
	assign dout_valid = metronome_out_valid;
	assign dout = (add8[BITWIDTH+3:BITWIDTH] > 0) ? (2<<BITWIDTH)-1:add8[BITWIDTH-1:0];
	
endmodule