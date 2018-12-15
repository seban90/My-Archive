`ifndef MODEL_SEQ_DEF
`define MODEL_SEQ_DEF
`include "params_def.svh"
class model_seq_item_c extends uvm_sequence_item;

	rand bit                 TYPE;
	rand bit [`BITWIDTH-1:0] DATA;

	`uvm_object_utils(model_seq_item_c)
	function new(string name="model_seq_item");
		super.new(name);
	endfunction
endclass: model_seq_item_c

class model_seq_c extends uvm_sequence # (model_seq_item_c);
	`uvm_object_utils(model_seq_c)
	model_seq_item_c items;
	function new(string name="model_seq_item");
		super.new(name);
	endfunction
	task body;
		start_item(items);
		finish_item(items);
	endtask
endclass: model_seq_c

`include "params_undef.svh"
`endif
