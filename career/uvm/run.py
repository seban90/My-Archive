#!/bin/python
import os
import sys
import io
import re

def setup_matching(ip_name, file_name, path, output_dir=None):
	template_path = path+'/'+'template'
	output_filename = ip_name +'_'+ file_name 
	template_file = template_path + '/'+file_name
	output_verilog_dir = output_dir+'/uvm_model'
	output_c_dir = output_dir+'/c_model'

	patt = re.compile(r'[\w_]+\.[sv]+')
	matched = patt.match(file_name)
	f = io.open(template_file, mode="rt", encoding="utf-8")
	s = str(f.read())
	contents = re.sub(r'MODEL',ip_name.upper(), s)
	contents = re.sub(r'params',ip_name+'_params', contents)
	contents = re.sub(r'model',ip_name, contents)
	f.close()

	if file_name == "top.sv" or file_name == "vseq.sv" :
		output_verilog_dir = output_dir
	elif file_name == "pkg.vinc":
		output_filename = file_name
		output_verilog_dir = output_dir+'/'+'test_bench'

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
	uvm_path = path+'/'+'uvm_model'
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
	contents += "module %s_wrapper (\n" % ip_name
	contents += "\t%s_vif vif\n" % ip_name
	contents += ");\n"
	contents += "endmodule\n"
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
	make_dut (ip_name, output_dir)
		

if __name__ == "__main__":
	run(os.environ['PWD'], ip_name=sys.argv[1])

