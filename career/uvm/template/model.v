module MODEL # (parameter BITWIDTH = 8) (
	 input                 i_CLK
	,input                 i_nRST 
%(i_intf_num)s
	,input                 i_VALID
	//,output                i_READY
	
%(o_intf_num)s
	,output                o_VALID
	//,input                 o_READY
);
	// implement modules

endmodule
