# Maltasim Summer Project 2025

This repo contains my 2025 Summer Project at the University of Birmingham, where I extended the CERN‑maintained Maltasim environment [Maltasim](https://gitlab.cern.ch/malta/maltasim/-/tree/maltasim_bham?ref_type=heads) to include realistic electric fields modeld off of the MALTA2 sensor in Allpix‑Squared simulation. Fields are generated via Sentaurus TCAD, and a suite of Python tools automates large‑scale runs & analysis.


## Overview

The main contributions in this repository are:
- **Sentaurus TCAD Project**: Creation of a Sentaurus TCAD project to generate realistic electric field profiles for detector simulations, this includes a Gaussian doping profile to make the electric field more structured.
- **Simulation Automation**: Scripts to automate running simulations across multiple angles, improving workflow efficiency. Examples are autonInclination.py and BulkReconstruct.py.


## Repository Structure and key locations

```
maltasim/TCAD/                                                                        # TCAD project files for electric field generation
maltasim/share/                                                                       # Scripts for automating simulation of runs and splitting planes
MaltaSW/bulk_reconstruction/                                                          # Bulk reconstruction analysis scripts
MaltaSW/MaltaTbAnalysis_SPS2021/simulation/PlottingScripts/                           # Tools and scripts for plotting results
README.md                                                                             # This file
```

## Getting Started

### Prerequisites

- **Sentaurus TCAD** (for electric field generation)
- **Allpix-Squared** (for detector simulation)
- Python 3.x and relevant libraries (`numpy`, `matplotlib`, etc.)

### Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/BHW270/maltasim-Summer-Project-2025.git
   cd maltasim-Summer-Project-2025
   ```
2.Follow Instructions under maltasim/README.md

### Usage

#### 1. Create the Sentarus project 
- Use the files maltasim/TCAD to create a new Sentarus TCAD project. Sde_std_dvs.cmd should be used in an SDE tool and sdevice_des.cmd should be used in an SDevice tool (some nodes will need to be created) Then run the SDE to create the geometry and SDevice to simulate the electric field.

#### 2. Export the electric field
- The Sentaurus TCAD project produces .tdr files for electric fields at different biases depending on the user input. These then need to be converted to a .init file for use in allpix-squared instructions can be found in this [presentation](https://indico.cern.ch/event/738283/contributions/3182969/attachments/1759855/2854982/slides_mmunker.pdf).
- The .conf required for the conversion can be found under maltasim/config/mesh_test.conf.

#### 3. Set up the simulation environment
- Follow the instructions on the maltasim [Maltasim](https://gitlab.cern.ch/malta/maltasim/-/tree/maltasim_bham?ref_type=heads) to set up the environment to simulate.

#### 4. Run the simulation over many angles 
- Use the python script maltasim/share/AutoInclination.py to run the allpix-squared simulation over many angles. To control the settings of the simulation alter the base file telescope_sim.conf, under the ELectricFieldReader place the file path for the electric field made with TCAD. [ElectricFieldReader module](https://allpix-squared.docs.cern.ch/docs/08_modules/electricfieldreader/) Autoinclination constructs a telescope_simAngle.conf file based off of this base file.
- These files are then run as an allpix squared simulation. The results are saved under maltasim/output/sim.

#### 5. Spit planes 
- Use split_planes.py found under maltasim/share/split_planes.py to split the events in the simulations into the different planes in the MALTA telescope.  
- This is used in the reconstruction process and the results are saved under maltasim/output/runs.
  
#### 6. Bulk Reconstruction
- The python script BulkReconstruction.py can then be used to reconstruct all the events over all the simulated angles, this works by automating the MaltaDQ_Sim.py script to run over many angles.
- For more detail on MaltaDQ_Sim.py check the original repository: [Maltasim](https://gitlab.cern.ch/malta/maltasim/-/tree/maltasim_bham?ref_type=heads). Results are saved under maltasim/output/proc.

## Acknowledgements

- Many thanks to Long Li and Karol Krizka for helping me with contributions to this project.
- Built on top of [Maltasim](https://gitlab.cern.ch/malta/maltasim/-/tree/maltasim_bham?ref_type=heads)
- Electric field generation with Sentaurus TCAD
- Detector simulation with Allpix-Squared

## Contact

For questions or collaboration, contact [BHW270](https://github.com/BHW270).
