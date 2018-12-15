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

def run(num_in, num_out,kernel,size, x=1, y=1, s=1):

	ff = FFNet()
	weight = np.random.random((num_output,num_input,kernel,kernel))
	d = Input(num_input, size)
	ff.add_atom_as_group(d)
	c = ConvPool.from_numpy_weight(weight,stride=(s,s))
	ff.add_group(c)
	ff.setup()

	ppb = PixelParallelBuilder()
	mfn = ppb.build(ff, x_ways=x, y_ways=y)

	td = 0
	ld = 0
	pd = 0

	for l in mfn.layers:
		for v in l.s_vertices:
			if v.type == VertexType.DELAY:
				td += v.delay
				if v.delay != 1:
					ld += 1
				else:
					pd += 1

	return td

#############################################################################
## hyper parameter
#############################################################################
kernel = 3   # up to 11
Lh, Lw = 1,1, # up to (2,2)
###############################################################################
###############################################################################
## fixed parameter
num_input,num_output = 1,1 
width_frac = 8
size = (32,32)
stride = [1,2,4]
total_delay =[] 
tmp =[] 
for i in stride:
	tmp.append(run(1,1,kernel,size,s=i))
total_delay.append(tmp)
tmp = []
for i in stride:
	tmp.append(run(1,1,kernel,size,x=2,y=1,s=i))
total_delay.append(tmp)
tmp =[]
for i in stride:
	tmp.append(run(1,1,kernel,size,x=4,y=1,s=i))
total_delay.append(tmp)
tmp = []
for i in stride:
	tmp.append(run(1,1,kernel,size,x=8,y=1,s=i))
total_delay.append(tmp)

print total_delay
total_delay = np.array(total_delay).T

print total_delay
bs = np.array(range(0,4))+0.5
bs2 = np.array([0,1,2,3])+0.5
bs_str = ['1', '2','4','8']

colors = ['b', 'deeppink', 'orange', 'purple','m', 'y', 'k']
marker = ['o', 's', '^', 'p', 'x']
lines = ['-','-.','--',':']
atts = {'marker':'s', 'color':'deeppink', 'markeredgecolor':'deeppink', 'markerfacecolor': 'none', 'markersize':4,'markeredgewidth':1.0, 'linestyle':'-.'}

atts['marker'] = marker[0]
atts['color'] = colors[0]
atts['markeredgecolor'] = colors[0]
atts['linestyle'] = lines[0]

fig = plt.figure(figsize=figsize)
plt.hold(True)
plt.plot([1,2,4,8], total_delay[0,:], label="Stride:1", **atts)
atts['marker'] = marker[1]
atts['color'] = colors[1]
atts['markeredgecolor'] = colors[1]
atts['linestyle'] = lines[1]
plt.plot([1,2,4,8], total_delay[1,:], label="Stride:2", **atts)
atts['marker'] = marker[2]
atts['color'] = colors[2]
atts['markeredgecolor'] = colors[2]
atts['linestyle'] = lines[2]

plt.plot([1,2,4,8], total_delay[2,:], label="Stride:4", **atts)
plt.axis([0,8.6,50,94],fontsize=8)
plt.xlabel('Block Size',fontsize=10)
plt.ylabel('Number of Delays',fontsize=10)
plt.yticks([60,70,80,90],['60', '70', ' 80',' 90'])
plt.legend(prop={'size':8},loc='best')

for ax1 in fig.get_axes():
	for label in ax1.xaxis.get_majorticklabels():
		label.set_fontsize(10)
	for label in ax1.yaxis.get_majorticklabels():
		label.set_fontsize(10)

plt.savefig("./fig7b.pdf", bbox_inches='tight')
