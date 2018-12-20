`ifndef MODEL_ENV_DEF
`define MODEL_ENV_DEF
`include "params_def.svh"
class model_env_c extends uvm_env;

	//agent for BUS_PROTOCOL

	// agent for MODEL
	model_agent_c agent;
	model_config_c cfg;
	model_seqr_c   seqr;
	virtual model_vif vif;

	`uvm_component_utils(model_env_c)

	function new(string name="model_env", uvm_component parent);
		super.new(name, parent);
	endfunction

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		uvm_config_db#(model_seqr_c)::set(this, "","model_seqr",seqr);
		if (!uvm_config_db#(virtual model_vif)::get(this,"","model_vif", vif))
			`uvm_error("DEBUG", $psprintf("%s [%3d] VIRTUAL INTERFACE NOT FOUND", `__FILE__, `__LINE__))

		if (!uvm_config_db#(model_config_c)::get(this,"","model_cfg", cfg))
			`uvm_error("DEBUG", $psprintf("%s [%3d] MODEL CONFIG NOT FOUND", `__FILE__, `__LINE__))

		agent = model_agent_c::type_id::create("model_agent", this);
		uvm_config_db#(virtual model_vif)::set(this,"model_agent", "model_vif", vif);
		uvm_config_db#(model_config_c)::set(this,"model_agent", "model_cfg", cfg);

	endfunction

	virtual function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
	endfunction

endclass: model_env_c
`include "params_undef.svh"
`endif
