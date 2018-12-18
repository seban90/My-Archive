`ifndef MODEL_AGENT_DEF
`define MODEL_AGENT_DEF
`include "params_def.svh"
class model_agent_c extends uvm_agent;
	virtual model_vif  vif;
	model_driver_c     drv;
	model_seqr_c       seqr;
	model_monitor_c    i_monitor;
	model_monitor_c    o_monitor;
	model_scoreboard_c sb;

	`uvm_component_utils(model_agent_c)

	function new(string name="model_agent", uvm_component parent);
		super.new(name, parent);
	endfunction

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		drv       = model_driver_c::type_id::create("model_driver", this);
		seqr      = model_seqr_c::type_id::create("model_seqr", this);
		i_monitor = model_monitor_c::type_id::create("model_i_monitor", this);
		o_monitor = model_monitor_c::type_id::create("model_o_monitor", this);
		sb        = model_scoreboard_c::type_id::create("model_scoreboard", this);

		i_monitor.monitor_type = 0;
		o_monitor.monitor_type = 1;

		uvm_config_db#(model_seqr_c)::set(this, "","model_seqr",seqr);
		if (!uvm_config_db#(virtual model_vif)::get(this,"","model_vif", vif))
			`uvm_error("DEBUG", $psprintf("%s [%3d] VIRTUAL INTERFACE NOT FOUND", `__FILE__, `__LINE__))
		uvm_config_db#(virtual model_vif)::set(this,"model_driver", "model_vif", vif);
		uvm_config_db#(virtual model_vif)::set(this,"model_seqr", "model_vif", vif);
		uvm_config_db#(virtual model_vif)::set(this,"model_i_monitor", "model_vif", vif);
		uvm_config_db#(virtual model_vif)::set(this,"model_o_monitor", "model_vif", vif);

	endfunction

	virtual function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		i_monitor.mon.connect(sb.i_data_sb_port);
		o_monitor.mon.connect(sb.o_data_sb_port);
		drv.seq_item_port.connect(seqr.seq_item_export);
	endfunction

endclass: model_agent_c
`include "params_undef.svh"
`endif
