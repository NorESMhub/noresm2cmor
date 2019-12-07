      MODULE m_namelists 
c
      IMPLICIT NONE 
c
c --- Namelist limits 
      INTEGER, PARAMETER :: rowmax=200,colmax=3,lenmax=200
      INTEGER, PARAMETER :: slenmax=1024,smax=10  
c
c --- System namelist
      CHARACTER(LEN=slenmax), SAVE :: ibasedir,obasedir,tabledir,
     .  griddata
      LOGICAL, SAVE :: createsubdirs,forcefilescan,verbose
      NAMELIST /sys/
     .  ibasedir, 
     .  obasedir, 
     .  tabledir,
     .  griddata,
     .  createsubdirs,
     .  forcefilescan,
     .  verbose
c
c --- Model namelist 
      CHARACTER(LEN=slenmax), SAVE :: 
     .  model_id,institute_id 
      CHARACTER(LEN=slenmax), DIMENSION(smax), SAVE :: 
     .  institution,source,references,contact
      CHARACTER(LEN=(slenmax+1)*smax), SAVE :: 
     .  institution1,source1,references1,contact1
      CHARACTER(LEN=slenmax), SAVE :: tagoyr,tagoyrbgc,tagomon,
     .  tagomonbgc,tagoday,tagodaybgc,tagimon,tagiday,tagamon,tagaday,
     .  taga6hr,taga6hri,taga3hr,taga3hri,taglmon,taglday,tagl3hr,
     .  tagl3hri
      CHARACTER(LEN=slenmax), SAVE :: 
     .  secindexfile,ocngridfile,ocninitfile,ocnmertfile,rhotablesuff,
     .  atmgridfile,ocnregnfile
      LOGICAL, SAVE :: linebreaks
#ifdef CMOR3
      CHARACTER(LEN=slenmax), SAVE :: 
     .  parent_source_id,coordtable,namelist_file_json,
     .  atmgrid,atmgrid_label,atmgrid_resolution,
     .  ocngrid,ocngrid_label,ocngrid_resolution,
     .  icegrid,icegrid_label,icegrid_resolution,
     .  lndgrid,lndgrid_label,lndgrid_resolution
#endif 
      NAMELIST /model/
#ifdef CMOR3
     .  parent_source_id, 
     .  atmgrid,atmgrid_label,atmgrid_resolution,
     .  ocngrid,ocngrid_label,ocngrid_resolution,
     .  icegrid,icegrid_label,icegrid_resolution,
     .  lndgrid,lndgrid_label,lndgrid_resolution,
#endif 
     .  model_id,
     .  source,              
     .  institution,
     .  institute_id, 
     .  references,
     .  contact,
     .  tagoyr,
     .  tagoyrbgc,
     .  tagomon,
     .  tagomonbgc,
     .  tagoday,
     .  tagodaybgc,
     .  tagimon,
     .  tagiday,
     .  tagamon,
     .  tagaday,
     .  taga6hr,
     .  taga6hri,
     .  taga3hr,
     .  taga3hri,
     .  taglmon,
     .  taglday,
     .  tagl3hr,
     .  tagl3hri,
     .  rhotablesuff, ! hidden
#ifdef CMOR3
     .  coordtable, ! hidden
#endif 
     .  secindexfile,
     .  atmgridfile,
     .  ocngridfile,
     .  ocninitfile,
     .  ocnmertfile,
     .  ocnregnfile,
     .  linebreaks  ! hidden
c
c --- Experiment namelist
      CHARACTER(LEN=slenmax), SAVE :: 
     .  casename,experiment_id,parent_experiment_id,
     .  parent_experiment_rip,isubdir,osubdir,membertag
      CHARACTER(LEN=slenmax), DIMENSION(smax), SAVE :: 
     .  history,comment,forcing
      CHARACTER(LEN=(slenmax+1)*smax), SAVE :: 
     .  history1,comment1,forcing1
      INTEGER, SAVE :: realization,exprefyear,year1,yearn,month1,monthn
      REAL(KIND=8), SAVE :: branch_time
      LOGICAL, SAVE :: dry_run,plevdummy,readdummy,add_fill_day,
     .  do_fx,do_oyr,do_oyrbgc,do_amon,do_omon,do_omonbgc,do_oimon,
     .  do_lmon,do_limon,do_aero,do_day,do_6hrlev,do_6hrlevi,do_6hrplev,

     .  do_3hr,do_3hri,do_2d,do_3d,do_xd,do_bgc,
     .  newcolumnorder,scanallfiles
      INTEGER, SAVE :: 
     .  physics_version=1,initialization_method=1,ivnmpos=1,ovnmpos=2
#ifdef CMOR3 
      LOGICAL, SAVE :: do_ofx,do_6hrPlevPt,do_AERday,do_AERhr,
     .  do_AERmonZ,do_CF3hr,do_CFday,do_CFmon,do_CFsubhr,do_E1hrClimMon,
     .  do_E1hr,do_E3hr,do_E3hrPt,do_E6hrZ,do_Eday,do_EdayZ,do_Efx,
     .  do_Emon,do_EmonZ,do_Esubhr,do_Eyr,do_Oclim,do_Oday,do_Odaybgc,
     .  do_Odec,do_COfx,do_SIday
      CHARACTER(LEN=slenmax), SAVE ::
     .  activity_id,parent_variant_label,parent_mip_era,mip_era,
     .  sub_experiment,parent_sub_experiment,parent_activity_id, 
     .  branch_method,parent_time_units,tracking_prefix,variant_label,
     .  source_type
      REAL(KIND=8), SAVE :: branch_time_in_child,branch_time_in_parent
      INTEGER, SAVE :: forcing_index
#endif 
      NAMELIST /experiment/ 
#ifdef CMOR3 
     .  activity_id, 
     .  variant_label,
     .  parent_variant_label,
     .  parent_mip_era,
     .  mip_era,
     .  sub_experiment,
     .  parent_sub_experiment,
     .  parent_activity_id,
     .  branch_time_in_child,
     .  branch_time_in_parent,
     .  branch_method, 
     .  parent_time_units,
     .  tracking_prefix,
     .  physics_version, 
     .  initialization_method, 
     .  forcing_index,
     .  source_type,
#endif 
     .  casename, 
     .  experiment_id,    
     .  history,
     .  comment,
     .  forcing,
     .  realization,
     .  branch_time,
     .  exprefyear,
     .  parent_experiment_id,
     .  parent_experiment_rip,
     .  year1, 
     .  month1, 
     .  yearn,
     .  monthn,
     .  do_fx, ! hidden
     .  do_amon, ! hidden
     .  do_oyr, ! hidden
     .  do_oyrbgc, ! hidden
     .  do_omon, ! hidden
     .  do_omonbgc, ! hidden
     .  do_oimon, ! hidden
     .  do_lmon, ! hidden
     .  do_limon, ! hidden
     .  do_aero, ! hidden
     .  do_day, ! hidden
     .  do_6hrlev, ! hidden
     .  do_6hrlevi, ! hidden
     .  do_6hrplev, ! hidden
     .  do_3hr, ! hidden
     .  do_3hri, ! hidden
     .  do_omon, ! hidden
     .  do_oimon, ! hidden
     .  do_2d, ! hidden
     .  do_3d, ! hidden
     .  do_xd, ! hidden
     .  do_bgc, ! hidden
#ifdef CMOR3 
     .  do_ofx, ! hidden
     .  do_6hrPlevPt, ! hidden
     .  do_AERday, ! hidden
     .  do_AERhr, ! hidden
     .  do_AERmonZ, ! hidden
     .  do_CF3hr, ! hidden
     .  do_CFday, ! hidden
     .  do_CFmon, ! hidden
     .  do_CFsubhr, ! hidden
     .  do_E1hrClimMon, ! hidden
     .  do_E1hr, ! hidden
     .  do_E3hr, ! hidden
     .  do_E3hrPt, ! hidden
     .  do_E6hrZ, ! hidden
     .  do_Eday, ! hidden
     .  do_EdayZ, ! hidden
     .  do_Efx, ! hidden
     .  do_Emon, ! hidden
     .  do_EmonZ, ! hidden
     .  do_Esubhr, ! hidden
     .  do_Eyr, ! hidden
     .  do_Oclim, ! hidden
     .  do_Oday, ! hidden
     .  do_Odaybgc, ! hidden
     .  do_Odec, ! hidden
     .  do_COfx, ! hidden
     .  do_SIday, ! hidden
#endif 
     .  dry_run, ! hidden
     .  plevdummy, ! hidden
     .  readdummy, ! hidden
     .  add_fill_day,! hidden
     .  newcolumnorder,! hidden
     .  isubdir,! hidden
     .  osubdir,! hidden
     .  scanallfiles, ! hidden
     .  membertag ! hidden
c 
c --- Tables 
      LOGICAL, SAVE :: 
     .  dfx,damon,domon,doimon,daero,dday,d6hrlev,d6hrlevi,d6hrplev,
     .  d3hr,d3hri,dlmon,dlimon,doyr,doyrbgc,domonbgc
      CHARACTER(len=lenmax),DIMENSION(colmax,rowmax), SAVE :: 
     .  vfx,vamon,vomon,voimon,vaero,vday,v6hrlev,v6hrlevi,v6hrplev,
     .  v3hr,v3hri,vlmon,vlimon,voyr,voyrbgc,vomonbgc
      CHARACTER(len=slenmax), SAVE ::
     .  pfx,pamon,pomon,poimon,paero,pday,p6hrlev,p6hrlevi,p6hrplev,
     .  p3hr,p3hri,plmon,plimon,poyr,poyrbgc,pomonbgc
      CHARACTER(len=slenmax), SAVE ::
     .  tfx,tamon,tomon,toimon,taero,tday,t6hrlev,t6hrlevi,t6hrplev,
     .  t3hr,t3hri,tlmon,tlimon,toyr,toyrbgc,tomonbgc,tgrids
      INTEGER, SAVE :: 
     .  nfx,namon,nomon,noimon,naero,nday,n6hrlev,n6hrlevi,n6hrplev,
     .  n3hr,n3hri,nlmon,nlimon,noyr,noyrbgc,nomonbgc
      INTEGER, SAVE :: 
     .  rfx,ramon,romon,roimon,raero,rday,r6hrlev,r6hrlevi,r6hrplev,
     .  r3hr,r3hri,
     .  rlmon,rlimon,royr,royrbgc,romonbgc
      NAMELIST /table_grids/   tgrids
      NAMELIST /table_fx/      dfx,pfx,tfx,vfx
      NAMELIST /table_amon/    damon,pamon,tamon,ramon,vamon
      NAMELIST /table_aero/    daero,paero,taero,raero,vaero
      NAMELIST /table_oyr/     doyr,poyr,toyr,royr,voyr
      NAMELIST /table_oyrbgc/  doyrbgc,poyrbgc,toyrbgc,royrbgc,voyrbgc
      NAMELIST /table_omon/    domon,pomon,tomon,romon,vomon
      NAMELIST /table_omonbgc/ domonbgc,pomonbgc,tomonbgc,romonbgc,
     .                         vomonbgc
      NAMELIST /table_oimon/   doimon,poimon,toimon,roimon,voimon
      NAMELIST /table_lmon/    dlmon,plmon,tlmon,rlmon,vlmon
      NAMELIST /table_limon/   dlimon,plimon,tlimon,rlimon,vlimon
      NAMELIST /table_day/     dday,pday,tday,rday,vday
      NAMELIST /table_6hrlev/  d6hrlev,p6hrlev,t6hrlev,r6hrlev,v6hrlev
      NAMELIST /table_6hrlevi/ d6hrlevi,p6hrlevi,t6hrlevi,r6hrlevi,
     .                         v6hrlevi
      NAMELIST /table_6hrplev/ d6hrplev,p6hrplev,t6hrplev,r6hrplev,
     .                         v6hrplev
      NAMELIST /table_3hr/     d3hr,p3hr,t3hr,r3hr,v3hr
      NAMELIST /table_3hri/    d3hri,p3hri,t3hri,r3hri,v3hri
