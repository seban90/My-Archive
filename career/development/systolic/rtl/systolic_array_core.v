module systolic_array_core
#(
	 parameter DBITS = 8
	,parameter ROWS = 2
	,parameter COLS = 2
)(
	 input                         i_CLK
	,input                         i_RSTN
	,input [ROWS*DBITS-1:0]        i_A
	,input [COLS*DBITS-1:0]        i_B
	,input [ROWS-1:0]              i_A_VALID
	,input [COLS-1:0]              i_B_VALID

	,output [ROW*COLS*2*DBITS-1:0] o_DATA
	,output [ROW*COLS-1:0]         o_DATA_VALID

	,output [2*DBITS-1:0]          acc
	,output                        acc_valid
);

	genvar g;
	generate

	wire [ROWS*DBITS-1:0] nst_row_data[0:COLS-1];
	wire [ROWS-1      :0] nst_row_valid[0:COLS-1];
	wire [COLS*DBITS-1:0] nst_col_data[0:ROWS];
	wire [COLS-1      :0] nst_col_valid[0:ROWS];

	assign nst_col_data[0]  = i_B;
	assign nst_col_valid[0] = i_B_VALID;

	for (g=0;g<COLS;g=g+1) begin: PE_gen

		wire [ROWS*DBITS-1:0] row_data_gen;
		wire [ROWS-1:0]       row_valid_gen;

		PE row[ROWS-1:0] # (
			 .DBITS (DBITS)
			,.ACC   (ROWS)
		) (
			 .CLK           (  {(ROWS){i_CLK}}       )
			,.RSTN          (  {(ROWS){i_RSTN}}      )
			,.DATA_A        (  row_data_gen          )
			,.DATA_B        (  nst_col_data[g]       )
			,.VALID_A       (  row_valid_gen         )
			,.VALID_B       (  nst_col_valid[g]      )
			,.NEXT_DATA_A   (  nst_row_data[g]       )
			,.NEXT_DATA_B   (  nst_col_data[g+1]     )
			,.NEXT_VALID_A  (  nst_row_valid[g]      )
			,.NEXT_VALID_B  (  nst_col_valid[g+1]    )
			,.OUT_DATA      (  OUT_DATA              )
			,.OUT_VALID     (  OUT_VALID             )
		);

		assign row_data_gen  = {nst_row_data[g], i_A[(g+1)*DBITS-1:g*DBITS]};
		assign row_valid_gen = {nst_row_valid[g], i_A_VALID[g:g]};
	end
	endgenerate

endmodule
