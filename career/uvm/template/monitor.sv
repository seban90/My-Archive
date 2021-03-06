`ifndef MODEL_MONITOR_DEF
`define MODEL_MONITOR_DEF
`include "params_def.svh"
class model_monitor_c extends uvm_monitor;

	virtual model_vif   vif;
	model_seq_item_c    items;
	model_config_c      cfg;
	bit                 monitor_type;

	uvm_analysis_port#(model_seq_item_c) mon;

	`uvm_component_utils(model_monitor_c)

	function new(string name="model_monitor", uvm_component parent);
		super.new(name ,parent);
		mon = new("monitor", this);
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
		@ (posedge this.vif.i_RSTN);
	endtask
	task i_data;
		if (cfg.is_handshake == 1) begin
			while (!((this.vif.i_VALID == 1) && (this.vif.i_READY == 1)))
				@ (posedge this.vif.i_CLK);
		end else begin
			while (this.vif.i_VALID == 0) 
				@ (posedge this.vif.i_CLK);
		end
%(seq_in_data_num)s
		@ (posedge this.vif.i_CLK);
	endtask
	task o_data;
		if (cfg.is_handshake == 1) begin
			while (!((this.vif.o_VALID == 1) && (this.vif.o_READY == 1)))
				@ (posedge this.vif.i_CLK);
		end else begin
			while (this.vif.o_VALID == 0) 
				@ (posedge this.vif.i_CLK);
		end
%(seq_out_data_num)s
		@ (posedge this.vif.i_CLK);
	endtask

	task collector;
		case (monitor_type)
			0: i_data;
			1: o_data;
		endcase
	endtask
	task run_phase(uvm_phase phase);
		super.run_phase(phase);
		reset;
		forever begin
			items = model_seq_item_c::type_id::create("monitor_item");
			collector;
			mon.write(items);
		end
	endtask

endclass: model_monitor_c
`include "params_undef.svh"
`endif