#ifdef CMOR3 
      LOGICAL, SAVE :: 
     .  dofx,d6hrPlevPt,dAERday,dAERhr,dAERmonZ,dCF3hr,dCFday,dCFmon,
     .  dCFsubhr,dE1hrClimMon,dE1hr,dE3hr,dE3hrPt,dE6hrZ,dEday,dEdayZ,
     .  dEfx,dEmon,dEmonZ,dEsubhr,dEyr,dOclim,dOday,dOdaybgc,dOdec,
     .  dCOfx,dSIday
      CHARACTER(len=lenmax),DIMENSION(colmax,rowmax), SAVE :: 
     .  vofx,v6hrPlevPt,vAERday,vAERhr,vAERmonZ,vCF3hr,vCFday,vCFmon,
     .  vCFsubhr,vE1hrClimMon,vE1hr,vE3hr,vE3hrPt,vE6hrZ,vEday,vEdayZ,
     .  vEfx,vEmon,vEmonZ,vEsubhr,vEyr,vOclim,vOday,vOdaybgc,vOdec,
     .  vCOfx,vSIday
      CHARACTER(len=slenmax), SAVE ::
     .  pofx,p6hrPlevPt,pAERday,pAERhr,pAERmonZ,pCF3hr,pCFday,pCFmon,
     .  pCFsubhr,pE1hrClimMon,pE1hr,pE3hr,pE3hrPt,pE6hrZ,pEday,pEdayZ,
     .  pEfx,pEmon,pEmonZ,pEsubhr,pEyr,pOclim,pOday,pOdaybgc,pOdec,
     .  pCOfx,pSIday
      CHARACTER(len=slenmax), SAVE ::
     .  tofx,t6hrPlevPt,tAERday,tAERhr,tAERmonZ,tCF3hr,tCFday,tCFmon,
     .  tCFsubhr,tE1hrClimMon,tE1hr,tE3hr,tE3hrPt,tE6hrZ,tEday,tEdayZ,
     .  tEfx,tEmon,tEmonZ,tEsubhr,tEyr,tOclim,tOday,tOdaybgc,tOdec,
     .  tCOfx,tSIday
      INTEGER, SAVE ::
     .  nofx,n6hrPlevPt,nAERday,nAERhr,nAERmonZ,nCF3hr,nCFday,nCFmon,
     .  nCFsubhr,nE1hrClimMon,nE1hr,nE3hr,nE3hrPt,nE6hrZ,nEday,nEdayZ,
     .  nEfx,nEmon,nEmonZ,nEsubhr,nEyr,nOclim,nOday,nOdaybgc,nOdec,
     .  nCOfx,nSIday
      INTEGER, SAVE ::
     .  rofx,r6hrPlevPt,rAERday,rAERhr,rAERmonZ,rCF3hr,rCFday,rCFmon,
     .  rCFsubhr,rE1hrClimMon,rE1hr,rE3hr,rE3hrPt,rE6hrZ,rEday,rEdayZ,
     .  rEfx,rEmon,rEmonZ,rEsubhr,rEyr,rOclim,rOday,rOdaybgc,rOdec,
     .  rCOfx,rSIday
      NAMELIST /table_ofx/       dofx,pofx,tofx,vofx,rofx
      NAMELIST /table_6hrPlevPt/ d6hrPlevPt,p6hrPlevPt,t6hrPlevPt,
     .                           v6hrPlevPt,r6hrPlevPt
      NAMELIST /table_AERday/    dAERday,pAERday,tAERday,vAERday,rAERday
      NAMELIST /table_AERhr/     dAERhr,pAERhr,tAERhr,vAERhr,rAERhr
      NAMELIST /table_AERmonZ/   dAERmonZ,pAERmonZ,tAERmonZ,vAERmonZ,
     .                           rAERmonZ
      NAMELIST /table_CF3hr/     dCF3hr,pCF3hr,tCF3hr,vCF3hr,rCF3hr
      NAMELIST /table_CFday/     dCFday,pCFday,tCFday,vCFday,rCFday
      NAMELIST /table_CFmon/     dCFmon,pCFmon,tCFmon,rCFmon,vCFmon,
     .                           rCFmon
      NAMELIST /table_CFsubhr/   dCFsubhr,pCFsubhr,tCFsubhr,vCFsubhr
      NAMELIST /table_E1hrClimMon/ dE1hrClimMon,pE1hrClimMon,
     .                           tE1hrClimMon,vE1hrClimMon,rE1hrClimMon
      NAMELIST /table_E1hr/      dE1hr,pE1hr,tE1hr,vE1hr,rE1hr
      NAMELIST /table_E3hr/      dE3hr,pE3hr,tE3hr,vE3hr,rE3hr
      NAMELIST /table_E3hrPt/    dE3hrPt,pE3hrPt,tE3hrPt,vE3hrPt,
     .                           rE3hrPt
      NAMELIST /table_E6hrZ/     dE6hrZ,pE6hrZ,tE6hrZ,vE6hrZ,rE6hrZ
      NAMELIST /table_Eday/      dEday,pEday,tEday,vEday,rEday
      NAMELIST /table_EdayZ/     dEdayZ,pEdayZ,tEdayZ,vEdayZ,rEdayZ
      NAMELIST /table_Efx/       dEfx,pEfx,tEfx,vEfx,rEfx
      NAMELIST /table_Emon/      dEmon,pEmon,tEmon,vEmon,rEmon
      NAMELIST /table_EmonZ/     dEmonZ,pEmonZ,tEmonZ,vEmonZ,rEmonZ
      NAMELIST /table_Esubhr/    dEsubhr,pEsubhr,tEsubhr,vEsubhr,
     .                           rEsubhr
      NAMELIST /table_Eyr/       dEyr,pEyr,tEyr,vEyr,rEyr
      NAMELIST /table_Oclim/     dOclim,pOclim,tOclim,vOclim,rOclim
      NAMELIST /table_Oday/      dOday,pOday,tOday,rOday,vOday,rOday
      NAMELIST /table_Odaybgc/   dOdaybgc,pOdaybgc,tOdaybgc,rOdaybgc,
     .                           vOdaybgc,rOdaybgc
      NAMELIST /table_Odec/      dOdec,pOdec,tOdec,vOdec,rOdec
      NAMELIST /table_COfx/      dCOfx,pCOfx,tCOfx,vCOfx,rCOfx
      NAMELIST /table_SIday/     dSIday,pSIday,tSIday,rSIday,vSIday,
     .                           rSIday
#endif
c
c --- Misc 
      INTEGER :: istatus,funit 
      CHARACTER(LEN=slenmax), SAVE :: fnm,fnm2,itag,nmlfp,vsingle=' ' ! input file name and tag 
      CHARACTER(LEN=slenmax), SAVE :: nmlfpsys,nmlfpmod,nmlfpexp, 
     .  nmlfpvar  ! namelist file paths 
c
c --- Time related variables 
      LOGICAL, SAVE :: linstant
      INTEGER, SAVE :: year,month,rec
      REAL(KIND=8), SAVE :: tval(1),tval2(2),tbnd(2),mbnd(2),
     .  tbnds(2,1),mbnds(2,1)
      CHARACTER(LEN=slenmax), SAVE :: calendar='noleap',
     .  calunits='days since 1850-01-01 00:00:00'


c --- -----------------------------------------------------------------
      CONTAINS
c --- -----------------------------------------------------------------

      

      SUBROUTINE read_namelists 
c
      IMPLICIT NONE 
c
      INTEGER :: n,pi,po
      LOGICAL :: fexist 
c
c --- Initialise namelist variables
      ibasedir      = ' '
      obasedir      = ' '
      tabledir      = ' '
      griddata      = ' '
      tagoyr        = ' '
      tagoyrbgc     = ' '
      tagomon       = ' '
      tagomonbgc    = ' '
      tagoday       = ' ' 
      tagodaybgc    = ' ' 
      tagimon       = ' '
      tagiday       = ' ' 
      tagamon       = ' '
      tagaday       = ' ' 
      taga6hr       = ' ' 
      taga6hri      = ' ' 
      taga3hr       = ' ' 
      taga3hri      = ' ' 
      taglmon       = ' '
      taglday       = ' ' 
      tagl3hr       = ' ' 
      tagl3hri      = ' ' 
      atmgridfile   = ' '
      ocngridfile   = ' '
      ocninitfile   = ' '
      ocnmertfile   = ' '
      ocnregnfile   = ' '
      secindexfile  = ' '
      rhotablesuff  = 'OnRho'
#ifdef CMOR3
      coordtable  = 'CMIP6_coordinate.json'
#endif
      year1         = 0 
      month1        = 1
      yearn         = 0
      monthn        = 12
      createsubdirs = .TRUE.
      forcefilescan = .TRUE.
      verbose       = .TRUE.
      do_fx         = .TRUE.
      do_oyr        = .TRUE.
      do_oyrbgc     = .TRUE.
      do_omon       = .TRUE.
      do_omonbgc    = .TRUE.
      do_oimon      = .TRUE.
      do_amon       = .TRUE.
      do_aero       = .TRUE.
      do_lmon       = .TRUE.
      do_limon      = .TRUE.
      do_day        = .TRUE.
      do_6hrlev     = .TRUE.
      do_6hrlevi    = .TRUE.
      do_6hrplev    = .TRUE.
      do_3hr        = .TRUE.
      do_3hri       = .TRUE.
      do_2d         = .TRUE.
      do_3d         = .TRUE.
      do_xd         = .TRUE.
      do_bgc        = .TRUE.
