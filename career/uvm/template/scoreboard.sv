`ifndef MODEL_SCOREBOARD_DEF
`define MODEL_SCOREBOARD_DEF
`define C_DATATYPE            longint unsigned

`include "params_def.svh"

import "DPI-C" context function c_model_func(
	 %(c_func_input_num)s
	%(c_func_output_num)s
);

class model_scoreboard_c extends uvm_scoreboard;
	uvm_analysis_export   # (model_seq_item_c) i_data_sb_port;
	uvm_analysis_export   # (model_seq_item_c) o_data_sb_port;
	uvm_tlm_analysis_fifo # (model_seq_item_c) i_data_sb_fifo;
	uvm_tlm_analysis_fifo # (model_seq_item_c) o_data_sb_fifo;

	`uvm_component_utils(model_scoreboard_c)
	function new(string name="model_scoreboard", uvm_component parent);
		super.new(name,parent);
	endfunction

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		i_data_sb_port = new("i_data_sb_port", this);
		o_data_sb_port = new("o_data_sb_port", this);
		i_data_sb_fifo = new("i_data_sb_fifo", this);
		o_data_sb_fifo = new("o_data_sb_fifo", this);
	endfunction

	virtual function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		i_data_sb_port.connect(i_data_sb_fifo.analysis_export);
		o_data_sb_port.connect(o_data_sb_fifo.analysis_export);
	endfunction
	
	task run_phase(uvm_phase phase);
		model_seq_item_c i_data_fifo[$];
		model_seq_item_c o_data_fifo[$];
		model_seq_item_c g_data_fifo[$];
		model_seq_item_c i_data;
		model_seq_item_c o_data;
		forever begin
			//////////////////////////////////////////////////////////////////////////////
			// Get data from monitor
			//////////////////////////////////////////////////////////////////////////////
			i_data_sb_fifo.get(i_data);
			i_data_fifo.push_back(i_data);
			o_data_sb_fifo.get(o_data);
			o_data_fifo.push_back(o_data);
			//////////////////////////////////////////////////////////////////////////////
			phase.raise_objection(this, "SCOREBOARD IN PROGRESS");
			//////////////////////////////////////////////////////////////////////////////
			void'(compare_data(i_data_fifo.pop_front(), o_data_fifo.pop_front()));
			//////////////////////////////////////////////////////////////////////////////
			phase.drop_objection(this, "SCOREBOARD FINISHED");
			//////////////////////////////////////////////////////////////////////////////
		end
	endtask
	function compare_data(
		 input model_seq_item_c i_data_seq
		,input model_seq_item_c o_data_seq
	);
%(compare_decl_input)s
%(compare_decl_output)s
%(compare_decl_golden)s
%(compare_deriv_input)s
%(compare_deriv_output)s
		c_model_func(
			 %(compare_c_input_num)s
			%(compare_c_output_num)s
		);
%(compare_dashboard)s
		uvm_report_info("DEBUG", "DATA MATCHED");
	endfunction

endclass: model_scoreboard_c
`undef USER_TYPE
`include "params_undef.svh"
`endif
