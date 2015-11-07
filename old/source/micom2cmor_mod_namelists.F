      MODULE micom2cmor_mod_namelists 
c
      IMPLICIT NONE 
c
c --- Namelist limits 
      INTEGER, PARAMETER :: rowmax=100,colmax=3,lenmax=80 
      INTEGER, PARAMETER :: slenmax=500,smax=10  
c
c --- Global namelist
      CHARACTER(LEN=slenmax), SAVE :: ibasedir,obasedir,itag,
     .  ocngridfile,ocninitfile,ocnmertfile,gridtable,rhotablesuff
      CHARACTER(LEN=slenmax), SAVE :: tagyr,tagyrbgc,tagmon,tagmonbgc,
     .  tagday,tagdaybgc
      INTEGER,                SAVE :: year1,yearn,month1,monthn
      LOGICAL,                SAVE :: createsubdirs,verbose,do_bgc,
     .  do_fx,do_oyr,do_oyrbgc,do_omon,do_omonbgc,do_day,do_3d,do_xd,
     .  add_fill_day  
      NAMELIST /global/ 
     .  ibasedir, 
     .  obasedir, 
     .  ocngridfile, 
     .  ocninitfile, 
     .  ocnmertfile, 
     .  gridtable, 
     .  rhotablesuff,
     .  tagyr, 
     .  tagyrbgc, 
     .  tagmon, 
     .  tagmonbgc, 
     .  tagday, 
     .  tagdaybgc, 
     .  year1, 
     .  month1, 
     .  yearn,
     .  monthn,
     .  createsubdirs,
     .  verbose,
     .  do_fx,
     .  do_oyr,
     .  do_oyrbgc,
     .  do_omon,
     .  do_omonbgc,
     .  do_day, 
     .  do_3d, 
     .  do_xd,
     .  do_bgc,
     .  add_fill_day 
c
c --- Experiment namelist
      CHARACTER(LEN=slenmax), SAVE :: 
     .  casename,experiment_id,parent_experiment_id,model_id,
     .  institute_id,parent_experiment_rip 
      CHARACTER(LEN=slenmax), DIMENSION(smax), SAVE :: 
     .  institution,source,history,comment,references,forcing,contact
      CHARACTER(LEN=(slenmax+1)*smax), SAVE :: 
     .  institution1,source1,history1,comment1,references1,forcing1,
     .  contact1
      INTEGER, SAVE :: realization,expstartyear
      REAL(KIND=8), SAVE :: branch_time
      LOGICAL, SAVE :: linebreaks 
      NAMELIST /experiment/ 
     .  casename, 
     .  experiment_id,    
     .  institute_id, 
     .  institution,
     .  source,              
     .  contact,
     .  history,
     .  comment,
     .  references,
     .  model_id,
     .  forcing,
     .  realization,
     .  branch_time, 
     .  expstartyear,
     .  parent_experiment_id,
     .  parent_experiment_rip,
     .  linebreaks 
c
c--- Tables 
      CHARACTER(len=lenmax),DIMENSION(colmax,rowmax), SAVE :: 
     .  vfx,voyr,voyrbgc,vomon,vomonbgc,vday
      CHARACTER(len=slenmax), SAVE :: pfx,poyr,poyrbgc,pomon,pomonbgc,
     .  pday
      CHARACTER(len=slenmax), SAVE :: tfx,toyr,toyrbgc,tomon,tomonbgc,
     .  tday
      INTEGER, SAVE :: nfx,noyr,noyrbgc,nomon,nomonbgc,nday
      NAMELIST /table_fx/      pfx,tfx,vfx
      NAMELIST /table_oyr/     poyr,toyr,voyr
      NAMELIST /table_oyrbgc/  poyrbgc,toyrbgc,voyrbgc
      NAMELIST /table_omon/    pomon,tomon,vomon
      NAMELIST /table_omonbgc/ pomonbgc,tomonbgc,vomonbgc
      NAMELIST /table_day/     pday,tday,vday



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
      ocngridfile   = ' ' 
      ocninitfile   = ' ' 
      ocnmertfile   = ' ' 
      gridtable     = '../../table/CMIP5_grids'  
      rhotablesuff  = '_onRho' 
      tagyr         = ' ' 
      tagyrbgc      = ' ' 
      tagmon        = ' ' 
      tagmonbgc     = ' ' 
      tagday        = ' ' 
      tagdaybgc     = ' ' 
      year1         = 0 
      month1        = 1
      yearn         = 0
      monthn        = 12
      createsubdirs = .TRUE.
      verbose       = .TRUE.
      do_3d         = .TRUE.
      do_xd         = .TRUE.
      do_fx         = .TRUE.
      do_oyr        = .TRUE.
      do_oyrbgc     = .TRUE.
      do_omon       = .TRUE.
      do_omonbgc    = .TRUE.
      do_day        = .TRUE.
      do_bgc        = .TRUE.
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
      vfx           = ' ' 
      voyr          = ' '
      voyrbgc       = ' '
      vomon         = ' '
      vomonbgc      = ' '
      vday          = ' ' 
