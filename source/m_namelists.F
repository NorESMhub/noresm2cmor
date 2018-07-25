      MODULE m_namelists 
c
      IMPLICIT NONE 
c
c --- MPI 
#ifdef CMOR3 
#ifdef MPI
      INCLUDE 'mpif.h'
      INTEGER :: mpierror,mpirank
#endif 
#endif 
c --- Namelist limits 
      INTEGER, PARAMETER :: rowmax=100,colmax=3,lenmax=80 
      INTEGER, PARAMETER :: slenmax=500,smax=10  
c
c --- System namelist
      CHARACTER(LEN=slenmax), SAVE :: ibasedir,obasedir,tabledir,
     .  griddata
      LOGICAL, SAVE :: createsubdirs,forcefilescan,verbose
      NAMELIST /system/
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
     .  taga6hr,taga3hr,taga3hri,taglmon,taglday,tagl3hr,tagl3hri
      CHARACTER(LEN=slenmax), SAVE :: 
     .  secindexfile,ocngridfile,ocninitfile,ocnmertfile,rhotablesuff,
     .  atmgridfile
      LOGICAL, SAVE :: linebreaks
#ifdef CMOR3
      CHARACTER(LEN=slenmax), SAVE :: 
     .  source_type,parent_source_id,grid,grid_label,grid_resolution,
     .  coordtable
#endif 
      NAMELIST /model/
#ifdef CMOR3
     .  source_type, 
     .  parent_source_id, 
     .  grid,
     .  grid_label,
     .  grid_resolution, 
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
     .  linebreaks  ! hidden
c
c --- Experiment namelist
      CHARACTER(LEN=slenmax), SAVE :: 
     .  casename,experiment_id,parent_experiment_id,
     .  parent_experiment_rip 
      CHARACTER(LEN=slenmax), DIMENSION(smax), SAVE :: 
     .  history,comment,forcing
      CHARACTER(LEN=(slenmax+1)*smax), SAVE :: 
     .  history1,comment1,forcing1
      INTEGER, SAVE :: realization,exprefyear,year1,yearn,month1,monthn
      REAL(KIND=8), SAVE :: branch_time
      LOGICAL, SAVE :: dry_run,plevdummy,readdummy,add_fill_day,
     .  do_fx,do_oyr,do_oyrbgc,do_amon,do_omon,do_omonbgc,do_oimon,
     .  do_lmon,do_limon,do_aero,do_day,do_6hrlev,do_6hrplev,do_3hr,
     .  do_3hri,do_2d,do_3d,do_xd,do_bgc
      INTEGER, SAVE :: 
     .  physics_version=1,initialization_method=1
#ifdef CMOR3 
      LOGICAL, SAVE :: do_ofx 
      CHARACTER(LEN=slenmax), SAVE ::
     .  activity_id,parent_variant_label,parent_mip_era,mip_era,
     .  sub_experiment,parent_sub_experiment,parent_activity_id, 
     .  branch_method,parent_time_units,tracking_prefix,variant_label
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
#endif 
     .  dry_run, ! hidden
     .  plevdummy, ! hidden
     .  readdummy, ! hidden
     .  add_fill_day ! hidden
c 
c --- Tables 
      LOGICAL, SAVE :: 
     .  dfx,damon,domon,doimon,daero,dday,d6hrlev,d6hrplev,d3hr,d3hri,
     .  dlmon,dlimon,doyr,doyrbgc,domonbgc
      CHARACTER(len=lenmax),DIMENSION(colmax,rowmax), SAVE :: 
     .  vfx,vamon,vomon,voimon,vaero,vday,v6hrlev,v6hrplev,v3hr,v3hri,
     .  vlmon,vlimon,voyr,voyrbgc,vomonbgc
      CHARACTER(len=slenmax), SAVE ::
     .  pfx,pamon,pomon,poimon,paero,pday,p6hrlev,p6hrplev,p3hr,p3hri,
     .  plmon,plimon,poyr,poyrbgc,pomonbgc
      CHARACTER(len=slenmax), SAVE ::
     .  tfx,tamon,tomon,toimon,taero,tday,t6hrlev,t6hrplev,t3hr,t3hri,
     .  tlmon,tlimon,toyr,toyrbgc,tomonbgc,tgrids
      INTEGER, SAVE :: 
     .  nfx,namon,nomon,noimon,naero,nday,n6hrlev,n6hrplev,n3hr,n3hri,
     .  nlmon,nlimon,noyr,noyrbgc,nomonbgc
      INTEGER, SAVE :: 
     .  rfx,ramon,romon,roimon,raero,rday,r6hrlev,r6hrplev,r3hr,r3hri,
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
      NAMELIST /table_6hrplev/ d6hrplev,p6hrplev,t6hrplev,r6hrplev,
     .                         v6hrplev
      NAMELIST /table_3hr/     d3hr,p3hr,t3hr,r3hr,v3hr
      NAMELIST /table_3hri/    d3hri,p3hri,t3hri,r3hri,v3hri
