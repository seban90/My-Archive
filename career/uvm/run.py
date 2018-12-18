#!/bin/python
import os
import sys
import io
import re

def setup_matching(ip_name, file_name, path, output_dir=None):
	template_path = path+'/'+'template'
	output_filename = ip_name +'_'+ file_name 
	template_file = template_path + '/'+file_name
	output_verilog_dir = output_dir+'/sim/uvm_model'
	output_c_dir = output_dir+'/sim/c_model'

	patt = re.compile(r'[\w_]+\.[sv]+')
	matched = patt.match(file_name)

	if file_name == "test_bench":
		return

	f = io.open(template_file, mode="rt", encoding="utf-8")
	s = str(f.read())
	contents = re.sub(r'MODEL',ip_name.upper(), s)
	contents = re.sub(r'params',ip_name+'_params', contents)
	contents = re.sub(r'model',ip_name, contents)
	f.close()

	if file_name == "top.sv" or file_name == "vseq.sv" :
		output_verilog_dir = output_dir+'/sim'
	elif file_name == "pkg.vinc":
		output_filename = file_name
		output_verilog_dir = output_dir+'/sim/'+'test_bench'

	elif file_name == "tb_top.sv":
		output_filename = file_name

	if matched:
		f = io.open("%s/%s"%(output_verilog_dir,output_filename), mode="wt", encoding="utf-8")
		f.write(unicode(contents))
		f.close()
	else:
		f = io.open("%s/%s"%(output_c_dir,output_filename), mode="wt", encoding="utf-8")
		f.write(unicode(contents))
		f.close()

	return

def packaging(ip_name, path):
	uvm_path = path + '/sim/uvm_model'
	f = io.open("%s/%s"%(uvm_path, "%s_pkg.sv"%ip_name), mode="wt", encoding="utf=8")
	contents  = ""
	contents += "// Please rearrange like this\n"
	contents += "// sequence.sv\n"
	contents += "// sequencer.sv\n"
	contents += "// driver.sv\n"
	contents += "// monitor.sv\n"
	contents += "// scoreboard.sv\n"
	contents += "// agent.sv\n\n"
	contents += "`timescale 1ns/1ps\n"
	contents += "package %s_pkg;\n"% ip_name
	contents += "\timport uvm_pkg::*;\n"
	contents += "\t`include \"uvm_macros.svh\"\n"
	contents += "\t`include \"%s_params_def.svh\"\n" % ip_name
	contents += "\t`include \"%s_params_undef.svh\"\n" % ip_name
	contents += "\t`include \"%s_config.sv\"\n" % ip_name
	contents += "\t`include \"%s_sequence.sv\"\n" % ip_name
	contents += "\t`include \"%s_sequencer.sv\"\n" % ip_name
	contents += "\t`include \"%s_driver.sv\"\n" % ip_name
	contents += "\t`include \"%s_monitor.sv\"\n" % ip_name
	contents += "\t`include \"%s_scoreboard.sv\"\n" % ip_name
	contents += "\t`include \"%s_agent.sv\"\n" % ip_name
	contents += "endpackage: %s_pkg\n" % ip_name
	f.write(unicode(contents))
	f.close()

def make_dut(ip_name, output_dir):
	rtl_path = output_dir + '/rtl'
	f = io.open("%s/%s" %(rtl_path, "dut_wrapper.sv"), mode="wt", encoding="utf-8")
	contents = ""
	contents += "import %s_pkg::*;\n" % ip_name
	contents += "`include \"%s_params_def.svh\"\n" % ip_name
	contents += "module %s_wrapper # (parameter BITWIDTH=`BITWIDTH) (\n" % ip_name
	contents += "\t%s_vif vif\n" % ip_name
	contents += ");\n"
	contents += "\t%s #(BITWIDTH) dut (\n" % ip_name
	contents += "\t\t .i_CLK   (vif.i_CLK  )\n"
	contents += "\t\t,.i_nRST  (vif.i_RSTN )\n"
	contents += "\t\t,.i_DATA  (vif.i_DATA )\n"
	contents += "\t\t,.i_VALID (vif.i_VALID)\n"
	contents += "\t\t//remove '//' if module is based on a handshake\n"
	contents += "\t\t//,.i_READY (vif.i_READY)\n"
	contents += "\t\t,.o_DATA  (vif.o_DATA )\n"
	contents += "\t\t,.o_VALID (vif.o_VALID)\n"
	contents += "\t\t//remove '//' if module is based on a handshake\n"
	contents += "\t\t//,.o_READY (vif.o_READY)\n"
	contents += "\t);\n"
	contents += "`include \"%s_params_undef.svh\"\n" % ip_name
	contents += "endmodule\n"
	f.write(unicode(contents))
	f.close()
	f = io.open("%s/%s" %(rtl_path, "dut.v"), mode="wt", encoding="utf-8")
	contents = ""
	contents += "module %s # (parameter BITWIDTH=8) (\n" % ip_name
	contents += "\t input                 i_CLK\n"
	contents += "\t,input                 i_nRST\n"
	contents += "\t,input  [BITWIDTH-1:0] i_DATA\n"
	contents += "\t,input                 i_VALID\n"
	contents += "\t//,output                i_READY\n"
	contents += "\t,output [BITWIDTH-1:0] o_DATA\n"
	contents += "\t,output                o_VALID\n"
	contents += "\t//,input                 o_READY\n"
	contents += ");\n"
	contents += "endmodule\n"
	f.write(unicode(contents))
	f.close()


