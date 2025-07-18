# this is a python script

#=======================================================================
#   Copyright (C) 2025 Univ. of Bham  All rights reserved.
#   
#   		FileName：		split_planes.py
#   	 	Author：		LongLI <long.l@cern.ch>
#   		Time：			2025.04.10
#   		Description：
#
#======================================================================

"""
For temporary use, shold be modified
extract MALTA tree from the original file and split 
in to different files according to the plane
"""

import ROOT
import sys
import os

data_path = "../output/sim"

for _, dirs, _ in os.walk(data_path):
    for dir in dirs:
        root_dir = os.path.join(data_path, dir)
        for currentDir, _, rootnames in os.walk(root_dir):
            for rootname in rootnames:
                if ".root.root"  in rootname: continue # in case to read the split data 
                fullpath = os.path.join(root_dir, rootname)
                rootfile = ROOT.TFile.Open(fullpath)
                if not rootfile:
                    print("File not open! please check the file path")
                    exit(-1)
                maltadata = rootfile.Get("MALTA_DATA")
                keys = maltadata.GetListOfKeys()
                for key in keys:
                    
                    plane = maltadata.Get(key.GetTitle())
                    maltatree = plane.Get("MALTA")
                    
                    
                    #outTree = maltatree.CloneTree()
                    # write out the MALTA Tree
                    outname = rootname.split(".")[0]
                    outname += "_"
                    if key.GetTitle() == "dut":
                        outname += "6"  # change here in case of 2 DUTs  DUT1 -> 6, DUT2 ->7
                    else:
                        outname += key.GetTitle().split("e")[-1]
                    # suffix
                    outname += ".root.root"
                    print(outname)
                    
                    
                    outpath = os.path.join(data_path.replace("sim", "runs"), dir)
                    if not os.path.exists(outpath):
                        os.makedirs(outpath)
                    outname = os.path.join(outpath, outname)
                    
                    outroot = ROOT.TFile.Open(outname, "RECREATE")

                    outTree = maltatree.CloneTree()
                    outTree.Write()

                    outroot.Close()
                    


                    
            
