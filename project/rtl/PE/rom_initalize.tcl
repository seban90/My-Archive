create_ip -vlnv xilinx.com:ip:blk_mem_gen:8.3 -module_name weightrom -dir ./generated/
set_property -name CONFIG.Memory_Type -value {Single_Port_ROM} -objects [get_ips weightrom]
set_property -name CONFIG.Write_Width_A -value {8} -objects [get_ips weightrom]
set_property -name CONFIG.Write_Depth_A -value {9} -objects [get_ips weightrom]
set_property -name CONFIG.Enable_A -value {Use_ENA_Pin} -objects [get_ips weightrom]

set_property -name generate_synth_checkpoint -value false -objects [get_files weightrom.xci]
set_property -name CONFIG.Load_Init_File -value {true} -objects [get_ips weightrom]
set_property -name CONFIG.Coe_File -value {../../white.coe} -objects [get_ips weightrom]
