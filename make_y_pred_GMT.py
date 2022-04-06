#convert y_pred to GMT readable values
import numpy as np
import matplotlib.pyplot as plt

ID = np.load("/Users/jtlin/Documents/Project/MLARGE/data/Run031_test_EQID.npy")

y = np.load("/Users/jtlin/Documents/Project/MLARGE/data/y_test031_backScaled.npy")
y_pred = np.load("/Users/jtlin/Documents/Project/MLARGE/data/y_pred_test031_backScaled.npy")

#--------------
prefix = 'Chile_full_new'
run_name = '024513'
#--------------

idx = np.where(ID==prefix+'_'+run_name)
print('Number of testing cases found:%d'%(len(idx)))
idx = idx[0][0]
print(idx)

#idx = 233 #manually asign the index! I want to use Chile_full_new_024513 so check if ID[idx] is that case

plt.figure()
for comp in range(5):
    plt.subplot(5,1,comp+1)
    plt.plot(y[idx,:,comp],'k')
    plt.plot(y_pred[idx,:,comp],'r')


fout = open('./Test031_pred/'+ID[idx]+'.txt','w')
fout.write('#time Mw Lon Lat Length Width   realMw realLon realLat realLength realWidth\n')
#loop through time
for i in range(y[idx].shape[0]):
    t = i*5+5
    fout.write('%d %f %f %f %f %f    %f %f %f %f %f\n'%(t, y_pred[idx,i,0], y_pred[idx,i,1],y_pred[idx,i,2],y_pred[idx,i,3],y_pred[idx,i,4], y[idx,i,0], y[idx,i,1],y[idx,i,2],y[idx,i,3],y[idx,i,4],    ))

fout.close()
