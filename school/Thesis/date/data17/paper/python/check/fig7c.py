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

##############################################################################
## hyper parameter
#############################################################################
num_input,num_output = 1,1 
kernel = 5 
Lw = [1,2,4,8]  # x - ways
#pool_shape = (1,1)
conv_stride_lter = [1,2,4]
image_size = (32,32)
###############################################################################
###############################################################################
## fixed parameter
width__frac = 8
Lh = 1 # y - ways
############################################################################
synapse = []
for s in conv_stride_lter:

	weight = np.random.random((num_output,num_input,kernel,kernel))
	ff = FFNet()
	d = Input(num_input, image_size)
	ff.add_atom_as_group(d)
	c = ConvPool.from_numpy_weight(weight,stride=(s,s))
	ff.add_group(c)
	ff.setup()

	ppb = PixelParallelBuilder()
	syn = []
	for x in Lw:
		mfn = ppb.build(ff, x_ways=x, y_ways=Lh)
		e = mfn.type_kernel_sizes(True)
		syn.append(e["n"])
		
	synapse.append(syn)

colors = ['b', 'deeppink', 'orange', 'purple','m', 'y', 'k']
marker = ['o', 's', '^', 'p', 'x']
lines = ['-','-.','--',':']
atts = {'marker':'s', 'color':'deeppink', 'markeredgecolor':'deeppink', 'markerfacecolor': 'none', 'markersize':4,'markeredgewidth':1.0, 'linestyle':'-.'}

f = figure(1,figsize=figsize)
plt.hold(True)

for i in range(len(synapse)):
	atts['marker'] = marker[i%len(marker)]
	atts['color'] = colors[i%len(colors)]
	atts['markeredgecolor'] = colors[i%len(colors)]
	atts['linestyle'] = lines[i%len(lines)]
	plt.plot(Lw, synapse[i],label='Stride: %d'%conv_stride_lter[i],**atts)


plt.axis([0,max(Lw)+0.5,0,max(synapse[0])+40],fontsize=8)
plt.hold(False)
plt.xlabel("Block Size", fontsize=10)
plt.ylabel("Number of Synapses", fontsize=10)
plt.legend(prop={'size':8},loc=2)

for ax in f.get_axes():
	for label in ax.xaxis.get_majorticklabels():
		label.set_fontsize(8)
	for label in ax.yaxis.get_majorticklabels():
		label.set_fontsize(8)

plt.savefig("./fig7c.pdf", bbox_inches='tight')