def make_vcode (ip_name, path):
	rtl_path = path + '/rtl'
	sim_path = path + '/sim'
	tb_path = sim_path + '/test_bench'
	uvm_path = sim_path + '/uvm_model'
	f = io.open("%s/%s"%(rtl_path, "vcode.f"), mode="wt", encoding="utf-8")
	contents = ""
	contents += "-INCDIR ${IP_DIR}/rtl\n\n"
	contents += "${IP_DIR}/rtl/dut_wrapper.sv\n"
	contents += "${IP_DIR}/rtl/dut.v"
	f.write(unicode(contents))
	f.close()
	f = io.open("%s/%s"%(sim_path, "vcode.f"), mode="wt", encoding="utf-8")
	contents = "-INCDIR ${IP_DIR}/sim\n\n"
	contents += "-f ${IP_DIR}/sim/uvm_model/vcode.f\n\n"
	contents += "${IP_DIR}/sim/%s_vseq.sv\n" %(ip_name)
	contents += "${IP_DIR}/sim/%s_top.sv\n" %(ip_name)
	contents += "-f ${IP_DIR}/sim/test_bench/vcode.f\n\n"
	contents += "-f ${IP_DIR}/rtl/vcode.f\n\n"
	f.write(unicode(contents))
	f.close()
	f = io.open("%s/%s"%(tb_path, "vcode.f"), mode="wt", encoding="utf-8")
	contents = "-INCDIR ${IP_DIR}/sim/test_bench\n\n"
	contents += "${IP_DIR}/sim/test_bench/tb_top.sv\n\n"
	f.write(unicode(contents))
	f.close()
	f = io.open("%s/%s"%(uvm_path, "vcode.f"), mode="wt", encoding="utf-8")
	contents = "-INCDIR ${IP_DIR}/sim/uvm_model\n\n"
	contents += "${IP_DIR}/sim/uvm_model/%s_pkg.sv\n" % ip_name
	contents += "${IP_DIR}/sim/uvm_model/%s_vif.sv\n" % ip_name
	f.write(unicode(contents))
	f.close()

def make_makefile(ip_name, path):
	f = io.open("%s/%s"%(path, "makefile"), mode="wt", encoding="utf-8")
	contents = ""
	contents += "IP_DIR:= $(CURDIR)\n"
	contents += "fsdb:= 1\n"
	contents += "dump:= 1\n"
	contents += "\n\n\n"
	contents += "ifeq (${dump}, 0)\n"
	contents += "\topt_dump =\n"
	contents += "else\n"
	contents += "ifeq (${fsdb}, 0)\n"
	contents += "\topt_dump = -input ncsim_shm.tcl\n"
	contents += "else\n"
	contents += "\topt_dump = -input ncsim_fsdb.tcl\n"
	contents += "endif\n"
	contents += "export IP_DIR\n\n\n"
	contents += "all:\n"
	contents += "\t@echo \"=========================================================\"\n"
	contents += "\t@echo \"make sim        ---> sim with fsdb dump files\"\n"
	contents += "\t@echo \"make sim fsdb=0 ---> sim with  shm dump files\"\n"
	contents += "\t@echo \"make sim dump=0 ---> sim without   dump files\"\n"
	contents += "\t@echo \"=========================================================\"\n"
	contents += "\n\n\n"
	contents += ".PHONY: sim\n"
	contents += "sim:\n"
	contents += "\t@if [ ! -e ./outputs ]; then \\\n\t\tmkdir outputs; \\\n"
	contents += "\tfi\n"
	contents += "\tmake cc\n"
	contents += "\tmake sim_env\n"
	contents += "\tcd outputs; time irun -access +rwc -sv -uvm -timescale 1ns/1ps -f ${IP_DIR}/sim/vcode.f -sv_lib ${IP_DIR}/outputs/sv_lib.so ${opt_dump}\n"
	contents += "\n\n\n"
	contents += "cc:\n"
	contents += "\tcd ${IP_DIR}/sim/c_model; time gcc -shared -o sv_lib.so %s_c_func.c -fPIC\n" % (ip_name)
	contents += "\tcp ${IP_DIR}/sim/c_model/sv_lib.so ${IP_DIR}/outputs\n"
	contents += "\n\n\n"
	contents += "sim_env:\n"
	contents += "\t@echo \"call fsdbDumpfile test.fsdb\" > outputs/ncsim_fsdb.tcl\n"
	contents += "\t@echo \"call fsdbDumpvars 0 t\"  >> outputs/ncsim_fsdb.tcl\n"
	contents += "\t@echo \"call fsdbDumpvars 0 t.dut\" >> outputs/ncsim_fsdb.tcl\n"
	contents += "\t@echo \"run\" >> outputs/ncsim_fsdb.tcl\n"
	contents += "\t@echo \"database -open waves -shm\" > outputs/ncsim_shm.tcl\n"
	contents += "\t@echo \"probe -create t -depth 5\"  >> outputs/ncsim_shm.tcl\n"
	contents += "\t@echo \"probe -show\" >> outputs/ncsim_shm.tcl\n"
	contents += "\t@echo \"run\" >> outputs/ncsim_shm.tcl\n"
	contents += ".PHONY: verdi\n"
	contents += "verdi:\n"
	contents += "cd outputs; verdi -f ${IP_DIR}/sim/vcode.f test.fsdb &\n"

	contents += "clean:\n"
	contents += "\trm -rf outputs\n"
	f.write(unicode(contents))
	f.close()


def run(path=None, ip_name=None):
	template_path = '%s/template' % path
	output_dir = path+'/'+ip_name
	files = os.listdir(template_path)
	for i in range(len(files)):
		#setup_matching(ip_name, files[i], template_path, output_dir)
		setup_matching(ip_name, files[i], path, output_dir)
	
	packaging(ip_name, output_dir)
	make_dut(ip_name, output_dir)
	make_makefile(ip_name, output_dir)
	make_vcode(ip_name, output_dir)
		

if __name__ == "__main__":
	run(os.environ['PWD'], ip_name=sys.argv[1])

