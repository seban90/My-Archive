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

#powers_1x = [1.4, 1.2, 1.2, 0.6] 
power_1x = [1.4+0.668, 1.2+0.661, 1.2+0.661, 0.6+0.653] 
#powers_2x = [0, 2.8, 2.4, 1.6]
power_2x = [0, 2.8+0.689, 2.4+0.689, 1.6+0.69]
power_4x = [0,0,0,3.4+0.707]

print power_1x, power_2x, power_4x

throu = [4882,9765,9765,19531]
eff_1x  = [throu[0]/power_1x[0], throu[1]/power_2x[1],throu[2]/power_2x[2],throu[3]/power_4x[3]]
eff_2x = [0,throu[0]/power_1x[1],throu[0]/power_1x[2],throu[1]/power_2x[3]]
eff_4x = [0,0,0,throu[0]/power_1x[3]]

print eff_1x, eff_2x, eff_4x
bs_str = ['(1,1)', '(2,1)','(1,2)','(2,2)']
bs2 = np.array([0,1,2,2.9])
bs = np.array(range(4))

fig = plt.figure(figsize=figsize)
ax = fig.add_subplot(111)

width = 0.3
rects1 = ax.bar(bs2, eff_1x, width, color='blue',linewidth=0)
rects2 = ax.bar(bs2+width,  eff_2x,width,color='red',linewidth=0)
rects3 = ax.bar(bs2+2*width,eff_4x,width,color='deeppink',linewidth=0)
ax.set_xlim(-width,len(bs)+width)
ax.set_ylim(1000,6100)
ax.set_ylabel('Performance per Watt [Images/s/W]',fontsize=8)
ax.set_xlabel('Block Size',fontsize=8)

plt.xlabel("Block Size", fontsize=10)

ax.set_xticks(bs+width)
ax.set_yticks([2000,4000,6000])
xtick_name = ax.set_xticklabels(bs_str)
ytick_name = ax.set_yticklabels(['2K','4K','6K'])
plt.setp(xtick_name, rotation=0,fontsize=8)
plt.setp(ytick_name, rotation=0,fontsize=8)

ax.legend((rects1[0],rects2[0],rects3[0]),('160Mhz','80MHz', '40MHz'),loc='best',fontsize=10)

for ax in fig.get_axes():
	for label in ax.xaxis.get_majorticklabels():
		label.set_fontsize(8)
	for label in ax.yaxis.get_majorticklabels():
		label.set_fontsize(8)

plt.savefig("./fig8b.pdf",bbox_inches='tight')
