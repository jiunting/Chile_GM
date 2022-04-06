#convert y(parameterized) and y_pred(Model) to fault file, and convert it to boundary for GMT plot
import numpy as np
import matplotlib.pyplot as plt
from mlarge import postprocessing



def find_bound(fault):
    from scipy.spatial import ConvexHull
    # input fault data, output the boundary
    points = fault[:,1:3]
    hull = ConvexHull(points)
    return np.hstack([points[hull.vertices,0].reshape(-1,1),points[hull.vertices,1].reshape(-1,1)])
    

ID = np.load("/Users/jtlin/Documents/Project/MLARGE/data/Run031_test_EQID.npy")

#--------------
prefix = 'Chile_full_new'
run_name = '024513' #this is an example of long rupture(1000+km)
run_name = '021761'
run_name = '024898'
run_name = '023494'
run_name = '021761'
run_name = '025413'
run_name = '026294'
#--------------

y = np.load("/Users/jtlin/Documents/Project/MLARGE/data/y_test031_backScaled.npy")
y_pred = np.load("/Users/jtlin/Documents/Project/MLARGE/data/y_pred_test031_backScaled.npy")
idx = np.where(ID==prefix+'_'+run_name)[0]
print('Number of testing cases found:%d'%(len(idx)))
idx = idx[0]
print(idx)
#idx = 233 #manually asign the index! I want to use Chile_full_new_024513 so check if ID[idx] is that case

fault = np.genfromtxt("/Users/jtlin/Documents/Project/MLARGE/data/chile.fault")
fout1 = open("./output/ruptures/%s_subduction.%s_true.fault"%(prefix,run_name),'w')
fout2 = open("./output/ruptures/%s_subduction.%s_model.fault"%(prefix,run_name),'w')
for epo in range(y.shape[1]):
    Mw_true = y[idx,epo,0]
    Mw_model = y_pred[idx,epo,0]
    center_true = [y[idx,epo,1],y[idx,epo,2]]
    center_model = [y_pred[idx,epo,1],y_pred[idx,epo,2]]
    # get the closest point from fault file to get strike/dip
    dist_fault = ((fault[:,1]-center_true[0])**2 + (fault[:,2]-center_true[1])**2)**0.5
    idx1 = np.where(dist_fault==dist_fault.min())[0][0]
    strike_true = fault[idx1,4]
    dip_true = fault[idx1,5]
    depth_true = fault[idx1,3]
    center_true.append(depth_true)
    # get the closest point from fault file to get strike/dip
    dist_fault = ((fault[:,1]-center_model[0])**2 + (fault[:,2]-center_model[1])**2)**0.5
    idx1 = np.where(dist_fault==dist_fault.min())[0][0]
    strike_model = fault[idx1,4]
    dip_model = fault[idx1,5]
    depth_model = fault[idx1,3]
    center_model.append(depth_model)
    #fault length/width
    length_true = max(10,y[idx,epo,3]) # the min length should be greater than 10km
    width_true = max(10,y[idx,epo,4])  # the min width should be greater than 10km
    length_model = max(10,y_pred[idx,epo,3]) # the min length should be greater than 10km
    width_model = max(10,y_pred[idx,epo,4])  # the min width should be greater than 10km
    # generate fault file
    F_true = postprocessing.fault_tool(Mw_true,center_true,strike_true,dip_true,length_true,width_true,fout=False)
    F_true.gen_fault()
    F_model = postprocessing.fault_tool(Mw_model,center_model,strike_model,dip_model,length_model,width_model,fout=None)
    F_model.gen_fault()
    # find boundary of the fault
    if F_true.F[0].shape[0]>=4:
        bound_true = find_bound(F_true.F[0])
    else:
        mean_lon = np.mean(F_true.F[0][:,1])
        mean_lat = np.mean(F_true.F[0][:,2])
        bound_true = np.array([[mean_lon-0.01,mean_lat-0.01],
                     [mean_lon+0.01,mean_lat-0.01],
                     [mean_lon+0.01,mean_lat+0.01],
                     [mean_lon-0.01,mean_lat+0.01],
                     [mean_lon-0.01,mean_lat-0.01]])
    if F_model.F[0].shape[0]>=4:
        bound_model = find_bound(F_model.F[0])
    else:
        mean_lon = np.mean(F_model.F[0][:,1])
        mean_lat = np.mean(F_model.F[0][:,2])
        bound_model = np.array([[mean_lon-0.01,mean_lat-0.01],
                     [mean_lon+0.01,mean_lat-0.01],
                     [mean_lon+0.01,mean_lat+0.01],
                     [mean_lon-0.01,mean_lat+0.01],
                     [mean_lon-0.01,mean_lat-0.01]])
    # write to file
    for i in bound_true:
        fout1.write('%f %f \\n'%(i[0],i[1]))
    fout1.write('%f %f \n'%(bound_true[0][0],bound_true[0][1]))# the first point
    for i in bound_model:
        fout2.write('%f %f \\n'%(i[0],i[1]))
    fout2.write('%f %f \n'%(bound_model[0][0],bound_model[0][1]))# the first point

fout1.close()
fout2.close()

'''
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
'''



'''
idx = 3486 #3550 #4965
plt.plot(y[idx,-1],'k')
plt.plot(y_pred[idx,-1],'m')
plt.show()


'''
