`ifndef MODEL_SEQR_DEF
`define MODEL_SEQR_DEF
class model_seqr_c extends uvm_sequencer # (model_seq_item_c);
	`uvm_component_utils(model_seqr_c)
	function new(string name="model_seqr", uvm_component parent);
		super.new(name, parent);
	endfunction
	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
	endfunction
	virtual function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
	endfunction
endclass: model_seqr_c
`endif
