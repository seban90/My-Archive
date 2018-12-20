#!/bin/python

import os
import sys
import io
import re

######################################################################################
######################################################################################
input_num = 4
output_num = 1
######################################################################################
######################################################################################
######################################################################################

def setup_uvm_package (ip_name, file_name, base_dir, output_dir):
	if file_name == "makefile":
		return
	p = re.compile(r'\.[\w_]+\.[scv]+')
	matched = p.match(file_name)
	if matched:
		print file_name
		return 

	template_path   = base_dir + '/template'
	template_file   = template_path + ('/%s' % file_name)
	output_filename = ip_name +'_'+file_name
	output_sv_dir   = output_dir + '/uvm_model'
	output_vector_dir   = output_dir + '/vectors/test'
	output_tb_dir   = output_dir + '/tb'
	output_vip_dir  = output_dir + '/uvm_model/vip'
	output_c_dir    = output_dir + '/cmodels'
	output_rtl_dir    = output_dir + '/rtl'

	params = {}

	if file_name == "test_bench":
		return
	f = io.open(template_file, mode="rt", encoding="utf-8")

	template_contents = str(f.read())
	f.close()

	uvm_contents = re.sub(r'MODEL', ip_name.upper(), template_contents)
	uvm_contents = re.sub(r'params', ip_name+'_params', uvm_contents)
	uvm_contents = re.sub(r'model', ip_name, uvm_contents)
	######################################################################################
	if file_name == "c_func.c":
		c_func_params = []
		for i in range(input_num):
			if i == 0:
				contents = ' USER_TYPE  i_data_%d\n' % i
			else:
				contents = '\t,USER_TYPE  i_data_%d\n' % i
			c_func_params.append(contents)
		for i in range(output_num):
			contents = '\t,USER_TYPE* o_data_%d\n' % i
			c_func_params.append(contents)
		params["c_func_parameters"] = ''.join(c_func_params)
		uvm_contents = uvm_contents % params

	elif file_name == "vif.sv":
		i_intf_params = []
		o_intf_params = []
		for i in range(input_num):
			contents = '\tlogic [`BITWIDTH-1:0] i_DATA_%d;\n' % i
			i_intf_params.append(contents)
		for i in range(output_num):
			contents = '\tlogic [`BITWIDTH-1:0] o_DATA_%d;\n' % i
			o_intf_params.append(contents)

		params["i_intf_num"] = ''.join(i_intf_params)
		params["o_intf_num"] = ''.join(o_intf_params)
		uvm_contents = uvm_contents % params

	elif file_name == "model_wrapper.sv":
		i_intf_params = []
		o_intf_params = []
		for i in range(input_num):
			contents = '\t\t,.i_DATA_%d       (vif.i_DATA_%d)\n' % (i,i)
			i_intf_params.append(contents)
		for i in range(output_num):
			contents = '\t\t,.o_DATA_%d       (vif.o_DATA_%d)\n' % (i,i)
			o_intf_params.append(contents)

		params["i_intf_num"] = ''.join(i_intf_params)
		params["o_intf_num"] = ''.join(o_intf_params)
		uvm_contents = uvm_contents % params

	elif file_name == "model.v":
		i_intf_params = []
		o_intf_params = []
		for i in range(input_num):
			contents = '\t,input  [BITWIDTH-1:0] i_DATA_%d\n' % (i)
			i_intf_params.append(contents)
		for i in range(output_num):
			contents = '\t,output [BITWIDTH-1:0] o_DATA_%d\n' % (i)
			o_intf_params.append(contents)
		params["i_intf_num"] = ''.join(i_intf_params)
		params["o_intf_num"] = ''.join(o_intf_params)
		uvm_contents = uvm_contents % params

	elif file_name == "sequence.sv":
		seq_in_data_params = []
		seq_out_data_params = []
		for i in range(input_num):
			contents = '\trand bit [`BITWIDTH-1:0] DATA_%d;\n' %i
			seq_in_data_params.append(contents)
		for i in range(output_num):
			contents = '\trand bit [`BITWIDTH-1:0] DATA_OUT_%d;\n' %i
			seq_out_data_params.append(contents)

		params["seq_in_data_num"] = ''.join(seq_in_data_params)
		params["seq_out_data_num"] = ''.join(seq_out_data_params)
		uvm_contents = uvm_contents % params
	elif file_name == "driver.sv":
		seq_in_data_params = []
		seq_in_data_reset_params = []
		seq_out_data_params = []
		for i in range(input_num):
			contents = '\t\tthis.vif.i_DATA_%d = 0;\n' % i
			seq_in_data_reset_params.append(contents)
		for i in range(input_num):
			contents = '\t\tthis.vif.i_DATA_%d = seq.DATA_%d;\n' %(i, i)
			seq_in_data_params.append(contents)
		for i in range(output_num):
			contents = '\t\tseq.DATA_%d = this.vif.o_DATA_%d;\n' %(i, i)
			seq_out_data_params.append(contents)

		params["seq_in_data_num"] = ''.join(seq_in_data_params)
		params["seq_in_data_reset"] = ''.join(seq_in_data_reset_params)
		params["seq_out_data_num"] = ''.join(seq_out_data_params)
		uvm_contents = uvm_contents % params
	elif file_name == "monitor.sv":
		seq_in_data_params = []
		seq_out_data_params = []
		for i in range(input_num):
			contents = '\t\titems.DATA_%d = this.vif.i_DATA_%d;\n' %(i, i)
			seq_in_data_params.append(contents)
		for i in range(output_num):
			contents = '\t\titems.DATA_OUT_%d = this.vif.o_DATA_%d;\n' %(i, i)
			seq_out_data_params.append(contents)

		params["seq_in_data_num"] = ''.join(seq_in_data_params)
		params["seq_out_data_num"] = ''.join(seq_out_data_params)
		uvm_contents = uvm_contents % params
	elif file_name == "scoreboard.sv":
		c_func_input_params        = []
		c_func_output_params       = []
		compare_decl_input_params  = []
		compare_decl_output_params = []
		compare_decl_golden_params = []
		compare_deriv_input_params  = []
		compare_deriv_output_params = []
		compare_c_input_params     = []
		compare_c_output_params    = []

		compare_dashboard_params   = []

		for i in range(input_num):
			contents = 'input  `C_DATATYPE i_data_%d\n\t' % i
			c_func_input_params.append(contents)
		for i in range(output_num):
			contents = ',output `C_DATATYPE o_data_%d\n\t' % i
			c_func_output_params.append(contents)
		for i in range(input_num):
			contents = '\t\t`C_DATATYPE i_data_%d;' % i
			compare_decl_input_params.append(contents)
		for i in range(output_num):
			contents = '\t\t`C_DATATYPE o_data_%d;' % i
			compare_decl_output_params.append(contents)
		for i in range(output_num):
			contents = '\t\t`C_DATATYPE g_data_%d;' % i
			compare_decl_golden_params.append(contents)

		for i in range(input_num):
			contents = '\t\ti_data_%d = i_data_seq.DATA_%d;' % (i, i)
			compare_deriv_input_params.append(contents)
		for i in range(output_num):
			contents = '\t\to_data_%d = o_data_seq.DATA_OUT_%d;' % (i, i)
			compare_deriv_output_params.append(contents)

		for i in range(input_num):
			if i is not (input_num-1):
				contents = 'i_data_%d' % i
			else:
				contents = 'i_data_%d\t\t\t' % i
			compare_c_input_params.append(contents)
		for i in range(output_num):
			if i is not (output_num-1):
				contents = ',g_data_%d' % i
			else:
				contents = ',g_data_%d\t\t\t' % i
			compare_c_output_params.append(contents)
		for i in range(output_num):
			contents  = "\t\tif (g_data_%d != o_data_%d) begin \n" % (i,i)
			contents += "\t\t\tuvm_report_info(\"DEBUG\", \
$psprintf(\"%s [%3d] PORT %d OUTPUT DATA %x GOLDEN DATA %x\" \
, `__FILE__, `__LINE__, "
			contents += "o_data_%d, g_data_%d));\n" % (i,i)
			contents += "\t\t\tuvm_report_info(\"*E\", $psprintf(\"%s [%3d] TEST_FAILED\",`__FILE__, `__LINE__));\n"
			contents += "\t\tend\n"
			compare_dashboard_params.append(contents)

		params["c_func_input_num"]     = ','.join(c_func_input_params)
		params["c_func_output_num"]    = ''.join(c_func_output_params)
		params["compare_decl_input"]   = '\n'.join(compare_decl_input_params)
		params["compare_decl_output"]  = '\n'.join(compare_decl_output_params)
		params["compare_decl_golden"]  = '\n'.join(compare_decl_golden_params)
		params["compare_deriv_input"]  = '\n'.join(compare_deriv_input_params)
		params["compare_deriv_output"] = '\n'.join(compare_deriv_output_params)
		params["compare_c_input_num"]  = ','.join(compare_c_input_params)
		params["compare_c_output_num"] = ''.join(compare_c_output_params)
		params["compare_dashboard"]    = ''.join(compare_dashboard_params)
		uvm_contents = uvm_contents % params

	######################################################################################
	if file_name == "top.sv":
		write_dir = output_sv_dir
	elif file_name == "vseq.sv":
		write_dir = output_vector_dir
	elif file_name == "pkg.vinc":
		output_filename = file_name
		write_dir = output_tb_dir
	elif file_name == "tb_top.sv":
		output_filename = file_name
		write_dir = output_tb_dir
	elif file_name == "model.v":
		output_filename = "%s.v" % ip_name
		write_dir = output_rtl_dir
	elif file_name == "model_wrapper.sv":
		output_filename = "%s_wrapper.sv" % ip_name
		write_dir = output_rtl_dir
	elif file_name == "c_func.c":
		write_dir = output_c_dir
	else:
		write_dir = output_vip_dir

	f = io.open("%s/%s"%(write_dir, output_filename), mode="wt", encoding="utf-8")
	f.write(unicode(uvm_contents))
	f.close()
		
	return

