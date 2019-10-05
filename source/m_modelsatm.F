      MODULE m_modelsatm
c
      USE netcdf 
      USE cmor_users_functions
      USE m_utilities
      USE m_namelists
c
      IMPLICIT NONE 
c
c --- Netcdf variables
      INTEGER :: ncid,rhid,dimid,status
c
c --- Grid dimensions and variables 
      INTEGER, SAVE :: idm,jdm,kdm,ldm,pdm 
      REAL(KIND=8), SAVE :: p0
      REAL(KIND=8), ALLOCATABLE, SAVE, DIMENSION(:) :: 
     .  lon,slon,lat,slat,lev,ilev,hyam,hybm,hyai,hybi,plevs,
     .  iilev,hyaii,hybii
      REAL(KIND=8), ALLOCATABLE, SAVE, DIMENSION(:,:) :: 
     .  lon_bnds,lat_bnds 
      CHARACTER(LEN=slenmax), SAVE :: zcoord,tcoord   
c 
c --- Dataset related variables 
      LOGICAL, SAVE :: lreqphis,lreqsst,lreadplev
      CHARACTER(LEN=slenmax), SAVE :: ivnm,ovnm,vunits  
      CHARACTER(LEN=slenmax), SAVE :: vcomment 
      CHARACTER(LEN=slenmax), SAVE :: vpositive 
c
c --- String for module special 
      CHARACTER(LEN=slenmax), SAVE :: special
c
c --- Table related variables 
      CHARACTER(LEN=lenmax) :: table 
c
c --- Cmor parameters 
      INTEGER, SAVE :: iaxid,jaxid,kaxid,taxid,varid,zfacid,table_id, 
     .  error_flag
c
c --- Data fields
      REAL(KIND=8), ALLOCATABLE, SAVE, DIMENSION(:,:) :: ps,phis,sst,
     .  tbot 
      REAL(KIND=8), ALLOCATABLE, SAVE, DIMENSION(:,:,:) :: ifld,ifld2,
     .  ofld,ifldacc
c
c --- Gravity (same as in nco_lifetimes_A2.csh by Alf Kirkevaag) 
      REAL(KIND=8), PARAMETER :: g=9.80665,ginv=1.d0/g  
c
c --- Auxillary variables for special operations 
      CHARACTER(LEN=slenmax), SAVE :: str1,str2


c --- -----------------------------------------------------------------
      CONTAINS 
c --- -----------------------------------------------------------------



      SUBROUTINE atm2cmor 
c
c --- -----------------------------------------------------------------
c
      IMPLICIT NONE
c
      LOGICAL :: badrec,last,skipini
      INTEGER :: m,n,nrec
c
c --- Print start information
      IF (verbose) THEN 
        WRITE(*,*) 
        WRITE(*,*) '----------------------------------'
        WRITE(*,*) '--- Process atmospheric output ---'
        WRITE(*,*) '----------------------------------'
        WRITE(*,*) 
      ENDIF 
c
c --- Read grid information from input files
      itag=tagamon
      CALL scan_files(reset=.TRUE.)
      IF (LEN_TRIM(fnm).EQ.0) then
        WRITE(*,*) 'ERROR: fnm is empty'
        RETURN 
      endif
      CALL read_gridinfo_ifile
c
c --- Initialise pressure level dimension 
      pdm=1 
      ALLOCATE(plevs(pdm))
c
c
c --- Process table fx 
      fnm=pfx
      table=tfx 
      linstant=.FALSE.
      DO n=1,nfx 
        IF (skip_variable(n,nfx,dfx)) CYCLE
c
c --- - Map namelist variables 
        ovnm=vfx(ovnmpos,n) 
        ivnm=vfx(ivnmpos,n) 
        special=vfx(3,n)
        vunits=' ' 
        vpositive=' ' 
        vcomment=' '
