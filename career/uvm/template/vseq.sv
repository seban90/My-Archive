import uvm_pkg::*;
import model_pkg::*;

class model_vseq_c extends uvm_sequence#(uvm_sequence_item);
	model_seq_c model_seq;
	model_seqr_c model_seqr;

	`uvm_object_utils(model_vseq_c)

	function new(string name="model_vseq");
		super.new(name);
		model_seq = model_seq_c::type_id::create("model_seq");
	endfunction

	task body;
		if (!uvm_config_db#(model_seqr_c)::get(null, "uvm_test_top.model_agent", "model_seqr", model_seqr)
			`uvm_error("DEBUG", $psprinf("%s [%3d] SEQEUNCER NOT FOUND", `__FILE__, `__LINE__))
		
		// set the number of test stimulus
		model_seq.test_num = 10;
		model_seq.start(this.model_seqr);

	endtask

endclass: model_vseq_c
