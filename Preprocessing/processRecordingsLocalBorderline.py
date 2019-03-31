#!/usr/bin/python

import psutil
import time
import sys
import subprocess
import os, glob
import fnmatch

# dataFolder = '/balrog_zpool/BWMouse3/ReadyToCluster/'
dataFolder = '/SSD2TB/wedge_160627/'


def main(argv):
    total = len(sys.argv)
    if total > 1:
        waittime = float(sys.argv[1])
        numJobs = float(sys.argv[2])
    else:
        waittime = 180
        numJobs = 4

        print('searching for unprocessed recordings...')
        for dirName, subdirList, fileList in os.walk(dataFolder):
	        # print('1')
            for file in fileList:
            	# print('2')
                #print(dirName)
                if (file.startswith(dirName.split('/')[-1]) | file.startswith("amplifier")) & file.endswith(".dat"):   # check that a .dat exists in this folder
                    # exitFlag = True
                    os.chdir(os.path.abspath(dirName))
                    print(os.path.abspath(dirName))
                    #print('3')
                    xmlfile = glob.glob("*xml")
                    if len(subdirList) < 11:  # check that the shank directories don't already exist
                        matlab_command = ['matlab -nodesktop -r "addpath(genpath(\'/mnt/brendon4/Dropbox/Processes/pythonKlusta\')); \
                            makeProbeMapKlusta2(\'' + os.path.abspath(dirName)  + '\',\'' + xmlfile[0] + '\');exit"']
                        subprocess.call(matlab_command[0],shell=True)  #generate folder structure and .prm/.prb files
                        time.sleep(10) # let the process get going...
                    for root, shankdirs, defaultFiles in os.walk(dirName):
                        for shank in shankdirs:
                            # if not fnmatch.fnmatch(shank,'.*'):
                            if shank.isdigit():
                            	# print(root)
                            	# print(shank)
                                os.chdir(shank)
                                for file in os.listdir('.'):
                                    if fnmatch.fnmatch(file, '*.prm'):
                                        if not any(fnmatch.fnmatch(i,'*.out') for i in os.listdir('.')):
                                            toRun = ['(nohup klusta ' + file + ' && touch job.done) &']  # create the spikedetekt command to run
                                            cpu = psutil.cpu_percent(5)
                                            while cpu > 95:
                                                print('current cpu usage: %f' % cpu)
                                                time.sleep(waittime) # wait until resources are available
                                                cpu = psutil.cpu_percent(5)
                                            mem = psutil.virtual_memory()
                                            while mem.percent > 75:
                                                print('current memory usage: %f' % mem.percent)
                                                time.sleep(waittime) # wait until resources are available
                                                mem = psutil.virtual_memory()
                                            while getCurrentJobs() >= numJobs:
                                                print('waiting for %f jobs to finish...' % getCurrentJobs())
                                                time.sleep(waittime)
                                            subprocess.call(toRun[0],shell=True)
                                            print(['starting... ' + toRun[0]])
                                            time.sleep(waittime)  # let one process start before generating another
                                os.chdir('..')
                                # break   
                            # if exitFlag:
                                # break             # 
        time.sleep(waittime)

def getCurrentJobs():
    detekt = "phy"
    kk = "klustakwik"
    klusta = "klusta"
    count = 0
    for proc in psutil.process_iter():
        if (kk.endswith(proc.name)):
            count+=1
        if (detekt.endswith(proc.name)):
            count+=1
        if (klusta.endswith(proc.name)):
            count+=1
    return count



if __name__ == "__main__":
    main(sys.argv[1:])
