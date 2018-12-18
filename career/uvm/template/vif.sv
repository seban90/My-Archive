`ifndef MODEL_INTERFACE_DEF
`define MODEL_INTERFACE_DEF
`include "params_def.svh"
interface model_vif (
	 input bit i_CLK
	,input bit i_RSTN
);
	logic [`BITWIDTH-1:0] i_DATA;
	logic                 i_VALID;
	logic                 i_READY;

	logic [`BITWIDTH-1:0] o_DATA;
	logic                 o_VALID;
	logic                 o_READY;
endinterface: model_vif
`include "params_undef.svh"
`endif
