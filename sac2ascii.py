# convert waveform sac files to one ascii file so that GMT can read
import obspy
import argparse
import glob
import pandas as pd

# parse arguments
parser = argparse.ArgumentParser()
parser.add_argument("-path", "--path", help="full path of the waveform directory", type=str)
args = parser.parse_args()
path_sacs = args.path


D = pd.read_csv("/Users/jtlin/Documents/Project/MLARGE/data/Chile_GNSS.gflist",names=['name','lon','lat'],skiprows=1,sep='\s+',usecols=[0,1,2])

print('In path:',path_sacs)

fout = open(path_sacs+"/timeseries.txt",'w')
fout.write('#lon lat name time E N Z\n') # header
Z_sacs = glob.glob(path_sacs+"/*.LYZ.sac")
for Z_sac in Z_sacs:
    E_sac = Z_sac.replace('.LYZ.','.LYE.')
    N_sac = Z_sac.replace('.LYZ.','.LYN.')
    Z = obspy.read(Z_sac)
    E = obspy.read(E_sac)
    N = obspy.read(N_sac)
    time = Z[0].times()
    Z = Z[0].data
    E = E[0].data
    N = N[0].data
    stname = Z_sac.split("/")[-1].split(".")[0]
    stlo = D[D['name']==stname].lon
    stla = D[D['name']==stname].lat
    for i,t in enumerate(time):
        fout.write('%f %f %s %f %f %f %f \n'%(stlo,stla,stname,t,E[i],N[i],Z[i]))

fout.close()
