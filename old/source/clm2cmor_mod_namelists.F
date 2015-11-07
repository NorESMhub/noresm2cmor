      MODULE clm2cmor_mod_namelists 
c
      IMPLICIT NONE 
c
c --- Namelist limits 
      INTEGER, PARAMETER :: rowmax=100,colmax=3,lenmax=80 
      INTEGER, PARAMETER :: slenmax=500,smax=10  
c
c --- Global namelist
      CHARACTER(LEN=slenmax), SAVE :: ibasedir,obasedir,itag
      CHARACTER(LEN=slenmax), SAVE :: tagmon,tagday,tag3hr,tag3hri
      INTEGER,                SAVE :: year1,yearn,month1,monthn
      LOGICAL,                SAVE :: createsubdirs,verbose,
     .  do_fx,do_lmon,do_limon,do_day,do_3hr,do_3hri,do_2d,do_3d
      NAMELIST /global/ 
     .  ibasedir, 
     .  obasedir, 
     .  tagmon, 
     .  tagday, 
     .  tag3hr, 
     .  tag3hri, 
     .  year1, 
     .  month1, 
     .  yearn,
     .  monthn,
     .  createsubdirs,
     .  verbose,
     .  do_fx,
     .  do_lmon,
     .  do_limon,
     .  do_day,
     .  do_3hr,
     .  do_3hri,
     .  do_2d, 
     .  do_3d
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
     .  vfx,vlmon,vlimon,vday,v3hr,v3hri
      CHARACTER(len=slenmax), SAVE :: pfx,plmon,plimon,pday,p3hr,p3hri
      CHARACTER(len=slenmax), SAVE :: tfx,tlmon,tlimon,tday,t3hr,t3hri
      INTEGER, SAVE :: nfx,nlmon,nlimon,nday,n3hr,n3hri
      NAMELIST /table_fx/      pfx,tfx,vfx
      NAMELIST /table_lmon/    plmon,tlmon,vlmon
      NAMELIST /table_limon/   plimon,tlimon,vlimon
      NAMELIST /table_day/     pday,tday,vday
      NAMELIST /table_3hr/     p3hr,t3hr,v3hr
      NAMELIST /table_3hri/    p3hri,t3hri,v3hri



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
      tagmon        = ' ' 
      tagday        = ' ' 
      tag3hr        = ' ' 
      obasedir      = ' ' 
      year1         = 0 
      month1        = 1
      yearn         = 0
      monthn        = 12
      createsubdirs = .TRUE.
      verbose       = .TRUE.
      do_fx         = .FALSE. 
      do_lmon       = .FALSE.
      do_limon      = .FALSE.
      do_day        = .FALSE.
      do_3hr        = .FALSE.
      do_3hri       = .FALSE.
      do_2d         = .FALSE.
      do_3d         = .FALSE.
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
      vlmon         = ' '
      vlimon        = ' '
      vday          = ' ' 
      v3hr          = ' ' 
      v3hri         = ' ' 
c
      pfx           = ' '
      plmon         = ' '
      plimon        = ' '
      pday          = ' ' 
      p3hr          = ' ' 
      p3hri         = ' ' 
c
      tfx           = 'CMIP5_fx'
      tlmon         = 'CMIP5_Lmon'
      tlimon        = 'CMIP5_LImon'
      tday          = 'CMIP5_da' 
      t3hr          = 'CMIP5_3hr' 
      t3hri         = 'CMIP5_3hr' 
c
c --- Read namelists 
      INQUIRE(FILE='clm2cmor.nml',EXIST=fexist)
      IF (.NOT.fexist) STOP 'cannot find clm2cmor.nml' 
      OPEN(10,FILE='clm2cmor.nml',STATUS='old',ACTION='read',RECL=200)
c
      READ(10,nml=global)
      READ(10,nml=experiment)
      READ(10,nml=table_fx)
      READ(10,nml=table_lmon)
      READ(10,nml=table_limon)
      READ(10,nml=table_day)
      READ(10,nml=table_3hr)
      READ(10,nml=table_3hri)
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
      nlmon=0  
      nlimon=0  
      nday=0   
      n3hr=0   
      n3hri=0   
      DO n=1,rowmax 
        IF (LEN_TRIM(vfx(1,n)).ne.0)    nfx=nfx+1 
        IF (LEN_TRIM(vlmon(1,n)).ne.0)  nlmon=nlmon+1 
        IF (LEN_TRIM(vlimon(1,n)).ne.0) nlimon=nlimon+1 
        IF (LEN_TRIM(vday(1,n)).ne.0)   nday=nday+1 
        IF (LEN_TRIM(v3hr(1,n)).ne.0)   n3hr=n3hr+1 
        IF (LEN_TRIM(v3hri(1,n)).ne.0)  n3hri=n3hri+1 
      ENDDO 
c     
c --- Skip deselected namelists 
      if (.not.do_fx)      nfx=0   
      if (.not.do_lmon)    nlmon=0   
      if (.not.do_limon)   nlimon=0   
      if (.not.do_day)     nday=0   
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
      WRITE(*,*) 'Global namelist:'
      WRITE(*,*) ' input directory  = ',trim(ibasedir)
      WRITE(*,*) ' tag monthly data = ',trim(tagmon) 
      WRITE(*,*) ' tag daily data   = ',trim(tagday) 
      WRITE(*,*) ' tag 3hourly data = ',trim(tag3hr) 
      WRITE(*,*) ' output directory = ',trim(obasedir)
      WRITE(*,*) ' start year       =',year1 
      WRITE(*,*) ' end year         =',yearn 
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
      WRITE(*,*) ' realization      =',realization
      WRITE(*,*) ' allow line break =',linebreaks 
c
      WRITE(*,*) 
      WRITE(*,*) 'Table fx:'
      DO n=1,nfx
        WRITE(*,*) ' ',vfx(:,n)
      ENDDO
c
      WRITE(*,*) 
      WRITE(*,*) 'Table lmon:'
      DO n=1,nlmon
        WRITE(*,*) ' ',vlmon(:,n)
      ENDDO
c
      WRITE(*,*) 
      WRITE(*,*) 'Table limon:'
      DO n=1,nlimon
        WRITE(*,*) ' ',vlimon(:,n)
      ENDDO
c
      WRITE(*,*) 
      WRITE(*,*) 
      WRITE(*,*) 'Table day:'
      DO n=1,nday
        WRITE(*,*) ' ',vday(:,n)
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



      END MODULE clm2cmor_mod_namelists       
