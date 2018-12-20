import model_pkg::*;

`include "params_def.svh"
module model_wrapper # (parameter BITWIDTH = `BITWIDTH) (
	model_vif vif
);
	MODEL # (BITWIDTH) dut (
		 .i_CLK          (vif.i_CLK    )
    	,.i_nRST         (vif.i_RSTN   )
%(i_intf_num)s
    	,.i_VALID        (vif.i_VALID  )
    	//,.i_READY        (vif.i_READY  )
%(o_intf_num)s
    	,.o_VALID        (vif.o_VALID  )
    	//,.o_READY        (vif.o_READY  )
	);
endmodule
`include "params_undef.svh"

