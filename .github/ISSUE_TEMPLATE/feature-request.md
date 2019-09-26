---
name: Feature request
about: Add support to more fields or function enhancement
title: Add fields for CMIP6_xx table (incremental)
labels: enhancement
assignees: ''

---

## The Following fields are now supported:
Fields in 3hr-averaged output (cam.h3,clm.h2)
```
'huss      ','QREFHT
```
Fields in 3hr-instantly output (cam.h4, clm.h3):
```
'clt       ','CLDTOT
'hfls      ','LHFLX
```
## The Following fields are not available in the model output:
```
'uas       ','UAS
'vas       ','VAS
```

### Sample cmorized fields
under /scratch/yanchun/cmorout/NorESM2-LM/historical/v20190815/3hr
```
clt_3hr_NorESM2-LM_historical_r1i1p1f1_gn_201001010130-201002282230.nc
hfls_3hr_NorESM2-LM_historical_r1i1p1f1_gn_201001010130-201002282230.nc
```

## Commit
ca5b932