#ifdef CMOR3
      do_ofx        = .TRUE.
      do_6hrPlevPt  = .TRUE.
      do_AERday     = .TRUE.
      do_AERhr      = .TRUE.
      do_AERmonZ    = .TRUE.
      do_CF3hr      = .TRUE.
      do_CFday      = .TRUE.
      do_CFmon      = .TRUE.
      do_CFsubhr    = .TRUE.
      do_E1hrClimMon= .TRUE.
      do_E1hr       = .TRUE.
      do_E3hr       = .TRUE.
      do_E3hrPt    = .TRUE.
      do_E6hrZ      = .TRUE.
      do_Eday       = .TRUE.
      do_EdayZ      = .TRUE.
      do_Efx        = .TRUE.
      do_Emon       = .TRUE.
      do_EmonZ      = .TRUE.
      do_Esubhr     = .TRUE.
      do_Eyr        = .TRUE.
      do_Oclim      = .TRUE.
      do_Oday       = .TRUE.
      do_Odaybgc    = .TRUE.
      do_Odec       = .TRUE.
      do_COfx       = .TRUE.
      do_SIday      = .TRUE.
#endif 
      dry_run       = .FALSE.  
      plevdummy     = .FALSE.  
      readdummy     = .FALSE.  
      add_fill_day  = .FALSE.
      newcolumnorder= .TRUE.  
      scanallfiles  = .TRUE.  
c
      casename      = ' '
      experiment_id = ' '
      institute_id  = ' '
      institution   = ' '
      source        = ' '  
      contact       = ' '
      history       = ' '
      comment       = ' ' 
      references    = ' ' 
      model_id      = ' ' 
      forcing       = ' '
      realization   = 1 
      branch_time   = 0.0 
      parent_experiment_id = ' ' 
      parent_experiment_rip = ' ' 
      isubdir     = ' ' 
      osubdir     = ' ' 
      membertag   = ' ' 
c
      dfx           = .FALSE.
      doyr          = .FALSE. 
      doyrbgc       = .FALSE. 
      domon         = .FALSE. 
      domonbgc      = .FALSE. 
      doimon        = .FALSE. 
      damon         = .FALSE. 
      daero         = .FALSE. 
      dlmon         = .FALSE. 
      dlimon        = .FALSE. 
      dday          = .FALSE. 
      d6hrlev       = .FALSE. 
      d6hrlevi      = .FALSE. 
      d6hrplev      = .FALSE. 
      d3hr          = .FALSE. 
      d3hri         = .FALSE.
#ifdef CMOR3 
      dofx          = .FALSE. 
      d6hrPlevPt    = .FALSE.
      dAERday       = .FALSE.
      dAERhr        = .FALSE.
      dAERmonZ      = .FALSE.
      dCF3hr        = .FALSE.
      dCFday        = .FALSE.
      dCFmon        = .FALSE.
      dCFsubhr      = .FALSE.
      dE1hrClimMon  = .FALSE.
      dE1hr         = .FALSE.
      dE3hr         = .FALSE.
      dE3hrPt       = .FALSE.
      dE6hrZ        = .FALSE.
      dEday         = .FALSE.
      dEdayZ        = .FALSE.
      dEfx          = .FALSE.
      dEmon         = .FALSE.
      dEmonZ        = .FALSE.
      dEsubhr       = .FALSE.
      dEyr          = .FALSE.
      dOclim        = .FALSE.
      dOday         = .FALSE.
      dOdaybgc      = .FALSE.
      dOdec         = .FALSE.
      dCOfx         = .FALSE.
      dSIday        = .FALSE.
#endif 
c
      vfx           = ' ' 
      voyr          = ' '
      voyrbgc       = ' '
      vomon         = ' '
      vomonbgc      = ' '
      voimon        = ' '
      vamon         = ' '
      vaero         = ' ' 
      vlmon         = ' ' 
      vlimon        = ' ' 
      vday          = ' ' 
      v6hrlev       = ' ' 
      v6hrlevi      = ' ' 
      v6hrplev      = ' ' 
      v3hr          = ' ' 
      v3hri         = ' ' 
#ifdef CMOR3 
      vofx          = ' ' 
      v6hrPlevPt    = ' '
      vAERday       = ' ' 
      vAERhr        = ' ' 
      vAERmonZ      = ' ' 
      vCF3hr        = ' ' 
      vCFday        = ' ' 
      vCFmon        = ' ' 
      vCFsubhr      = ' ' 
      vE1hrClimMon  = ' ' 
      vE1hr         = ' ' 
      vE3hr         = ' ' 
      vE3hrPt       = ' ' 
      vE6hrZ        = ' ' 
      vEday         = ' ' 
      vEdayZ        = ' ' 
      vEfx          = ' ' 
      vEmon         = ' ' 
      vEmonZ        = ' ' 
      vEsubhr       = ' ' 
      vEyr          = ' ' 
      vOclim        = ' ' 
      vOday         = ' ' 
      vOdaybgc      = ' ' 
      vOdec         = ' ' 
      vCOfx         = ' ' 
      vSIday        = ' ' 
#endif 
c
      pfx           = ' '
      poyr          = ' '
      poyrbgc       = ' '
      pomon         = ' '
      pomonbgc      = ' '
      poimon        = ' '
      pamon         = ' '
      paero         = ' '
      plmon         = ' '
      plimon        = ' '
      pday          = ' '
      p6hrlev       = ' '
      p6hrlevi      = ' '
      p6hrplev      = ' '
      p3hr          = ' '
      p3hri         = ' '
#ifdef CMOR3 
      pofx          = ' ' 
      p6hrPlevPt    = ' '
      pAERday       = ' '
      pAERhr        = ' '
      pAERmonZ      = ' '
      pCF3hr        = ' '
      pCFday        = ' '
      pCFmon        = ' '
      pCFsubhr      = ' '
      pE1hrClimMon  = ' '
      pE1hr         = ' '
      pE3hr         = ' ' 
      pE3hrPt       = ' ' 
      pE6hrZ        = ' ' 
      pEday         = ' ' 
      pEdayZ        = ' ' 
      pEfx          = ' ' 
      pEmon         = ' ' 
      pEmonZ        = ' ' 
      pEsubhr       = ' ' 
      pEyr          = ' ' 
      pOclim        = ' ' 
      pOday         = ' ' 
      pOdaybgc      = ' '
      pOdec         = ' ' 
      pCOfx         = ' ' 
      pSIday        = ' ' 
#endif 
c
      royr          = 1000000
      royrbgc       = 1000000
      romon         = 1000000
      romonbgc      = 1000000
      roimon        = 1000000
      ramon         = 1000000
      raero         = 1000000
      rlmon         = 1000000
      rlimon        = 1000000
      rday          = 1000000
      r6hrlev       = 1000000
      r6hrlevi      = 1000000
      r6hrplev      = 1000000
      r3hr          = 1000000
      r3hri         = 1000000
#ifdef CMOR3 
      rofx          = 1000000
      r6hrPlevPt    = 1000000
      rAERday       = 1000000 
      rAERhr        = 1000000 
      rAERmonZ      = 1000000 
      rCF3hr        = 1000000 
      rCFday        = 1000000 
      rCFmon        = 1000000 
      rCFsubhr      = 1000000 
      rE1hrClimMon  = 1000000 
      rE1hr         = 1000000 
      rE3hr         = 1000000  
      rE3hrPt       = 1000000  
      rE6hrZ        = 1000000  
      rEday         = 1000000  
      rEdayZ        = 1000000  
      rEfx          = 1000000  
      rEmon         = 1000000  
      rEmonZ        = 1000000  
      rEsubhr       = 1000000  
      rEyr          = 1000000  
      rOclim        = 1000000  
      rOday         = 1000000  
      rOdaybgc      = 1000000  
      rOdec         = 1000000  
      rCOfx         = 1000000  
      rSIday        = 1000000  
#endif 
c
#ifndef CMOR3 
      tgrids        = 'CMIP5_grids'
      tfx           = 'CMIP5_fx'
      toyr          = 'CMIP5_Oyr'
      toyrbgc       = 'CMIP5_Oyr'
      tomon         = 'CMIP5_Omon'
      tomonbgc      = 'CMIP5_Omon'
      toimon        = 'CMIP5_OImon'
      tamon         = 'CMIP5_Amon'
      taero         = 'CMIP5_aero'
      tlmon         = 'CMIP5_Lmon'
      tlimon        = 'CMIP5_LImon'
      tday          = 'CMIP5_da' 
      t6hrlev       = 'CMIP5_6hrLev' 
      t6hrlevi      = 'CMIP5_6hrLev' 
      t6hrplev      = 'CMIP5_6hrPlev' 
      t3hr          = 'CMIP5_3hr' 
      t3hri         = 'CMIP5_3hr' 
#else 
      tgrids        = 'CMIP6_grids.json'
      tfx           = 'CMIP6_fx.json'
      toyr          = 'CMIP6_Oyr.json'
      toyrbgc       = 'CMIP6_Oyr.json'
      tomon         = 'CMIP6_Omon.json'
      tomonbgc      = 'CMIP6_Omon.json'
      toimon        = 'CMIP6_OImon.json'
      tamon         = 'CMIP6_Amon.json'
      taero         = 'CMIP6_aero.json'
      tlmon         = 'CMIP6_Lmon.json'
      tlimon        = 'CMIP6_LImon.json'
      tday          = 'CMIP6_da.json'
      t6hrlev       = 'CMIP6_6hrLev.json'
      t6hrlevi      = 'CMIP6_6hrLev.json'
      t6hrplev      = 'CMIP6_6hrPlev.json'
      t3hr          = 'CMIP6_3hr.json'
      t3hri         = 'CMIP6_3hr.json'
c
      tofx          = 'CMIP6_ofx.json'
      t6hrPlevPt    = 'CMIP6_6hrPlevPt.json'
      tAERday       = 'CMIP6_AERday.json'
      tAERhr        = 'CMIP6_AERhr.json'
      tAERmonZ      = 'CMIP6_AERmonZ.json'
      tCF3hr        = 'CMIP6_CF3hr.json'
      tCFday        = 'CMIP6_CFday.json'
      tCFmon        = 'CMIP6_CFmon.json'
      tCFsubhr      = 'CMIP6_CFsubhr.json'
      tE1hrClimMon  = 'CMIP6_E1hrClimMon.json'
      tE1hr         = 'CMIP6_E1hr.json'
      tE3hr         = 'CMIP6_E3hr.json'
      tE3hrPt       = 'CMIP6_E3hrPt.json'
      tE6hrZ        = 'CMIP6_E6hrZ.json'
      tEday         = 'CMIP6_Eday.json'
      tEdayZ        = 'CMIP6_EdayZ.json'
      tEfx          = 'CMIP6_Efx.json'
      tEmon         = 'CMIP6_Emon.json'
      tEmonZ        = 'CMIP6_EmonZ.json'
      tEsubhr       = 'CMIP6_Esubhr.json'
      tEyr          = 'CMIP6_Eyr.json'
      tOclim        = 'CMIP6_Oclim.json'
      tOday         = 'CMIP6_Oday.json'
      tOdaybgc      = 'CMIP6_Oday.json'
      tOdec         = 'CMIP6_Odec.json'
      tCOfx         = 'CMIP6_COfx.json'
      tSIday        = 'CMIP6_SIday.json'
