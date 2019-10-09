---
name: Add CMIP6_xxx table
about: Add support to table or add fields to
title: Add CMIP6_xxx table
labels: ''
assignees: ''

---

The Following fields are now supported:

Fields in  xxx-averaged output (e.g., cam.h3,clm.h2)
```
'huss      ','QREFHT
'mrro      ','QRUNOFF
...
```

The Following fields are not available in the model output:
```
'uas       ','UAS
'vas       ','VAS
```

**Sample output**
 -  /scratch/yanchun/cmorout/NorESM2-LM/historical/v20190815/3hr

**Commit**
- ca5b932
