`ifndef MODEL_DRIVER_DEF
`define MODEL_DRIVER_DEF
`include "params_def.svh"
class model_driver_c extends uvm_driver # (model_seq_item_c);
	virtual model_vif   vif;
	model_seq_item_c    item;
	model_config_c      cfg;

	`uvm_component_utils(model_driver_c)

	function new(string name="model_driver", uvm_component parent);
		super.new(name, parent);
	endfunction

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if (!uvm_config_db#(virtual model_vif)::get(this,"","model_vif", vif))
			`uvm_error("DEBUG", $psprintf("VIRTUAL INTERFACE NOT FOUND"))
		if (!uvm_config_db#(model_config_c)::get(this,"","model_cfg", cfg))
			`uvm_error("DEBUG", $psprintf("MODEL CONFIG NOT FOUND"))
	endfunction

	virtual function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
	endfunction 
	task reset;
		this.vif.i_VALID = 0;
		//this.vif.i_DATA = 0;
%(seq_in_data_reset)s
		if (cfg.is_handshake == 1)
			this.vif.o_READY = 1;

		@(posedge this.vif.i_RSTN);
	endtask
	task tx(input model_seq_item_c seq);
		this.vif.i_VALID = 0;
%(seq_in_data_num)s
		#1;
		this.vif.i_VALID = 1;
		@(posedge this.vif.i_CLK);

		if (cfg.is_handshake == 1) begin
			while (this.vif.i_READY == 0) @ (posedge this.vif.i_CLK);
		end

		#1;
		this.vif.i_VALID = 0;
	endtask
	task rx(input model_seq_item_c seq);

		if (cfg.is_handshake == 1) begin
			while (!(this.vif.o_VALID==1)&&(this.vif.o_READY==1)) 
				@ (posedge this.vif.i_CLK);
		end else begin
			while (this.vif.o_VALID == 0)
				@ (posedge this.vif.i_CLK);
		end

		#1;
%(seq_out_data_num)s
	endtask
	task run_phase(uvm_phase phase);
		reset;
		forever begin
			seq_item_port.get_next_item(req);
			case (req.TYPE)
				0: tx(req);
				1: rx(req);
			endcase
			seq_item_port.item_done();
		end
	endtask

endclass: model_driver_c
`include "params_undef.svh"
`endif
