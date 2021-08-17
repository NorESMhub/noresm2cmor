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

```bash
cd ~/noresm2cmor/workflow
./cmorSetup.sh --casename=NHIST_02_f19_tn14_20190801 --model=NorESM2-LM --expid=exp4test --expidref=historical --version=v20210811 --year1=2015 --yearn=2050 --realization=1 --physics=1 --forcing=1 --mpi=DMPI --ibasedir=/projects/NS2345K/noresm/cases --obasedir=/projects/NS9034K/CMIP6/.cmorout

cd ~/noresm2cmor/namelists/CMIP6_NorESM2-LM/exp4test
```
the namelists are configured under: `$version/`
and a script to submit the job is created `cmor_${casename}.sh`.

Check the settings in the script and namelist.

Then submit the cmorization job:
```bash
./cmor_NHIST_02_f19_tn14_20190801.sh
```

