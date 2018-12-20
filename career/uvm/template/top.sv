`timescale 1ns/1ps

import uvm_pkg::*;
import model_pkg::*;


class test_c extends uvm_test;

	model_env_c      env;
	model_vseq_c     vseq;

	model_config_c   cfg;

	virtual model_vif vif;

	`uvm_component_utils(test_c)

	function new (string name="test_c", uvm_component parent);
		super.new(name, parent);
	endfunction

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if (!uvm_config_db#(virtual model_vif)::get(this, "", "model_vif", vif))
			`uvm_error("DEBUG", $psprintf("%s [%3d] VIRTUAL INTERFACE NOT FOUND", `__FILE__, `__LINE__))
		env   = model_env_c::type_id::create("model_env", this);
		vseq  = model_vseq_c::type_id::create("model_vseq", this);
		cfg   = model_config_c::type_id::create("model_cfg");
		///////////////////////////////////////////////////////////////////////
		// CONFIGURE HANDSHAKE MODEL
		// cfg.is_handshake = 0        ---> no handshake model (only valid)
		// cfg.is_handshake = 1        --->    handshake model (valid, ready)
		///////////////////////////////////////////////////////////////////////
		cfg.is_handshake = 1;
		///////////////////////////////////////////////////////////////////////
		///////////////////////////////////////////////////////////////////////
		///////////////////////////////////////////////////////////////////////

		uvm_config_db#(virtual model_vif)::set(this, "model_env", "model_vif", vif);
		uvm_config_db#(model_config_c)::set(this, "model_env", "model_cfg", cfg);
	endfunction

	virtual function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
	endfunction
	
	virtual function void start_of_simulation_phase(uvm_phase phase);
		super.start_of_simulation_phase(phase);
		uvm_top.print_topology();
	endfunction

	task run_phase(uvm_phase phase);
		phase.raise_objection(this, "START TEST");
		$display("==================================================================");
		$display("==    MODEL     SIMULATION START!!");
		$display("==================================================================");
		vseq.start(null);
		phase.drop_objection(this, "");
	endtask
	virtual function void report_phase(uvm_phase phase);
		super.report_phase(phase);
		$display("==================================================================");
		$display("==              SIMULATION FINISHED!!");
		$display("==================================================================");
	endfunction
endclass: test_c
