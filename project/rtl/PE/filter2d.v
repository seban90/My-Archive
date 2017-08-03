module filter2d (
	clk, 
	fclk, 
	rst, 
	process_enable,
	data_in_valid,
	weight_in_valid,
	data_in,
	weight_addr,
	weight_data,
	data_out,
	data_out_valid,
	cols,
	rows
	);
	/*
	filter2d #(.BITWIDTH(BITWIDTH),.COLS(COLS),.ROWS(ROWS)) ist(
        .clk(), 
        .fclk(), 
        .rst(), 
        .process_enable(),
        .data_in_valid(),
        .weight_in_valid(),
        .data_in(),
        .weight_addr(),
        .weight_data(),
        .data_out(),
        .data_out_valid(),
        .cols(),
        .rows()
    );
	*/
	parameter BITWIDTH = 8;
	parameter COLS = 640;
	parameter ROWS = 480;
	function integer clog2;
            input integer value;
            begin
                value = value - 1;
                for (clog2=0;value>0;clog2=clog2+1)
                    value = value >> 1;
            end
    endfunction
    
	input clk, fclk, rst, process_enable, data_in_valid, weight_in_valid;
	input [BITWIDTH-1:0] data_in, weight_data;
	input [3:0] weight_addr;
	output [BITWIDTH-1:0] data_out; //8-bits output data 
	output data_out_valid;
	output [clog2(COLS):0] cols;
	output [clog2(ROWS):0] rows;
	
	
	
	reg [BITWIDTH-1:0] weight_reg[0:8];
	reg [BITWIDTH*COLS-1:0] linebuffer1, linebuffer2;
	reg data_in_valid_1;
	wire [clog2(2*BITWIDTH)+1:0] last_count;
	reg [clog2(2*BITWIDTH)+1:0] last_count2;
	reg [clog2(COLS):0] x;
    reg [clog2(ROWS):0] y;
	wire metronome_in_valid, metronome_out_valid, row_filter_out_valid;
    //wire signed [2*BITWIDTH-1:0] tmp1, tmp2, tmp3, out;
    wire signed [2*BITWIDTH-1:0] tmp1, tmp2, tmp3;
    wire [BITWIDTH-1:0] line_buffed_wire1,line_buffed_wire2;
    reg [BITWIDTH-1:0] pixel_buffed_reg1, pixel_buffed_reg2,pixel_buffed_reg3, pixel_buffed_reg4,pixel_buffed_reg5, pixel_buffed_reg6;
  //  wire mul_out_valid;
    wire signed [2*BITWIDTH-1:0] add_tmp, add_out;
    integer j;
	always @ (posedge clk or negedge rst ) begin
	   if (!rst) begin
	       for (j=0;j<=8;j=j+1)
	           weight_reg[j] <= 0;
	   end
	   else if (weight_in_valid) weight_reg[weight_addr] <= weight_data;
	end
	
	
	assign line_buffed_wire1 = linebuffer1[BITWIDTH*COLS-1:BITWIDTH*(COLS-1)];
	assign line_buffed_wire2 = linebuffer2[BITWIDTH*COLS-1:BITWIDTH*(COLS-1)];
	always @ (posedge clk or negedge rst) begin
	   if (!rst) begin
	       pixel_buffed_reg1 <= 0; pixel_buffed_reg2 <= 0; pixel_buffed_reg3 <= 0; 
	       pixel_buffed_reg4 <= 0; pixel_buffed_reg5 <= 0; pixel_buffed_reg6 <= 0;
	   end else if (data_in_valid && process_enable) begin
	       pixel_buffed_reg1 <= data_in;
	       pixel_buffed_reg2 <= pixel_buffed_reg1;
	       pixel_buffed_reg3 <= line_buffed_wire1;
	       pixel_buffed_reg4 <= pixel_buffed_reg3;
	       pixel_buffed_reg5 <= line_buffed_wire2;
           pixel_buffed_reg6 <= pixel_buffed_reg5;
	   end
	end
	// it would be implemented as FIFO
	always @ (posedge clk or negedge rst) begin
		if (!rst) begin
			linebuffer1 <= 0;
			linebuffer2 <= 0;
		//	pixelbuffer <= 0;
		end else if (data_in_valid && process_enable) begin
			linebuffer1 <= {linebuffer1[BITWIDTH*(COLS-1)-1:0], data_in};
			linebuffer2 <= {linebuffer2[BITWIDTH*(COLS-1)-1:0], line_buffed_wire1};
			//pixelbuffer <= {pixelbuffer[BITWIDTH*3-1:BITWIDTH*2], line_buffed_wire2};
		end
	end
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//             TODO:: Check this!
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	always  @(posedge clk or negedge rst) begin
		if (!rst) data_in_valid_1 <= 0;
		else data_in_valid_1 <= data_in_valid;
	end
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	always @ (posedge fclk or negedge rst) begin
		if (!rst) last_count2 <= 0;
		else last_count2 <= last_count;
	end
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//Q7.8 format
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	metronome_signed #(BITWIDTH) met0(fclk, rst, data_in_valid_1&process_enable, metronome_in_valid, metronome_out_valid, last_count);
	row_filter #(BITWIDTH) rf1(
        .clk(fclk), .rst(rst), 
        .data_in_valid(metronome_in_valid),  
        .din1(data_in), .din2(pixel_buffed_reg1), .din3(pixel_buffed_reg2),
        .weight1(weight_reg[8]), .weight2(weight_reg[7]), .weight3(weight_reg[6]), 
        .metronome(metronome_out_valid), 
        .data_out_valid(row_filter_out_valid), 
        .last_count(last_count2), 
        .dout(tmp1)
        );
	row_filter #(BITWIDTH) rf2(
        .clk(fclk), .rst(rst), 
        .data_in_valid(metronome_in_valid), 
        .din1(line_buffed_wire1), .din2(pixel_buffed_reg3), .din3(pixel_buffed_reg4),
        .weight1(weight_reg[5]), .weight2(weight_reg[4]), .weight3(weight_reg[3]),
        .metronome(metronome_out_valid), 
        .data_out_valid(), 
        .last_count(last_count2), 
        .dout(tmp2)
        );
	row_filter #(BITWIDTH) rf3(
        .clk(fclk), .rst(rst), 
        .data_in_valid(metronome_in_valid), 
        .din1(line_buffed_wire2), .din2(pixel_buffed_reg5), .din3(pixel_buffed_reg6),
        .weight1(weight_reg[2]), .weight2(weight_reg[1]), .weight3(weight_reg[0]), 
        .metronome(metronome_out_valid), 
        .data_out_valid(), 
        .last_count(last_count2), 
        .dout(tmp3)
        );
        /*
	row_filter #(BITWIDTH) rf4(
        .clk(fclk), .rst(rst), 
        .data_in_valid(row_filter_out_valid), 
        .din1(tmp1[15:8]), .din2(tmp2[15:8]), .din3(tmp3[15:8]), 
        .weight1(8'sd1), .weight2(8'sd1), .weight3(8'sd1), 
        .metronome(metronome_out_valid), 
        .data_out_valid(mul_out_valid), 
        .last_count(last_count2), 
        .dout(out)
        );
        */
    
    n_bit_adder #(2*BITWIDTH) adder_tree1(tmp1, tmp2, add_tmp, );
    n_bit_adder #(2*BITWIDTH) adder_tree2(tmp3, add_tmp, add_out, );
    /*
    reg [2*BITWIDTH-1:0] out_tmp;
    always @ (posedge fclk or negedge rst) begin
        if (!rst) out_tmp <= 0;
        else if (row_filter_out_valid) out_tmp <= add_out;
    end
    */
    always @ (posedge fclk or negedge rst) begin
        if (!rst) begin
            x <= 0;
            y <= 0;
        end else if (row_filter_out_valid) begin
            if (x == COLS - 1) begin
                x <= 0;
                if (y == ROWS-1) y <= 0;
                else y <= y + 1'b1;
            end else x <= x + 1'b1;
        end
    end
    //takes 2 cycles on slow clock
    assign cols = x;
    assign rows = y;
	assign data_out_valid = ((x >= 2) && (y >= 2)) && row_filter_out_valid;
	//assign data_out = (data_out_valid)? out[7:0]:0;
	//assign data_out = (data_out_valid)? out_tmp[2*BITWIDTH-1:BITWIDTH]:0;
	assign data_out = (data_out_valid)? add_out[2*BITWIDTH-1:BITWIDTH]:0;
endmodule