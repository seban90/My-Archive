`ifndef MODEL_INTERFACE_DEF
`define MODEL_INTERFACE_DEF
`include "params_def.svh"
interface model_vif (
	 input bit i_CLK
	,input bit i_RSTN
);
%(i_intf_num)s
	logic                 i_VALID;
	logic                 i_READY;

%(o_intf_num)s
	logic                 o_VALID;
	logic                 o_READY;
endinterface: model_vif
`include "params_undef.svh"
`endif
