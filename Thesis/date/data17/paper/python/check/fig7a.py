#!/usr/bin/python2.7

from nnc2.model.filternetwork import *
from nnc2.imp.rtl import *
from nnc2.imp.rtlsim import *
from nnc2.sim.fnsim import *
from nnc2.sim.simulator import *
from nnc2.fxpnum import *
from nnc2.imp import *
from nnc2.arch.builder import *
import os

from matplotlib.pyplot import *

import matplotlib
import matplotlib.pyplot as plt

matplotlib.rcParams['pdf.fonttype'] = 42
matplotlib.rcParams['ps.fonttype'] = 42
figsize = (3.5, 2.8)
###############################################################################
## fixed parameter
###############################################################################
Lw = [1,2,4,8]
width__frac = 8
image_size = (32,32)
clock_freq = 5e6 # 10MHz
clk_per_img = image_size[0]*image_size[1]
throughput_rate = clock_freq / clk_per_img
throughput = []
for l in Lw:
	throughput.append(throughput_rate*l)
###############################################################################
for i in range(len(throughput)):
	throughput[i] /= 1000

colors = ['b', 'deeppink', 'pink', 'orange','m', 'y', 'k']
marker = ['o', 's', '^', 'p', 'x']
lines = ['-','-.','--',':','']
atts = {'marker':'s', 'color':'deeppink', 'markeredgecolor':'deeppink', 'markerfacecolor': 'none', 'markersize':4,'markeredgewidth':1.0, 'linestyle':'-.'}

f = figure(1, figsize=figsize)
plt.hold(True)
atts['marker'] = marker[2]
atts['color'] = colors[0]
atts['markeredgecolor']=colors[0]
atts['linestyle'] = lines[4]

plt.plot(Lw,throughput,**atts)

plt.yticks([10,20,30,40], ('10K', '20K', '30K', '40K'))
plt.axis([0,max(Lw)+0.5,0,max(throughput)+10],fontsize=8)	
for i in range(len(Lw)):
	plt.text(Lw[i]-0.9,throughput[i]+1, '(%d)'%(throughput[i]*1000),fontsize=8)

plt.hold(False)
plt.xlabel("Block Size", fontsize=10)
plt.ylabel("Throughput [Images/sec]", fontsize=10)
plt.legend(prop={'size':10},loc=2)
for ax in f.get_axes():
	for label in ax.xaxis.get_majorticklabels():
		label.set_fontsize(10)
	for label in ax.yaxis.get_majorticklabels():
		label.set_fontsize(10)

plt.savefig("./fig7a.pdf", bbox_inches='tight')

