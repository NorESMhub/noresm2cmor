# noresm2cmor

**************************************************************************************************

** This verion is now under development for CMIP7, and the following documentation is out-dated **

**************************************************************************************************

## 1. General

noresm2cmor is a FORTRAN based command line tool for post-processing NorESM 
output using the Climate Model Output Rewriter (cmor) libraries.

System, model, experiment and variable information are set in namelist files 
which noresm2cmor reads during its execution. 


## 2. Installation

### 2.1 Download

Download noresm2cmor with
```bash
 git clone https://github.com/NorESMhub/noresm2cmor
```
Set the `CMOR_ROOT` enviroment variable in your `.bashrc`. For example, if you clone the code to your home directory, then set
```bash
export CMOR_ROOT=~/noresm2cmor
```
### 2.2 Build 
```bash
# Change directory 
cd noresm2cmor/build/  
```

Make a copy of Makefile.nird_intel - e.g., Makefile.xxx - and customize 
your make file.

**IMPORTANT**:

The build of noresm2cmor requires the fortran version of the cmor-library. The CMOR-related libraries are currently installed on NIRD under: `/projects/NS9560K/cmor/cmorlib`. The `Makefile.xxx` has by default linked to this installed library. For example, `Makefile_cmor3mpi.nird_intel` has linked to the installed CMOR libbries compiled with the `Intel` compiler, at `/projects/NS9560K/cmor/cmorlib/nird_intel`.

If you are going to build the CMOR dependent libraries by yourself, instead of using the installed one on NIRD, please refer to CMOR documentation for installation, here](https://cmor.llnl.gov/mydoc_cmor3_github) for more instructions.

Build the `noresm2cmor` with Makefile, for example,
```
 make -f Makefile_cmor3mpi.nird_intel
```
, using Intel compiler and with MPI enabled.

### 2.3 Installation of grid data and sample input (use only if data not available)

Change directory to noresm2cmor/scripts

Run installation script for grid data 
 ./install_griddata.sh <absolute path to folder where grid data should be stored> 

Run installation script for input data sample 
 ./install_sampledata.sh <absolute path to folder where sample input should be stored> 

### 2.4 Set paths to grid data, sample data and output folder  

Change directory to noresm2cmor/scripts

If install_griddata.sh not used, set path to grid data 
 ./setpath_griddata.sh <absolute path to folder where grid data is stored>

If install_sampledata.sh not used, set path to sample data 
 ./setpath_sampledata.sh <absolute path to folder where sample input is stored>

Set path to output folder
 ./install_cmorout.sh <absolute path to folder where CMOR output should be stored>

## 3 Run the noresm2cmor program

### 3.1 A quick setup from template
Run the script `workflow/cmorSetup.sh` to setup namelist template:
```bash
$ ./cmorSetup.sh

 Usage:
 ./cmorSetup.sh \
  -c=[casename]     # e.g., NHIST_f19_tn14_20190625 \
  -m=[model]        # e.g., NorESM2-LM, NorESM2-MM, NorESM1-F,NorESM1-M \
  -e=[expid]        # e.g., historical, piControl, ssp126, omip2, etc \
  -v=[version]      # e.g., v20200702 \
  -y1=[year1]       # e.g., 1850 \
  -y2=[yearn]       # e.g., 2014 \
  -r=[realization]  # e.g., 1,2,3 \
  -p=[physics]      # e.g., 1,2,3 \
  -i=[ibasedir]     # path to model output. e.g., /projects/NS9560K/noresm/cases \
  -o=[obasedir]     # path to cmorized output. e.g., /projects/NSxxxxK/CMIP6/cmorout \%
```
For example,
```bash
./cmorSetup.sh -c=NFHISTnorpibc_aeroxidonly_03_f19_20200118 \
-m=NorESM2-LM \
-e=piClim-histaer \
-v=v20200702 \
-y1=1850 -y2=2014 \
-r=3 -p=2 \
-i=/projects/NS9560K/noresm/cases \
-o=/projects/NS9034K/CMIP6/.cmorout
```

Then under `$CMOR_ROOT/namelists/CMIP6_${model}/${expid}`, the namelists are configured under: `${version}/`,
and a script to submit the job is created `cmor_${casename}.sh`.

Check the settings in the script and namelist. One can start the cmorization by exectuting the script `cmor_${casename}.sh`

### 3.2 A full workflow from scratch
A more general workflow of cmorization if found at the wiki page:
https://github.com/NorESMhub/noresm2cmor/wiki/Workflow