#endif 
c
c --- Read namelists 
      IF (iargc().NE.1.AND.iargc().NE.2.AND.iargc().NE.4
     .    .AND.iargc().NE.5) THEN 
        WRITE(*,*) 'Usage: noresm2cmor <path to master namelist file>'
     .           //' [<cmor variable to process>]'  
        WRITE(*,*) '       or                                       '  
        WRITE(*,*) '       noresm2cmor <system nml-file> <model nml'//
     .             '-file> <exp nml-file> <variable nml-file>'  
     .           //' [<cmor variable to process>]'  
        STOP  
      ELSEIF (iargc().EQ.1.OR.iargc().EQ.2) THEN
        nmlfp=' ' 
        CALL getarg(1,nmlfp)
        INQUIRE(FILE=TRIM(nmlfp),EXIST=fexist)
        IF (.NOT.fexist) THEN
          WRITE(*,*) 'cannot find namelist file'//TRIM(nmlfp) 
          STOP
        ENDIF
        nmlfpsys=nmlfp
        nmlfpmod=nmlfp
        nmlfpexp=nmlfp
        nmlfpvar=nmlfp
        IF (iargc().EQ.2) THEN 
          CALL getarg(2,vsingle) 
        ENDIF  
      ELSEIF (iargc().EQ.4.OR.iargc().EQ.5) THEN
        nmlfpsys=' ' 
        CALL getarg(1,nmlfpsys)
        INQUIRE(FILE=TRIM(nmlfpsys),EXIST=fexist)
        IF (.NOT.fexist) THEN
          WRITE(*,*) 'cannot find namelist file'//TRIM(nmlfpsys) 
          STOP
        ENDIF
        nmlfpmod=' ' 
        CALL getarg(2,nmlfpmod)
        INQUIRE(FILE=TRIM(nmlfpmod),EXIST=fexist)
        IF (.NOT.fexist) THEN
          WRITE(*,*) 'cannot find namelist file'//TRIM(nmlfpmod) 
          STOP
        ENDIF
        nmlfpexp=' ' 
        CALL getarg(3,nmlfpexp)
        INQUIRE(FILE=TRIM(nmlfpexp),EXIST=fexist)
        IF (.NOT.fexist) THEN
          WRITE(*,*) 'cannot find namelist file'//TRIM(nmlfpexp) 
          STOP
        ENDIF
        nmlfpvar=' ' 
        CALL getarg(4,nmlfpvar)
        INQUIRE(FILE=TRIM(nmlfpvar),EXIST=fexist)
        IF (.NOT.fexist) THEN
          WRITE(*,*) 'cannot find namelist file'//TRIM(nmlfpvar) 
          STOP
        ENDIF
        IF (iargc().EQ.5) THEN 
          CALL getarg(5,vsingle) 
        ENDIF  
      ENDIF
c        
      funit=get_free_unit()
      OPEN(funit,FILE=TRIM(nmlfpsys),STATUS='old',ACTION='read',
     .  RECL=200)
      READ(funit,nml=sys,IOSTAT=istatus)
      CLOSE(funit)
      IF (istatus.NE.0) THEN 
        WRITE(*,*) 'Problem reading namelist system in file '//
     .    TRIM(nmlfpsys)
        STOP
      ENDIF  
      griddata=TRIM(griddata)//'/' 
      tabledir=TRIM(tabledir)//'/' 
c
      OPEN(funit,FILE=TRIM(nmlfpmod),STATUS='old',ACTION='read',
     .  RECL=200)
      READ(funit,nml=model,IOSTAT=istatus)
      CLOSE(funit)
      IF (istatus.NE.0) THEN 
        WRITE(*,*) 'Problem reading namelist model in file '//
     .    TRIM(nmlfpmod)
        STOP
      ENDIF  
c
      OPEN(funit,FILE=TRIM(nmlfpexp),STATUS='old',ACTION='read',
     .  RECL=200)
      READ(funit,nml=experiment,IOSTAT=istatus)
      CLOSE(funit)
      IF (istatus.NE.0) THEN 
        WRITE(*,*) 'Problem reading namelist experiment in file '//
     .    TRIM(nmlfpexp)
        STOP
      ENDIF  