c
      pfx           = ' '
      poyr          = ' '
      poyrbgc       = ' '
      pomon         = ' '
      pomonbgc      = ' '
      pday          = ' ' 
c
      tfx           = 'CMIP5_fx'
      toyr          = 'CMIP5_Oyr'
      toyrbgc       = 'CMIP5_Oyr'
      tomon         = 'CMIP5_Omon'
      tomonbgc      = 'CMIP5_Omon'
      tday          = 'CMIP5_da' 
c
c --- Read namelists 
      INQUIRE(FILE='micom2cmor.nml',EXIST=fexist)
      IF (.NOT.fexist) STOP 'cannot find micom2cmor.nml' 
      OPEN(10,FILE='micom2cmor.nml',STATUS='old',ACTION='read',RECL=200)
c
      READ(10,nml=global)
      READ(10,nml=experiment)
      READ(10,nml=table_fx)
      WRITE(*,*) 'read oyr'
      READ(10,nml=table_oyr)
      WRITE(*,*) 'read oyrbgc'
      READ(10,nml=table_oyrbgc)
      READ(10,nml=table_omon)
      READ(10,nml=table_omonbgc)
      READ(10,nml=table_day)
c
      CLOSE(10)
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
      nomon=0  
      nday=0   
      DO n=1,rowmax 
        IF (LEN_TRIM(vfx(1,n)).ne.0)      nfx=nfx+1 
        IF (LEN_TRIM(voyr(1,n)).ne.0)     noyr=noyr+1 
        IF (LEN_TRIM(voyrbgc(1,n)).ne.0)  noyrbgc=noyrbgc+1 
        IF (LEN_TRIM(vomon(1,n)).ne.0)    nomon=nomon+1 
        IF (LEN_TRIM(vomonbgc(1,n)).ne.0) nomonbgc=nomonbgc+1 
        IF (LEN_TRIM(vday(1,n)).ne.0)     nday=nday+1 
      ENDDO 
c     
c --- Skip deselected namelists 
      if (.not.do_fx)      nfx=0   
      if (.not.do_oyr)     noyr=0   
      if (.not.do_oyrbgc)  noyrbgc=0   
      if (.not.do_omon)    nomon=0   
      if (.not.do_omonbgc) nomonbgc=0   
      if (.not.do_day)     nday=0   
      if (.not.do_bgc) then 
        nomonbgc=0   
        noyrbgc=0   
      endif
c
      END SUBROUTINE read_namelists       

     
 
      SUBROUTINE print_namelists
c
      IMPLICIT NONE 
c
      INTEGER :: n
c 
      WRITE(*,*) 
      WRITE(*,*) 'Global namelist:'
      WRITE(*,*) ' input directory  = ',trim(ibasedir)
      WRITE(*,*) ' output directory = ',trim(obasedir)
      WRITE(*,*) ' ocean grid file  = ',trim(ocngridfile)
      WRITE(*,*) ' ocean ini file   = ',trim(ocninitfile)
      WRITE(*,*) ' grid table file  = ',trim(gridtable)
      WRITE(*,*) ' rho table suffix = ',trim(rhotablesuff)
      WRITE(*,*) ' tag annual       = ',trim(tagyr) 
      WRITE(*,*) ' tag annual bgc   = ',trim(tagyrbgc) 
      WRITE(*,*) ' tag monthly      = ',trim(tagmon) 
      WRITE(*,*) ' tag monthly bgc  = ',trim(tagmonbgc) 
      WRITE(*,*) ' tag daily        = ',trim(tagday) 
      WRITE(*,*) ' tag daily bgc    = ',trim(tagdaybgc) 
      WRITE(*,*) ' start year       =' ,year1 
      WRITE(*,*) ' end year         =' ,yearn 
      WRITE(*,*) ' add dummy day    =' ,add_fill_day 
c
      WRITE(*,*) 
      WRITE(*,*) 'Experiment namelist:'
      WRITE(*,*) ' case name        = ',trim(casename) 
      WRITE(*,*) ' experiment id    = ',trim(experiment_id)
      WRITE(*,*) ' institution      = ',trim(institution1)
      WRITE(*,*) ' source           = ',trim(source1)
      WRITE(*,*) ' contact          = ',trim(contact1)
      WRITE(*,*) ' history          = ',trim(history1)
      WRITE(*,*) ' comment          = ',trim(comment1)
      WRITE(*,*) ' references       = ',trim(references1)
      WRITE(*,*) ' model id         = ',trim(model_id)
      WRITE(*,*) ' forcing          = ',trim(forcing1)
      WRITE(*,*) ' realization      =' ,realization
      WRITE(*,*) ' allow line break =' ,linebreaks 
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
      WRITE(*,*) 
      WRITE(*,*) 'Table day:'
      DO n=1,nday
        WRITE(*,*) ' ',vday(:,n)
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



      END MODULE micom2cmor_mod_namelists       
