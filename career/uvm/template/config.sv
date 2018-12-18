`ifndef MODEL_CONFIG_DEF
`define MODEL_CONFIG_DEF
class model_config_c extends uvm_object;
	bit is_handshake;
	function new(string name="model_config");
		super.new(name);
		is_handshake = 0;
	endfunction
endclass
`endif