c
      CALL SYSTEM('cat '//TRIM(nmlfpvar))
      OPEN(funit,FILE=TRIM(nmlfpvar),STATUS='old',ACTION='read',
     .  RECL=200)
      READ(funit,nml=table_grids,IOSTAT=istatus)
      REWIND(funit)
      IF (istatus.NE.0) WRITE(*,*) 
     .  'WARNING: Table grids not in namelist file. Using CMIP5 default'
      OPEN(funit,FILE=TRIM(nmlfpvar),STATUS='old',ACTION='read',
     .  RECL=200)
c
      READ(funit,nml=table_fx,IOSTAT=istatus)
      REWIND(funit)
      IF (istatus.NE.0) WRITE(*,*) 
     .  'WARNING: Table FX not in namelist file. Skipping table...'
      READ(funit,nml=table_oyr,IOSTAT=istatus)
      REWIND(funit)
      IF (istatus.NE.0) WRITE(*,*) 
     .  'WARNING: Table Oyr not in namelist file. Skipping table...'
      READ(funit,nml=table_oyrbgc,IOSTAT=istatus)
      REWIND(funit)
      IF (istatus.NE.0) WRITE(*,*) 
     .  'WARNING: Table Oyrbgc not in namelist file. Skipping table...'
      READ(funit,nml=table_omon,IOSTAT=istatus)
      REWIND(funit)
      IF (istatus.NE.0) WRITE(*,*) 
     .  'WARNING: Table Omon not in namelist file. Skipping table...'
      READ(funit,nml=table_omonbgc,IOSTAT=istatus)
      REWIND(funit)
      IF (istatus.NE.0) WRITE(*,*) 
     .  'WARNING: Table Omonbgc not in namelist file. Skipping table...'
      READ(funit,nml=table_oimon,IOSTAT=istatus)
      REWIND(funit)
      IF (istatus.NE.0) WRITE(*,*) 
     .  'WARNING: Table OImon not in namelist file. Skipping table...'
      READ(funit,nml=table_amon,IOSTAT=istatus)
      REWIND(funit)
      IF (istatus.NE.0) WRITE(*,*) 
     .  'WARNING: Table Amon not in namelist file. Skipping table...'
      READ(funit,nml=table_aero,IOSTAT=istatus)
      REWIND(funit)
      IF (istatus.NE.0) WRITE(*,*) 
     .  'WARNING: Table Aero not in namelist file. Skipping table...'
      READ(funit,nml=table_lmon,IOSTAT=istatus)
      REWIND(funit)
      IF (istatus.NE.0) WRITE(*,*) 
     .  'WARNING: Table Lmon not in namelist file. Skipping table...'
      READ(funit,nml=table_limon,IOSTAT=istatus)
      REWIND(funit)
      IF (istatus.NE.0) WRITE(*,*) 
     .  'WARNING: Table LImon not in namelist file. Skipping table...'
      READ(funit,nml=table_day,IOSTAT=istatus)
      REWIND(funit)
      IF (istatus.NE.0) WRITE(*,*) 
     .  'WARNING: Table Day not in namelist file. Skipping table...'
      READ(funit,nml=table_6hrlev,IOSTAT=istatus)
      REWIND(funit)
      IF (istatus.NE.0) WRITE(*,*) 
     .  'WARNING: Table 6hrLev not in namelist file. Skipping table...'
      READ(funit,nml=table_6hrlevi,IOSTAT=istatus)
      REWIND(funit)
      IF (istatus.NE.0) WRITE(*,*) 
     .  'WARNING: Table 6hrLevi not in namelist file. Skipping table...'
      READ(funit,nml=table_6hrplev,IOSTAT=istatus)
      REWIND(funit)
      IF (istatus.NE.0) WRITE(*,*) 
     .  'WARNING: Table 6hrPLev not in namelist file. Skipping table...'
      READ(funit,nml=table_3hr,IOSTAT=istatus)
      REWIND(funit)
      IF (istatus.NE.0) WRITE(*,*) 
     .  'WARNING: Table 3hr not in namelist file. Skipping table...'
      READ(funit,nml=table_3hri,IOSTAT=istatus)
      REWIND(funit)
      IF (istatus.NE.0) WRITE(*,*) 
     .  'WARNING: Table 3hri not in namelist file. Skipping table...'
#ifdef CMOR3
      READ(funit,nml=table_ofx,IOSTAT=istatus)
      IF (istatus.NE.0) WRITE(*,*) 
     .  'WARNING: Table Ofx not in namelist file. Skipping table...'
      REWIND(funit,IOSTAT=istatus)
      IF (istatus.NE.0) WRITE(*,*) 'cannot rewind namelist file'
      READ(funit,nml=table_6hrPlevPt,IOSTAT=istatus)
      IF (istatus.NE.0) WRITE(*,*) 
     .  'WARNING: Table 6hrPlevPt not in namelist file. Skip table...'
      REWIND(funit,IOSTAT=istatus)
      IF (istatus.NE.0) WRITE(*,*) 'cannot rewind namelist file'
      READ(funit,nml=table_AERday,IOSTAT=istatus)
      IF (istatus.NE.0) WRITE(*,*) 
     .  'WARNING: Table AERday not in namelist file. Skipping table...'
      REWIND(funit,IOSTAT=istatus)
      IF (istatus.NE.0) WRITE(*,*) 'cannot rewind namelist file'
      READ(funit,nml=table_AERhr,IOSTAT=istatus)
      IF (istatus.NE.0) WRITE(*,*) 
     .  'WARNING: Table AERhr not in namelist file. Skipping table...'
      REWIND(funit,IOSTAT=istatus)
      IF (istatus.NE.0) WRITE(*,*) 'cannot rewind namelist file'
      READ(funit,nml=table_AERmonZ,IOSTAT=istatus)
      IF (istatus.NE.0) WRITE(*,*) 
     .  'WARNING: Table AERmonZ not in namelist file. Skipping table...'
      REWIND(funit,IOSTAT=istatus)
      IF (istatus.NE.0) WRITE(*,*) 'cannot rewind namelist file'
      READ(funit,nml=table_CF3hr,IOSTAT=istatus)
      IF (istatus.NE.0) WRITE(*,*) 
     .  'WARNING: Table CF3hr not in namelist file. Skipping table...'
      REWIND(funit,IOSTAT=istatus)
      IF (istatus.NE.0) WRITE(*,*) 'cannot rewind namelist file'
      READ(funit,nml=table_CFday,IOSTAT=istatus)
      REWIND(funit,IOSTAT=istatus)
      IF (istatus.NE.0) WRITE(*,*) 'cannot rewind namelist file'
      READ(funit,nml=table_CFmon,IOSTAT=istatus)
      IF (istatus.NE.0) WRITE(*,*) 
     .  'WARNING: Table CFmon not in namelist file. Skipping table...'
      REWIND(funit,IOSTAT=istatus)
      IF (istatus.NE.0) WRITE(*,*) 'cannot rewind namelist file'
      READ(funit,nml=table_CFsubhr,IOSTAT=istatus)
      IF (istatus.NE.0) WRITE(*,*) 
     .  'WARNING: Table CFsubhr not in namelist file. Skipping table...'
      REWIND(funit,IOSTAT=istatus)
      IF (istatus.NE.0) WRITE(*,*) 'cannot rewind namelist file'
      READ(funit,nml=table_E1hrClimMon,IOSTAT=istatus)
      IF (istatus.NE.0) WRITE(*,*) 
     .  'WARNING: Table E1hrClimMon not in namelist file. Skip table...'
      REWIND(funit,IOSTAT=istatus)
      IF (istatus.NE.0) WRITE(*,*) 'cannot rewind namelist file'
      READ(funit,nml=table_E1hr,IOSTAT=istatus)
      IF (istatus.NE.0) WRITE(*,*) 
     .  'WARNING: Table E1hr not in namelist file. Skipping table...'
      REWIND(funit,IOSTAT=istatus)
      IF (istatus.NE.0) WRITE(*,*) 'cannot rewind namelist file'
      READ(funit,nml=table_E3hr,IOSTAT=istatus)
      IF (istatus.NE.0) WRITE(*,*) 
     .  'WARNING: Table E3hr not in namelist file. Skipping table...'
      REWIND(funit,IOSTAT=istatus)
      IF (istatus.NE.0) WRITE(*,*) 'cannot rewind namelist file'
      READ(funit,nml=table_E3hrPt,IOSTAT=istatus)
      IF (istatus.NE.0) WRITE(*,*) 
     .  'WARNING: Table E3hrPt not in namelist file. Skipping table...'
      REWIND(funit,IOSTAT=istatus)
      IF (istatus.NE.0) WRITE(*,*) 'cannot rewind namelist file'
      READ(funit,nml=table_E6hrZ,IOSTAT=istatus)
      IF (istatus.NE.0) WRITE(*,*) 
     .  'WARNING: Table E6hrZ not in namelist file. Skipping table...'
      REWIND(funit,IOSTAT=istatus)
      IF (istatus.NE.0) WRITE(*,*) 'cannot rewind namelist file'
      READ(funit,nml=table_Eday,IOSTAT=istatus)
      IF (istatus.NE.0) WRITE(*,*) 
     .  'WARNING: Table Eday not in namelist file. Skipping table...'
      REWIND(funit,IOSTAT=istatus)
      IF (istatus.NE.0) WRITE(*,*) 'cannot rewind namelist file'
      READ(funit,nml=table_EdayZ,IOSTAT=istatus)
      IF (istatus.NE.0) WRITE(*,*) 
     .  'WARNING: Table EdayZ not in namelist file. Skipping table...'
      REWIND(funit,IOSTAT=istatus)
      IF (istatus.NE.0) WRITE(*,*) 'cannot rewind namelist file'
      READ(funit,nml=table_Efx,IOSTAT=istatus)
      IF (istatus.NE.0) WRITE(*,*) 
     .  'WARNING: Table Efx not in namelist file. Skipping table...'
      REWIND(funit,IOSTAT=istatus)
      IF (istatus.NE.0) WRITE(*,*) 'cannot rewind namelist file'
      READ(funit,nml=table_Emon,IOSTAT=istatus)
      IF (istatus.NE.0) WRITE(*,*) 
     .  'WARNING: Table Emon not in namelist file. Skipping table...'
      REWIND(funit,IOSTAT=istatus)
      IF (istatus.NE.0) WRITE(*,*) 'cannot rewind namelist file'
      READ(funit,nml=table_EmonZ,IOSTAT=istatus)
      IF (istatus.NE.0) WRITE(*,*) 
     .  'WARNING: Table EmonZ not in namelist file. Skipping table...'
      REWIND(funit,IOSTAT=istatus)
      IF (istatus.NE.0) WRITE(*,*) 'cannot rewind namelist file'
      READ(funit,nml=table_Esubhr,IOSTAT=istatus)
      IF (istatus.NE.0) WRITE(*,*) 
     .  'WARNING: Table Esubhr not in namelist file. Skipping table...'
      REWIND(funit,IOSTAT=istatus)
      IF (istatus.NE.0) WRITE(*,*) 'cannot rewind namelist file'
      READ(funit,nml=table_Eyr,IOSTAT=istatus)
      IF (istatus.NE.0) WRITE(*,*) 
     .  'WARNING: Table Eyr not in namelist file. Skipping table...'
      REWIND(funit,IOSTAT=istatus)
      IF (istatus.NE.0) WRITE(*,*) 'cannot rewind namelist file'
      READ(funit,nml=table_Oclim,IOSTAT=istatus)
      IF (istatus.NE.0) WRITE(*,*) 
     .  'WARNING: Table Oclim not in namelist file. Skipping table...'
      REWIND(funit,IOSTAT=istatus)
      IF (istatus.NE.0) WRITE(*,*) 'cannot rewind namelist file'
      READ(funit,nml=table_Oday,IOSTAT=istatus)
      IF (istatus.NE.0) WRITE(*,*) 
     .  'WARNING: Table Oday not in namelist file. Skipping table...'
      REWIND(funit,IOSTAT=istatus)
      IF (istatus.NE.0) WRITE(*,*) 'cannot rewind namelist file'
      READ(funit,nml=table_Odaybgc,IOSTAT=istatus)
      IF (istatus.NE.0) WRITE(*,*) 
     .  'WARNING: Table Odaybgc not in namelist file. Skipping table...'
      REWIND(funit,IOSTAT=istatus)
      IF (istatus.NE.0) WRITE(*,*) 'cannot rewind namelist file'
      READ(funit,nml=table_Odec,IOSTAT=istatus)
      IF (istatus.NE.0) WRITE(*,*) 
     .  'WARNING: Table Odec not in namelist file. Skipping table...'
      REWIND(funit,IOSTAT=istatus)
      IF (istatus.NE.0) WRITE(*,*) 'cannot rewind namelist file'
      READ(funit,nml=table_COfx,IOSTAT=istatus)
      IF (istatus.NE.0) WRITE(*,*) 
     .  'WARNING: Table COfx not in namelist file. Skipping table...'
      REWIND(funit,IOSTAT=istatus)
      IF (istatus.NE.0) WRITE(*,*) 'cannot rewind namelist file'
      READ(funit,nml=table_SIday,IOSTAT=istatus)
      IF (istatus.NE.0) WRITE(*,*) 
     .  'WARNING: Table SIday not in namelist file. Skipping table...'
      REWIND(funit,IOSTAT=istatus)
      IF (istatus.NE.0) WRITE(*,*) 'cannot rewind namelist file'
#endif
c
      CLOSE(funit)
c
c --- Map column order of variable definitions
      IF (newcolumnorder) THEN
        ivnmpos=2
        ovnmpos=1
      ENDIF
c 
c --- Merge global string arrays
      CALL merge_strarr(slenmax,smax,source,source1,linebreaks)  
      CALL merge_strarr(slenmax,smax,history,history1,linebreaks)  
      CALL merge_strarr(slenmax,smax,comment,comment1,linebreaks)  
      CALL merge_strarr(slenmax,smax,references,references1,linebreaks) 
      CALL merge_strarr(slenmax,smax,forcing,forcing1,.false.)  
      CALL merge_strarr(slenmax,smax,contact,contact1,.false.)  
      CALL merge_strarr(slenmax,smax,institution,institution1,.false.)  
c
c --- Count number of table entries
      nfx=0 
      noyr=0  
      noyrbgc=0  
      nomon=0  
      nomonbgc=0  
      noimon=0  
      namon=0  
      naero=0   
      nlmon=0   
      nlimon=0   
      nday=0   
      n6hrlev=0   
      n6hrlevi=0   
      n6hrplev=0   
      n3hr=0   
      n3hri=0   
      DO n=1,rowmax 
        IF (LEN_TRIM(vfx(1,n)).ne.0) nfx=nfx+1 
        IF (LEN_TRIM(voyr(1,n)).ne.0) noyr=noyr+1 
        IF (LEN_TRIM(voyrbgc(1,n)).ne.0) noyrbgc=noyrbgc+1 
        IF (LEN_TRIM(vomon(1,n)).ne.0) nomon=nomon+1 
        IF (LEN_TRIM(vomonbgc(1,n)).ne.0) nomonbgc=nomonbgc+1 
        IF (LEN_TRIM(voimon(1,n)).ne.0) noimon=noimon+1 
        IF (LEN_TRIM(vamon(1,n)).ne.0) namon=namon+1 
        IF (LEN_TRIM(vaero(1,n)).ne.0) naero=naero+1 
        IF (LEN_TRIM(vlmon(1,n)).ne.0) nlmon=nlmon+1 
        IF (LEN_TRIM(vlimon(1,n)).ne.0) nlimon=nlimon+1 
        IF (LEN_TRIM(vday(1,n)).ne.0) nday=nday+1 
        IF (LEN_TRIM(v6hrlev(1,n)).ne.0) n6hrlev=n6hrlev+1 
        IF (LEN_TRIM(v6hrlevi(1,n)).ne.0) n6hrlevi=n6hrlevi+1 
        IF (LEN_TRIM(v6hrplev(1,n)).ne.0) n6hrplev=n6hrplev+1 
        IF (LEN_TRIM(v3hr(1,n)).ne.0) n3hr=n3hr+1 
        IF (LEN_TRIM(v3hri(1,n)).ne.0) n3hri=n3hri+1 
      ENDDO 
      IF (LEN_TRIM(vsingle).NE.0) THEN  
        pi=ivnmpos
        po=ovnmpos
        DO n=1,rowmax 
          IF (TRIM(vsingle).NE.TRIM(vfx(po,n))) vfx(pi,n)='SKIP'
          IF (TRIM(vsingle).NE.TRIM(voyr(po,n))) voyr(pi,n)='SKIP'
          IF (TRIM(vsingle).NE.TRIM(voyrbgc(po,n))) voyrbgc(pi,n)='SKIP'
          IF (TRIM(vsingle).NE.TRIM(vomon(po,n))) vomon(pi,n)='SKIP'
          IF (TRIM(vsingle).NE.TRIM(vomonbgc(po,n))) 
     .      vomonbgc(pi,n)='SKIP'
          IF (TRIM(vsingle).NE.TRIM(voimon(po,n))) voimon(pi,n)='SKIP'
          IF (TRIM(vsingle).NE.TRIM(vamon(po,n))) vamon(pi,n)='SKIP'
          IF (TRIM(vsingle).NE.TRIM(vaero(po,n))) vaero(pi,n)='SKIP'
          IF (TRIM(vsingle).NE.TRIM(vlmon(po,n))) vlmon(pi,n)='SKIP'
          IF (TRIM(vsingle).NE.TRIM(vlimon(po,n))) vlimon(pi,n)='SKIP'
          IF (TRIM(vsingle).NE.TRIM(vday(po,n))) vday(pi,n)='SKIP'
          IF (TRIM(vsingle).NE.TRIM(v6hrlev(po,n))) v6hrlev(pi,n)='SKIP'
          IF (TRIM(vsingle).NE.TRIM(v6hrlevi(po,n)))
     .      v6hrlevi(pi,n)='SKIP'
          IF (TRIM(vsingle).NE.TRIM(v6hrplev(po,n))) 
     .      v6hrplev(pi,n)='SKIP'
          IF (TRIM(vsingle).NE.TRIM(v3hr(po,n))) v3hr(pi,n)='SKIP'
          IF (TRIM(vsingle).NE.TRIM(v3hri(po,n))) v3hri(pi,n)='SKIP'
        ENDDO 
      ENDIF 
#ifdef CMOR3
      nofx          = 0
      n6hrPlevPt    = 0
      nAERday       = 0
      nAERhr        = 0
      nAERmonZ      = 0
      nCF3hr        = 0
      nCFday        = 0
      nCFmon        = 0
      nCFsubhr      = 0
      nE1hrClimMon  = 0
      nE1hr         = 0
      nE3hr         = 0
      nE3hrPt       = 0
      nE6hrZ        = 0
      nEday         = 0
      nEdayZ        = 0
      nEfx          = 0
      nEmon         = 0
      nEmonZ        = 0
      nEsubhr       = 0
      nEyr          = 0
      nOclim        = 0
      nOday         = 0
      nOdaybgc      = 0
      nOdec         = 0
      nCOfx         = 0
      nSIday        = 0
      DO n=1,rowmax 
        IF (LEN_TRIM(vofx(1,n)).ne.0) nofx=nofx+1 
        IF (LEN_TRIM(v6hrPlevPt(1,n)).ne.0) n6hrPlevPt=n6hrPlevPt+1 
        IF (LEN_TRIM(vAERday(1,n)).ne.0) nAERday=nAERday+1 
        IF (LEN_TRIM(vAERhr(1,n)).ne.0) nAERhr=nAERhr+1 
        IF (LEN_TRIM(vAERmonZ(1,n)).ne.0) nAERmonZ=nAERmonZ+1 
        IF (LEN_TRIM(vCF3hr(1,n)).ne.0) nCF3hr=nCF3hr+1 
        IF (LEN_TRIM(vCFday(1,n)).ne.0) nCFday=nCFday+1 
        IF (LEN_TRIM(vCFmon(1,n)).ne.0) nCFmon=nCFmon+1 
        IF (LEN_TRIM(vCFsubhr(1,n)).ne.0) nCFsubhr=nCFsubhr+1 
        IF (LEN_TRIM(vE1hrClimMon(1,n)).ne.0)nE1hrClimMon=nE1hrClimMon+1
        IF (LEN_TRIM(vE1hr(1,n)).ne.0) nE1hr=nE1hr+1 
        IF (LEN_TRIM(vE3hr(1,n)).ne.0) nE3hr=nE3hr+1 
        IF (LEN_TRIM(vE3hrPt(1,n)).ne.0) nE3hrPt=nE3hrPt+1 
        IF (LEN_TRIM(vE6hrZ(1,n)).ne.0) nE6hrZ=nE6hrZ+1 
        IF (LEN_TRIM(vEday(1,n)).ne.0) nEday=nEday+1 
        IF (LEN_TRIM(vEdayZ(1,n)).ne.0) nEdayZ=nEdayZ+1 
        IF (LEN_TRIM(vEfx(1,n)).ne.0) nEfx=nEfx+1 
        IF (LEN_TRIM(vEmon(1,n)).ne.0) nEmon=nEmon+1 
        IF (LEN_TRIM(vEmonZ(1,n)).ne.0) nEmonZ=nEmonZ+1 
        IF (LEN_TRIM(vEsubhr(1,n)).ne.0) nEsubhr=nEsubhr+1 
        IF (LEN_TRIM(vEyr(1,n)).ne.0) nEyr=nEyr+1 
        IF (LEN_TRIM(vOclim(1,n)).ne.0) nOclim=nOclim+1 
        IF (LEN_TRIM(vOday(1,n)).ne.0) nOday=nOday+1 
        IF (LEN_TRIM(vOdaybgc(1,n)).ne.0) nOdaybgc=nOdaybgc+1 
        IF (LEN_TRIM(vOdec(1,n)).ne.0) nOdec=nOdec+1 
        IF (LEN_TRIM(vCOfx(1,n)).ne.0) nCOfx=nCOfx+1 
        IF (LEN_TRIM(vSIday(1,n)).ne.0) nSIday=nSIday+1 
      ENDDO 
      IF (LEN_TRIM(vsingle).NE.0) THEN       
        pi=ivnmpos
        po=ovnmpos
        DO n=1,rowmax
          IF (TRIM(vsingle).NE.TRIM(vofx(po,n))) vofx(pi,n)='SKIP'
          IF (TRIM(vsingle).NE.TRIM(v6hrPlevPt(po,n))) 
     .      v6hrPlevPt(pi,n)='SKIP'
          IF (TRIM(vsingle).NE.TRIM(vAERday(po,n))) vAERday(pi,n)='SKIP'
          IF (TRIM(vsingle).NE.TRIM(vAERhr(po,n))) vAERhr(pi,n)='SKIP'
          IF (TRIM(vsingle).NE.TRIM(vAERmonZ(po,n))) 
     .      vAERmonZ(pi,n)='SKIP'
          IF (TRIM(vsingle).NE.TRIM(vCF3hr(po,n))) vCF3hr(pi,n)='SKIP'
          IF (TRIM(vsingle).NE.TRIM(vCFday(po,n))) vCFday(pi,n)='SKIP'
          IF (TRIM(vsingle).NE.TRIM(vCFmon(po,n))) vCFmon(pi,n)='SKIP'
          IF (TRIM(vsingle).NE.TRIM(vCFsubhr(po,n))) 
     .      vCFsubhr(pi,n)='SKIP'
          IF (TRIM(vsingle).NE.TRIM(vE1hrClimMon(po,n))) 
     .      vE1hrClimMon(pi,n)='SKIP'
          IF (TRIM(vsingle).NE.TRIM(vE1hr(po,n))) vE1hr(pi,n)='SKIP'
          IF (TRIM(vsingle).NE.TRIM(vE3hr(po,n))) vE3hr(pi,n)='SKIP'
          IF (TRIM(vsingle).NE.TRIM(vE3hrPt(po,n))) 
     .      vE3hrPt(pi,n)='SKIP'
          IF (TRIM(vsingle).NE.TRIM(vE6hrZ(po,n))) vE6hrZ(pi,n)='SKIP'
          IF (TRIM(vsingle).NE.TRIM(vEday(po,n))) vEday(pi,n)='SKIP'
          IF (TRIM(vsingle).NE.TRIM(vEdayZ(po,n))) vEdayZ(pi,n)='SKIP'
          IF (TRIM(vsingle).NE.TRIM(vEfx(po,n))) vEfx(pi,n)='SKIP'
          IF (TRIM(vsingle).NE.TRIM(vEmon(po,n))) vEmon(pi,n)='SKIP'
          IF (TRIM(vsingle).NE.TRIM(vEmonZ(po,n))) vEmonZ(pi,n)='SKIP'
          IF (TRIM(vsingle).NE.TRIM(vEsubhr(po,n))) vEsubhr(pi,n)='SKIP'
          IF (TRIM(vsingle).NE.TRIM(vEyr(po,n))) vEyr(pi,n)='SKIP'
          IF (TRIM(vsingle).NE.TRIM(vOclim(po,n))) vOclim(pi,n)='SKIP'
          IF (TRIM(vsingle).NE.TRIM(vOday(po,n))) vOday(pi,n)='SKIP'
          IF (TRIM(vsingle).NE.TRIM(vOdaybgc(po,n))) 
     .                                            vOdaybgc(pi,n)='SKIP'
          IF (TRIM(vsingle).NE.TRIM(vOdec(po,n))) vOdec(pi,n)='SKIP'
          IF (TRIM(vsingle).NE.TRIM(vCOfx(po,n))) vCOfx(pi,n)='SKIP'
          IF (TRIM(vsingle).NE.TRIM(vSIday(po,n))) vSIday(pi,n)='SKIP'
        ENDDO
      ENDIF 
#endif
c     
c --- Skip deselected namelists 
      if (.not.do_fx)      nfx=0   
      if (.not.do_oyr)     noyr=0   
      if (.not.do_oyrbgc.or..not.do_bgc)  noyrbgc=0   
      if (.not.do_omon)    nomon=0   
      if (.not.do_omonbgc.or..not.do_bgc) nomonbgc=0   
      if (.not.do_oimon)   noimon=0   
      if (.not.do_amon)    namon=0   
      if (.not.do_aero)    naero=0   
      if (.not.do_lmon)    nlmon=0   
      if (.not.do_limon)   nlimon=0   
      if (.not.do_day)     nday=0   
      if (.not.do_6hrlev)  n6hrlev=0   
      if (.not.do_6hrlevi) n6hrlevi=0   
      if (.not.do_6hrplev) n6hrplev=0   
      if (.not.do_3hr)     n3hr=0   
      if (.not.do_3hri)    n3hri=0   
#ifdef CMOR3
      if (.not.do_ofx)         nofx=0   
      if (.not.do_6hrPlevPt)   n6hrPlevPt=0   
      if (.not.do_AERday)      nAERday=0   
      if (.not.do_AERhr)       nAERhr=0   
      if (.not.do_AERmonZ)     nAERmonZ=0   
      if (.not.do_CF3hr)       nCF3hr=0   
      if (.not.do_CFday)       nCFday=0   
      if (.not.do_CFmon)       nCFmon=0   
      if (.not.do_CFsubhr)     nCFsubhr=0   
      if (.not.do_E1hrClimMon) nE1hrClimMon=0   
      if (.not.do_E1hr)        nE1hr=0   
      if (.not.do_E3hr)        nE3hr=0   
      if (.not.do_E3hrPt)      nE3hrPt=0   
      if (.not.do_E6hrZ)       nE6hrZ=0   
      if (.not.do_Eday)        nEday=0   
      if (.not.do_EdayZ)       nEdayZ=0   
      if (.not.do_Efx)         nEfx=0   
      if (.not.do_Emon)        nEmon=0   
      if (.not.do_EmonZ)       nEmonZ=0   
      if (.not.do_Esubhr)      nEsubhr=0   
      if (.not.do_Eyr)         nEyr=0   
      if (.not.do_Oclim)       nOclim=0   
      if (.not.do_Oday)        nOday=0   
      if (.not.do_Odaybgc)     nOdaybgc=0   
      if (.not.do_Odec)        nOdec=0   
      if (.not.do_COfx)        nCOfx=0   
      if (.not.do_SIday)       nSIday=0   
#endif 
c
#ifndef CMOR3
c --- Derive physics_version and initialization_method from
c --- parent_experiment_rip
      IF (TRIM(parent_experiment_rip).NE.'r1i1p1'.AND.
     .    TRIM(parent_experiment_rip).NE.'N/A' .AND
     .    TRIM(parent_experiment_rip).NE.'no parent' ) THEN
        READ(parent_experiment_rip(INDEX(parent_experiment_rip,'i')+1:
     .    INDEX(parent_experiment_rip,'p')-1),*) initialization_method
        READ(parent_experiment_rip(INDEX(parent_experiment_rip,'p')+1:),
     .    *) physics_version
      ENDIF
#endif 
c
c --- Extend input path if necessary 
      IF (LEN_TRIM(isubdir).GT.0)
     .  ibasedir=TRIM(ibasedir)//'/'//TRIM(isubdir)

c --- Modify output path and create output folder 
      obasedir=TRIM(obasedir)//'/'//TRIM(osubdir) 
      call SYSTEM('mkdir -p '//TRIM(obasedir))
c
      END SUBROUTINE read_namelists       

     
 
      SUBROUTINE print_namelists
c
      IMPLICIT NONE 
c
      INTEGER :: n
c 
      WRITE(*,*) 
      WRITE(*,*) 'System namelist:'
      WRITE(*,*) ' input directory  = ',TRIM(ibasedir)
      WRITE(*,*) ' output directory = ',TRIM(obasedir)
      WRITE(*,*) ' table directory  = ',TRIM(tabledir)
      WRITE(*,*) ' grid data dir.   = ',TRIM(griddata)
      WRITE(*,*) ' create sub-dirs  = ',createsubdirs
      WRITE(*,*) ' verbose          = ',verbose
      WRITE(*,*) 
      WRITE(*,*) 'Model namelist:' 
      WRITE(*,*) ' institution      = ',TRIM(institution1)
      WRITE(*,*) ' model id         = ',TRIM(model_id)
      WRITE(*,*) ' source           = ',TRIM(source1)
      WRITE(*,*) ' references       = ',TRIM(references1)
      WRITE(*,*) ' contact          = ',TRIM(contact1)
      WRITE(*,*) ' tag annual ocn   = ',TRIM(tagoyr)
      WRITE(*,*) ' tag annual bgc   = ',TRIM(tagoyrbgc)
      WRITE(*,*) ' tag monthly ocn  = ',TRIM(tagomon)
      WRITE(*,*) ' tag monthly bgc  = ',TRIM(tagomonbgc)
      WRITE(*,*) ' tag daily ocn    = ',TRIM(tagoday)
      WRITE(*,*) ' tag daily bgc    = ',TRIM(tagodaybgc)
      WRITE(*,*) ' tag monthly ice  = ',TRIM(tagimon)
      WRITE(*,*) ' tag daily ice    = ',TRIM(tagiday)
      WRITE(*,*) ' tag monthly atm  = ',TRIM(tagamon)
      WRITE(*,*) ' tag daily atm    = ',TRIM(tagaday)
      WRITE(*,*) ' tag 6hourly atm  = ',TRIM(taga6hr) 
      WRITE(*,*) ' tag 6hourly insa = ',TRIM(taga6hri) 
      WRITE(*,*) ' tag 3hourly atm  = ',TRIM(taga3hr) 
      WRITE(*,*) ' tag 3hourly insa = ',TRIM(taga3hri) 
      WRITE(*,*) ' tag monthly lnd  = ',TRIM(taglmon)
      WRITE(*,*) ' tag daily lnd    = ',TRIM(taglday)
      WRITE(*,*) ' tag 3hourly lnd  = ',TRIM(tagl3hr) 
      WRITE(*,*) ' tag 3hourly insl = ',TRIM(tagl3hri) 
      WRITE(*,*) ' atmos grid file  = ',TRIM(atmgridfile)
      WRITE(*,*) ' ocean grid file  = ',TRIM(ocngridfile)
      WRITE(*,*) ' ocean ini file   = ',TRIM(ocninitfile)
      WRITE(*,*) ' ocean sec file   = ',TRIM(secindexfile)
      WRITE(*,*) ' ocean moc file   = ',TRIM(ocnmertfile)
      WRITE(*,*) ' ocean reg file   = ',TRIM(ocnregnfile)
      WRITE(*,*) ' allow line break = ',linebreaks 
c
      WRITE(*,*) 
      WRITE(*,*) 'Experiment namelist:'
      WRITE(*,*) ' case name        = ',TRIM(casename) 
      WRITE(*,*) ' experiment id    = ',TRIM(experiment_id)
      WRITE(*,*) ' history          = ',TRIM(history1)
      WRITE(*,*) ' comment          = ',TRIM(comment1)
      WRITE(*,*) ' forcing          = ',TRIM(forcing1)
      WRITE(*,*) ' realization      =',realization
      WRITE(*,*) ' start year       = ',year1 
      WRITE(*,*) ' end year         = ',yearn 
      WRITE(*,*) ' start month      = ',month1 
      WRITE(*,*) ' end month        = ',monthn 
      WRITE(*,*) ' add dummy day    = ',add_fill_day
      WRITE(*,*) ' dry run          = ',dry_run
c
      WRITE(*,*) 
      WRITE(*,*) 'Table grids:'
      WRITE(*,*) ' grid table file  = ',TRIM(tgrids)
c
      WRITE(*,*) 
      WRITE(*,*) 'Table fx:'
      DO n=1,nfx
        WRITE(*,'(1X,A20,A20,A20)') vfx(:,n)
      ENDDO
c
      WRITE(*,*)
      WRITE(*,*) 'Table yr:'
      DO n=1,noyr
        WRITE(*,'(1X,A20,A20,A20)') voyr(:,n)
      ENDDO
c
      WRITE(*,*)
      WRITE(*,*) 'Table yr (bgc):'
      DO n=1,noyrbgc
        WRITE(*,'(1X,A20,A20,A20)') voyrbgc(:,n)
      ENDDO
c
      WRITE(*,*)
      WRITE(*,*) 'Table omon:'
      DO n=1,nomon
        WRITE(*,'(1X,A20,A20,A20)') vomon(:,n)
      ENDDO
c
      WRITE(*,*)
      WRITE(*,*) 'Table omon (bgc):'
      DO n=1,nomonbgc
        WRITE(*,'(1X,A20,A20,A20)') vomonbgc(:,n)
      ENDDO
c
      WRITE(*,*)
      WRITE(*,*) 'Table oimon:'
      DO n=1,namon
        WRITE(*,'(1X,A20,A20,A20)') voimon(:,n)
      ENDDO
c
      WRITE(*,*) 
      WRITE(*,*) 'Table amon:'
      DO n=1,namon
        WRITE(*,'(1X,A20,A20,A20)') vamon(:,n)
      ENDDO
c
      WRITE(*,*) 
      WRITE(*,*) 'Table aero:'
      DO n=1,naero
        WRITE(*,'(1X,A20,A20,A20)') vaero(:,n)
      ENDDO
c
      WRITE(*,*)
      WRITE(*,*) 'Table Lmon:'
      DO n=1,nlmon
        WRITE(*,'(1X,A20,A20,A20)') vlmon(:,n)
      ENDDO
c
      WRITE(*,*)
      WRITE(*,*) 'Table LImon:'
      DO n=1,nlimon
        WRITE(*,'(1X,A20,A20,A20)') vlimon(:,n)
      ENDDO
c
      WRITE(*,*) 
      WRITE(*,*) 'Table day:'
      DO n=1,nday
        WRITE(*,'(1X,A20,A20,A20)') vday(:,n)
      ENDDO
c
      WRITE(*,*) 
      WRITE(*,*) 'Table 6hrlev:'
      DO n=1,n6hrlev
        WRITE(*,'(1X,A20,A20,A20)') v6hrlev(:,n)
      ENDDO
c
      WRITE(*,*) 
      WRITE(*,*) 'Table 6hrlevi:'
      DO n=1,n6hrlevi
        WRITE(*,'(1X,A20,A20,A20)') v6hrlevi(:,n)
      ENDDO
c
      WRITE(*,*) 
      WRITE(*,*) 'Table 6hrplev:'
      DO n=1,n6hrplev
        WRITE(*,'(1X,A20,A20,A20)') v6hrplev(:,n)
      ENDDO
c
      WRITE(*,*) 
      WRITE(*,*) 'Table 3hr:'
      DO n=1,n3hr
        WRITE(*,'(1X,A20,A20,A20)') v3hr(:,n)
      ENDDO
c
      WRITE(*,*) 
      WRITE(*,*) 'Table 3hri:'
      DO n=1,n3hri
        WRITE(*,'(1X,A20,A20,A20)') v3hri(:,n)
      ENDDO
c
#ifdef CMOR3
      WRITE(*,*) 
      WRITE(*,*) 'Table ofx:'
      DO n=1,nofx
        WRITE(*,'(1X,A20,A20,A20)') vofx(:,n)
      ENDDO
c
      WRITE(*,*) 
      WRITE(*,*) 'Table 6hrPlevPt:'
      DO n=1,n6hrPlevPt
        WRITE(*,'(1X,A20,A20,A20)') v6hrPlevPt(:,n)
      ENDDO
c
      WRITE(*,*) 
      WRITE(*,*) 'Table AERday:'
      DO n=1,nAERday
        WRITE(*,'(1X,A20,A20,A20)') vAERday(:,n)
      ENDDO
c
      WRITE(*,*) 
      WRITE(*,*) 'Table AERhr:'
      DO n=1,nAERhr
        WRITE(*,'(1X,A20,A20,A20)') vAERhr(:,n)
      ENDDO
c
      WRITE(*,*) 
      WRITE(*,*) 'Table AERmonZ:'
      DO n=1,nAERmonZ
        WRITE(*,'(1X,A20,A20,A20)') vAERmonZ(:,n)
      ENDDO
c
      WRITE(*,*) 
      WRITE(*,*) 'Table CF3hr:'
      DO n=1,nCF3hr
        WRITE(*,'(1X,A20,A20,A20)') vCF3hr(:,n)
      ENDDO
c
      WRITE(*,*)
      WRITE(*,*) 'Table CFday:'
      DO n=1,nCFday
        WRITE(*,'(1X,A20,A20,A20)') vCFday(:,n)
      ENDDO
c
      WRITE(*,*) 
      WRITE(*,*) 'Table CFmon:'
      DO n=1,nCFmon
        WRITE(*,'(1X,A20,A20,A20)') vCFmon(:,n)
      ENDDO
c
      WRITE(*,*) 
      WRITE(*,*) 'Table CFsubhr:'
      DO n=1,nCFsubhr
        WRITE(*,'(1X,A20,A20,A20)') vCFsubhr(:,n)
      ENDDO
c
      WRITE(*,*) 
      WRITE(*,*) 'Table E1hrClimMon:'
      DO n=1,nE1hrClimMon
        WRITE(*,'(1X,A20,A20,A20)') vE1hrClimMon(:,n)
      ENDDO
c
      WRITE(*,*) 
      WRITE(*,*) 'Table E1hr:'
      DO n=1,nE1hr
        WRITE(*,'(1X,A20,A20,A20)') vE1hr(:,n)
      ENDDO
c
      WRITE(*,*) 
      WRITE(*,*) 'Table E3hr:'
      DO n=1,nE3hr
        WRITE(*,'(1X,A20,A20,A20)') vE3hr(:,n)
      ENDDO
c
      WRITE(*,*) 
      WRITE(*,*) 'Table E3hrPt:'
      DO n=1,nE3hrPt
        WRITE(*,'(1X,A20,A20,A20)') vE3hrPt(:,n)
      ENDDO
c
      WRITE(*,*) 
      WRITE(*,*) 'Table E6hrZ:'
      DO n=1,nE6hrZ
        WRITE(*,'(1X,A20,A20,A20)') vE6hrZ(:,n)
      ENDDO
c
      WRITE(*,*) 
      WRITE(*,*) 'Table Eday:'
      DO n=1,nEday
        WRITE(*,'(1X,A20,A20,A20)') vEday(:,n)
      ENDDO
c
      WRITE(*,*) 
      WRITE(*,*) 'Table EdayZ:'
      DO n=1,nEdayZ
        WRITE(*,'(1X,A20,A20,A20)') vEdayZ(:,n)
      ENDDO
c
      WRITE(*,*) 
      WRITE(*,*) 'Table Efx:'
      DO n=1,nEfx
        WRITE(*,'(1X,A20,A20,A20)') vEfx(:,n)
      ENDDO
c
      WRITE(*,*) 
      WRITE(*,*) 'Table Emon:'
      DO n=1,nEmon
        WRITE(*,'(1X,A20,A20,A20)') vEmon(:,n)
      ENDDO
c
      WRITE(*,*) 
      WRITE(*,*) 'Table EmonZ:'
      DO n=1,nEmonZ
        WRITE(*,'(1X,A20,A20,A20)') vEmonZ(:,n)
      ENDDO
c
      WRITE(*,*) 
      WRITE(*,*) 'Table Esubhr:'
      DO n=1,nEsubhr
        WRITE(*,'(1X,A20,A20,A20)') vEsubhr(:,n)
      ENDDO
c
      WRITE(*,*) 
      WRITE(*,*) 'Table Eyr:'
      DO n=1,nEyr
        WRITE(*,'(1X,A20,A20,A20)') vEyr(:,n)
      ENDDO
c
      WRITE(*,*) 
      WRITE(*,*) 'Table Oclim:'
      DO n=1,nOclim
        WRITE(*,'(1X,A20,A20,A20)') vOclim(:,n)
      ENDDO
c
      WRITE(*,*) 
      WRITE(*,*) 'Table Oday:'
      DO n=1,nOday
        WRITE(*,'(1X,A20,A20,A20)') vOday(:,n)
      ENDDO
c
      WRITE(*,*) 
      WRITE(*,*) 'Table Odaybgc:'
      DO n=1,nOdaybgc
        WRITE(*,'(1X,A20,A20,A20)') vOdaybgc(:,n)
      ENDDO
c
      WRITE(*,*) 
      WRITE(*,*) 'Table Odec:'
      DO n=1,nOdec
        WRITE(*,'(1X,A20,A20,A20)') vOdec(:,n)
      ENDDO
c
      WRITE(*,*) 
      WRITE(*,*) 'Table COfx:'
      DO n=1,nCOfx
        WRITE(*,'(1X,A20,A20,A20)') vCOfx(:,n)
      ENDDO
c
      WRITE(*,*) 
      WRITE(*,*) 'Table SIday:'
      DO n=1,nSIday
        WRITE(*,'(1X,A20,A20,A20)') vSIday(:,n)
      ENDDO
#endif 
      END SUBROUTINE print_namelists



      SUBROUTINE merge_strarr(slen,sdm,strin,strout,lb)  
c
      IMPLICIT NONE 
c  
      INTEGER :: sdm,slen 
      CHARACTER(LEN=slen), DIMENSION(sdm) :: strin 
      CHARACTER(LEN=(slen+1)*sdm) :: strout 
      LOGICAL :: lb
c
      INTEGER :: n,pos  
c
      strout=' ' 
      pos=0 
      DO n=1,sdm 
        IF (LEN_TRIM(strin(n)).GT.0) THEN 
          IF (pos.NE.0) THEN           
            pos=pos+1 
            IF (lb) THEN
              strout(pos:pos)=achar(10)
            ELSE
              strout(pos:pos)=' '
            ENDIF
          ENDIF 
          strout(pos+1:pos+LEN_TRIM(strin(n)))=TRIM(strin(n))
          pos=pos+LEN_TRIM(strin(n))
        ENDIF 
      ENDDO           
      pos=1 
      DO 
        IF (INDEX(strout(pos:),'\n').GT.0) THEN
          pos=pos+INDEX(strout(pos:),'\n')
          strout(pos-1:pos)=' '//achar(10) 
          pos=pos+2
          IF (pos.GE.LEN(strout)) EXIT 
        ELSE
          EXIT
        ENDIF
      ENDDO  
c
      END SUBROUTINE merge_strarr 



      FUNCTION get_free_unit() RESULT(free_unit)
c
      IMPLICIT NONE
c
      INTEGER :: free_unit
      LOGICAL :: in_use
c     
      DO free_unit=10,99
        INQUIRE(free_unit,OPENED=in_use)  
        IF (.NOT.in_use) EXIT 
      ENDDO 
c
      END FUNCTION get_free_unit



#ifdef CMOR3
      SUBROUTINE write_namelist_json(grid,grid_label,grid_resolution,
     .                               varname)
c
      USE json_module
c
      IMPLICIT NONE
c
#ifdef MPI 
      INCLUDE 'mpif.h'
      INTEGER :: mpirank,mpisize,mpierror
#endif 
c 
      CHARACTER(len=*) :: grid,grid_label,grid_resolution,varname
      CHARACTER :: yyyymm1*6,yyyymm2*6,c2*2,r3*3
      TYPE(json_core) :: json 
      TYPE(json_value), POINTER :: p 
      CALL json%initialize()
      CALL json%create_object(p,'') 
c --- mapped from cmor2     
      CALL json%add(p,'outpath',TRIM(obasedir)) 
      CALL json%add(p,'experiment_id',TRIM(experiment_id)) 
      CALL json%add(p,'institution_id',TRIM(institute_id)) 
      CALL json%add(p,'institution',TRIM(institution1))
      CALL json%add(p,'source_id',TRIM(model_id))
      CALL json%add(p,'source',TRIM(source1))
      CALL json%add(p,'calendar',TRIM(calendar))
      CALL json%add(p,'realization_index',realization)
      CALL json%add(p,'physics_index',physics_version)
      CALL json%add(p,'initialization_index',initialization_method)
      CALL json%add(p,'contact',TRIM(contact1))
      CALL json%add(p,'history',TRIM(history1))
      CALL json%add(p,'comment',TRIM(comment1))
      CALL json%add(p,'references',TRIM(references1))
      CALL json%add(p,'model_id',TRIM(model_id))
      CALL json%add(p,'run_variant',TRIM(forcing1))
      CALL json%add(p,'branch_time',branch_time)
      CALL json%add(p,'parent_experiment_id',TRIM(parent_experiment_id))
c --- new for cmor3
      CALL json%add(p,'forcing_index',forcing_index)
      CALL json%add(p,'parent_variant_label',TRIM(parent_variant_label))
      CALL json%add(p,'_control_vocabulary_file',
     .  TRIM(tabledir)//'CMIP6_CV.json')
      CALL json%add(p,'_cmip6_option','CMIP6')
      CALL json%add(p,'activity_id',TRIM(activity_id))  
      CALL json%add(p,'source_type',TRIM(source_type))  
      CALL json%add(p,'sub_experiment',TRIM(sub_experiment))
      CALL json%add(p,'sub_experiment_id',TRIM(sub_experiment))
      CALL json%add(p,'parent_sub_experiment_id',
     .  TRIM(parent_sub_experiment))
      CALL json%add(p,'parent_mip_era',TRIM(parent_mip_era))
      CALL json%add(p,'mip_era',TRIM(mip_era))
      CALL json%add(p,'parent_activity_id',TRIM(parent_activity_id))  
      CALL json%add(p,'parent_source_id',TRIM(parent_source_id))  
      CALL json%add(p,'grid',TRIM(grid))
      CALL json%add(p,'grid_label',TRIM(grid_label))
      CALL json%add(p,'nominal_resolution',TRIM(grid_resolution))
      CALL json%add(p,'branch_method',TRIM(branch_method)) 
      CALL json%add(p,'branch_time_in_child',branch_time_in_child) 
      CALL json%add(p,'branch_time_in_parent',branch_time_in_parent) 
      CALL json%add(p,'parent_time_units',TRIM(parent_time_units)) 
      CALL json%add(p,'tracking_prefix',TRIM(tracking_prefix)) 
      CALL json%add(p,'output_path_template','<activity_id>'
     .  //'<institution_id><source_id><experiment_id><_member_id>'
     .  //'<table><variable_id><grid_label><version>')
      CALL json%add(p,'output_file_template','<variable_id><table>'
     .  //'<source_id><experiment_id><_member_id><grid_label>')
      CALL json%add(p,'license',
     . "CMIP6 model data produced by NCC is licensed under a Creative "
     .//"Commons Attribution ShareAlike 4.0 International License "
     .//"(https://creativecommons.org/licenses). Consult "
     .//"https://pcmdi.llnl.gov/CMIP6/TermsOfUse for terms of use " 
     .//"governing CMIP6 output, including citation requirements and " 
     .//"proper acknowledgment. Further information about this " 
     .//"data, including some limitations, can be found via the "
     .//"further_info_url (recorded as a global attribute in this " 
     .//"file) and at https:///pcmdi.llnl.gov/. "
     .//"The data producers and data providers make no "
     .//"warranty, either express or implied, including, but not " 
     .//"limited to, warranties of merchantability and fitness for a "
     .//"particular purpose. All liabilities arising from the " 
     .//"supply of the information (including any liability arising " 
     .//"in negligence) are excluded to the fullest extent permitted " 
     .//"by law.") 
c 
      WRITE(yyyymm1,'(I4.4,I2.2)') year1,month1
      WRITE(yyyymm2,'(I4.4,I2.2)') yearn,monthn
      WRITE(r3,'(I3.3)') realization
#ifdef MPI 
      CALL MPI_COMM_RANK(MPI_COMM_WORLD, mpirank, mpierror)
      WRITE(c2,'(I2.2)') mpirank
#else 
      c2='00'
#endif 
c
      namelist_file_json='namelist_'//TRIM(casename)//'_'//
     .  TRIM(varname)//'_'//yyyymm1//'-'//yyyymm2//'_'//r3
     .  //'_'//c2//'.json'  
      CALL json%print(p,namelist_file_json)
      CALL json%destroy(p)            !cleanup
      WRITE(*,*) 'json-namelist file: ',TRIM(namelist_file_json)
      CALL SYSTEM('cat '//TRIM(namelist_file_json))
c
      END SUBROUTINE write_namelist_json 
#endif 

      END MODULE m_namelists       
