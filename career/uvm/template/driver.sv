`ifndef MODEL_DRIVER_DEF
`define MODEL_DRIVER_DEF
`include "params_def.sv"
class model_driver_c extends uvm_driver # (model_seq_item_c);
	virtual model_vif   vif;
	model_seq_item_c    item;

	`uvm_component_utils(model_driver_c)

	function new(string name="model_driver", uvm_component parent);
		super.new(name, parent);
	endfunction

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if (!uvm_config_db#(virtual model_vif)::get(this,"","model_vif", vif))
			`uvm_error("DEBUG", $psprinf("%s [%3d] VIRTUAL INTERFACE NOT FOUND", `__FILE__, `__LINE__))
	endfunction
	virtual function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
	endfunction 
	task reset;
		@(negedge this.vif.i_RSTN);
		@(posedge this.vif.i_RSTN);
	endtask
	task tx(input bit [`BITWIDTH-1:0] d);
		this.vif.i_VALID = 0;
		this.vif.i_DATA = d;
		#1;
		this.vif.i_VALID = 1;
		@(posedge this.vif.i_CLK);
		#1;
		this.vif.i_VALID = 0;
	endtask
	task rx(output bit [`BITWIDTH-1:0] d);
		//wait (this.vif.o_VALID);
		while (this.vif.o_VALID == 0) @ (posedge this.vif.i_CLK);
		#1;
		d = this.vif.o_DATA;
	endtask
	task run_phase(uvm_phase phase);
		reset;
		forever begin
			`uvm_info("DEBUG", "WAITING ITEM", UVM_LOW)
			seq_item_port.get_next_item(req)
			`uvm_info("DEBUG", "WAITING ITEM", UVM_LOW)
			case (req.TYPE)
				0: tx(req.DATA);
				1: rx(req.DATA);
			endcase
			seq_item_port.item_done();
		end
	endtask

endclass: model_driver_c
`include "params_undef.sv"
`endif