c 
c --- - Check if 2d and/or 3d fields are to be written 
        WRITE(*,*) TRIM(ivnm),TRIM(ovnm)
        CALL get_vertcoord(TRIM(tabledir)//TRIM(table),ovnm,zcoord)
        IF (zcoord(1:4).EQ.'plev'.OR.zcoord(2:5).EQ.'leve'.OR.
     .    zcoord(2:5).EQ.'levh') THEN
          IF (.NOT.do_3d) CYCLE
        ELSE
          IF (.NOT.do_2d) CYCLE
        ENDIF
c
c --- - Check if input variable is present        
        WRITE(*,*) TRIM(ivnm),TRIM(ovnm),TRIM(atmgridfile)
        IF (LEN_TRIM(pfx).eq.0) fnm=TRIM(griddata)//TRIM(atmgridfile)
cdiag   write(*,*) 'DEBUG: ',trim(fnm),year,month
        IF (.NOT.var_in_file(fnm,ivnm)) CYCLE 
c
c --- - Prepare output file 
        CALL special_pre     
        CALL open_ofile(fx=.TRUE.)
c
c --- - Read field 
        CALL read_field
c
c --- - Post Processing 
        ofld=ifld  
        CALL special_post 
c         
c --- - Write field 
        CALL write_field 
c
c --- - Close output file 
        CALL close_ofile
c
      ENDDO          
c
c 
c --- Process table amon
      fnm=pamon
      table=tamon 
      linstant=.FALSE.
      lreadplev=.TRUE.
      DO n=1,namon 
        IF (skip_variable(n,namon,damon)) CYCLE
c
c --- - Map namelist variables 
        ovnm=vamon(ovnmpos,n) 
        ivnm=vamon(ivnmpos,n) 
        special=vamon(3,n)
        vunits=' ' 
        vpositive=' ' 
        vcomment=' '
c 
c --- - Check if 2d and/or 3d fields are to be written 
        CALL get_vertcoord(TRIM(tabledir)//TRIM(table),ovnm,zcoord)
cdiag   WRITE(*,*) TRIM(ovnm),TRIM(zcoord),do_3d
        IF (zcoord(1:4).EQ.'plev'.OR.zcoord(2:5).EQ.'leve'.OR.
     .    zcoord(2:5).EQ.'levh') THEN
          IF (.NOT.do_3d) CYCLE
c --- --- Read pressure levels from table 
          IF (lreadplev.AND.zcoord(1:4).EQ.'plev') THEN 
            CALL read_gridinfo_plev(TRIM(zcoord))
            lreadplev=.FALSE.
          ENDIF
        ELSE
          IF (.NOT.do_2d) CYCLE
        ENDIF
c 
c --- - Choose history file 
        SELECT CASE (TRIM(special)) 
          CASE ('day2mon')
            itag=tagaday 
          CASE ('6hr2mon') 
            itag=taga6hr
          CASE ('3hr2mon')
            itag=taga3hr
          CASE DEFAULT 
            itag=tagamon
        END SELECT
c
c --- - Check if input variable is present  
        IF (LEN_TRIM(pamon).eq.0) CALL scan_files(reset=.TRUE.)
cdiag   write(*,*) 'DEBUG: ',trim(fnm),year1,year,month
        IF (INDEX(special,'catplev').LT.1) THEN 
          IF (.NOT.var_in_file(fnm,ivnm)) CYCLE 
        ENDIF
c 
c --- - Prepare special operations
        CALL special_pre    
c
c --- - Loop over input files 
        m=0 
        DO 
          m=m+1
c
c --- --- Open output file
          IF (MOD(m-1,ramon).EQ.0) CALL open_ofile 
c
c --- --- Read variable into buffer (average if necessary)
          rec=0
          nrec=0
          ifldacc=0. 
          LAST=.FALSE. 
          DO 
            IF (LEN_TRIM(pamon).eq.0) CALL scan_files
            IF (rec.EQ.0) THEN
              last=.TRUE. 
              EXIT 
            ENDIF 
            nrec=nrec+1
cdiag      write(*,*) 'DEBUG: ',trim(fnm),rec,nrec,tbnd,mbnd,year,month
            CALL read_tslice(rec,badrec,fnm)
            ifldacc=ifldacc+ifld 
            IF (tbnd(2).EQ.mbnd(2)) EXIT 
          ENDDO 
          IF (last) EXIT 
          ifld=ifldacc/FLOAT(nrec) 
          tbnds(:,1)=mbnd
          tval=0.5*(tbnds(1,1)+tbnds(2,1))
c 
c --- --- Post processing 
          IF (zcoord(1:4).EQ.'plev'.AND.
     .      INDEX(special,'catplev').LT.1) THEN 
            CALL interp_z
          ELSE
            ofld=ifld  
          ENDIF                 
          CALL special_post 
c
c --- --- Write time slice to output file 
          CALL write_tslice  
c
c --- --- Close output file if max rec has been reached 
          IF (MOD(m,ramon).EQ.0) CALL close_ofile 
c
c --- - End loop over files and records
        ENDDO 
c
c --- - Close output file if still open 
        IF (MOD(m,ramon).GT.0) CALL close_ofile
c
      ENDDO    
c 
#ifdef CMOR3
c --- Process table Emon
      fnm=pEmon
      table=tEmon
      linstant=.FALSE.
      lreadplev=.TRUE.
      DO n=1,nEmon
        IF (skip_variable(n,nEmon,dEmon)) CYCLE
c
c --- - Map namelist variables 
        ovnm=vEmon(ovnmpos,n)
        ivnm=vEmon(ivnmpos,n)
        special=vEmon(3,n)
        vunits=' '
        vpositive=' '
        vcomment=' '
c 
c --- - Check if 2d and/or 3d fields are to be written 
        CALL get_vertcoord(TRIM(tabledir)//TRIM(table),ovnm,zcoord)
cdiag   WRITE(*,*) TRIM(ovnm),TRIM(zcoord),do_3d
        IF (zcoord(1:4).EQ.'plev'.OR.zcoord(2:5).EQ.'leve'.OR.
     .    zcoord(2:5).EQ.'levh') THEN
          IF (.NOT.do_3d) CYCLE
c --- --- Read pressure levels from table 
          IF (lreadplev.AND.zcoord(1:4).EQ.'plev') THEN
            CALL read_gridinfo_plev(TRIM(zcoord))
            lreadplev=.FALSE.
          ENDIF
        ELSE
          IF (.NOT.do_2d) CYCLE
        ENDIF
c 
c --- - Choose history file 
        SELECT CASE (TRIM(special))
          CASE ('day2mon')
            itag=tagaday
          CASE ('6hr2mon')
            itag=taga6hr
          CASE ('3hr2mon')
            itag=taga3hr
          CASE DEFAULT
            itag=tagamon
        END SELECT
c
c --- - Check if input variable is present  
        IF (LEN_TRIM(pEmon).eq.0) CALL scan_files(reset=.TRUE.)
cdiag   write(*,*) 'DEBUG: ',trim(fnm),year1,year,month
        IF (INDEX(special,'catplev').LT.1) THEN
          IF (.NOT.var_in_file(fnm,ivnm)) CYCLE
        ENDIF
c 
c --- - Prepare special operations
        CALL special_pre
c
c --- - Loop over input files 
        m=0
        DO
          m=m+1
c
c --- --- Open output file
          IF (MOD(m-1,rEmon).EQ.0) CALL open_ofile
c
c --- --- Read variable into buffer (average if necessary)
          rec=0
          nrec=0
          ifldacc=0.
          LAST=.FALSE.
          DO
            IF (LEN_TRIM(pEmon).eq.0) CALL scan_files
            IF (rec.EQ.0) THEN
              last=.TRUE.
              EXIT
            ENDIF
            nrec=nrec+1
cdiag      write(*,*) 'DEBUG: ',trim(fnm),rec,nrec,tbnd,mbnd,year,month
            CALL read_tslice(rec,badrec,fnm)
            ifldacc=ifldacc+ifld
            IF (tbnd(2).EQ.mbnd(2)) EXIT
          ENDDO
          IF (last) EXIT
          ifld=ifldacc/FLOAT(nrec)
          tbnds(:,1)=mbnd
          tval=0.5*(tbnds(1,1)+tbnds(2,1))
c 
c --- --- Post processing 
          IF (zcoord(1:4).EQ.'plev'.AND.
     .      INDEX(special,'catplev').LT.1) THEN
            CALL interp_z
          ELSE
            ofld=ifld
          ENDIF
          CALL special_post
c
c --- --- Write time slice to output file 
          CALL write_tslice
c
c --- --- Close output file if max rec has been reached 
          IF (MOD(m,rEmon).EQ.0) CALL close_ofile
c
c --- - End loop over files and records
        ENDDO
c
c --- - Close output file if still open 
        IF (MOD(m,rEmon).GT.0) CALL close_ofile
c
      ENDDO
#endif
c 
c --- Process table aero
      fnm=paero
      table=taero
      linstant=.FALSE.
      lreadplev=.FALSE.
      DO n=1,naero
        IF (skip_variable(n,naero,daero)) CYCLE
c 
c --- - Map namelist variables 
        ovnm=vaero(ovnmpos,n)
        ivnm=vaero(ivnmpos,n)
        special=vaero(3,n)
        vunits=' '
        vpositive=' ' 
        vcomment=' '
c 
c --- - Check if 2d and/or 3d fields are to be written 
        CALL get_vertcoord(TRIM(tabledir)//TRIM(table),ovnm,zcoord)
cdiag   WRITE(*,*) TRIM(ovnm),TRIM(zcoord),do_3d
        IF (zcoord(1:4).EQ.'plev'.OR.zcoord(2:5).EQ.'leve'.OR.
     .    zcoord(2:5).EQ.'levh') THEN
          IF (.NOT.do_3d) CYCLE
c --- --- Read pressure levels from table 
          IF (lreadplev.AND.zcoord(1:4).EQ.'plev') THEN 
            CALL read_gridinfo_plev(TRIM(zcoord))
            lreadplev=.FALSE.
          ENDIF
        ELSE
          IF (.NOT.do_2d) CYCLE
        ENDIF
c 
c --- - Choose history file 
        SELECT CASE (TRIM(special))
          CASE ('day2mon')
            itag=tagaday
          CASE ('6hr2mon')
            itag=taga6hr
          CASE ('3hr2mon')
            itag=taga3hr
          CASE DEFAULT
            itag=tagamon
        END SELECT
c
c --- - Check if input variable is present  
        IF (LEN_TRIM(paero).eq.0) CALL scan_files(reset=.TRUE.)
        IF (.NOT.var_in_file(fnm,ivnm)) CYCLE
c
c --- - Prepare output file 
        CALL special_pre
c
c --- - Loop over files and records
        m=0
        DO
          m=m+1
c
c --- --- Open output file
          IF (MOD(m-1,raero).EQ.0) CALL open_ofile 
c
c --- --- Read variable into buffer (average if necessary)
          rec=0
          nrec=0
          ifldacc=0.
          LAST=.FALSE.
          DO
            IF (LEN_TRIM(paero).eq.0) CALL scan_files 
            IF (rec.EQ.0) THEN
              last=.TRUE.
              EXIT
            ENDIF
            nrec=nrec+1
cdiag       write(*,*) 'DEBUG: ',trim(fnm),rec,nrec,tbnd,mbnd,year,month
            CALL read_tslice(rec,badrec,fnm)
            ifldacc=ifldacc+ifld
            IF (tbnd(2).EQ.mbnd(2)) EXIT
          ENDDO
          IF (last) EXIT

            ifld=ifldacc/FLOAT(nrec)
            tbnds(:,1)=mbnd
            tval=0.5*(tbnds(1,1)+tbnds(2,1))
c 
c --- --- Post processing 
          ofld=ifld
          CALL special_post
c
c --- --- Write time slice to output file 
          CALL write_tslice
c
c --- --- Close output file if max rec has been reached 
          IF (MOD(m,raero).EQ.0) CALL close_ofile 
c
c --- - End loop over files and records
        ENDDO 
c
c --- - Close output file if still open 
        IF (MOD(m,raero).GT.0) CALL close_ofile
c
      ENDDO
c
c
c --- Process table day
      fnm=pday
      table=tday
      linstant=.FALSE.
      lreadplev=.TRUE.
      DO n=1,nday
        IF (skip_variable(n,nday,dday)) CYCLE
c
c --- - Map namelist variables 
        ovnm=vday(ovnmpos,n)
        ivnm=vday(ivnmpos,n)
        special=vday(3,n)
        vunits=' '
        vpositive=' '
        vcomment=' '
c 
c --- - Check if 2d and/or 3d fields are to be written 
        CALL get_vertcoord(TRIM(tabledir)//TRIM(table),ovnm,zcoord)
        IF (zcoord(1:4).EQ.'plev'.OR.zcoord(2:5).EQ.'leve'.OR.
     .    zcoord(2:5).EQ.'levh') THEN
          IF (.NOT.do_3d) CYCLE
c --- --- Read pressure levels from table 
          IF (lreadplev.AND.zcoord(1:4).EQ.'plev') THEN 
            CALL read_gridinfo_plev(TRIM(zcoord)) 
!            lreadplev=.FALSE.
          ENDIF
        ELSE
          IF (.NOT.do_2d) CYCLE
        ENDIF
c 
c --- - Choose history file 
        itag=tagaday
c
c --- - Check if input variable is present  
        IF (LEN_TRIM(pday).eq.0) CALL  scan_files(reset=.TRUE.)
        IF (INDEX(special,'catplev').LT.1) THEN 
          IF (.NOT.var_in_file(fnm,ivnm)) CYCLE
        ENDIF
c
c --- - Prepare output file 
        CALL special_pre
c
c --- - Loop over files
        skipini=.false.
        m=0
        DO
          m=m+1 
c
c --- --- Open output file
          IF (MOD(m-1,rday).EQ.0) CALL open_ofile 
c
c --- --- Read variable into buffer (average if necessary)
          rec=0
          IF (LEN_TRIM(pday).eq.0) CALL scan_files 
          IF (rec.EQ.0) EXIT
cdiag     write(*,*) 'DEBUG: ',trim(fnm),rec,tbnd,mbnd,year,month
          IF (tbnd(1).EQ.tbnd(2)) THEN 
            IF(verbose) WRITE(*,*) 'Skip initialisation record'
            skipini=.true.
            CYCLE 
          ENDIF 
          tbnds(:,1)=tbnd 
          tval=0.5*(tbnds(1,1)+tbnds(2,1))
c
c --- --- Read data 
          CALL read_tslice(rec,badrec,fnm)
c
c --- --- Post processing 
          IF (zcoord(1:4).EQ.'plev'.AND.
     .      INDEX(special,'catplev').LT.1) THEN 
            CALL interp_z
          ELSE
            ofld=ifld
          ENDIF
          CALL special_post
c
c --- --- Write time slice to output file 
          CALL write_tslice
c
c --- --- Close output file if max rec has been reached 
          IF (skipini.AND.MOD(m-1,rday).EQ.0.OR..NOT.skipini.AND.
     .       MOD(m,rday).EQ.0) CALL close_ofile 
c
c --- - End loop over files and records
        ENDDO
c
c --- - Close output file if still open 
        IF (MOD(m,rday).GT.0) CALL close_ofile
c
      ENDDO
c
c
c --- Process table AERday
      fnm=pAERday
      table=tAERday
      linstant=.FALSE.
      lreadplev=.TRUE.
      DO n=1,nAERday
        IF (skip_variable(n,nAERday,dAERday)) CYCLE
c
c --- - Map namelist variables 
        ovnm=vAERday(ovnmpos,n)
        ivnm=vAERday(ivnmpos,n)
        special=vAERday(3,n)
        vunits=' '
        vpositive=' '
        vcomment=' '
c 
c --- - Check if 2d and/or 3d fields are to be written 
        CALL get_vertcoord(TRIM(tabledir)//TRIM(table),ovnm,zcoord)
        IF (zcoord(1:4).EQ.'plev'.OR.zcoord(2:5).EQ.'leve'.OR.
     .    zcoord(2:5).EQ.'levh') THEN
          IF (.NOT.do_3d) CYCLE
c --- --- Read pressure levels from table 
          IF (lreadplev.AND.zcoord(1:4).EQ.'plev') THEN
            CALL read_gridinfo_plev(TRIM(zcoord))
!            lreadplev=.FALSE.
          ENDIF
        ELSE
          IF (.NOT.do_2d) CYCLE
        ENDIF
c 
c --- - Choose history file 
        itag=tagaday
c
c --- - Check if input variable is present  
        IF (LEN_TRIM(pAERday).eq.0) CALL  scan_files(reset=.TRUE.)
        IF (INDEX(special,'catplev').LT.1) THEN
          IF (.NOT.var_in_file(fnm,ivnm)) CYCLE
        ENDIF
c
c --- - Prepare output file 
        CALL special_pre
c
c --- - Loop over files
        skipini=.false.
        m=0
        DO
          m=m+1
c
c --- --- Open output file
          IF (MOD(m-1,rAERday).EQ.0) CALL open_ofile
c
c --- --- Read variable into buffer (average if necessary)
          rec=0
          IF (LEN_TRIM(pAERday).eq.0) CALL scan_files
          IF (rec.EQ.0) EXIT
cdiag     write(*,*) 'DEBUG: ',trim(fnm),rec,tbnd,mbnd,year,month
          IF (tbnd(1).EQ.tbnd(2)) THEN
            IF(verbose) WRITE(*,*) 'Skip initialisation record'
            skipini=.true.
            CYCLE
          ENDIF
          tbnds(:,1)=tbnd
          tval=0.5*(tbnds(1,1)+tbnds(2,1))
c
c --- --- Read data 
          CALL read_tslice(rec,badrec,fnm)
c
c --- --- Post processing 
          IF (zcoord(1:4).EQ.'plev'.AND.
     .      INDEX(special,'catplev').LT.1) THEN
            CALL interp_z
          ELSE
            ofld=ifld
          ENDIF
          CALL special_post
c
c --- --- Write time slice to output file 
          CALL write_tslice
c
c --- --- Close output file if max rec has been reached 
          IF (skipini.AND.MOD(m-1,rAERday).EQ.0.OR..NOT.skipini.AND.
     .       MOD(m,rAERday).EQ.0) CALL close_ofile
c
c --- - End loop over files and records
        ENDDO
c
c --- - Close output file if still open 
        IF (MOD(m,rAERday).GT.0) CALL close_ofile
c
      ENDDO
c
c
c --- Process table Eday
      fnm=pEday
      table=tEday
      linstant=.FALSE.
      lreadplev=.TRUE.
      DO n=1,nEday
        IF (skip_variable(n,nEday,dEday)) CYCLE
c
c --- - Map namelist variables 
        ovnm=vEday(ovnmpos,n)
        ivnm=vEday(ivnmpos,n)
        special=vEday(3,n)
        vunits=' '
        vpositive=' '
        vcomment=' '
c 
c --- - Check if 2d and/or 3d fields are to be written 
        CALL get_vertcoord(TRIM(tabledir)//TRIM(table),ovnm,zcoord)
        IF (zcoord(1:4).EQ.'plev'.OR.zcoord(2:5).EQ.'leve'.OR.
     .    zcoord(2:5).EQ.'levh') THEN
          IF (.NOT.do_3d) CYCLE
c --- --- Read pressure levels from table 
          IF (lreadplev.AND.zcoord(1:4).EQ.'plev') THEN
            CALL read_gridinfo_plev(TRIM(zcoord))
!            lreadplev=.FALSE.
          ENDIF
        ELSE
          IF (.NOT.do_2d) CYCLE
        ENDIF
c 
c --- - Choose history file 
        itag=tagaday
c
c --- - Check if input variable is present  
        IF (LEN_TRIM(pEday).eq.0) CALL  scan_files(reset=.TRUE.)
        IF (INDEX(special,'catplev').LT.1) THEN
          IF (.NOT.var_in_file(fnm,ivnm)) CYCLE
        ENDIF
c
c --- - Prepare output file 
        CALL special_pre
c
c --- - Loop over files
        skipini=.false.
        m=0
        DO
          m=m+1
c
c --- --- Open output file
          IF (MOD(m-1,rEday).EQ.0) CALL open_ofile
c
c --- --- Read variable into buffer (average if necessary)
          rec=0
          IF (LEN_TRIM(pEday).eq.0) CALL scan_files
          IF (rec.EQ.0) EXIT
cdiag     write(*,*) 'DEBUG: ',trim(fnm),rec,tbnd,mbnd,year,month
          IF (tbnd(1).EQ.tbnd(2)) THEN
            IF(verbose) WRITE(*,*) 'Skip initialisation record'
            skipini=.true.
            CYCLE
          ENDIF
          tbnds(:,1)=tbnd
          tval=0.5*(tbnds(1,1)+tbnds(2,1))
c
c --- --- Read data 
          CALL read_tslice(rec,badrec,fnm)
c
c --- --- Post processing 
          IF (zcoord(1:4).EQ.'plev'.AND.
     .      INDEX(special,'catplev').LT.1) THEN
            CALL interp_z
          ELSE
            ofld=ifld
          ENDIF
          CALL special_post
c
c --- --- Write time slice to output file 
          CALL write_tslice
c
c --- --- Close output file if max rec has been reached 
          IF (skipini.AND.MOD(m-1,rEday).EQ.0.OR..NOT.skipini.AND.
     .       MOD(m,rEday).EQ.0) CALL close_ofile
c
c --- - End loop over files and records
        ENDDO
c
c --- - Close output file if still open 
        IF (MOD(m,rEday).GT.0) CALL close_ofile
c
      ENDDO
c
c
c --- Process table CFday
      fnm=pCFday
      table=tCFday
      linstant=.FALSE.
      lreadplev=.TRUE.
      DO n=1,nCFday
        IF (skip_variable(n,nCFday,dCFday)) CYCLE
c
c --- - Map namelist variables 
        ovnm=vCFday(ovnmpos,n)
        ivnm=vCFday(ivnmpos,n)
        special=vCFday(3,n)
        vunits=' '
        vpositive=' '
        vcomment=' '
c 
c --- - Check if 2d and/or 3d fields are to be written 
        CALL get_vertcoord(TRIM(tabledir)//TRIM(table),ovnm,zcoord)
        IF (zcoord(1:4).EQ.'plev'.OR.zcoord(2:5).EQ.'leve'.OR.
     .    zcoord(2:5).EQ.'levh') THEN
          IF (.NOT.do_3d) CYCLE
c --- --- Read pressure levels from table 
          IF (lreadplev.AND.zcoord(1:4).EQ.'plev') THEN
            CALL read_gridinfo_plev(TRIM(zcoord))
!            lreadplev=.FALSE.
          ENDIF
        ELSE
          IF (.NOT.do_2d) CYCLE
        ENDIF
c 
c --- - Choose history file 
        itag=tagaday
c
c --- - Check if input variable is present  
        IF (LEN_TRIM(pCFday).eq.0) CALL  scan_files(reset=.TRUE.)
        IF (INDEX(special,'catplev').LT.1) THEN
          IF (.NOT.var_in_file(fnm,ivnm)) CYCLE
        ENDIF
c
c --- - Prepare output file 
        CALL special_pre
c
c --- - Loop over files
        skipini=.false.
        m=0
        DO
          m=m+1
c
c --- --- Open output file
          IF (MOD(m-1,rCFday).EQ.0) CALL open_ofile
c
c --- --- Read variable into buffer (average if necessary)
          rec=0
          IF (LEN_TRIM(pCFday).eq.0) CALL scan_files
          IF (rec.EQ.0) EXIT
cdiag     write(*,*) 'DEBUG: ',trim(fnm),rec,tbnd,mbnd,year,month
          IF (tbnd(1).EQ.tbnd(2)) THEN
            IF(verbose) WRITE(*,*) 'Skip initialisation record'
            skipini=.true.
            CYCLE
          ENDIF
          tbnds(:,1)=tbnd
          tval=0.5*(tbnds(1,1)+tbnds(2,1))
c
c --- --- Read data 
          CALL read_tslice(rec,badrec,fnm)
c
c --- --- Post processing 
          IF (zcoord(1:4).EQ.'plev'.AND.
     .      INDEX(special,'catplev').LT.1) THEN
            CALL interp_z
          ELSE
            ofld=ifld
          ENDIF
          CALL special_post
c
c --- --- Write time slice to output file 
          CALL write_tslice
c
c --- --- Close output file if max rec has been reached 
          IF (skipini.AND.MOD(m-1,rCFday).EQ.0.OR..NOT.skipini.AND.
     .       MOD(m,rCFday).EQ.0) CALL close_ofile
c
c --- - End loop over files and records
        ENDDO
c
c --- - Close output file if still open 
        IF (MOD(m,rCFday).GT.0) CALL close_ofile
c
      ENDDO
c
c
c --- Process table 6hrlev
      fnm=p6hrlev
      table=t6hrlev
      linstant=.TRUE.
      DO n=1,n6hrlev
        IF (skip_variable(n,n6hrlev,d6hrlev)) CYCLE
c
c --- - Map namelist variables 
        ovnm=v6hrlev(ovnmpos,n)
        ivnm=v6hrlev(ivnmpos,n)
        special=v6hrlev(3,n)
        vunits=' '
        vpositive=' '
        vcomment=' '
c 
c --- - Check if 2d and/or 3d fields are to be written 
        CALL get_vertcoord(TRIM(tabledir)//TRIM(table),ovnm,zcoord)
        IF (zcoord(1:4).EQ.'plev'.OR.zcoord(2:5).EQ.'leve'.OR.
     .    zcoord(2:5).EQ.'levh') THEN
          IF (.NOT.do_3d) CYCLE
        ELSE
          IF (.NOT.do_2d) CYCLE
        ENDIF
c 
c --- - Choose history file 
        itag=taga6hr
c
c --- - Check if input variable is present  
        IF (LEN_TRIM(p6hrlev).eq.0) CALL scan_files(reset=.TRUE.)
        IF (.NOT.var_in_file(fnm,ivnm)) CYCLE
c
c --- - Prepare output file 
        CALL special_pre
c
c --- - Loop over files
        m=0
        DO
          m=m+1
c
c --- --- Open output file
          IF (MOD(m-1,r6hrlev).EQ.0) CALL open_ofile 
c
c --- --- Read variable into buffer (average if necessary)
          rec=0
          IF (LEN_TRIM(p6hrlev).eq.0) CALL scan_files
          IF (rec.EQ.0) EXIT
cdiag     write(*,*) 'DEBUG: ',trim(fnm),rec,tbnd,mbnd,year,month
          tbnds(:,1)=tbnd
          tval=0.5*(tbnds(1,1)+tbnds(2,1))
c
c --- --- Read data 
          CALL read_tslice(rec,badrec,fnm) 
c
c --- --- Post processing 
          ofld=ifld
          CALL special_post
          IF (badrec) ofld=1e20
c
c --- --- Write time slice to output file 
          CALL write_tslice
c
c --- --- Close output file if max rec has been reached 
          IF (MOD(m,r6hrlev).EQ.0) CALL close_ofile 
c
c --- - End loop over files and records
        ENDDO
c
c --- - Close output file if still open 
        IF (MOD(m,r6hrlev).GT.0) CALL close_ofile
c
      ENDDO
c
c
c --- Process table 6hrplev
      fnm=p6hrplev
      table=t6hrplev
      linstant=.TRUE.
      lreadplev=.TRUE.
      DO n=1,n6hrplev
        IF (skip_variable(n,n6hrplev,d6hrplev)) CYCLE
c
c --- - Map namelist variables 
        ovnm=v6hrplev(ovnmpos,n)
        ivnm=v6hrplev(ivnmpos,n)
        special=v6hrplev(3,n)
        vunits=' '
        vpositive=' '
        vcomment=' '
c 
c --- - Check if 2d and/or 3d fields are to be written 
        CALL get_vertcoord(TRIM(tabledir)//TRIM(table),ovnm,zcoord)
        IF (zcoord(1:4).EQ.'plev'.OR.zcoord(2:5).EQ.'leve'.OR.
     .    zcoord(2:5).EQ.'levh') THEN
          IF (.NOT.do_3d) CYCLE
c --- --- Read pressure levels from table 
          IF (lreadplev.AND.zcoord(1:4).EQ.'plev') THEN 
            CALL read_gridinfo_plev(TRIM(zcoord))
            lreadplev=.FALSE.
          ENDIF
        ELSE
          IF (.NOT.do_2d) CYCLE
        ENDIF
c 
c --- - Choose history file 
        itag=taga6hr
c
c --- - Check if input variable is present  
        IF (LEN_TRIM(p6hrplev).EQ.0)CALL scan_files(reset=.TRUE.)
        IF (.NOT.var_in_file(fnm,ivnm)) CYCLE
c
c --- - Prepare output file 
        CALL special_pre
c
c --- - Loop over files
        m=0
        DO
          m=m+1
c
c --- --- Open output file
          IF (MOD(m-1,r6hrplev).EQ.0) CALL open_ofile 
c
c --- --- Read variable into buffer (average if necessary)
          rec=0
          IF (LEN_TRIM(p6hrplev).eq.0) CALL scan_files 
          IF (rec.EQ.0) EXIT
cdiag     write(*,*) 'DEBUG: ',trim(fnm),rec,tbnd,mbnd,year,month
          tbnds(:,1)=tbnd
          tval=0.5*(tbnds(1,1)+tbnds(2,1))
c
c --- --- Read data 
          CALL read_tslice(rec,badrec,fnm)
c
c --- --- Post processing 
          IF (zcoord(1:4).EQ.'plev'.AND.
     .      INDEX(special,'catplev').LT.1) THEN 
            CALL interp_z
          ELSE
            ofld=ifld
          ENDIF
          CALL special_post
          IF (badrec) ofld=1e20

c --- --- Write time slice to output file 
          CALL write_tslice
c
c --- --- Close output file if max rec has been reached 
          IF (MOD(m,r6hrplev).EQ.0) CALL close_ofile 
c
c --- - End loop over files and records
        ENDDO
c
c --- - Close output file if still open 
        IF (MOD(m,r6hrplev).GT.0) CALL close_ofile
c
      ENDDO
c
c
c --- Process table 3hr 
      fnm=p3hr
      table=t3hr
      linstant=.FALSE.
      DO n=1,n3hr
        IF (skip_variable(n,n3hr,d3hr)) CYCLE
c
c --- - Map namelist variables 
        ovnm=v3hr(ovnmpos,n)
        ivnm=v3hr(ivnmpos,n)
        special=v3hr(3,n)
        vunits=' '
        vpositive=' '
        vcomment=' '
c 
c --- - Check if 2d and/or 3d fields are to be written 
        CALL get_vertcoord(TRIM(tabledir)//TRIM(table),ovnm,zcoord)
        IF (zcoord(1:4).EQ.'plev'.OR.zcoord(2:5).EQ.'leve'.OR.
     .    zcoord(2:5).EQ.'levh') THEN
          IF (.NOT.do_3d) CYCLE
        ELSE
          IF (.NOT.do_2d) CYCLE
        ENDIF
c 
c --- - Choose history file 
        itag=taga3hr
c
c --- - Check if input variable is present  
        IF (LEN_TRIM(p3hr).eq.0) CALL scan_files(reset=.TRUE.)
        IF (.NOT.var_in_file(fnm,ivnm)) CYCLE
c
c --- - Prepare output file 
        CALL special_pre
c
c --- - Loop over files
        m=0
        DO
          m=m+1
c
c --- --- Open output file
          IF (MOD(m-1,r3hr).EQ.0) CALL open_ofile 
c
c --- --- Read variable into buffer (average if necessary)
          rec=0
          IF (LEN_TRIM(p3hr).eq.0) CALL scan_files 
          IF (rec.EQ.0) EXIT
cdiag     write(*,*) 'DEBUG: ',trim(fnm),rec,tbnd,mbnd,year,month
          tbnds(:,1)=tbnd
          tval=0.5*(tbnds(1,1)+tbnds(2,1))
c
c --- --- Read data 
          CALL read_tslice(rec,badrec,fnm)

c --- --- Post processing 
          ofld=ifld
          CALL special_post
c
c --- --- Write time slice to output file 
          CALL write_tslice
c
c --- --- Close output file if max rec has been reached 
          IF (MOD(m,r3hr).EQ.0) CALL close_ofile 
c
c --- - End loop over files
        ENDDO 
c
c --- - Close output file if still open 
        IF (MOD(m,r3hr).GT.0) CALL close_ofile
c
      ENDDO
c
c
c --- Process table 3hr (instantaneous)
      fnm=p3hri
      table=t3hri
      linstant=.TRUE.
      DO n=1,n3hri
        IF (skip_variable(n,n3hri,d3hri)) CYCLE
c
c --- - Map namelist variables 
        ovnm=v3hri(ovnmpos,n)
        ivnm=v3hri(ivnmpos,n)
        special=v3hri(3,n)
        vunits=' '
        vpositive=' '
        vcomment=' '
c 
c --- - Check if 2d and/or 3d fields are to be written 
        CALL get_vertcoord(TRIM(tabledir)//TRIM(table),ovnm,zcoord)
        IF (zcoord(1:4).EQ.'plev'.OR.zcoord(2:5).EQ.'leve'.OR.
     .    zcoord(2:5).EQ.'levh') THEN
          IF (.NOT.do_3d) CYCLE
        ELSE
          IF (.NOT.do_2d) CYCLE
        ENDIF
c 
c --- - Choose history file 
        itag=taga3hri
c
c --- - Check if input variable is present  
        IF (LEN_TRIM(p3hri).eq.0) CALL scan_files(reset=.TRUE.)
        IF (.NOT.var_in_file(fnm,ivnm)) CYCLE
c
c --- - Prepare output file 
        CALL special_pre
c
c --- - Loop over files
        m=0
        DO
          m=m+1
c
c --- --- Open output file
          IF (MOD(m-1,r3hri).EQ.0) CALL open_ofile 
c
c --- --- Read variable into buffer (average if necessary)
          rec=0
          IF (LEN_TRIM(p3hri).eq.0) CALL scan_files 
          IF (rec.EQ.0) EXIT
cdiag     write(*,*) 'DEBUG: ',trim(fnm),rec,tbnd,mbnd,year,month
          tbnds(:,1)=tbnd
          tval=0.5*(tbnds(1,1)+tbnds(2,1))
c
c --- --- Read data 
          CALL read_tslice(rec,badrec,fnm)
c
c --- --- Post processing 
          ofld=ifld
          CALL special_post
          IF (badrec) ofld=1e20
c
c --- --- Write time slice to output file 
          CALL write_tslice
c
c --- --- Close output file if max rec has been reached 
          IF (MOD(m,r3hri).EQ.0) CALL close_ofile 
c
c --- - End loop over files
        ENDDO 
c
c --- - Close output file if still open 
        IF (MOD(m,r3hri).GT.0) CALL close_ofile
c
      ENDDO
c
c
      END SUBROUTINE atm2cmor



      SUBROUTINE special_pre
c
      IMPLICIT NONE
c
      str2=special
      DO
        IF (INDEX(str2,';').GT.0) THEN
          str1=str2(1:INDEX(str2,';')-1)
          str2=str2(INDEX(str2,';')+1:)
        ELSE
          str1=str2
        ENDIF
        SELECT CASE (str1)
c
c --- - Fix unitless units 
        CASE ('unitless')
          vunits='1'
c
c --- - CO2 units 
        CASE ('co2units')
          vunits='1e-6'
c
c --- - Set correct units for percentage
        CASE ('percent')
          vunits='%'
c 
c --- - Unit transformation: m -> kg m-2  
        CASE ('kg m-2','calcload')
          vunits='kg m-2'
c 
c --- - Unit transformation: m s-1 -> kg m-2 s-1 
        CASE ('kg m-2 s-1')
          vunits='kg m-2 s-1'
c 
c --- - Fix micrometers units 
        CASE ('micrometer')
          vunits='micrometers'
c
c --- - Fix m units 
        CASE ('m')
          vunits='m'
c
c --- - Fix m-2 units 
        CASE ('m-2')
          vunits='m-2'
c 
c --- - Set N_AER units
        CASE ('cm-3')
          vunits='cm-3'
c 
c --- - Set OH_aft units
        CASE ('mol mol-1')
          vunits='mol mol-1'
c
c --- - Convert degress Celsius to K 
        CASE ('Celsius2Kelvin')
          vunits='K'
c       
c --- - Convert units from radians2 to m2    
        CASE ('rad2m')
          vunits='m2'
c
c --- - Set positive attribute  
        CASE ('positiveup')
          vpositive='up'
          WRITE(*,*) 'set positive attribute to ',TRIM(vpositive)
        CASE ('positivedo')
          vpositive='down'
          WRITE(*,*) 'set positive attribute to ',TRIM(vpositive)
c
c --- - Write comment for hur and hurs
        CASE ('hurcomment')
          vcomment='field is weighted towards water-ice fraction'
c
c --- - Write comment for evspsbl
        CASE ('evscomment')
          vcomment='field includes dew fall and therefore may '
     .      //'have negative values'
c
c --- - Times dry mass 
        CASE ('timesmass')
          vunits='kg'
c
c --- - Weight with CLDFOC^-1 or FOCHANA^-1  
        CASE ('cldfoc','fochana')
          vcomment=
     .      'Variable definition deviates from the CMIP5 table '
     .    //'definition. The variable is weighted toward '
     .    //'frequency of occurence of warm clouds.'
c
c --- - Weight with CLDFOC^-1 or FOCHANA^-1  
        CASE ('blayer')
          vcomment=
     .      'Variable definition deviates from the CMIP5 table '
     .    //'definition. Values are taken from the lowest model layer.'

c
        END SELECT
        IF (str1.EQ.str2) exit
      END DO
c
      END SUBROUTINE special_pre



      SUBROUTINE special_post
c
      IMPLICIT NONE
c
      INTEGER :: i,j,k
c
      str2=special
      DO
        IF (INDEX(str2,';').GT.0) THEN
          str1=str2(1:INDEX(str2,';')-1)
          str2=str2(INDEX(str2,';')+1:)
        ELSE
          str1=str2
        ENDIF
        SELECT CASE (str1)
c
c --- - Convert degress Celsius to K 
        CASE ('Celsius2Kelvin')
          ofld=ofld+273.15 
c
c --- - CO2 units 
        CASE ('co2units')
          ofld=ofld*1e6*29./(12.+2.*16.)
c
c --- - Density weighted vertical integration  
        CASE ('calcload')
          CALL calcload
c
c --- - Convert units from radians2 to m2    
        CASE ('rad2m')
          ofld=ofld*6.37122e6**2
c
c --- - Unit transformation: m -> kg m-2 
        CASE ('kg m-2')
          ofld=ofld*1e3
c
c --- - Unit transformation: m s-1 -> kg m-2 s-1 
        CASE ('kg m-2 s-1')
          ofld=ofld*1e3
c
c --- - Weight with DAYFOC^-1, CLDFOC^-1 or FOCHANA^-1  
        CASE ('dayfoc','cldfoc','fochana')
          DO k=1,kdm
            DO j=1,jdm
              DO i=1,idm 
                IF (ABS(ifld2(i,j,k)).GT.1e-15) THEN 
                  ofld(i,j,k)=ofld(i,j,k)/ifld2(i,j,k)
                ELSE
                  ofld(i,j,k)=1e20
                ENDIF
              ENDDO
            ENDDO
          ENDDO
c
c --- - Weight with land fraction 
        CASE ('landfrac')
          ofld=ofld*ifld2
c
c --- - Times dry mass (computed offline from PS and Q)
        CASE ('timesmass')
          ofld=ofld*5.11253535805483d+18
c
c --- - Invert fraction field
        CASE ('invert')
          ofld=1-ofld
c
c --- - Divide by g 
        CASE ('xginv')
          ofld=ofld/9.80665
c 
        END SELECT
        IF (str1.EQ.str2) exit
      END DO
c
      END SUBROUTINE special_post



      SUBROUTINE calcload
c
      IMPLICIT NONE
c     
      REAL(KIND=8) :: pt,pb,ps1,fldint
      INTEGER :: i,j,k
c 
c --- Compute dp and dz   
      DO j=1,jdm
        DO i=1,idm
          fldint=0.
          DO k=1,kdm
            ps1=ps(i,j)
            pt=p0*hyai(k)+ps1*hybi(k)
            pb=p0*hyai(k+1)+ps1*hybi(k+1)
            fldint=fldint+ofld(i,j,k)*(pb-pt)*ginv
          ENDDO
          ofld(i,j,kdm)=fldint
        ENDDO
      ENDDO
c 
      END SUBROUTINE calcload

   

      SUBROUTINE read_gridinfo_ifile 
c
      IMPLICIT NONE
c
      INTEGER :: i,j
c
c --- Open first input file 
      CALL scan_files(reset=.TRUE.)
      status=nf90_open(fnm,nf90_nowrite,ncid) 
      CALL handle_ncerror(status)
c
c --- Read longitudes 
      status=nf90_inq_dimid(ncid,'lon',dimid)
      CALL handle_ncerror(status)
      status=nf90_inquire_dimension(ncid,dimid,len=idm)
      CALL handle_ncerror(status)
c
      ALLOCATE(lon(idm),slon(idm),lon_bnds(2,idm),STAT=status) 
      IF (status.NE.0) STOP 'cannot ALLOCATE enough memory (1)'
c
      status=nf90_inq_varid(ncid,'lon',rhid) 
      CALL handle_ncerror(status)
      status=nf90_get_var(ncid,rhid,lon)
      CALL handle_ncerror(status)
      status=nf90_inq_varid(ncid,'slon',rhid) 
      IF (status.EQ.0) THEN 
        status=nf90_get_var(ncid,rhid,slon)
        CALL handle_ncerror(status)
      ELSE 
        slon(1)=0.5*(lon(1)+lon(idm)-360)
        DO i=2,idm
          slon(i)=0.5*(lon(i)+lon(i-1))
        ENDDO
      ENDIF
c
      DO i=1,idm-1 
        lon_bnds(1,i)=slon(i)
        lon_bnds(2,i)=slon(i+1) 
      ENDDO
      lon_bnds(1,idm)=slon(idm)
      lon_bnds(2,idm)=slon(1)+360.  
c
c --- Read latitudes
      status=nf90_inq_dimid(ncid,'lat',dimid)
      CALL handle_ncerror(status)
      status=nf90_inquire_dimension(ncid,dimid,len=jdm)
      CALL handle_ncerror(status)
c
      ALLOCATE(lat(jdm),slat(jdm-1),lat_bnds(2,jdm),STAT=status) 
      IF (status.NE.0) STOP 'cannot ALLOCATE enough memory (2)'
c
      status=nf90_inq_varid(ncid,'lat',rhid) 
      CALL handle_ncerror(status)
      status=nf90_get_var(ncid,rhid,lat)
      CALL handle_ncerror(status)
      status=nf90_inq_varid(ncid,'slat',rhid) 
      IF (status.EQ.0) THEN 
        status=nf90_get_var(ncid,rhid,slat)
        CALL handle_ncerror(status)
      ELSE 
        DO j=1,jdm-1
          slat(j)=0.5*(lat(j+1)+lat(j))
        ENDDO
      ENDIF
c
      lat_bnds(1,1)=-90.
      lat_bnds(2,1)=slat(1)
      DO j=2,jdm-1 
        lat_bnds(1,j)=slat(j-1)
        lat_bnds(2,j)=slat(j) 
      ENDDO
      lat_bnds(1,jdm)=slat(jdm-1)
      lat_bnds(2,jdm)=90.
c
c --- Read vertical hybrid coefficients 
      status=nf90_inq_dimid(ncid,'lev',dimid)
      CALL handle_ncerror(status)
      status=nf90_inquire_dimension(ncid,dimid,len=ldm)
      CALL handle_ncerror(status)
c
      ALLOCATE(lev(ldm),hyam(ldm),hybm(ldm),ilev(ldm+1),hyai(ldm+1),
     .  hybi(ldm+1),iilev(ldm+2),hyaii(ldm+2),hybii(ldm+2),STAT=status)
      IF (status.NE.0) STOP 'cannot allocate enough memory'
c
      status=nf90_inq_varid(ncid,'lev',rhid) 
      CALL handle_ncerror(status)
      status=nf90_get_var(ncid,rhid,lev)
      CALL handle_ncerror(status)
      status=nf90_inq_varid(ncid,'hyam',rhid) 
      CALL handle_ncerror(status)
      status=nf90_get_var(ncid,rhid,hyam)
      CALL handle_ncerror(status)
      status=nf90_inq_varid(ncid,'hybm',rhid) 
      CALL handle_ncerror(status)
      status=nf90_get_var(ncid,rhid,hybm)
      CALL handle_ncerror(status)
      status=nf90_inq_varid(ncid,'P0',rhid) 
      CALL handle_ncerror(status)
      status=nf90_get_var(ncid,rhid,p0)
      CALL handle_ncerror(status)
c
      status=nf90_inq_varid(ncid,'ilev',rhid) 
      CALL handle_ncerror(status)
      status=nf90_get_var(ncid,rhid,ilev)
      CALL handle_ncerror(status)
      status=nf90_inq_varid(ncid,'hyai',rhid) 
      CALL handle_ncerror(status)
      status=nf90_get_var(ncid,rhid,hyai)
      CALL handle_ncerror(status)
      status=nf90_inq_varid(ncid,'hybi',rhid) 
      CALL handle_ncerror(status)
      status=nf90_get_var(ncid,rhid,hybi)
      CALL handle_ncerror(status)
c
      iilev(1)=ilev(1)
      iilev(2:ldm+1)=lev
      iilev(ldm+2)=ilev(ldm+1)
      hyaii(1)=hyai(1)
      hyaii(2:ldm+1)=hyam
      hyaii(ldm+2)=hyai(ldm+1)
      hybii(1)=hybi(1)
      hybii(2:ldm+1)=hybm
      hybii(ldm+2)=hybi(ldm+1)
c
c --- Read calendar info 
      status=nf90_inq_varid(ncid,'time',rhid) 
      CALL handle_ncerror(status)
      status=nf90_get_att(ncid,rhid,'calendar',calendar) 
      CALL handle_ncerror(status)
c     status=nf90_get_att(ncid,rhid,'units',calunits) 
c     CALL handle_ncerror(status)
      WRITE(calunits(12:15),'(i4.4)') exprefyear
c
c --- Close file 
      status=nf90_close(ncid)
      CALL handle_ncerror(status)
c
      END SUBROUTINE read_gridinfo_ifile



      SUBROUTINE read_gridinfo_plev(str)
c  
#ifdef CMOR3
      USE json_module
#endif 
c
      IMPLICIT NONE
c
      CHARACTER(LEN=*) :: str
      INTEGER,PARAMETER :: kmax=200 
      REAL(KIND=8) :: kvec(kmax)
      CHARACTER(LEN=200) :: c200
      LOGICAL :: fexists
#ifdef CMOR3
      TYPE(json_file) :: json
      LOGICAL :: found
      INTEGER :: k 
      CHARACTER(len=10), ALLOCATABLE :: cval(:)
#endif 
c
#ifdef CMOR3
      INQUIRE(FILE=TRIM(tabledir)//TRIM(coordtable),
     .  EXIST=fexists) 
      IF (.NOT.fexists) THEN
        WRITE(*,*) 'Table ',TRIM(tabledir)//TRIM(coordtable),
     .   ' does not exist' 
        STOP
      ENDIF  
      CALL json%initialize()
      CALL json%load_file(filename=
     .  TRIM(tabledir)//TRIM(coordtable))
      CALL json%get('axis_entry.'//TRIM(str)//'.requested',cval,
     .  found)
      CALL json%destroy()
      pdm=size(cval)
      DO k=1,pdm
        READ(cval(k)(1:10),*) kvec(k)
      ENDDO
      DEALLOCATE(cval)
#else
      INQUIRE(FILE=TRIM(tabledir)//TRIM(table),EXIST=fexists) 
      IF (.NOT.fexists) THEN
        WRITE(*,*) 'Table ',TRIM(table), ' does not exist' 
        STOP
      ENDIF  
      pdm=0
      OPEN(funit,FILE=TRIM(tabledir)//TRIM(table),STATUS='OLD')
      DO
        READ(funit,'(a200)') c200
        IF (INDEX(c200,'axis_entry: '//TRIM(str)).LE.0) CYCLE
        DO
          READ(funit,'(a200)') c200
          IF (INDEX(c200,'requested:').LE.0) CYCLE
          c200=ADJUSTL(TRIM(c200(11:)))
          DO
            IF (c200(1:1).EQ.'!'.OR.c200(1:1).EQ.' ') EXIT
            pdm=pdm+1
            READ(c200(1:INDEX(c200,' ')-1),*) kvec(pdm)
            c200=c200(INDEX(c200,' ')+1:)
          ENDDO
          EXIT
        ENDDO
        EXIT
      ENDDO
      CLOSE(funit)
#endif 
c
      IF (ALLOCATED(plevs)) DEALLOCATE(plevs) 
      ALLOCATE(plevs(pdm)) 
      IF (status.NE.0) STOP 'cannot ALLOCATE enough memory (3)'  
      plevs=kvec(1:pdm)
      WRITE(*,*) TRIM(str),': ',plevs
c    
      END SUBROUTINE read_gridinfo_plev



      SUBROUTINE open_ofile(fx)
c 
      IMPLICIT NONE
c
      LOGICAL, OPTIONAL :: fx
      LOGICAL :: fxflag
c
      REAL :: fac1,fac2,fac3,fac4,fac5,fac6
      INTEGER, PARAMETER :: ndimmax=10
      INTEGER :: n,ndims,dimids(ndimmax),dimlens(ndimmax)
      CHARACTER(len=slenmax) :: ivnm1,ivnm2,ivnm3,ivnm4,ivnm5,ivnm6,str
      REAL(KIND=8), DIMENSION(:), ALLOCATABLE :: tmp1d, tmp1d_2
      REAL(KIND=8), DIMENSION(:), ALLOCATABLE :: tmp2d
c
c --- Check if output variable should have time coordinate
      fxflag=.FALSE.
      IF (PRESENT(fx)) THEN
        IF (fx) fxflag=.TRUE.
      ENDIF
c
c --- Inquire variable units and dimensions in input file 
      status=nf90_open(fnm,nf90_nowrite,ncid)
      CALL handle_ncerror(status)
c
      CALL resolve_vnm(slenmax,ivnm,ivnm1,ivnm2,ivnm3,ivnm4,ivnm5,ivnm6,
     .  fac1,fac2,fac3,fac4,fac5,fac6)
      IF (verbose) THEN
        WRITE(*,*) 'Resolve input variable term ',TRIM(ivnm),' ='
        IF (LEN_TRIM(ivnm1).GT.0) WRITE(*,*) ' ',TRIM(ivnm1),'*',fac1
        IF (LEN_TRIM(ivnm2).GT.0) WRITE(*,*) ' + ',TRIM(ivnm2),'*',fac2
        IF (LEN_TRIM(ivnm3).GT.0) WRITE(*,*) ' + ',TRIM(ivnm3),'*',fac3
        IF (LEN_TRIM(ivnm4).GT.0) WRITE(*,*) ' + ',TRIM(ivnm4),'*',fac4
        IF (LEN_TRIM(ivnm5).GT.0) WRITE(*,*) ' + ',TRIM(ivnm5),'*',fac5
        IF (LEN_TRIM(ivnm6).GT.0) WRITE(*,*) ' + ',TRIM(ivnm6),'*',fac6
      ENDIF 
      IF (INDEX(special,'catplev').GE.1) THEN
        str=' ' 
        IF (nint(plevs(1)*1e-2).LT.1000) THEN  
           WRITE(str,'(i3.3)') nint(plevs(1)*1e-2)
        ELSE 
           WRITE(str,'(i4.4)') nint(plevs(1)*1e-2)
        ENDIF 
        IF (ivnm1(1:2).EQ.'Z3') THEN
          ivnm1='Z'//TRIM(str)
        ELSE
          ivnm1=TRIM(ivnm1)//TRIM(str)
        ENDIF
      ENDIF
      status=nf90_inq_varid(ncid,TRIM(ivnm1),rhid)
      IF (status.NE.nf90_noerr) THEN
        WRITE(*,*) 'cannot find input variable ',TRIM(ivnm1)
        STOP
      ENDIF
      status=nf90_inquire_variable(ncid,rhid,ndims=ndims)
      CALL handle_ncerror(status)
      status=nf90_inquire_variable(ncid,rhid,dimids=dimids(1:ndims))
      CALL handle_ncerror(status)
      IF (ndims.lt.3) THEN
        WRITE(*,*) 'Variable ',TRIM(ivnm1),' has too few dimensions'
      ENDIF
      dimlens=1
      DO n=1,ndims
        status=nf90_inquire_dimension(ncid,dimids(n),len=dimlens(n))
        CALL handle_ncerror(status)
      ENDDO
      IF (dimlens(1).NE.idm) THEN
        WRITE(*,*) 'unexpected first dimension of variable ',
     .    TRIM(ivnm1),': ',dimlens(1),' versus idm=',idm
c       STOP
      ENDIF
      IF (dimlens(2).NE.jdm) THEN
        WRITE(*,*) 'unexpected second dimension of variable ',
     .    TRIM(ivnm1),': ',dimlens(2),' versus jdm=',idm
c       STOP
      ENDIF
      IF (ndims.GT.3) THEN
        kdm=dimlens(3)
      ELSE
        kdm=1
      ENDIF
      IF (INDEX(special,'catplev').GE.1) THEN
        kdm=pdm
      ENDIF  
      IF (ALLOCATED(ifld)) DEALLOCATE(ifld,ifld2,ifldacc)
      ALLOCATE(ifld(idm,jdm,kdm),ifld2(idm,jdm,kdm),
     .  ifldacc(idm,jdm,kdm),STAT=status)
      IF (status.NE.0) STOP 'cannot ALLOCATE enough memory (4)'
c 
      IF (LEN_TRIM(vunits).EQ.0) THEN
        status=nf90_get_att(ncid,rhid,'units',vunits)
        CALL handle_ncerror(status)
      END IF 
c
      status=nf90_close(ncid)
      CALL handle_ncerror(status)
c
c --- Inquire time and vertical dimension of output variable 
      IF (.NOT.fxflag) THEN 
        CALL get_timecoord(TRIM(tabledir)//TRIM(table),ovnm,tcoord)
        IF (LEN_TRIM(tcoord).EQ.0) tcoord='time'
      ENDIF  
      CALL get_vertcoord(TRIM(tabledir)//TRIM(table),ovnm,zcoord)
      IF (zcoord(2:4).EQ.'lev'.OR.INDEX(special,'calcload').GT.0) THEN 
        IF (.NOT.ALLOCATED(ps)) THEN 
          ALLOCATE(ps(idm,jdm),STAT=status)
          IF (status.NE.0) STOP 'cannot allocate enough memory'
        ENDIF
      ENDIF
c
      lreqphis=.FALSE.
      IF (TRIM(ivnm1).EQ.'Z3'.OR.TRIM(ivnm1).EQ.'T') THEN
        lreqphis=.TRUE.
        IF (.NOT.ALLOCATED(phis)) THEN
          ALLOCATE(phis(idm,jdm),tbot(idm,jdm),STAT=status)
          IF (status.NE.0) STOP 'cannot allocate enough memory'
        ENDIF
      ENDIF
c
      lreqsst=.FALSE.
      IF (TRIM(ovnm).EQ.'tslsi') THEN
        lreqsst=.TRUE.
        IF (.NOT.ALLOCATED(sst)) THEN
          ALLOCATE(sst(idm,jdm),STAT=status)
          IF (status.NE.0) STOP 'cannot allocate enough memory'
        ENDIF
      ENDIF
c      
c --- Call CMOR setup 
      IF (verbose) THEN
        IF (createsubdirs) THEN  
          error_flag=cmor_setup(inpath=TRIM(ibasedir),
     .      netcdf_file_action=CMOR_REPLACE_4,set_verbosity=CMOR_NORMAL, 
     .      create_subdirectories=1)
        ELSE
          error_flag=cmor_setup(inpath=TRIM(ibasedir),
     .      netcdf_file_action=CMOR_REPLACE_4,set_verbosity=CMOR_NORMAL, 
     .      create_subdirectories=0)
        ENDIF
      ELSE
        IF (createsubdirs) THEN
          error_flag=cmor_setup(inpath=TRIM(ibasedir),
     .      netcdf_file_action=CMOR_REPLACE_4,set_verbosity=CMOR_QUIET,
     .      create_subdirectories=1)
        ELSE
          error_flag=cmor_setup(inpath=TRIM(ibasedir),
     .      netcdf_file_action=CMOR_REPLACE_4,set_verbosity=CMOR_QUIET,
     .      create_subdirectories=0)
        ENDIF
      ENDIF
      IF (error_flag.NE.0) STOP 'Problem setting up CMOR'
c
c --- Define output dataset 
#ifdef CMOR3
      IF (ndims.EQ.1) THEN 
        CALL write_namelist_json('global mean or integral','gm',
     .    atmgrid_resolution,ovnm) 
      ELSE 
        CALL write_namelist_json(atmgrid,atmgrid_label,
     .    atmgrid_resolution,ovnm)
      ENDIF
      error_flag=cmor_dataset_json(namelist_file_json)
      CALL SYSTEM('rm '//TRIM(namelist_file_json))
#else
      error_flag=cmor_dataset(
     .  outpath         = obasedir,
     .  experiment_id   = experiment_id,
     .  institute_id    = institute_id,
     .  institution     = institution1,
     .  source          = source1,
     .  calendar        = calendar,
     .  realization     = realization,
     .  physics_version = physics_version,
     .  initialization_method = initialization_method,
     .  contact         = contact1,
     .  history         = history1,
     .  comment         = comment1,
     .  references      = references1,
     .  model_id        = model_id,
     .  forcing         = forcing1,
     .  branch_time     = branch_time,
     .  parent_experiment_id = parent_experiment_id, 
     .  parent_experiment_rip = parent_experiment_rip)
#endif
c
c --- Define horizontal axes 
      iaxid=cmor_axis(
     .  table           = TRIM(tabledir)//TRIM(table),
     .  table_entry     = 'longitude',
     .  units           = 'degrees_east',
     .  length          = idm,
     .  coord_vals      = lon,
     .  cell_bounds     = lon_bnds)
c
      jaxid=cmor_axis(
     .  table           = TRIM(tabledir)//TRIM(table),
     .  table_entry     = 'latitude', 
     .  units           = 'degrees_north',
     .  length          = jdm,
     .  coord_vals      = lat,
     .  cell_bounds     = lat_bnds)
c
c --- Define time axis 
      IF (.NOT.fxflag) THEN  
        taxid=cmor_axis(
     .    table          = TRIM(tabledir)//TRIM(table),
     .    table_entry    = TRIM(tcoord),
     .    units          = TRIM(calunits),
     .    length         = 1)
      ENDIF 
c
c --- Define vertical axis 
      str='ps'
#ifdef CMOR3 
      IF (tcoord(1:5).EQ.'time1') str='ps1'
#endif
      IF (zcoord(1:4).EQ.'plev') THEN
        kaxid=cmor_axis(
     .    table         = TRIM(tabledir)//TRIM(table),
     .    table_entry   = TRIM(zcoord),
     .    units         = 'Pa',
     .    length        = pdm,
     .    coord_vals    = plevs)
      ELSEIF (TRIM(zcoord).EQ.'alev1') THEN
        ALLOCATE (tmp1d(kdm),tmp1d_2(kdm+1))
        tmp1d(:) = (/lev(kdm)*1d-3/)
        tmp1d_2(1) = dble(ilev(kdm+1))*1.d-3
        tmp1d_2(2) = dble(ilev(kdm))*1.d-3
        kaxid=cmor_axis(
     .    table         = TRIM(tabledir)//TRIM(table),
     .    table_entry   = 'standard_hybrid_sigma',
     .    units         = '1',
     .    length        = 1,
     .    coord_vals    = tmp1d, !(/lev(kdm)*1d-3/),
     .    cell_bounds   = tmp1d_2 ) !(/ilev(kdm+1)*1d-3,ilev(kdm)*1d-3/))
        DEALLOCATE (tmp1d,tmp1d_2)
        error_flag=cmor_zfactor(
     .    zaxis_id      = kaxid,
     .    zfactor_name  = 'p0',
     .    units         = 'Pa',
     .    zfactor_values= p0)
        error_flag=cmor_zfactor(
     .    zaxis_id      = kaxid,
     .    zfactor_name  = 'b',
     .    axis_ids      = (/kaxid/),
     .    zfactor_values= (/hybm(kdm)/),
     .    zfactor_bounds= (/hybi(kdm+1),hybi(kdm)/))
        error_flag=cmor_zfactor(
     .    zaxis_id      = kaxid,
     .    zfactor_name  = 'a',
     .    axis_ids      = (/kaxid/),
     .    zfactor_values= (/hyam(kdm)/),
     .    zfactor_bounds= (/hyai(kdm+1),hyai(kdm)/))
        zfacid=cmor_zfactor(
     .    zaxis_id      = kaxid,
     .    zfactor_name  = TRIM(str),
     .    axis_ids      = (/iaxid,jaxid,taxid/),
     .    units         = 'Pa' )
      ELSEIF (TRIM(zcoord).EQ.'alevel') THEN
        ALLOCATE (tmp1d(SIZE(lev)),tmp1d_2(SIZE(ilev)))
        tmp1d(:) =   1.d-3*lev(:)
        tmp1d_2(:) = 1.d-3*ilev(:)
        kaxid=cmor_axis(
     .    table         = TRIM(tabledir)//TRIM(table),
     .    table_entry   = 'standard_hybrid_sigma',
     .    units         = '1',
     .    length        = ldm,
     .    coord_vals    = tmp1d, !lev*1d-3,
     .    cell_bounds   = tmp1d_2) !ilev*1d-3)
        DEALLOCATE (tmp1d,tmp1d_2)
        error_flag=cmor_zfactor(  
     .    zaxis_id      = kaxid,                       
     .    zfactor_name  = 'p0',                   
     .    units         = 'Pa',                          
     .    zfactor_values= p0)
        error_flag=cmor_zfactor(   
     .    zaxis_id      = kaxid,                        
     .    zfactor_name  = 'b',                     
     .    axis_ids      = (/kaxid/),                 
     .    zfactor_values= hybm,             
     .    zfactor_bounds= hybi )
        error_flag=cmor_zfactor(   
     .    zaxis_id      = kaxid,
     .    zfactor_name  = 'a',
     .    axis_ids      = (/kaxid/),
     .    zfactor_values= hyam,   
     .    zfactor_bounds= hyai )
        zfacid=cmor_zfactor(   
     .    zaxis_id      = kaxid,                          
     .    zfactor_name  = TRIM(str),                     
     .    axis_ids      = (/iaxid,jaxid,taxid/),        
     .    units         = 'Pa' )
      ELSEIF (TRIM(zcoord).EQ.'alevhalf') THEN
        ALLOCATE (tmp1d(size(ilev)),tmp1d_2(size(iilev)))
        tmp1d(:) = ilev(:)*1.d-3
        tmp1d_2(:) = iilev(:)*1.d-3 
        kaxid=cmor_axis(
     .    table         = TRIM(tabledir)//TRIM(table),
#ifdef CMOR3
     .    table_entry   = 'standard_hybrid_sigma_half',
#else
     .    table_entry   = 'standard_hybrid_sigma',
#endif 
     .    units         = '1',
     .    length        = ldm+1,
     .    coord_vals    = tmp1d, !ilev*1d-3,
     .    cell_bounds   = tmp1d_2)! (iilev*1d-3)
        DEALLOCATE (tmp1d,tmp1d_2)
        error_flag=cmor_zfactor(
     .    zaxis_id      = kaxid,
     .    zfactor_name  = 'p0',
     .    units         = 'Pa',
     .    zfactor_values= p0)
        error_flag=cmor_zfactor(
     .    zaxis_id      = kaxid,
#ifdef CMOR3
     .    zfactor_name  = 'b_half',
#else
     .    zfactor_name  = 'b',
#endif 
     .    axis_ids      = (/kaxid/),
     .    zfactor_values= hybi,
     .    zfactor_bounds= hybii )
        error_flag=cmor_zfactor(
     .    zaxis_id      = kaxid,
#ifdef CMOR3
     .    zfactor_name  = 'a_half',
#else
     .    zfactor_name  = 'a',
#endif 
     .    axis_ids      = (/kaxid/),
     .    zfactor_values= hyai,
     .    zfactor_bounds= hyaii )
        zfacid=cmor_zfactor(
     .    zaxis_id      = kaxid,
     .    zfactor_name  = TRIM(str),
     .    axis_ids      = (/iaxid,jaxid,taxid/),
     .    units         = 'Pa' )
      ENDIF
c
c --- Define output variable
      IF (fxflag) THEN 
        varid=cmor_variable(
     .    table          = TRIM(tabledir)//TRIM(table),
     .    table_entry    = TRIM(ovnm),
     .    units          = TRIM(vunits),
     .    axis_ids       = (/ iaxid, jaxid /),
     .    original_name  = TRIM(ivnm),
     .    missing_value  = 1e20,
     .    comment        = TRIM(vcomment))
      ELSE  
        IF (zcoord(1:4).EQ.'plev'.OR.zcoord(1:4).EQ.'alev') THEN
          varid=cmor_variable(
     .      table          = TRIM(tabledir)//TRIM(table),
     .      table_entry    = TRIM(ovnm),
     .      units          = TRIM(vunits),
     .      axis_ids       = (/ iaxid, jaxid, kaxid, taxid /),
     .      original_name  = TRIM(ivnm), 
     .      missing_value  = 1e20,
     .      comment        = TRIM(vcomment),
     .      positive       = TRIM(vpositive))
        ELSEIF (ndims.EQ.1) THEN
            varid=cmor_variable(
     .        table          = TRIM(tabledir)//TRIM(table),
     .        table_entry    = TRIM(ovnm),
     .        units          = TRIM(vunits),
     .        axis_ids       = (/ taxid /),
     .        original_name  = TRIM(ivnm),
     .        missing_value  = 1e20,
     .        comment        = TRIM(vcomment),
     .        positive       = TRIM(vpositive))
        ELSE
          IF (lreqsst) THEN 
            varid=cmor_variable(
     .        table          = TRIM(tabledir)//TRIM(table),
     .        table_entry    = TRIM(ovnm),
     .        units          = TRIM(vunits),
     .        axis_ids       = (/ iaxid, jaxid, taxid /),
     .        original_name  = TRIM(ivnm),
     .        missing_value  = 1e20,
     .        comment        = TRIM(vcomment),
     .        positive       = TRIM(vpositive))
          ELSE
cdiag       WRITE(*,*) 'DEBUG 1'
            varid=cmor_variable(
     .        table          = TRIM(tabledir)//TRIM(table),
     .        table_entry    = TRIM(ovnm),
     .        units          = TRIM(vunits),
     .        axis_ids       = (/ iaxid, jaxid, taxid /),
     .        original_name  = TRIM(ivnm),
     .        missing_value  = 1e20,
     .        comment        = TRIM(vcomment),
     .        positive       = TRIM(vpositive))
cdiag       WRITE(*,*) 'DEBUG 2'
          ENDIF
        ENDIF
      ENDIF
#ifdef DEFLATE
      error_flag = cmor_set_deflate(varid,1,1,5)
#endif 

c --- Allocate memory for output variable
      IF (ALLOCATED(ofld)) DEALLOCATE(ofld)
      IF (zcoord(1:4).EQ.'plev') THEN 
        ALLOCATE(ofld(idm,jdm,pdm),STAT=status)
      ELSE 
        ALLOCATE(ofld(idm,jdm,kdm),STAT=status)
      ENDIF
      IF (status.NE.0) STOP 'cannot allocate enough memory (0)'
c
      END SUBROUTINE open_ofile



      SUBROUTINE close_ofile
c
      IMPLICIT NONE
c
      status=cmor_close()
      IF (status.NE.0) STOP 'problem closing CMOR output file'
c
      END SUBROUTINE close_ofile



      SUBROUTINE read_field
c
      IMPLICIT NONE
c
      REAL :: fac1,fac2,fac3,fac4,fac5,fac6
      INTEGER :: ind
      CHARACTER(LEN=slenmax) :: ivnm1,ivnm2,ivnm3,ivnm4,ivnm5,ivnm6
c
c --- Open input file 
      status=nf90_open(fnm,nf90_nowrite,ncid)
      CALL handle_ncerror(status)
c
c --- Read data
      CALL resolve_vnm(slenmax,ivnm,ivnm1,ivnm2,ivnm3,ivnm4,ivnm5,ivnm6,
     .  fac1,fac2,fac3,fac4,fac5,fac6)
      status=nf90_inq_varid(ncid,TRIM(ivnm1),rhid)
      IF (status.NE.nf90_noerr) THEN
        WRITE(*,*) 'cannot find input variable ',TRIM(ivnm1)
        STOP
      ENDIF
      status=nf90_get_var(ncid,rhid,ifld)
      CALL handle_ncerror(status)
      IF (fac1.ne.1) THEN
        ifld=ifld*fac1
      ENDIF
c 
      IF (LEN_TRIM(ivnm2).GT.0) THEN
        status=nf90_inq_varid(ncid,TRIM(ivnm2),rhid)
        IF (status.NE.nf90_noerr) THEN
          WRITE(*,*) 'cannot find input variable ',TRIM(ivnm2)
          STOP
        ENDIF
        status=nf90_get_var(ncid,rhid,ifld2)
        CALL handle_ncerror(status)
        ifld=ifld+ifld2*fac2 
      ENDIF 
c 
      IF (LEN_TRIM(ivnm3).GT.0) THEN
        status=nf90_inq_varid(ncid,TRIM(ivnm3),rhid)
        IF (status.NE.nf90_noerr) THEN
          WRITE(*,*) 'cannot find input variable ',TRIM(ivnm3)
          STOP
        ENDIF
        status=nf90_get_var(ncid,rhid,ifld2)
        CALL handle_ncerror(status)
        ifld=ifld+ifld2*fac3
      ENDIF 
c 
      IF (LEN_TRIM(ivnm4).GT.0) THEN
        status=nf90_inq_varid(ncid,TRIM(ivnm4),rhid)
        IF (status.NE.nf90_noerr) THEN
          WRITE(*,*) 'cannot find input variable ',TRIM(ivnm4)
          STOP
        ENDIF
        status=nf90_get_var(ncid,rhid,ifld2)
        CALL handle_ncerror(status)
        ifld=ifld+ifld2*fac4
      ENDIF
c 
      IF (LEN_TRIM(ivnm5).GT.0) THEN
        status=nf90_inq_varid(ncid,TRIM(ivnm5),rhid)
        IF (status.NE.nf90_noerr) THEN
          WRITE(*,*) 'cannot find input variable ',TRIM(ivnm5)
          STOP
        ENDIF
        status=nf90_get_var(ncid,rhid,ifld2)
        CALL handle_ncerror(status)
        ifld=ifld+ifld2*fac5
      ENDIF
c 
      IF (LEN_TRIM(ivnm6).GT.0) THEN
        status=nf90_inq_varid(ncid,TRIM(ivnm6),rhid)
        IF (status.NE.nf90_noerr) THEN
          WRITE(*,*) 'cannot find input variable ',TRIM(ivnm6)
          STOP
        ENDIF
        status=nf90_get_var(ncid,rhid,ifld2)
        CALL handle_ncerror(status)
        ifld=ifld+ifld2*fac6
      ENDIF
c
      IF (INDEX(special,'landfrac').GT.0) THEN
          ifld2=1.
          status=nf90_inq_varid(ncid,'LANDFRAC',rhid)
          CALL handle_ncerror(status)
          status=nf90_get_var(ncid,rhid,ifld2)
          CALL handle_ncerror(status)
      ENDIF
c
      status=nf90_close(ncid)
      CALL handle_ncerror(status)
c
      END SUBROUTINE read_field



      SUBROUTINE read_tslice(rec,badrec,fname)
c
      IMPLICIT NONE
c
      REAL :: fac1,fac2,fac3,fac4,fac5,fac6
      INTEGER :: ind,rec,i,j
      INTEGER, SAVE :: fid,fidphis
      CHARACTER(LEN=*), INTENT(IN), OPTIONAL :: fname 
      CHARACTER(LEN=slenmax) :: ivnm1,ivnm2,ivnm3,ivnm4,ivnm5,ivnm6,str
      LOGICAL :: badrec    
c
c --- Open input file 
      IF (PRESENT(fname)) THEN 
        status=nf90_open(fname,nf90_nowrite,fid)
        CALL handle_ncerror(status)
      ELSE
        status=nf90_open(fnm,nf90_nowrite,fid)
        CALL handle_ncerror(status)
      ENDIF
c
      IF (.FALSE.) THEN 
c --- Read time information
      badrec=.FALSE.
      status=nf90_inq_varid(fid,'time',rhid)
      IF (status.NE.nf90_noerr) THEN
        WRITE(*,*) 'cannot find time variable'
        STOP
      ENDIF
      status=nf90_get_var(fid,rhid,tval,(/rec/),(/1/))
      CALL handle_ncerror(status)
      status=nf90_inq_varid(fid,'time_bnds',rhid)
      IF (status.NE.nf90_noerr) THEN
        WRITE(*,*) 'cannot find time_bnds variable'
        STOP
      ENDIF
      status=nf90_get_var(fid,rhid,tbnds,(/1,rec/),(/2,1/))
      CALL handle_ncerror(status)
      IF (linstant) THEN
c --- - Exception for instantaneous 6+3 hourly data
        IF (rec.eq.1) THEN
          status=nf90_inq_varid(fid,'time',rhid)
          CALL handle_ncerror(status)
          status=nf90_get_var(fid,rhid,tval2,(/2/),(/2/))
          CALL handle_ncerror(status)
          IF (tval(1).EQ.tval2(1)) THEN
            tbnds(2,1)=tval(1)+tval2(1)-tval2(2)
            badrec=.TRUE.
          ENDIF     
        ENDIF    
        tbnds(1,1)=tbnds(2,1)
      ENDIF
      tval=0.5*(tbnds(1,1)+tbnds(2,1))
      END IF
c
c --- Read data 
      CALL resolve_vnm(slenmax,ivnm,ivnm1,ivnm2,ivnm3,ivnm4,ivnm5,ivnm6,
     .  fac1,fac2,fac3,fac4,fac5,fac6)
      IF (INDEX(special,'catplev').LT.1) THEN 
        status=nf90_inq_varid(fid,TRIM(ivnm1),rhid)
      ENDIF
cdiag WRITE(*,*) 'DEBUG',trim(ivnm1),rec,idm,jdm,kdm
      IF (INDEX(ivnm1,'vmr').GT.0) THEN 
          status=nf90_get_var(fid,rhid,ifld,(/rec/),(/1/))
      ELSE
        IF (INDEX(special,'catplev').LT.1) THEN 
          IF (status.NE.nf90_noerr) THEN
            WRITE(*,*) 'cannot find input variable ',TRIM(ivnm1)
            STOP
          ENDIF
          IF (.NOT.readdummy) THEN
            IF (kdm.eq.1) THEN
              status=nf90_get_var(fid,rhid,ifld,(/1,1,rec/), 
     .          (/idm,jdm,1/)) 
            ELSE 
              status=nf90_get_var(fid,rhid,ifld,(/1,1,1,rec/), 
     .          (/idm,jdm,kdm,1/)) 
            ENDIF 
            CALL handle_ncerror(status)
          ELSE 
            ifld=0.
          ENDIF
          IF (fac1.ne.1) THEN
            ifld=ifld*fac1
          ENDIF
        ELSE         
          DO i=1,kdm 
            str=' ' 
            IF (nint(plevs(i)*1e-2).LT.1000) THEN 
              WRITE(str,'(i3.3)') nint(plevs(i)*1e-2) 
            ELSE 
              WRITE(str,'(i4.4)') nint(plevs(i)*1e-2) 
            ENDIF 
            IF (ivnm1(1:2).EQ.'Z3') THEN
              status=nf90_inq_varid(fid,'Z'//TRIM(str),rhid) 
            ELSE
              status=nf90_inq_varid(fid,TRIM(ivnm1)//TRIM(str),rhid) 
            ENDIF
            IF (status.NE.nf90_noerr) THEN
              WRITE(*,*) 'cannot find input variable ',
     .          TRIM(ivnm1)//TRIM(str)
              STOP
            ENDIF
            IF (.NOT.readdummy) THEN
              status=nf90_get_var(fid,rhid,ps,(/1,1,rec/), 
     .          (/idm,jdm,1/)) 
               ifld(:,:,i)=ps 
            ELSE 
              ifld=0.
            ENDIF
          ENDDO         
        ENDIF  
c
        IF (LEN_TRIM(ivnm2).GT.0) THEN
          status=nf90_inq_varid(fid,TRIM(ivnm2),rhid)
          IF (status.NE.nf90_noerr) THEN
            WRITE(*,*) 'cannot find input variable ',TRIM(ivnm2)
            STOP
          ENDIF
          IF (kdm.eq.1) THEN
            status=nf90_get_var(fid,rhid,ifld2,(/1,1,rec/),
     .      (/idm,jdm,1/))
          ELSE
            status=nf90_get_var(fid,rhid,ifld2,(/1,1,1,rec/),
     .        (/idm,jdm,kdm,1/))
          ENDIF
          CALL handle_ncerror(status)
          ifld=ifld+ifld2*fac2
        ENDIF
c
        IF (LEN_TRIM(ivnm3).GT.0) THEN
          status=nf90_inq_varid(fid,TRIM(ivnm3),rhid)
          IF (status.NE.nf90_noerr) THEN
            WRITE(*,*) 'cannot find input variable ',TRIM(ivnm3)
            STOP
          ENDIF
          IF (kdm.eq.1) THEN
            status=nf90_get_var(fid,rhid,ifld2,(/1,1,rec/),
     .        (/idm,jdm,1/))
          ELSE
            status=nf90_get_var(fid,rhid,ifld2,(/1,1,1,rec/),
     .        (/idm,jdm,kdm,1/))
          ENDIF
          CALL handle_ncerror(status)
          ifld=ifld+ifld2*fac3
        ENDIF
c
        IF (LEN_TRIM(ivnm4).GT.0) THEN
          status=nf90_inq_varid(fid,TRIM(ivnm4),rhid)
          IF (status.NE.nf90_noerr) THEN
            WRITE(*,*) 'cannot find input variable ',TRIM(ivnm4)
            STOP
          ENDIF
          IF (kdm.eq.1) THEN
            status=nf90_get_var(fid,rhid,ifld2,(/1,1,rec/),
     .        (/idm,jdm,1/))
          ELSE
            status=nf90_get_var(fid,rhid,ifld2,(/1,1,1,rec/),
     .        (/idm,jdm,kdm,1/))
          ENDIF
          CALL handle_ncerror(status)
          ifld=ifld+ifld2*fac4
        ENDIF
c
        IF (LEN_TRIM(ivnm5).GT.0) THEN
          status=nf90_inq_varid(fid,TRIM(ivnm5),rhid)
          IF (status.NE.nf90_noerr) THEN
            WRITE(*,*) 'cannot find input variable ',TRIM(ivnm5)
            STOP
          ENDIF
          IF (kdm.eq.1) THEN
            status=nf90_get_var(fid,rhid,ifld2,(/1,1,rec/),
     .        (/idm,jdm,1/))
          ELSE
            status=nf90_get_var(fid,rhid,ifld2,(/1,1,1,rec/),
     .        (/idm,jdm,kdm,1/))
          ENDIF
          CALL handle_ncerror(status)
          ifld=ifld+ifld2*fac5
        ENDIF
c
        IF (LEN_TRIM(ivnm6).GT.0) THEN
          status=nf90_inq_varid(fid,TRIM(ivnm6),rhid)
          IF (status.NE.nf90_noerr) THEN
            WRITE(*,*) 'cannot find input variable ',TRIM(ivnm6)
            STOP
          ENDIF
          IF (kdm.eq.1) THEN
            status=nf90_get_var(fid,rhid,ifld2,(/1,1,rec/),
     .        (/idm,jdm,1/))
          ELSE
            status=nf90_get_var(fid,rhid,ifld2,(/1,1,1,rec/),
     .        (/idm,jdm,kdm,1/))
          ENDIF
          CALL handle_ncerror(status)
          ifld=ifld+ifld2*fac6
        ENDIF
      ENDIF
c
c --- Read auxillary data 
      IF (zcoord(2:4).EQ.'lev'.OR.INDEX(special,'calcload').GT.0) THEN 
        IF (.NOT.readdummy) THEN
          status=nf90_inq_varid(fid,'PS',rhid)
          CALL handle_ncerror(status)
          status=nf90_get_var(fid,rhid,ps,(/1,1,rec/),(/idm,jdm,1/))
          CALL handle_ncerror(status)
        ELSE 
          ps=0.
        ENDIF
      ENDIF
c
      IF (INDEX(special,'dayfoc').GT.0) THEN 
          ifld2=1.
          status=nf90_inq_varid(fid,'DAYFOC',rhid)
          CALL handle_ncerror(status)
          status=nf90_get_var(fid,rhid,ifld2,(/1,1,rec/),(/idm,jdm,1/))
          CALL handle_ncerror(status)
      ELSEIF (INDEX(special,'fochana').GT.0) THEN  
          ifld2=1.
          status=nf90_inq_varid(fid,'FOCHANA',rhid)
          CALL handle_ncerror(status)
          status=nf90_get_var(fid,rhid,ifld2,(/1,1,rec/),(/idm,jdm,1/))
          CALL handle_ncerror(status)
      ELSEIF (INDEX(special,'cldfoc').GT.0) THEN  
          ifld2=1.
          status=nf90_inq_varid(fid,'CLDFOC',rhid)
          CALL handle_ncerror(status)
          status=nf90_get_var(fid,rhid,ifld2,(/1,1,1,rec/),
     .      (/idm,jdm,kdm,1/))
          CALL handle_ncerror(status)
      ENDIF 
c
      IF (INDEX(special,'landfrac').GT.0) THEN
          ifld2=1.
          status=nf90_inq_varid(fid,'LANDFRAC',rhid)
          CALL handle_ncerror(status)
          status=nf90_get_var(fid,rhid,ifld2)
          CALL handle_ncerror(status)
      ENDIF
c
      IF (lreqphis) THEN
        IF (.NOT.readdummy) THEN
          status=nf90_inq_varid(fid,'PHIS',rhid)
          IF(status.NE.nf90_noerr) THEN 
            status=nf90_open(TRIM(griddata)//TRIM(atmgridfile),
     .       nf90_nowrite,fidphis)
            CALL handle_ncerror(status)
            status=nf90_inq_varid(fidphis,'PHIS',rhid)
            CALL handle_ncerror(status)
            status=nf90_get_var(fidphis,rhid,phis,(/1,1/),(/idm,jdm/))
            CALL handle_ncerror(status)
            status=nf90_close(fidphis) 
          ELSE
            status=nf90_get_var(fid,rhid,phis,(/1,1,rec/),(/idm,jdm,1/))
          ENDIF
          CALL handle_ncerror(status)
          status=nf90_inq_varid(fid,'T',rhid)
          CALL handle_ncerror(status)
          status=nf90_get_var(fid,rhid,tbot,(/1,1,ldm,rec/),
     .      (/idm,jdm,1,1/))
          CALL handle_ncerror(status)          
        ELSE 
          phis=0.
        ENDIF
      ENDIF
c
c --- Mask SSTs 
      IF (lreqsst) THEN
        IF (.NOT.readdummy) THEN
          status=nf90_inq_varid(fid,'SST',rhid)
          CALL handle_ncerror(status)
          status=nf90_get_var(fid,rhid,sst,(/1,1,rec/),(/idm,jdm,1/))
          CALL handle_ncerror(status)
        ELSE
          sst=0.
        ENDIF
        DO j=1,jdm 
          DO i=1,idm
            IF (ifld(i,j,1).EQ.sst(i,j)) ifld(i,j,1)=1e20  
          ENDDO
        ENDDO
      ENDIF
c     
      status=nf90_close(fid)
      CALL handle_ncerror(status)
c
      END SUBROUTINE read_tslice



      SUBROUTINE write_field
c
      IMPLICIT NONE
c
c --- Store variable
      IF (zcoord(1:4).EQ.'plev'.OR.TRIM(zcoord).EQ.'alevel') THEN
        error_flag=cmor_write(
     .    var_id         = varid,
     .    data           = ofld)
      ELSE
        error_flag=cmor_write(
     .    var_id         = varid,
     .    data           = RESHAPE(ofld,(/idm,jdm/)))
      ENDIF
c
c --- Store auxillary data 
      IF (zcoord(1:4).EQ.'alev') THEN
        IF (TRIM(tcoord).NE.'time1') THEN
          error_flag=cmor_write(
     .      var_id         = zfacid,
     .      data           = ps,
     .      ntimes_passed  = 1,
     .      time_vals      = tval,
     .      time_bnds      = tbnds,
     .      store_with     = varid)
        ELSE
          error_flag=cmor_write(
     .      var_id         = zfacid,
     .      data           = ps,
     .      ntimes_passed  = 1,
     .      time_vals      = tval,
     .      store_with     = varid)
        ENDIF
      ENDIF
c
      END SUBROUTINE write_field



      SUBROUTINE write_tslice
c
      IMPLICIT NONE
c
      IF (dry_run) RETURN
c
c --- Store variable
      IF (TRIM(tcoord).NE.'time1') THEN  
        IF (TRIM(ZCOORD).EQ.'alev1'.OR.INDEX(special,'blayer').GT.0.OR.
     .    INDEX(special,'calcload').GT.0) THEN
          error_flag=cmor_write(
     .      var_id         = varid,
     .      data           = RESHAPE(ofld(:,:,kdm:kdm),(/idm,jdm/)),
     .      ntimes_passed  = 1,
     .      time_vals      = tval,
     .      time_bnds      = tbnds)
        ELSEIF (INDEX(ivnm,'vmr').GT.0) THEN 
          error_flag=cmor_write(
     .      var_id         = varid,
     .      data           = RESHAPE(ofld(1:1,1:1,1:1),(/1/)), 
     .      ntimes_passed  = 1,
     .      time_vals      = tval,
     .      time_bnds      = tbnds)
        ELSE
          error_flag=cmor_write(
     .      var_id         = varid,
     .      data           = ofld,
     .      ntimes_passed  = 1,
     .      time_vals      = tval,
     .      time_bnds      = tbnds)
        ENDIF
      ELSE
        IF (TRIM(ZCOORD).EQ.'alev1'.OR.INDEX(special,'blayer').GT.0.OR.
     .    INDEX(special,'calcload').GT.0) THEN
          error_flag=cmor_write(
     .      var_id         = varid,
     .      data           = RESHAPE(ofld(:,:,kdm:kdm),(/idm,jdm/)),
     .      ntimes_passed  = 1,
     .      time_vals      = tval)
        ELSE
          error_flag=cmor_write(
     .      var_id         = varid,
     .      data           = ofld,
     .      ntimes_passed  = 1,
     .      time_vals      = tval)
        ENDIF
      ENDIF
c
c --- Store auxillary data 
      IF (zcoord(1:4).EQ.'alev') THEN 
        IF (TRIM(tcoord).NE.'time1') THEN  
          error_flag=cmor_write(                            
     .      var_id         = zfacid,                          
     .      data           = ps,
     .      ntimes_passed  = 1,
     .      time_vals      = tval,
     .      time_bnds      = tbnds,
     .      store_with     = varid)
        ELSE
          error_flag=cmor_write(
     .      var_id         = zfacid,
     .      data           = ps,
     .      ntimes_passed  = 1,
     .      time_vals      = tval,
     .      store_with     = varid)
        ENDIF
      ENDIF
c
      END SUBROUTINE write_tslice



      SUBROUTINE interp_z
c
      IMPLICIT NONE 
c
      REAL(KIND=8), SAVE :: p0_hpa,missing    
      REAL(KIND=8), SAVE, ALLOCATABLE, DIMENSION(:) :: tmp1d,plevs_hpa 
c
      IF (.NOT.ALLOCATED(tmp1d)) THEN 
        ALLOCATE(tmp1d(ldm+1),STAT=status) 
        IF (status.NE.0) STOP 'cannot allocate enough memory'
        missing=-999. 
        p0_hpa=p0*1e-2 
      ENDIF
      IF (ALLOCATED(plevs_hpa)) DEALLOCATE(plevs_hpa)
      ALLOCATE(plevs_hpa(pdm),STAT=status) 
      IF (status.NE.0) STOP 'cannot allocate enough memory'
      plevs_hpa=plevs*1e-2 
c    
      IF (.NOT.plevdummy) THEN 
        IF (TRIM(ivnm).EQ.'T') THEN  
          CALL vinth2pecmwf(ifld,ofld,hyam,hybm,p0_hpa,tmp1d,plevs_hpa,
     .    1,ps,missing,1,idm,jdm,ldm,ldm,pdm,1,tbot,phis)
        ELSEIF (TRIM(ivnm).EQ.'Z3') THEN  
          CALL vinth2pecmwf(ifld,ofld,hyam,hybm,p0_hpa,tmp1d,plevs_hpa,
     .    1,ps,missing,1,idm,jdm,ldm,ldm,pdm,-1,tbot,phis)
        ELSE 
          CALL vinth2pecmwf(ifld,ofld,hyam,hybm,p0_hpa,tmp1d,plevs_hpa,
     .    1,ps,missing,1,idm,jdm,ldm,ldm,pdm,0,tbot,phis)
        ENDIF 
      ELSE
        ofld=0. 
      ENDIF 
c
      END SUBROUTINE interp_z


      END MODULE m_modelsatm 
