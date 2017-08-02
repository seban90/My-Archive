#!/usr/bin/python2.7

from nnc2.model.filternetwork import *
from nnc2.imp.rtl import *
from nnc2.imp.rtlsim import *
from nnc2.imp.fpgasyn import *
from nnc2.sim.fnsim import *
from nnc2.sim.simulator import *
from nnc2.fxpnum import *
from nnc2.imp import *
from nnc2.arch.builder import *
from matplotlib.pyplot import *
import matplotlib
import matplotlib.pyplot as plt

import os

matplotlib.rcParams['pdf.fonttype'] = 42
matplotlib.rcParams['ps.fonttype'] = 42
figsize = (3.5, 2.8)

powers_1x = [1.4+0.668, 1.2+0.661, 1.2+0.661, 0.6+0.653] 
powers_2x = [0, 2.8+0.689, 2.4+0.689, 1.6+0.69]
powers_4x = [0,0,0,3.4+0.707]


bs = np.array(range(0,4))
bs2 = np.array([0,1,2,2.9])
bs_str = ['(1,1)', '(2,1)','(1,2)','(2,2)']

colors = ['b', 'deeppink', 'orange', 'purple','m', 'y', 'k']
marker = ['o', 's', '^', 'p', 'x']
lines = ['-','-.','--',':','']
atts = {'marker':'s', 'color':'deeppink', 'markeredgecolor':'deeppink', 'markerfacecolor': 'none', 'markersize':4,'markeredgewidth':1.0, 'linestyle':'-.'}

legends=  ['Block Size:1x1', 'Block Size:1x2','Block Size:2x1','Block Size:2x2']
fig = plt.figure(figsize=figsize)
plt.hold(True)
for i in range(len(powers_1x)):
	atts['marker'] = marker[i]
	atts['color'] = colors[i]
	atts['markeredgecolor'] = colors[i]
	atts['linestyle'] = lines[4]

	plt.plot([1],powers_1x[i],label=legends[i],**atts)
for i in range(1,len(powers_2x)):
	atts['marker'] = marker[i]
	atts['color'] = colors[i]
	atts['markeredgecolor'] = colors[i]
	atts['linestyle'] = lines[4]

	plt.plot([2],powers_2x[i],**atts)
for i in range(3,len(powers_4x)):
	atts['marker'] = marker[i]
	atts['color'] = colors[i]
	atts['markeredgecolor'] = colors[i]
	atts['linestyle'] = lines[4]

	plt.plot([4],powers_4x[i],**atts)

plt.plot([1,2], [powers_1x[1],powers_2x[1]],'-',color='deeppink')
plt.plot([1,2], [powers_1x[2],powers_2x[2]],'--',color='orange')
plt.plot([1,2,4], [powers_1x[3],powers_2x[3],powers_4x[3]],'-.',color='purple')
plt.xticks([1,2,4], ['4882','9765','19531','39062'])
plt.legend(loc='lower right', fontsize=8)
plt.axis([0,4.5, 0, 5])
plt.xlabel('Throughput [Images/sec]',fontsize=8)
plt.ylabel('Power [W]',fontsize=8)

for ax in fig.get_axes():
	for label in ax.xaxis.get_majorticklabels():
		label.set_fontsize(8)
	for label in ax.yaxis.get_majorticklabels():
		label.set_fontsize(8)

plt.savefig("./fig8a.pdf",bbox_inches='tight')
