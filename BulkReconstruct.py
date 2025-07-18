import os
import subprocess
import ROOT
ROOT.gSystem.Load("/disk/moose/bilpa/MALTA/MaltaSW/installed/x86_64-el9-gcc13-opt/lib/libMaltaTbAnalysis.so")

# --- Configuration ---
runs_base_path = "../simulation"
script_path = "MaltaDQ_Sim.py"

# Prefix + suffix list to generate full run numbers
prefix = "999"
suffixes = [
    "011", "012", "013", "014", "015", "016",
    "020", "021", "022", "023", "024", "025", "026"
]

# --- Change working directory ---
os.chdir(runs_base_path)

# --- Loop through generated run numbers ---    
for suffix in suffixes:
    run_number = prefix + suffix
    print(f"▶️ Running MaltaDQ_Sim.py for run {run_number}...")
    
    cmd = [
        "python", script_path,
        "-r", run_number,
        "-p", "-c", "-t", "-a", "-d"
    ]

    try:
        print("Running command: ", cmd )
        subprocess.run(cmd, check=True)
    except subprocess.CalledProcessError as e:
        print(f"❌ Error running command: {' '.join(cmd)}")
        print(f"    ↳ Exception: {e}")
