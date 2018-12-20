`ifndef MODEL_SEQ_DEF
`define MODEL_SEQ_DEF
`include "params_def.svh"
class model_seq_item_c extends uvm_sequence_item;

	rand bit                 TYPE;
%(seq_in_data_num)s
%(seq_out_data_num)s

	constraint value_type {TYPE inside {0,1};}

	`uvm_object_utils(model_seq_item_c)
	function new(string name="model_seq_item");
		super.new(name);
	endfunction
endclass: model_seq_item_c

class model_seq_c extends uvm_sequence # (model_seq_item_c);
	`uvm_object_utils(model_seq_c)
	bit [31:0] test_num;
	model_seq_item_c items;
	function new(string name="model_seq");
		super.new(name);
		items = model_seq_item_c::type_id::create("model_seq_item");
	endfunction
	task body;
		// the num of Simulataon
		repeat (test_num) begin
			start_item(items);
			void'(

				items.randomize() with {
					TYPE == 0;
				}
			);
			finish_item(items);
		end
	endtask
endclass: model_seq_c

`include "params_undef.svh"
`endif
