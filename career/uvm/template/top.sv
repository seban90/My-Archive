`timescale 1ns/1ps

import uvm_pkg::*;
import model_pkg::*;


class test_c extends uvm_test;

	model_agent_c model_agent;
	model_vseq_c vseq;

	virtual model_vif vif;

	`uvm_component_utils(test_c)

	function new (string name="test_c", uvm_component parent);
		super.new(name, parent);
	endfunction

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if (!uvm_config_db#(virtual model_vif)::get(this, "", "model_vif", vif))
			`uvm_error("DEBUG", $psprintf("%s [%3d] VIRTUAL INTERFACE NOT FOUND", `__FILE__, `__LINE__))
		model_agent = model_agent_c::type_id::create("model_agent", this);
		uvm_config_db#(virtual model_vif)::set(this, "model_agent", "model_vif", vif);
		vseq = model_vseq_c::type_id::create("model_vseq", this);
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
		$display("==              SIMULATION START!!");
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
