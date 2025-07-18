
Simulation of MALTA-like Structures
-----------------------------------

A C++ library and framework for simulating MAPS sensors based on the MALTA design. Designed to with three goals in mind:

- A lightweight library (`libMaltaSim`) implementing a fast simulation of a MALTA sensor and any digital functionality. It allows third-party detector simulation frameworks to incorporate MALTA sensors in their design.
- Implementation of MALTA behaviour for the Allpix Squared simulation program. Consists of a collection of AllPix Squared modules, together referred to as `libMaltaAllPix2`.
- A framework levarating AllPix Squared to validate the implementation and understand the behaviour of MALTA-like structures using simulation. Consists of configuration files for the `allpix` program and plotting scripts.

## References
- [pymaltasim](https://gitlab.cern.ch/malta/pymaltasim/): A predecessor Python-based framework.

## Installation

The `maltasim` build process follows a basic CMake process and principle should work on any computer that has the necessary dependencies installed.

Dependencies:

- [Allpix Squared](https://allpix-squared.docs.cern.ch/)

The following sub-sections contain detailed instructions for two recommended environments. The commands should be run inside a clone of this repository.

### lxplus (or any Alma 9 PC with CVMFS installed)

A typical environment for most particle physics applications. Make sure to setup the Allpix Squared installation at the start of every new session.

```shell
source /cvmfs/clicdp.cern.ch/software/allpix-squared/3.1.2/x86_64-el9-gcc12-opt/setup.sh
cmake -S. -Bbuild
cmake --build build
```

### Docker

Leverage the official `gitlab-registry.cern.ch/allpix-squared/allpix-squared:v3.1.2` Docker image. Useful if you don't have easy access to a computer running Alma 9 with CVMFS. Run the following commands inside an `allpix-squared` container.

```shell
cmake -S. -Bbuild -DAllpix_DIR=/usr/local/share/cmake
cmake --build build
```

The repository CI is based around this method.

## Running

A convenient setup script is created inside the build directory. It adds all the Allpix Squared modules to the `LD_LIBRARY_PATH`. If you loaded Allpix Squared from CVMFS, then it is automatically loaded too. At the start of your session, run the following.

```shell
source build/setup.sh
```

An example of running a simplified version of the MALTA2 telescope with a DUT (another MALTA2 sensor) implemented in Allpix Squared. For now a linear electric field is assumed.

```shell
allpix -c config/telescope_sim.conf
```

## Step by step Instruction for B'ham users

### Work on UoB particle physics group cluster
This simulation package along with the MALTA software has been installed on the computing cluster for UoB PP group, [click here](http://www.ep.ph.bham.ac.uk/index.php?page=guide/systeminfo) for more information about the cluster. Please contact [mark.slater@cern.ch](mark.slater@cern.ch) to set up an account.

Log into the cluster when you get an account by

```shell
ssh -Y user@eprexa.ph.bham.ac.uk
```

Both **maltasim** and **MaltaSW** have been installed under `/disk/moose/eic/MALTA`, which are responsible for simulation and reconstruction respectively. So, change your current path to `/disk/moose/eic/MALTA` by

```shell
cd /disk/moose/eic/MALTA
```

### configure and run maltasim

#### Swich to AlmaLinux9 
Both packages are installed in AlmaLinux 9 container, since **MaltaSW** is built on AlmaLinux 9. You can easily check in by typing

```shell
alma9
```

Then go to
```shell
cd maltasim
```

#### check the git branch and repository
There are two branches for **maltasim**, *main* and *maltasim_bham*, and *maltasim_bham* is currently our 
working branch. To check your current branch, 
```shell
git branch -v
```
if you are not on the working branch, please do
```shell
git checkout maltasim_bham
```
Then, pull the lateset repository by
```shell
git pull
```
[click here](https://docs.gitlab.com/tutorials/) for GitLab instructions

#### File description
| file |location|description|
|------|----------|-----------|
|Malta2TreeWriteModule.cpp|src/libMaltaAllPix2/Malta2TreeWriter| source file for Malta2TreeWriteModule|
|Malta2TreeWriterModule.hpp|src/libMaltaAllPix2/Malta2TreeWriter| head file|
|Hit.cpp|src/libMaltaSim|source file for toy monte carlo simulation (not implemented)|
|Hit.hpp|src/libMaltaSim|head file(not implemented)|
|telescope_sim.conf|config/|main configure file for MALTA allpix2 simulation|
|telescop.conf|config/|configure file for telescope geometry|
|malta_simple.conf|config/|a simple template of MALTA2 like pixel sensor|
|split_planes.py|share/|python file to split hit information according to planes|
|compile.sh|./|bash file for compiling, run `. compile.sh` after changes in source file|


#### grab allpix2 from cvmfs
Set up the Allpix Squared installation before your simulation
```shell
source /cvmfs/clicdp.cern.ch/software/allpix-squared/3.1.2/x86_64-el9-gcc12-opt/setup.sh
```

#### set the malta2 environment
Compile the source code for the first time
```
. compile.sh
```
Then source the environment every time after logged in.
```shell
source build/setup.sh
```

#### run simulation 
Before you run simulation, please comply with the naming rule for run number:

|Rule |Description | example|
|-----|------------|--------|
|999000-999998| Run number range|
999\*XY|X%2 == 0 for Y0 degrees of rotation of DUT,<br> else for Y5 degrees| 999020 -> 0 deg, <br> 999011 -> 5 deg



Okay, Let's do some simulations
```shell
allpix -c config/telescope_sim.conf
```
You should have result ROOT file `run_999000.root` under `output/sim/run_999000`. `999000` is the run number left for simulation in **MaltaSW**. We need to split the hit information from the ROOT file according to planes (could be optimized in the future).
```shell
cd share
```
and run 
```
python split_planes.py
```
There should be some WriteBuffer failure Error (need to be fixed in the future), please ignore this.
We should have the run files needed by **MaltaSW** under `output/runs/run_999999`.


### run reconstruction in MaltaSW
The reconstruction is based on the **MaltaSW** from [Malta GitLab](https://gitlab.cern.ch/malta).  
#### run reconstruction
Shift to the reconstruction environment by
```shell
source MaltaSW/setup.sh
```
Then, 
```
cd MaltaSW/simulation
python MaltaDQ_Sim.py -r 999000 -p -c -t -a -d 
```
Details for the parameters are as blew
```shell
-r, Run number, 999000 by default for simulation
-p, prepare the data, add this only for the first time
-c, alignment
-t, tracking
-a, analysis
-d, for DUT
-w, cluster weights (not implemented in simulation yet) 

```
The reconstruction breaks down at the tracking stage. Optimization is in pregress (need to check the tag of timing of each event).