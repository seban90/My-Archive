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
	#output_filename = ip_name +'_'+ file_name 
	uvm_path = path+'/sim/'+'uvm_model'
	files = os.listdir(uvm_path)
	f = io.open("%s/%s"%(uvm_path, "%s_pkg.sv"%ip_name), mode="wt", encoding="utf=8")
	contents  = ""
	contents += "// Delete *.svh\n"
	contents += "// Please rearrange like this\n"
	contents += "// vif.sv\n"
	contents += "// sequence.sv\n"
	contents += "// sequencer.sv\n"
	contents += "// driver.sv\n"
	contents += "// monitor.sv\n"
	contents += "// scoreboard.sv\n"
	contents += "// agent.sv\n\n"
	contents += "package %s_pkg;\n"% ip_name
	contents += "\timport uvm_pkg::*;\n"
	for g in files:
		contents += "\t`include \"%s\";\n" % g
	contents += "endpackage: %s_pkg\n"% ip_name
	f.write(unicode(contents))
	f.close()
def make_dut(ip_name, output_dir):
	rtl_path = output_dir + '/rtl'
	f = io.open("%s/%s" %(rtl_path, "dut_wrapper.sv"), mode="wt", encoding="utf-8")
	contents = ""
	contents += "import %s_pkg::*;\n" % ip_name
	contents += "module %s_wrapper (\n" % ip_name
	contents += "\t%s_vif vif\n" % ip_name
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
	contents += "${IP_DIR}/sim/%s_top.sv\n" %(ip_name)
	contents += "${IP_DIR}/sim/%s_vseq.sv\n" %(ip_name)
	contents += "-f ${IP_DIR}/sim/test_bench/vcode.f\n\n"
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
	f.write(unicode(contents))
	f.close()

def make_makefile(ip_name, path):
	f = io.open("%s/%s"%(path, "makefile"), mode="wt", encoding="utf-8")
	contents = ""
	contents += "IP_DIR:= $(CURDIR)\n"
	contents += "fsdb:= 1\n"
	contents += "dump:= 1\n"
	contents += "\n\n\n"
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
	contents += "\t@if [! -e ./outputs ]; then \\\n\t\tmkdir outputs; \\\n"
	contents += "\tfi\n"
	contents += "\tmake cc\n"
	contents += "ifeq (${dump}, 0)\n"
	contents += "\tcd outputs; time irun -access +rwc -uvm -timescale 1ns/1ps -f ${IP_DIR}/sim/vcode.f -sv_lib ${IP_DIR}/outputs/sv_lib.so\n"
	contents += "else\n"
	contents += "ifeq (${fsdb}, 0)\n"
	contents += "\tcd outputs; time irun -access +rwc -uvm -timescale 1ns/1ps -f ${IP_DIR}/sim/vcode.f -sv_lib ${IP_DIR}/outputs/sv_lib.so -input ncsim_fsdb.tcl\n"
	contents += "else\n"
	contents += "\tcd outputs; time irun -access +rwc -uvm -timescale 1ns/1ps -f ${IP_DIR}/sim/vcode.f -sv_lib ${IP_DIR}/outputs/sv_lib.so -input ncsim_shm.tcl\n"
	contents += "endif\n"
	contents += "endif\n"
	contents += "\n\n\n"
	contents += "cc:\n"
	contents += "\tcd ${IP_DIR}/sim/c_model; time gcc -shared -o sv_lib.so %s_c_func.c -fPIC\n" % (ip_name)
	contents += "\tcp ${IP_DIR}/sim/c_model/sv_lib.so ${IP_DIR}/outputs\n"
	contents += "\n\n\n"
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