#ifdef CMOR3 
      LOGICAL, SAVE :: 
     .  dofx 
      CHARACTER(len=lenmax),DIMENSION(colmax,rowmax), SAVE :: 
     .  vofx
      CHARACTER(len=slenmax), SAVE ::
     .  pofx 
      CHARACTER(len=slenmax), SAVE ::
     .  tofx 
      INTEGER, SAVE ::
     .  nofx 
      INTEGER, SAVE ::
     .  rofx 
      NAMELIST /table_ofx/      dofx,pofx,tofx,vofx
#endif 
c
c --- Misc 
      INTEGER :: istatus,funit 
      CHARACTER(LEN=slenmax), SAVE :: fnm,itag,nmlfp ! input file name and tag 
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
      INTEGER :: n
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
      do_6hrplev    = .TRUE.
      do_3hr        = .TRUE.
      do_3hri       = .TRUE.
      do_2d         = .TRUE.
      do_3d         = .TRUE.
      do_xd         = .TRUE.
      do_bgc        = .TRUE.
#ifdef CMOR3
      do_ofx        = .TRUE.
#endif 
      dry_run       = .FALSE.  
      plevdummy     = .FALSE.  
      readdummy     = .FALSE.  
      add_fill_day  = .FALSE.
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
c
      dfx           = .false.
      doyr          = .false. 
      doyrbgc       = .false. 
      domon         = .false. 
      domonbgc      = .false. 
      doimon        = .false. 
      damon         = .false. 
      daero         = .false. 
      dlmon         = .false. 
      dlimon        = .false. 
      dday          = .false. 
      d6hrlev       = .false. 
      d6hrplev      = .false. 
      d3hr          = .false. 
      d3hri         = .false.
#ifdef CMOR3 
      dofx          = .false. 
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
      v6hrplev      = ' ' 
      v3hr          = ' ' 
      v3hri         = ' ' 
#ifdef CMOR3 
      vofx          = ' ' 
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
      p6hrplev      = ' '
      p3hr          = ' '
      p3hri         = ' '
#ifdef CMOR3 
      pofx          = ' ' 
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
      r6hrplev      = 1000000
      r3hr          = 1000000
      r3hri         = 1000000
#ifdef CMOR3 
      rofx          = 1000000
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
      t6hrplev      = 'CMIP6_6hrPlev.json'
      t3hr          = 'CMIP6_3hr.json'
      t3hri         = 'CMIP6_3hr.json'
c
      tofx          = 'CMIP6_ofx.json'
#endif 
c
c --- Read namelists 
      IF (iargc().NE.1.AND.iargc().NE.4) THEN 
        WRITE(*,*) 'Usage: noresm2cmor <path to master namelist file>'  
        WRITE(*,*) '       or                                       '  
        WRITE(*,*) '       noresm2cmor <system nml-file> <model nml'//
     .    '-file> <exp nml-file> <variable nml-file>'  
        STOP  
      ELSEIF (iargc().EQ.1) THEN
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
      ELSEIF (iargc().EQ.4) THEN
        nmlfpsys=' ' 
        CALL getarg(1,nmlfpsys)
        INQUIRE(FILE=TRIM(nmlfpsys),EXIST=fexist)
        IF (.NOT.fexist) THEN
          WRITE(*,*) 'cannot find namelist file'//TRIM(nmlfpsys) 
          STOP
        ENDIF
        nmlfpmod=' ' 
        CALL getarg(1,nmlfpmod)
        INQUIRE(FILE=TRIM(nmlfpmod),EXIST=fexist)
        IF (.NOT.fexist) THEN
          WRITE(*,*) 'cannot find namelist file'//TRIM(nmlfpmod) 
          STOP
        ENDIF
        nmlfpexp=' ' 
        CALL getarg(1,nmlfpexp)
        INQUIRE(FILE=TRIM(nmlfpexp),EXIST=fexist)
        IF (.NOT.fexist) THEN
          WRITE(*,*) 'cannot find namelist file'//TRIM(nmlfpexp) 
          STOP
        ENDIF
        nmlfpvar=' ' 
        CALL getarg(1,nmlfpvar)
        INQUIRE(FILE=TRIM(nmlfpvar),EXIST=fexist)
        IF (.NOT.fexist) THEN
          WRITE(*,*) 'cannot find namelist file'//TRIM(nmlfpvar) 
          STOP
        ENDIF
      ENDIF
