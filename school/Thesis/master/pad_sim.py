    
def sim_pad(img_cols=32, L=1, bleed=0, pad=0):

    
    X = range(img_cols)
    padded_bleed = bleed - 2*pad;
    assert (padded_bleed >= 0) and (img_cols % L == 0)
    
    pad_list, x_points, node_select = [],[],[]
    for i in range(0,pad):
        pad_list.append(padded_bleed+i)
        pad_list.append(img_cols-1-i)
    pad_list.sort()
    
    for g in pad_list:
        x_points.append(g/L)
        node_select.append(g%L)
        
    print 'Bleed:', bleed, ", pad: ",pad, ', PAD_list: ', pad_list
    print "Selected Node: ", node_select, "\n\t    x: ", x_points
    print '\n' 
    
    


#sim_pad(img_cols=8, L=2, bleed=2, pad=1)
#sim_pad(img_cols=8, L=4, bleed=2, pad=1)
#sim_pad(img_cols=8, L=8, bleed=2, pad=1)
#sim_pad(img_cols=8, L=2, bleed=6, pad=1)
#sim_pad(img_cols=8, L=2, bleed=6, pad=2)
#sim_pad(img_cols=8, L=2, bleed=6, pad=3)

sim_pad(img_cols=15, L=3, bleed=8, pad=1)
sim_pad(img_cols=15, L=5, bleed=8, pad=1)
sim_pad(img_cols=15, L=3, bleed=8, pad=2)
sim_pad(img_cols=15, L=5, bleed=8, pad=2)
sim_pad(img_cols=15, L=3, bleed=8, pad=3)
sim_pad(img_cols=15, L=5, bleed=8, pad=3)
