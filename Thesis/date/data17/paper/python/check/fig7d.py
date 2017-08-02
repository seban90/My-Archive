#!/usr/bin/python2.7

from nnc2.model.ffnet import *
from nnc2.model.filternetwork import *
from nnc2.arch.builder import *
from nnc2.imp.rtl import *
from nnc2.imp.rtlsim import *
from nnc2.imp.fpgasyn import *
from nnc2.sim.fnsim import *
from nnc2.fxpnum import *
from nnc2.imp import *
from nnc2.aprx.decomp import *
from nnc2.adtr.tf import *

from matplotlib.pyplot import *
import matplotlib
import matplotlib.pyplot as plt

import sys
import os

my_path = os.environ['PYTHONPATH'].split(os.pathsep)
Imp.template_dir = my_path[0]+"/templates/metronome_ooc/"

matplotlib.rcParams['pdf.fonttype'] = 42
matplotlib.rcParams['ps.fonttype'] = 42
figsize = (3.5, 2.8)

def run_syn(x=1,y=1, s=1):
	
	w = np.random.random((1,1,5,5))
	ff = FFNet()
	d = Input(1, (32,32))
	ff.add_atom_as_group(d)
	c = ConvPool.from_numpy_weight(w,stride=(s,s))
	ff.add_group(c)
	ff.setup()
	
	ppb = PixelParallelBuilder()
	mfn = ppb.build(ff, x_ways=x, y_ways=y)
	
	width_frac = 8 # for activation
	width_int = 7 # for activation
	width_frac_bias = 8

	global_bitwidth = width_int + width_frac + 1
	width_frac_weight = 3
	width_int_weight = 1
	#5bit per weight

	######################################################
	# Verilog Write
	######################################################
	writer = DigitSerialImp(mfn) #, sim.get_last_quantized_input(), sim.get_last_quantized_output()) 
	writer.set_uniform_bitwidth(width_int, width_frac, width_frac_weight=width_frac_weight, width_frac_bias=width_frac_bias)
	writer.write('nnc', './outputs/blk%d%d_s%d'%(x,y,s))
	######################################################
	# FPGA Synthesis
	######################################################	
	fs = FPGASyn()
	params = {"sample" : 1, "device_name" : "KINTEX7" , "global_bitwidth" : global_bitwidth, "norm_channel" : "true", "channel_r_mean" : "16'sd125", "channel_g_mean" : "16'sd123", "channel_b_mean" : "16'sd114", "bitwidth_frac" : width_frac, "use_parallelism" : "false" }
	ret, data, dataerr = fs.run(rtl_dir='./outputs/blk%d%d_s%d'%(y,x,s), params=params)
	
	return
	
def draw_graph():
	xway = [1,2,4,8]
	stride = [1,2,4]
	
	luts = []
	for x in xway:
		lut_tmp = []
		for s in stride:
			tmp = read_and_parse_reports('./outputs/blk%d%d_s%d'%(1,y,s))
			lut_tmp.append(tmp['post_route_util_lut'])
		luts.append(lut_tmp)
	
	colors = ['b', 'deeppink', 'orange', 'purple','m', 'y', 'k']
	marker = ['o', 's', '^', 'p', 'x']
	lines = ['-','-.','--',':']
	atts = {'marker':'s', 'color':'deeppink', 'markeredgecolor':'deeppink', 'markerfacecolor': 'none', 'markersize':4,'markeredgewidth':1.0, 'linestyle':'-.'}
	
	fig = plt.figure(1, figsize=figsize)
	plt.hold(True)
	for i in range(len(stride)):
		atts['marker'] = marker[i]
		atts['markeredgecolor'] = colors[i]
		atts['color'] = colors[i]
		atts['linestyle'] = lines[i]
		plt.plot(xway,luts[i],label='Stride: %d'%(stride[i]), **atts)
	
	plt.hold(False)
	plt.axis([0,max(xway)+0.5,max(luts[0])+20],fontsize=8)	
	plt.xlabel("Block Size", fontsize=10)
	plt.ylabel("Area [LUT count]", fontsize=10)
	plt.legend(loc='best',fontsize=10)
	
	for ax in fig.get_axes():
		for label in ax.xaxis.get_majorticklabels():
			label.set_fontsize(8)
		for label in ax.yaxis.get_majorticklabels():
			label.set_fontsize(8)

	plt.savefig("./fig7d.pdf", bbox_inches='tight')
	print "Done"
	return
	
def run():
	if not os.path.exists('outputs'):
		run_syn()
		run_syn(s=2)
		run_syn(s=4)
		print "Baseline complete!"
		run_syn(x=2)
		run_syn(x=2,s=2)
		run_syn(x=2,s=4)
		print "BLK 1x2 complete!"
		run_syn(x=4)
		run_syn(x=4,s=2)
		run_syn(x=4,s=4)
		print "BLK 1x4 complete!"
		run_syn(x=8)
		run_syn(x=8,s=2)
		run_syn(x=8,s=4)
		print "BLK 1x8 complete!"
		
		print "Synthesis has been done.."
		print ""
	else:
		print "Synthesis had already been done.."
		print ""

	draw_graph()
	
	return
	

####################################################################################
#
#
#  Draw lut consumption via stride
#
#
####################################################################################

run()
