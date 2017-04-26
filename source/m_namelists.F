      MODULE m_namelists 
c
      IMPLICIT NONE 
c
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
      NAMELIST /model/
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
      NAMELIST /experiment/ 
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
c
c --- Misc 
      INTEGER :: istatus
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
      dfx           = .true.
      doyr          = .true. 
      doyrbgc       = .true. 
      domon         = .true. 
      domonbgc      = .true. 
      doimon        = .true. 
      damon         = .true. 
      daero         = .true. 
      dlmon         = .true. 
      dlimon        = .true. 
      dday          = .true. 
      d6hrlev       = .true. 
      d6hrplev      = .true. 
      d3hr          = .true. 
      d3hri         = .true.
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
c
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
      OPEN(10,FILE=TRIM(nmlfpsys),STATUS='old',ACTION='read',RECL=200)
      READ(10,nml=system,IOSTAT=istatus)
      CLOSE(10)
      IF (istatus.NE.0) THEN 
        WRITE(*,*) 'Problem reading namelist system in file '//
     .    TRIM(nmlfpsys)
        STOP
      ENDIF  
      griddata=TRIM(griddata)//'/' 
      tabledir=TRIM(tabledir)//'/' 
c
      OPEN(10,FILE=TRIM(nmlfpmod),STATUS='old',ACTION='read',RECL=200)
      READ(10,nml=model,IOSTAT=istatus)
      CLOSE(10)
      IF (istatus.NE.0) THEN 
        WRITE(*,*) 'Problem reading namelist model in file '//
     .    TRIM(nmlfpmod)
        STOP
      ENDIF  
c
      OPEN(10,FILE=TRIM(nmlfpexp),STATUS='old',ACTION='read',RECL=200)
      READ(10,nml=experiment,IOSTAT=istatus)
      CLOSE(10)
      IF (istatus.NE.0) THEN 
        WRITE(*,*) 'Problem reading namelist experiment in file '//
     .    TRIM(nmlfpexp)
        STOP
      ENDIF  
c
      OPEN(10,FILE=TRIM(nmlfpvar),STATUS='old',ACTION='read',RECL=200)
      READ(10,nml=table_grids,IOSTAT=istatus)
      REWIND(10)
      IF (istatus.NE.0) WRITE(*,*) 
     .  'WARNING: Table grids not in namelist file. Using CMIP5 default'
      OPEN(10,FILE=TRIM(nmlfpvar),STATUS='old',ACTION='read',RECL=200)
      READ(10,nml=table_fx,IOSTAT=istatus)
      REWIND(10)
      IF (istatus.NE.0) WRITE(*,*) 
     .  'WARNING: Table FX not in namelist file. Skipping table...'
      READ(10,nml=table_oyr,IOSTAT=istatus)
      REWIND(10)
      IF (istatus.NE.0) WRITE(*,*) 
     .  'WARNING: Table Oyr not in namelist file. Skipping table...'
      READ(10,nml=table_oyrbgc,IOSTAT=istatus)
      REWIND(10)
      IF (istatus.NE.0) WRITE(*,*) 
     .  'WARNING: Table Oyrbgc not in namelist file. Skipping table...'
      READ(10,nml=table_omon,IOSTAT=istatus)
      REWIND(10)
      IF (istatus.NE.0) WRITE(*,*) 
     .  'WARNING: Table Omon not in namelist file. Skipping table...'
      READ(10,nml=table_omonbgc,IOSTAT=istatus)
      REWIND(10)
      IF (istatus.NE.0) WRITE(*,*) 
     .  'WARNING: Table Omonbgc not in namelist file. Skipping table...'
      READ(10,nml=table_oimon,IOSTAT=istatus)
      REWIND(10)
      IF (istatus.NE.0) WRITE(*,*) 
     .  'WARNING: Table OImon not in namelist file. Skipping table...'
      READ(10,nml=table_amon,IOSTAT=istatus)
      REWIND(10)
      IF (istatus.NE.0) WRITE(*,*) 
     .  'WARNING: Table Amon not in namelist file. Skipping table...'
      READ(10,nml=table_aero,IOSTAT=istatus)
      REWIND(10)
      IF (istatus.NE.0) WRITE(*,*) 
     .  'WARNING: Table Aero not in namelist file. Skipping table...'
      READ(10,nml=table_lmon,IOSTAT=istatus)
      REWIND(10)
      IF (istatus.NE.0) WRITE(*,*) 
     .  'WARNING: Table Lmon not in namelist file. Skipping table...'
      READ(10,nml=table_limon,IOSTAT=istatus)
      REWIND(10)
      IF (istatus.NE.0) WRITE(*,*) 
     .  'WARNING: Table LImon not in namelist file. Skipping table...'
      READ(10,nml=table_day,IOSTAT=istatus)
      REWIND(10)
      IF (istatus.NE.0) WRITE(*,*) 
     .  'WARNING: Table Day not in namelist file. Skipping table...'
      READ(10,nml=table_6hrlev,IOSTAT=istatus)
      REWIND(10)
      IF (istatus.NE.0) WRITE(*,*) 
     .  'WARNING: Table 6hrLev not in namelist file. Skipping table...'
      READ(10,nml=table_6hrplev,IOSTAT=istatus)
      REWIND(10)
      IF (istatus.NE.0) WRITE(*,*) 
     .  'WARNING: Table 6hrPLev not in namelist file. Skipping table...'
      READ(10,nml=table_3hr,IOSTAT=istatus)
      REWIND(10)
      IF (istatus.NE.0) WRITE(*,*) 
     .  'WARNING: Table 3hr not in namelist file. Skipping table...'
      READ(10,nml=table_3hri,IOSTAT=istatus)
      REWIND(10)
      IF (istatus.NE.0) WRITE(*,*) 
     .  'WARNING: Table 3hri not in namelist file. Skipping table...'
      CLOSE(10)