c        
      funit=get_free_unit()
      OPEN(funit,FILE=TRIM(nmlfpsys),STATUS='old',ACTION='read',
     .  RECL=200)
      READ(funit,nml=system,IOSTAT=istatus)
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
      REWIND(funit)
      IF (istatus.NE.0) WRITE(*,*) 
     .  'WARNING: Table Ofx not in namelist file. Skipping table...'
#endif
c
      CLOSE(funit)
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
        IF (LEN_TRIM(v6hrplev(1,n)).ne.0) n6hrplev=n6hrplev+1 
        IF (LEN_TRIM(v3hr(1,n)).ne.0) n3hr=n3hr+1 
        IF (LEN_TRIM(v3hri(1,n)).ne.0) n3hri=n3hri+1 
      ENDDO 
#ifdef CMOR3
      nofx=0
      DO n=1,rowmax 
        IF (LEN_TRIM(vofx(1,n)).ne.0) nofx=nofx+1 
      ENDDO 
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
      if (.not.do_6hrplev) n6hrplev=0   
      if (.not.do_3hr)     n3hr=0   
      if (.not.do_3hri)    n3hri=0   
#ifdef CMOR3
      if (.not.do_ofx)     nofx=0   
#endif 
c
#ifndef CMOR3
c --- Derive physics_version and initialization_method from
c --- parent_experiment_rip
      IF (TRIM(parent_experiment_rip).NE.'r1i1p1'.AND.
     .    TRIM(parent_experiment_rip).NE.'N/A') THEN
        READ(parent_experiment_rip(INDEX(parent_experiment_rip,'i')+1:
     .    INDEX(parent_experiment_rip,'p')-1),*) initialization_method
        READ(parent_experiment_rip(INDEX(parent_experiment_rip,'p')+1:),
     .    *) physics_version
      ENDIF
#endif 
c
#ifdef CMOR3
#ifdef MPI
      CALL MPI_COMM_RANK(MPI_COMM_WORLD, mpirank, mpierror)
      IF (mpirank.EQ.0) THEN
#endif 
c --- Dump experiment and model information to json file (only master)
      CALL write_namelist_json 
#ifdef MPI
      ENDIF 
#endif 
#endif 
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
      INTEGER :: n,count 
c
      strout=' ' 
      count=0 
      DO n=1,sdm 
        IF (LEN_TRIM(strin(n)).GT.0) THEN 
          IF (count.NE.0) THEN           
            count=count+1 
            IF (lb) THEN
              strout(count:count)=achar(10)
            ELSE
              strout(count:count)=' '
            ENDIF
          ENDIF 
          strout(count+1:count+LEN_TRIM(strin(n)))=TRIM(strin(n))
          count=count+LEN_TRIM(strin(n))
        ENDIF 
      ENDDO           
c
      END SUBROUTINE merge_strarr 


      
      INTEGER function get_free_unit
c
      IMPLICIT NONE
c
      LOGICAL :: in_use
c     
      DO get_free_unit=10,99
        INQUIRE(get_free_unit,OPENED=in_use)  
        IF (.NOT.in_use) EXIT 
      ENDDO 
c
      END FUNCTION get_free_unit



#ifdef CMOR3
      SUBROUTINE write_namelist_json 
c
      USE json_module
c
      IMPLICIT NONE
c
      TYPE(json_core) :: json 
      TYPE(json_value), POINTER :: p 
c
      CALL json%initialize()
      CALL json%create_object(p,'') 
c --- mapped from cmor2     
      CALL json%add(p,'outpath',TRIM(obasedir)) 
      CALL json%add(p,'experiment_id',TRIM(experiment_id)) 
      CALL json%add(p,'institution_id',TRIM(institute_id)) 
      CALL json%add(p,'institution',TRIM(institution1))
      CALL json%add(p,'source_id',TRIM(source1))
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
     .  //'<institution_id><source_id><experiment_id><variant_label>'
     .  //'<table><variable_id><grid_label><version>')
      CALL json%add(p,'output_file_template','<variable_id><table>'
     .  //'<experiment_id><source_id><variant_label><grid_label>')
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
      call json%print(p,'namelist_'//TRIM(casename)//'.json')  
      call json%destroy(p)            !cleanup
c
      END SUBROUTINE write_namelist_json 
#endif 

      END MODULE m_namelists       
