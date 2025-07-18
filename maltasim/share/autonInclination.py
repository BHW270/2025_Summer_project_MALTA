import os
import subprocess

allpix_binary = "/cvmfs/clicdp.cern.ch/software/allpix-squared/3.1.2/x86_64-el9-gcc12-opt/bin/allpix"
base_config_path = "../config/telescope.conf"
base_sim_path = "../config/telescope_sim.conf"
output_dir = "../output/sim"


inclinations = range(0,65, 5)
#Custom conf
with open(base_config_path, "r") as file:
    base_lines = file.readlines()

for angle in inclinations:
    new_lines = []
    in_dut_block = False

    for line in base_lines:
        if line.strip().startswith("[dut]"):
            in_dut_block = True
            new_lines.append(line)
            continue 
        if in_dut_block and line.strip().startswith("orientation"):
            new_line = f"orientation = 0deg {angle}deg 90deg\n"
            new_lines.append(new_line)
            in_dut_block = False
        else:
            new_lines.append(line)   

    conf_name = f"telescope_{angle}.conf"
    conf_path = f"../config/{conf_name}"

    with open(conf_path, 'w') as file:
        file.writelines(new_lines)
#custom sim files
with open(base_sim_path, "r") as file:
    base_lines = file.readlines()

for angle in inclinations:
    #print(f"angle {angle}")
    new_lines = []
    in_det_block = False
    in_save_block = False
    for line in base_lines:
        if line.strip().startswith("[Allpix]"):
            in_det_block = True
            new_lines.append(line)
            continue 
        if in_det_block and line.strip().startswith("detectors_file "):
            new_line = f'detectors_file = "telescope_{angle}.conf"\n'
            print("new line",new_line)
            new_lines.append(new_line)
            in_det_block = False
            continue
        if line.strip().startswith("[Malta2TreeWriter]"):
            in_save_block = True
            new_lines.append(line)
            continue 
        if in_save_block and line.strip().startswith("file_name"):
            if angle == 0:
                coded_angle = "020"
            elif angle % 10 == 5:  # angles ending in 5
                # Use odd tens digit, calculate units digit
                units_digit = (angle + 5) // 10
                coded_angle = f"01{units_digit}"
            elif angle % 10 == 0:  # angles ending in 0
                # Use even tens digit, calculate units digit  
                units_digit = angle // 10
                coded_angle = f"02{units_digit}"
            else:
                raise ValueError(f"Angle {angle} cannot be encoded with this naming scheme")

            new_line = f'file_name = "../output/sim/run_999{coded_angle}/run_999{coded_angle}.root"\n'
            print("new line", new_line)
            new_lines.append(new_line)
            in_save_block = False
        else:
            new_lines.append(line)   

    conf_name = f"telescope_sim{angle}.conf"
    conf_path = f"../config/{conf_name}"


    with open(conf_path, 'w') as file:
        file.writelines(new_lines)
    
#finally run allpix
for angle in inclinations:
    #command will look something like allpix -c ../config/telescope_0.conf
    command = f"allpix -c config/telescope_sim{angle}.conf"
    print(f"Simulating at {angle} degrees")
    print(f"command:{command}")
    #subprocess.run(command, check=True, shell = True)


