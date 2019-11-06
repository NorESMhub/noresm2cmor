#!/bin/bash
set -e

source ../scripts/runcmor_single.sh

#version=v20190920
#version=v20190920b #set fx,Ofx to false
version=v20190920c  #set fx,Ofx to false

# initialize
login0=false
login1=false
login2=false
login3=false

# set active
#login0=true
#login1=true
login2=true

if $login0
then
#----------------
# 1pctCO2-cdr, part1
#----------------
CaseName=N1PCT_f19_tn14_CDR_20190926
expid=1pctCO2-cdr
#login0
years1=(141 $(seq 150 10 270))
years2=(149 $(seq 159 10 279))

runcmor -c=$CaseName -e=$expid -v=$version -r=$real -yrs1="${years1[*]}" -yrs2="${years2[*]}"
#---
fi
#---
if $login1
then
#----------------
# 1pctCO2-cdr, part2
#----------------

CaseName=N1850_f19_tn14_CDRxt_20191011
expid=1pctCO2-cdr
#login0
years1=($(seq 280 10 300))
years2=($(seq 289 10 309))
#---
fi
#---
#---
if $login2
then
#----------------
# 1pctCO2-cdr, part3
#----------------

CaseName=N1850_f19_tn14_CDRxt_20191011
expid=1pctCO2-cdr
#login0
years1=($(seq 310 10 390))
years2=($(seq 319 10 399))

runcmor -c=$CaseName -e=$expid -v=$version -r=$real -yrs1="${years1[*]}" -yrs2="${years2[*]}"
#---
fi
#---

