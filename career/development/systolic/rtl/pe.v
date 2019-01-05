module PE 
#(
	 parameter DBITS = 16
	,parameter ACC   = 3
)
(
	 input                  CLK
	,input                  RSTN
	,input      [DBITS-1:0] DATA_A 
	,input      [DBITS-1:0] DATA_B 
	,input                  VALID_A
	,input                  VALID_B
	,output reg [DBITS-1:0] NEXT_DATA_A 
	,output reg [DBITS-1:0] NEXT_DATA_B 
	,output reg             NEXT_VALID_A
	,output reg             NEXT_VALID_B
	,output [2*DBITS-1:0]   OUT_DATA
	,output                 OUT_VALID
	);
	//////////////////////////////////////////////////////////////////////////
	//    Function : LOG2
	//////////////////////////////////////////////////////////////////////////
	function integer LOG2;
		input [31:0] n;
		reg [31:0] n_reg;
		begin
			n_reg = n;
			n_reg = n_reg-1;
			for (LOG2=0;n_reg>0;LOG2=LOG2+1) n_reg = n_reg >> 1;
		end
	endfunction
	//////////////////////////////////////////////////////////////////////////
	//////////////////////////////////////////////////////////////////////////
	reg [2*DBITS-1:0] acculmulate;
	reg [2*DBITS-1:0] partial_mul;
	reg               partial_valid;
	reg [LOG2(ACC):0] acc_cnt;
	wire              cnt_clr;

	always @ (posedge CLK or negedge RSTN) begin
		if (!RSTN)        NEXT_DATA_A <= 0;
		else if (VALID_A) NEXT_DATA_A <= DATA_A;
	end

	always @ (posedge CLK or negedge RSTN) begin
		if (!RSTN)        NEXT_DATA_B <= 0;
		else if (VALID_B) NEXT_DATA_B <= DATA_B;
	end
	always @ (posedge CLK or negedge RSTN) begin
		if (!RSTN) NEXT_VALID_A <= 0;
		else       NEXT_VALID_A <= VALID_A;
	end
	always @ (posedge CLK or negedge RSTN) begin
		if (!RSTN) NEXT_VALID_B <= 0;
		else       NEXT_VALID_B <= VALID_B;
	end

	wire update_partial_mul = VALID_A && VALID_B;

	always @ (posedge CLK or negedge RSTN) begin
		if (!RSTN)                   partial_mul <= 0;
		else if (update_partial_mul) partial_mul <= DATA_A*DATA_B;
	end
	always @ (posedge CLK or negedge RSTN) begin
		if (!RSTN) partial_valid <= 0;
		else begin
			if (update_partial_mul) partial_valid <= 1'b1;
			else                    partial_valid <= 1'b0;
		end
	end

	always @ (posedge CLK or negedge RSTN) begin
		if (!RSTN)                  acculmulate <= 0;
		else begin
			if (cnt_clr)            acculmulate <= 0; 
			else if (partial_valid) acculmulate <= acculmulate + partial_mul; 
		end
	end
	always @ (posedge CLK or negedge RSTN) begin
		if (!RSTN)                  acc_cnt <= 0;
		else begin
			if (cnt_clr)            acc_cnt <= 0;
			else if (partial_valid) acc_cnt <= acc_cnt +1'b1;
		end
	end

	assign OUT_DATA  = acculmulate;
	assign cnt_clr   = (acc_cnt == ACC);
	assign OUT_VALID = (acc_cnt == ACC);


endmodule
