---
name: CMORization request
about: Create one CMORize request Issue for each single experiment_id
title: "[CMORization request] experiment_id (NOT casename)"
labels: task
assignees: ''

---

### Mandatory information:

**Full path to the case(s) of the experiment on NIRD**
e.g., /projects/projects/NS9560K/noresm/cases
or
e.g., /projects/projects/NS2345K/noresm/cases

**experiment_id**
e.g., historical

**CASENAME(s) and years to be CMORized**
e.g., 
NHIST_f19_tn14_20190625, 1850-1948
NHIST_f19_tn14_20190710,  1950-2014

### Optional information
(additional information, if the experiment is branched/hybrid restart from previous parent experiment; you may find more information relevant to the experiment_id here: https://github.com/NorwegianClimateCentre/noresm2cmor/blob/master/tables/CMIP6_CV.json)

**parent_experiment_id**
e.g., 
piControl
historical
no parent
etc.,...

**parent_experiment_rip**
e.g., r1i1p1

**parent_time_units**
e.g.,
'days since 0421-01-01'

**branch_method**
e.g.,
'Hybrid-restart from year 1600-01-01 of piControl',

**other information**
(provide other information that might be useful)
e.g., realisation, initialisation, etc...
and the cases name and path to the parent experiment, etc
