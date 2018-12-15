create_ip -vlnv xilinx.com:ip:blk_mem_gen:8.3 -module_name RAM -dir ./generated/
set_property -name CONFIG.Memory_Type -value {True_Dual_Port_RAM} -objects [get_ips RAM]
#set_property -dict [list CONFIG.Disable_Collision_Warnings {false}] [get_ips RAM]
set_property -name CONFIG.Write_Width_A -value {12} -objects [get_ips RAM]
set_property -name CONFIG.Write_Depth_A -value {307200} -objects [get_ips RAM]
set_property -name CONFIG.Enable_A -value {Use_ENA_Pin} -objects [get_ips RAM]
set_property -name CONFIG.Write_Width_B -value {12} -objects [get_ips RAM]
set_property -name CONFIG.Enable_B -value {Use_ENB_Pin} -objects [get_ips RAM]
set_property -name generate_synth_checkpoint -value false -objects [get_files RAM.xci]
