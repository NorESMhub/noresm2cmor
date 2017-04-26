      MODULE cice2cmor_mod_namelists 
c
      IMPLICIT NONE 
c
c --- Namelist limits 
      INTEGER, PARAMETER :: rowmax=100,colmax=3,lenmax=80 
      INTEGER, PARAMETER :: slenmax=500,smax=10  
c
c --- Global namelist
      CHARACTER(LEN=slenmax), SAVE :: ibasedir,obasedir,itag,
     .  gridtable,secindexfile
      CHARACTER(LEN=slenmax), SAVE :: tagmon,tagday,tag3hr
      INTEGER,                SAVE :: year1,yearn,month1,monthn
      LOGICAL,                SAVE :: createsubdirs,verbose,
     .  do_fx,do_omon,do_oimon,do_day
      NAMELIST /global/ 
     .  ibasedir, 
     .  obasedir, 
     .  secindexfile,
     .  gridtable, 
     .  tagmon, 
     .  tagday, 
     .  tag3hr, 
     .  year1, 
     .  month1, 
     .  yearn,
     .  monthn,
     .  createsubdirs,
     .  verbose,
     .  do_fx,
     .  do_omon,
     .  do_oimon,
     .  do_day
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
     .  vfx,vomon,voimon,vday
      CHARACTER(len=slenmax), SAVE :: pfx,pomon,poimon,pday
      CHARACTER(len=slenmax), SAVE :: tfx,tomon,toimon,tday
      INTEGER, SAVE :: nfx,nomon,noimon,nday
      NAMELIST /table_fx/      pfx,tfx,vfx
      NAMELIST /table_omon/    poimon,tomon,vomon
      NAMELIST /table_oimon/   poimon,toimon,voimon
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
      secindexfile  = '../../dat/secindex.dat'
      gridtable     = '../../tbl/CMIP5_grids' 
      tagmon        = ' ' 
      tagday        = ' ' 
      year1         = 0 
      month1        = 1
      yearn         = 0
      monthn        = 12
      createsubdirs = .TRUE.
      verbose       = .TRUE.
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
      vomon         = ' '
      voimon        = ' '
      vday          = ' ' 
c
      pfx           = ' '
      pomon         = ' '
      poimon        = ' '
      pday          = ' ' 
c
      tfx           = 'CMIP5_fx'
      tomon         = 'CMIP5_Omon'
      toimon        = 'CMIP5_OImon'
      tday          = 'CMIP5_da' 
c
c --- Read namelists 
      INQUIRE(FILE='cice2cmor.nml',EXIST=fexist)
      IF (.NOT.fexist) STOP 'cannot find cice2cmor.nml' 
      OPEN(10,FILE='cice2cmor.nml',STATUS='old',ACTION='read',RECL=200)
c
      READ(10,nml=global)
      READ(10,nml=experiment)
      READ(10,nml=table_fx)
      READ(10,nml=table_omon)
      READ(10,nml=table_oimon)
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
      nomon=0  
      noimon=0  
      nday=0   
      DO n=1,rowmax 
        IF (LEN_TRIM(vfx(1,n)).ne.0) nfx=nfx+1 
        IF (LEN_TRIM(vomon(1,n)).ne.0) nomon=nomon+1 
        IF (LEN_TRIM(voimon(1,n)).ne.0) noimon=noimon+1 
        IF (LEN_TRIM(vday(1,n)).ne.0) nday=nday+1 
      ENDDO 
c     
c --- Skip deselected namelists 
      if (.not.do_fx)      nfx=0   
      if (.not.do_omon)    nomon=0   
      if (.not.do_oimon)   noimon=0   
      if (.not.do_day)     nday=0   
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
      WRITE(*,*) ' secindex file    = ',trim(secindexfile)
      WRITE(*,*) ' grid table file  = ',trim(gridtable)
      WRITE(*,*) ' tag monthly data = ',trim(tagmon) 
      WRITE(*,*) ' tag daily data   = ',trim(tagday) 
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
      WRITE(*,*) 'Table omon:'
      DO n=1,nomon
        WRITE(*,*) ' ',vomon(:,n)
      ENDDO
c
      WRITE(*,*) 
      WRITE(*,*) 'Table oimon:'
      DO n=1,noimon
        WRITE(*,*) ' ',voimon(:,n)
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



      END MODULE cice2cmor_mod_namelists       