c
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
      WRITE(*,*) ' input directory  = ',trim(ibasedir)
      WRITE(*,*) ' output directory = ',trim(obasedir)
      WRITE(*,*) ' table directory  = ',trim(tabledir)
      WRITE(*,*) ' grid data dir.   = ',trim(griddata)
      WRITE(*,*) ' create sub-dirs  = ',createsubdirs
      WRITE(*,*) ' verbose          = ',verbose
      WRITE(*,*) 
      WRITE(*,*) 'Model namelist:' 
      WRITE(*,*) ' institution      = ',trim(institution1)
      WRITE(*,*) ' model id         = ',trim(model_id)
      WRITE(*,*) ' source           = ',trim(source1)
      WRITE(*,*) ' references       = ',trim(references1)
      WRITE(*,*) ' contact          = ',trim(contact1)
      WRITE(*,*) ' tag annual ocn   = ',trim(tagoyr)
      WRITE(*,*) ' tag annual bgc   = ',trim(tagoyrbgc)
      WRITE(*,*) ' tag monthly ocn  = ',trim(tagomon)
      WRITE(*,*) ' tag monthly bgc  = ',trim(tagomonbgc)
      WRITE(*,*) ' tag daily ocn    = ',trim(tagoday)
      WRITE(*,*) ' tag daily bgc    = ',trim(tagodaybgc)
      WRITE(*,*) ' tag monthly ice  = ',trim(tagimon)
      WRITE(*,*) ' tag daily ice    = ',trim(tagiday)
      WRITE(*,*) ' tag monthly atm  = ',trim(tagamon)
      WRITE(*,*) ' tag daily atm    = ',trim(tagaday)
      WRITE(*,*) ' tag 6hourly atm  = ',trim(taga6hr) 
      WRITE(*,*) ' tag 3hourly atm  = ',trim(taga3hr) 
      WRITE(*,*) ' tag 3hourly insa = ',trim(taga3hri) 
      WRITE(*,*) ' tag monthly lnd  = ',trim(taglmon)
      WRITE(*,*) ' tag daily lnd    = ',trim(taglday)
      WRITE(*,*) ' tag 3hourly lnd  = ',trim(tagl3hr) 
      WRITE(*,*) ' tag 3hourly insl = ',trim(tagl3hri) 
      WRITE(*,*) ' atmos grid file  = ',trim(atmgridfile)
      WRITE(*,*) ' ocean grid file  = ',trim(ocngridfile)
      WRITE(*,*) ' ocean ini file   = ',trim(ocninitfile)
      WRITE(*,*) ' ocean sec file   = ',trim(secindexfile)
      WRITE(*,*) ' ocean moc file   = ',trim(ocnmertfile)
      WRITE(*,*) ' allow line break = ',linebreaks 
