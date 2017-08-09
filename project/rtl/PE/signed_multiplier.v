`timescale 1ns / 1ps

module mul(din, m, dout);
    parameter bitwidth = 4;
    input signed [bitwidth-1:0] din;
    input m;
    output signed [bitwidth-1:0] dout;
    genvar i;
    generate
        for (i=0;i<bitwidth;i=i+1) begin: MUL_AND
            if (i == bitwidth-1) nand na(dout[i], din[i], m);
            else and ad(dout[i], din[i], m); 
        end
    endgenerate 
endmodule

module signed_multiplier(
	clk, rst, data_in_valid, 
	a, b,
	weight_int,
	metronome_data_out_valid,
	last_count, 
	data_out_valid,
	dout
	);
	/*
	signed_multiplier #(BITWIDTH) inst0(
		.clk(), 
		.rst(), 
		.data_in_valid(), 
		.a(), 
		.b(),
		.weight_int(),
		.metronome_data_out_valid(),
		.last_count(), 
		.data_out_valid(),
		.dout()
	);
	
	*/
	function integer clog2;
		input integer value;
		begin
			value = value-1;
			for (clog2=0;value>0;clog2=clog2+1)
				value = value >> 1;
		end
	endfunction
	
	parameter BITWIDTH = 8;
	input clk, rst, data_in_valid;
	input signed [BITWIDTH-1:0] a;
	input signed [BITWIDTH-1:0] b;
	input weight_int;
	input [clog2(BITWIDTH)+1:0] last_count;
	input metronome_data_out_valid;
	
	output reg data_out_valid;
	output [2*BITWIDTH-1:0] dout;
	
	reg pass;
	reg [BITWIDTH-1:0] a_reg, b_reg;
	reg [BITWIDTH-1:0] a_reg_reg;
	wire [BITWIDTH-1:0] mul; 

	initial pass <= 0;

	always @ (posedge clk) begin
		if (data_in_valid) pass <= 1;
	end
	
	always @ (posedge clk or negedge rst) begin
		if (!rst) begin
			a_reg <= 0;
			b_reg <= 0;
		end else begin
			if (data_in_valid) begin
				a_reg <= a;
				b_reg <= b;
			end
		end
	end
	always @ (posedge clk or negedge rst) begin
	   if (!rst) a_reg_reg <= 0;
	   else a_reg_reg <= a_reg;
	end
	wire [BITWIDTH:0] add_tmp;
	//reg [3*BITWIDTH-1:0] add_shift_reg;
	reg [3*BITWIDTH-1:0] add_shift_reg;
	wire [3*BITWIDTH-1:0] add_shift_reg_tmp;
	wire sel;
	wire [BITWIDTH-1:0] in2;
	assign in2 = add_shift_reg[3*BITWIDTH-1:2*BITWIDTH];
	assign sel = (last_count >= BITWIDTH) ? b_reg[BITWIDTH-1]:b_reg[last_count];
	mul #(BITWIDTH) m0(.din(a_reg), .m(sel), .dout(mul));
	n_bit_adder #(BITWIDTH) adder(.din1(mul),.din2(in2),.dout(add_tmp[BITWIDTH-1:0]), .carry(add_tmp[BITWIDTH]));
	
	assign add_shift_reg_tmp = {add_tmp, add_shift_reg[2*BITWIDTH-1:1]};
	always @ (posedge clk or negedge rst) begin
	   if (!rst || data_out_valid) add_shift_reg <= 1 << (3*BITWIDTH-1);
	   else if (pass) begin
	       //add_shift_reg <= {1'b0, add_tmp, add_shift_reg[2*BITWIDTH-2:1]};
	       add_shift_reg <= add_shift_reg_tmp;
	   end
	end
	always @ (posedge clk or negedge rst) begin
            if (!rst) data_out_valid <= 0;
            else data_out_valid <= metronome_data_out_valid;
    end
    //assign dout = (data_out_valid) ? add_shift_reg[2*BITWIDTH-1:0]:0;
    assign dout = (data_out_valid) ?((weight_int) ? (a_reg_reg << BITWIDTH):add_shift_reg_tmp[2*BITWIDTH-1:0]):0;
	
endmodule