def setup_uvm_pkg (ip_name, output_dir):
	output_vip_dir  = output_dir + '/uvm_model/vip'
	f = io.open("%s/%s"%(output_vip_dir, "%s_pkg.sv"%ip_name), mode="wt", encoding="utf-8")
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
	contents += "\t`include \"%s_env.sv\"\n" % ip_name
	contents += "endpackage: %s_pkg\n" % ip_name
	f.write(unicode(contents))
	f.close()


def setup_vcode (ip_name, output_dir):
	#pass
	p = re.compile(r'[\w_]+pkg\.[sv]+')
	for root, dirs, files in os.walk(output_dir):
		if root == ("%s/rtl" % output_dir):
			f = io.open("%s/%s" % (root, "vcode.f"), mode="wt", encoding="utf-8")
			contents = "-INCDIR ${ip_path}/rtl\n\n"
			files.sort()
			for g in files:
				contents += "${ip_path}/rtl/%s\n" % g
			f.write(unicode(contents))
			f.close()
		elif root == ("%s/tb" % output_dir):
			f = io.open("%s/%s" % (root, "vcode.f"), mode="wt", encoding="utf-8")
			contents = "-INCDIR ${ip_path}/tb\n\n"
			contents += "${ip_path}/tb/tb_top.sv\n"
			f.write(unicode(contents))
			f.close()
		elif root == ("%s/uvm_model" % output_dir):
			f = io.open("%s/%s" % (root, "vcode.f"), mode="wt", encoding="utf-8")
			contents = "-INCDIR ${ip_path}/uvm_model\n\n"
			#contents += "-f ${ip_path}/uvm_model/vip/vcode.f\n\n"
			for g in files:
				contents += "${ip_path}/uvm_model/%s\n" % g
			f.write(unicode(contents))
			f.close()
		elif root == ("%s/uvm_model/vip" % output_dir):
			f = io.open("%s/%s" % (root, "vcode.f"), mode="wt", encoding="utf-8")
			contents = "-INCDIR ${ip_path}/uvm_model/vip\n\n"
			contents += "${ip_path}/uvm_model/vip/%s_vif.sv\n" % ip_name
			contents += "${ip_path}/uvm_model/vip/%s_pkg.sv\n" % ip_name
			f.write(unicode(contents))
			f.close()
		elif root == ("%s/vectors/test" % output_dir):
			f = io.open("%s/%s" % (root, "vcode.f"), mode="wt", encoding="utf-8")
			contents  = "-f ${ip_path}/uvm_model/vip/vcode.f\n"
			contents += "${ip_path}/vectors/test/%s_vseq.sv\n" % (ip_name)
			contents += "-f ${ip_path}/uvm_model/vcode.f\n\n"
			contents += "-f ${ip_path}/rtl/vcode.f\n"
			contents += "-f ${ip_path}/tb/vcode.f\n"
			f.write(unicode(contents))
			f.close()

		else:
			continue

def run(path, ip_name):
	template_path = '%s/template' % path
	output_dir = cur_path + '/%s' % ip_name
	files = os.listdir(template_path)
	for i in range(len(files)):
		setup_uvm_package(ip_name, files[i], path, output_dir)

	setup_uvm_pkg(ip_name, output_dir)
	setup_vcode(ip_name, output_dir)


if __name__ == "__main__":
	cur_path = os.environ['PWD']
	ip_name = sys.argv[1]

	run(cur_path, ip_name)