c
      WRITE(*,*) 
      WRITE(*,*) 'Experiment namelist:'
      WRITE(*,*) ' case name        = ',trim(casename) 
      WRITE(*,*) ' experiment id    = ',trim(experiment_id)
      WRITE(*,*) ' contact          = ',trim(contact1)
      WRITE(*,*) ' history          = ',trim(history1)
      WRITE(*,*) ' comment          = ',trim(comment1)
      WRITE(*,*) ' forcing          = ',trim(forcing1)
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
      WRITE(*,*) ' grid table file  = ',trim(tgrids)
c
      WRITE(*,*) 
      WRITE(*,*) 'Table fx:'
      DO n=1,nfx
        WRITE(*,*) ' ',vfx(:,n)
      ENDDO
c
      WRITE(*,*)
      WRITE(*,*) 'Table yr:'
      DO n=1,noyr
        WRITE(*,*) ' ',voyr(:,n)
      ENDDO
c
      WRITE(*,*)
      WRITE(*,*) 'Table yr (bgc):'
      DO n=1,noyrbgc
        WRITE(*,*) ' ',voyrbgc(:,n)
      ENDDO
c
      WRITE(*,*)
      WRITE(*,*) 'Table omon:'
      DO n=1,nomon
        WRITE(*,*) ' ',vomon(:,n)
      ENDDO
c
      WRITE(*,*)
      WRITE(*,*) 'Table omon (bgc):'
      DO n=1,nomonbgc
        WRITE(*,*) ' ',vomonbgc(:,n)
      ENDDO
c
      WRITE(*,*)
      WRITE(*,*) 'Table oimon:'
      DO n=1,namon
        WRITE(*,*) ' ',voimon(:,n)
      ENDDO
c
      WRITE(*,*) 
      WRITE(*,*) 'Table amon:'
      DO n=1,namon
        WRITE(*,*) ' ',vamon(:,n)
      ENDDO
c
      WRITE(*,*) 
      WRITE(*,*) 'Table aero:'
      DO n=1,naero
        WRITE(*,*) ' ',vaero(:,n)
      ENDDO
c
      WRITE(*,*)
      WRITE(*,*) 'Table Lmon:'
      DO n=1,nlmon
        WRITE(*,*) ' ',vlmon(:,n)
      ENDDO
c
      WRITE(*,*)
      WRITE(*,*) 'Table LImon:'
      DO n=1,nlimon
        WRITE(*,*) ' ',vlimon(:,n)
      ENDDO
c
      WRITE(*,*) 
      WRITE(*,*) 'Table day:'
      DO n=1,nday
        WRITE(*,*) ' ',vday(:,n)
      ENDDO
c
      WRITE(*,*) 
      WRITE(*,*) 'Table 6hrlev:'
      DO n=1,n6hrlev
        WRITE(*,*) ' ',v6hrlev(:,n)
      ENDDO
c
      WRITE(*,*) 
      WRITE(*,*) 'Table 6hrplev:'
      DO n=1,n6hrplev
        WRITE(*,*) ' ',v6hrplev(:,n)
      ENDDO
c
      WRITE(*,*) 
      WRITE(*,*) 'Table 3hr:'
      DO n=1,n3hr
        WRITE(*,*) ' ',v3hr(:,n)
      ENDDO
c
      WRITE(*,*) 
      WRITE(*,*) 'Table 3hri:'
      DO n=1,n3hri
        WRITE(*,*) ' ',v3hri(:,n)
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



      END MODULE m_namelists       
