#!/bin/python
import os
import sys
import io
import re

def setup_matching(ip_name, file_name, path, output_dir=None):
	output_filename = ip_name +'_'+ file_name 
	templete_file = path + '/'+file_name
	output_verilog_dir = output_dir+'/uvm_model'
	output_c_dir = output_dir+'/c_model'

	patt = re.compile(r'[\w_]+\.[sv]+')
	matched = patt.match(file_name)
	f = io.open(templete_file, mode="rt", encoding="utf-8")
	string = str(f.read())
	setup_str = re.sub(r'MODEL',ip_name.upper(), string)
	setup_str = re.sub(r'params',ip_name+'_params', setup_str)
	setup_str = re.sub(r'model',ip_name, setup_str)
	f.close()
	if matched:
		f = io.open("%s/%s"%(output_verilog_dir,output_filename), mode="wt", encoding="utf-8")
		f.write(unicode(setup_str))
		f.close()
	else:
		f = io.open("%s/%s"%(output_c_dir,output_filename), mode="wt", encoding="utf-8")
		f.write(unicode(setup_str))
		f.close()

	return

def run(path=None, ip_name=None):
	templete_path = '%s/templete' % path
	output_dir = path+'/'+ip_name+"_vip"
	files = os.listdir(templete_path)
	for i in range(len(files)):
		setup_matching(ip_name, files[i], templete_path, output_dir)
		

if __name__ == "__main__":
	run(os.environ['PWD'], ip_name=sys.argv[1])

