# noresm2cmor

The is a feature branch for cmorizing Non-CMIP experiments.

## A quick example for setting up a non-cmip experiment:
(For detailed information for this tool, please refer to the [main branch](://github.com/NorESMhub/noresm2cmor/blob/9b4b7db16bb110095bb13d4f628ea744a062220c/README.md))

### Prerequisite
* The following steps are tested under the [NIRD IPCC container node](ipcc.nird.sigma2.no)
*

### Installation

Setup environment
```bash
 source /opt/intel/compilers_and_libraries/linux/bin/compilervars.sh -arch intel64 -platform linux
```

Download `noresm2cmor`
```bash
cd ~/
git clone -b noncmip https://github.com/NorESMhub/noresm2cmor
```

Build 
```bash
cd noresm2cmor/build/  
make -f Makefile_cmor3mpi.nird_intel
```

### Setup receipe with `cmorSetup.sh`

This is an example to set up a non-CMIP experiment `generic` with the `historical` experiment (also non-CMIP) as template:
```bash
cd ~/noresm2cmor/workflow
./cmorSetup.sh --casename=NHIST_02_f19_tn14_20190801 --model=NorESM2-LM --expid=generic --expidref=historical --version=v20210818 --year1=1850 --yearn=1949 --realization=1 --physics=1 --forcing=1 --mpi=DMPI --ibasedir=/projects/NS9560K/noresm/cases --obasedir=/scratch/$USER/cmorout --noncmip=true

```
the namelists are configured under:
```
~/noresm2cmor/namelists/CMIP6_NorESM2-LM/generic
```
and a script to submit the job is created `cmor_${casename}.sh`.

Check the settings in the script and namelist. If one wants to modify the 'Control Vocabulary', replace the symbolic links under tables/ with the changed corresponding *.json files.

Then submit the cmorization job:
```bash
./cmor_NHIST_02_f19_tn14_20190801.sh
```

The cmorized output is found under:
```
/scratch/$USER/cmorout
```

