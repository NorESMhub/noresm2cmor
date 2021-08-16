      MODULE m_modelslnd
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
      INTEGER, SAVE :: ii,jj,idm,jdm,kdm,idmrof,jdmrof,ldm
      REAL(KIND=8), ALLOCATABLE, SAVE, DIMENSION(:) :: lon,lat,lev,
     .  lonrof,latrof
      REAL(KIND=8), ALLOCATABLE, SAVE, DIMENSION(:,:) :: 
     .  lon_bnds,lat_bnds,lev_bnds,lonrof_bnds,latrof_bnds
      CHARACTER(LEN=slenmax), ALLOCATABLE, SAVE, DIMENSION(:) :: ltype
      CHARACTER(LEN=slenmax), SAVE :: zcoord,tcoord   
c 
c --- Dataset related variables 
      CHARACTER(LEN=slenmax), SAVE :: ivnm,ovnm,vunits,vpositive  
c
c --- Table related variables 
      CHARACTER(LEN=lenmax) :: table 
c
c --- Cmor parameters 
      INTEGER, SAVE :: iaxid,jaxid,kaxid,taxid,varid,table_id, 
     .  error_flag
c
c --- Data fields
      REAL(KIND=8), ALLOCATABLE, SAVE, DIMENSION(:,:,:) :: fld,fld2,
     .  fldacc 
c
c --- Auxillary variables for special operations 
      CHARACTER(LEN=slenmax), SAVE :: special,str1,str2


c --- -----------------------------------------------------------------
      CONTAINS 
c --- -----------------------------------------------------------------



      SUBROUTINE lnd2cmor 
c
      IMPLICIT NONE
c
      LOGICAL :: badrec,last
      INTEGER :: m,n,nrec
c
c --- Print start information
      IF (verbose) THEN
        WRITE(*,*)
        WRITE(*,*) '---------------------------'
        WRITE(*,*) '--- Process land output ---'
        WRITE(*,*) '---------------------------'
        WRITE(*,*)
      ENDIF
c
c --- Read grid information from input files
      WRITE(*,*) 'Read grid information from input files'
      itag=taglmon
      CALL scan_files(reset=.TRUE.)
      IF (LEN_TRIM(fnm).EQ.0) RETURN 
      CALL read_gridinfo_ifile
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
c
c --- - Skip variable?
        CALL get_vertcoord(TRIM(tabledir)//TRIM(table),ovnm,zcoord)
        IF (TRIM(zcoord).EQ.'sdepth') THEN 
          IF (.NOT.do_3d) CYCLE 
        ELSE 
          IF (.NOT.do_2d) CYCLE 
        ENDIF
c
c --- - Check if input variable is present 
        IF (LEN_TRIM(pfx).eq.0) CYCLE 
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
#ifdef CMOR3
c --- Process table Eyr
      WRITE(*,*) 'Process table Eyr'
      fnm=pEyr
      table=tEyr
      linstant=.FALSE.
      DO n=1,nEyr
        IF (skip_variable(n,nEyr,dEyr)) CYCLE
c
c --- - Map namelist variables 
        ovnm=vEyr(ovnmpos,n)
        ivnm=vEyr(ivnmpos,n)
        special=vEyr(3,n)
        vunits=' '
        vpositive=' '
c
c --- - Skip variable?
        CALL get_vertcoord(TRIM(tabledir)//TRIM(table),ovnm,zcoord)
c 
c --- - Choose history file 
         itag=taglyr
c
c --- - Check if input variable is present  
        IF (LEN_TRIM(pEyr).eq.0) CALL scan_files(reset=.TRUE.)
        IF (.NOT.var_in_file(fnm,ivnm)) CYCLE
c
c --- - Prepare output file 
        CALL special_pre
c
c --- - Loop over input files 
        m=0
        DO
          m=m+1
c
c --- --- Open output file
          IF (MOD(m-1,rEyr).EQ.0) CALL open_ofile
c
c --- --- Read variable into buffer (average if necessary)
          rec=0
          nrec=0
          fldacc=0.
          LAST=.FALSE.
          DO
            IF (LEN_TRIM(pEyr).eq.0) CALL scan_files(reset=.FALSE.)
            IF (rec.EQ.0) then
              last=.TRUE.
              EXIT
            ENDIF
            nrec=nrec+1
cdiag       write(*,*) 'DEBUG: ',trim(fnm),rec,nrec,tbnd,mbnd,year,month
            CALL read_tslice(rec,badrec,fnm)
            fldacc=fldacc+fld
            WRITE(*,*) "WARNING: NO TIME_BOUNDS CHECK FOR Eyr VARIABLE!"
            EXIT
c            IF (tbnd(2).EQ.mbnd(2)) EXIT
          ENDDO
          IF (last) EXIT
          fld=fldacc/FLOAT(nrec)
          tbnds(:,1)=mbnd
          tval=0.5*(tbnds(1,1)+tbnds(2,1))
c 
c --- --- Post processing 
          CALL special_post
c
c --- --- Write time slice to output file 
          CALL write_tslice
c
c --- --- Close output file if max rec has been reached 
          IF (MOD(m,rEyr).EQ.0) CALL close_ofile
c
c --- - End loop over files and records
        ENDDO
c
c --- - Close output file if still open 
        IF (MOD(m,rEyr).GT.0) CALL close_ofile
c
      ENDDO
#endif
c
c --- Process table lmon
      WRITE(*,*) 'Process table lmon'
      fnm=plmon
      table=tlmon 
      linstant=.FALSE.
      DO n=1,nlmon 
        IF (skip_variable(n,nlmon,dlmon)) CYCLE
c
c --- - Map namelist variables 
        ovnm=vlmon(ovnmpos,n) 
        ivnm=vlmon(ivnmpos,n) 
        special=vlmon(3,n)
        vunits=' ' 
        vpositive=' ' 
c
c --- - Skip variable?
        CALL get_vertcoord(TRIM(tabledir)//TRIM(table),ovnm,zcoord)
        IF (TRIM(zcoord).EQ.'sdepth') THEN 
          IF (.NOT.do_3d) CYCLE 
        ELSE 
          IF (.NOT.do_2d) CYCLE 
        ENDIF
c 
c --- - Choose history file 
        SELECT CASE (TRIM(special)) 
          CASE ('day2mon')
            itag=taglday 
          CASE ('3hr2mon')
            itag=tagl3hr
          CASE DEFAULT 
            itag=taglmon
        END SELECT
c
c --- - Check if input variable is present  
        IF (LEN_TRIM(plmon).eq.0) CALL scan_files(reset=.TRUE.)
        IF (.NOT.var_in_file(fnm,ivnm)) CYCLE 
c
c --- - Prepare output file 
        CALL special_pre     
c
c --- - Loop over input files 
        m=0
        DO
          m=m+1
c
c --- --- Open output file
          IF (MOD(m-1,rlmon).EQ.0) CALL open_ofile
c
c --- --- Read variable into buffer (average if necessary)
          rec=0
          nrec=0
          fldacc=0.
          LAST=.FALSE.
          DO
            IF (LEN_TRIM(plmon).eq.0) CALL scan_files(reset=.FALSE.)
            IF (rec.EQ.0) then
              last=.TRUE.
              EXIT
            ENDIF
            nrec=nrec+1
cdiag       write(*,*) 'DEBUG: ',trim(fnm),rec,nrec,tbnd,mbnd,year,month
            CALL read_tslice(rec,badrec,fnm)
            fldacc=fldacc+fld
            IF (tbnd(2).EQ.mbnd(2)) EXIT
          ENDDO
          IF (last) EXIT
          fld=fldacc/FLOAT(nrec)
          tbnds(:,1)=mbnd
          tval=0.5*(tbnds(1,1)+tbnds(2,1))
c 
c --- --- Post processing 
          CALL special_post 
c
c --- --- Write time slice to output file 
          CALL write_tslice  
c
c --- --- Close output file if max rec has been reached 
          IF (MOD(m,rlmon).EQ.0) CALL close_ofile
c
c --- - End loop over files and records
        ENDDO
c
c --- - Close output file if still open 
        IF (MOD(m,rlmon).GT.0) CALL close_ofile
c
      ENDDO
c
c 
#ifdef CMOR3
c --- Process table Emon
      WRITE(*,*) 'Process table Emon'
      fnm=pEmon
      table=tEmon
      linstant=.FALSE.
      DO n=1,nEmon
        IF (skip_variable(n,nEmon,dEmon)) CYCLE
c
c --- - Map namelist variables 
        ovnm=vEmon(ovnmpos,n)
        ivnm=vEmon(ivnmpos,n)
        special=vEmon(3,n)
        vunits=' '
        vpositive=' '
c
c --- - Skip variable?
        CALL get_vertcoord(TRIM(tabledir)//TRIM(table),ovnm,zcoord)
        IF (TRIM(zcoord).EQ.'sdepth') THEN
          IF (.NOT.do_3d) CYCLE
        ELSE
          IF (.NOT.do_2d) CYCLE
        ENDIF
c 
c --- - Choose history file 
        SELECT CASE (TRIM(special))
          CASE ('day2mon')
            itag=taglday
          CASE ('3hr2mon')
            itag=tagl3hr
          CASE DEFAULT
            itag=taglmon
        END SELECT
c
c --- - Check if input variable is present  
        IF (LEN_TRIM(pEmon).eq.0) CALL scan_files(reset=.TRUE.)
        IF (.NOT.var_in_file(fnm,ivnm)) CYCLE
c
c --- - Prepare output file 
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
          fldacc=0.
          LAST=.FALSE.
          DO
            IF (LEN_TRIM(pEmon).eq.0) CALL scan_files(reset=.FALSE.)
            IF (rec.EQ.0) then
              last=.TRUE.
              EXIT
            ENDIF
            nrec=nrec+1
cdiag       write(*,*) 'DEBUG: ',trim(fnm),rec,nrec,tbnd,mbnd,year,month
            CALL read_tslice(rec,badrec,fnm)
            fldacc=fldacc+fld
            IF (tbnd(2).EQ.mbnd(2)) EXIT
          ENDDO
          IF (last) EXIT
          fld=fldacc/FLOAT(nrec)
          tbnds(:,1)=mbnd
          tval=0.5*(tbnds(1,1)+tbnds(2,1))
c 
c --- --- Post processing 
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
c 
c --- Process table limon
      WRITE(*,*) 'Process table limon'
      fnm=plimon
      table=tlimon
      linstant=.FALSE.
      DO n=1,nlimon
        IF (skip_variable(n,nlimon,dlimon)) CYCLE
c
c --- - Map namelist variables 
        ovnm=vlimon(ovnmpos,n)
        ivnm=vlimon(ivnmpos,n)
        special=vlimon(3,n)
        vunits=' '
        vpositive=' '
c
c --- - Skip variable?
        CALL get_vertcoord(TRIM(tabledir)//TRIM(table),ovnm,zcoord)
        IF (TRIM(zcoord).EQ.'sdepth') THEN 
          IF (.NOT.do_3d) CYCLE 
        ELSE 
          IF (.NOT.do_2d) CYCLE 
        ENDIF
c 
c --- - Choose history file 
        SELECT CASE (TRIM(special))
          CASE ('day2mon')
            itag=taglday
          CASE ('3hr2mon')
            itag=tagl3hr
          CASE DEFAULT
            itag=taglmon
        END SELECT
c
c --- - Check if input variable is present  
        IF (LEN_TRIM(plimon).eq.0) CALL scan_files(reset=.TRUE.)
        IF (.NOT.var_in_file(fnm,ivnm)) CYCLE
c
c --- - Prepare output file 
        CALL special_pre
c
c --- - Loop over input files 
        m=0
        DO
          m=m+1
c
c --- --- Open output file
          IF (MOD(m-1,rlimon).EQ.0) CALL open_ofile
c 
c --- --- Read variable into buffer (average if necessary)
          rec=0
          nrec=0
          fldacc=0.
          LAST=.FALSE.
          DO
            IF (LEN_TRIM(plimon).eq.0) CALL scan_files(reset=.FALSE.)
            IF (rec.EQ.0) then
              last=.TRUE.
              EXIT
            ENDIF
            nrec=nrec+1
cdiag       write(*,*) 'DEBUG: ',trim(fnm),rec,nrec,tbnd,mbnd,year,month
            CALL read_tslice(rec,badrec,fnm)
            fldacc=fldacc+fld
            IF (tbnd(2).EQ.mbnd(2)) EXIT
          ENDDO
          IF (last) EXIT
          fld=fldacc/FLOAT(nrec)
          tbnds(:,1)=mbnd
          tval=0.5*(tbnds(1,1)+tbnds(2,1))
c 
c --- --- Post processing 
          CALL special_post
c
c --- --- Write time slice to output file 
          CALL write_tslice
c
c --- --- Close output file if max rec has been reached 
          IF (MOD(m,rlimon).EQ.0) CALL close_ofile
c
c --- - End loop over files and records
        ENDDO
c
c --- - Close output file if still open 
        IF (MOD(m,rlimon).GT.0) CALL close_ofile
c
      ENDDO
c
c
c --- Process table day
      WRITE(*,*) 'Process table day'
      fnm=pday
      table=tday
      linstant=.FALSE.
      DO n=1,nday
        IF (skip_variable(n,nday,dday)) CYCLE
c
c --- - Map namelist variables 
        ovnm=vday(ovnmpos,n)
        ivnm=vday(ivnmpos,n)
        special=vday(3,n)
        vunits=' '
        vpositive=' '
c
c --- - Skip variable?
        CALL get_vertcoord(TRIM(tabledir)//TRIM(table),ovnm,zcoord)
        IF (TRIM(zcoord).EQ.'sdepth') THEN 
          IF (.NOT.do_3d) CYCLE 
        ELSE 
          IF (.NOT.do_2d) CYCLE 
        ENDIF
c 
c --- - Choose history file 
        itag=taglday
c
c --- - Check if input variable is present  
        IF (LEN_TRIM(pday).eq.0) CALL scan_files(reset=.TRUE.)
        IF (.NOT.var_in_file(fnm,ivnm)) CYCLE
c
c --- - Prepare output file 
        CALL special_pre
c
c --- - Loop over input files 
        m=0
        DO
          m=m+1
c
c --- --- Open output file
          IF (MOD(m-1,rday).EQ.0) CALL open_ofile
c
c --- --- Read variable into buffer 
          rec=0
          IF (LEN_TRIM(pday).eq.0) CALL scan_files(reset=.FALSE.)
          IF (rec.EQ.0) EXIT
          tbnds(:,1)=tbnd
          tval=0.5*(tbnds(1,1)+tbnds(2,1))
c
c --- --- Read data 
          CALL read_tslice(rec,badrec,fnm)
c 
c --- --- Post processing 
          CALL special_post
c
c --- --- Write time slice to output file 
          CALL write_tslice
c
c --- --- Close output file if max rec has been reached 
          IF (MOD(m,rday).EQ.0) CALL close_ofile
c
c --- - End loop over files and records
        ENDDO
c
c --- - Close output file if still open 
        IF (MOD(m,rday).GT.0) CALL close_ofile
c
      ENDDO

c --- Process table Eday
      WRITE(*,*) 'Process table Eday'
      fnm=pEday
      table=tEday
      linstant=.FALSE.
      DO n=1,nEday
        IF (skip_variable(n,nEday,dEday)) CYCLE
c
c --- - Map namelist variables 
        ovnm=vEday(ovnmpos,n)
        ivnm=vEday(ivnmpos,n)
        special=vEday(3,n)
        vunits=' '
        vpositive=' '
c
c --- - Skip variable?
        CALL get_vertcoord(TRIM(tabledir)//TRIM(table),ovnm,zcoord)
        IF (TRIM(zcoord).EQ.'sdepth') THEN 
          IF (.NOT.do_3d) CYCLE 
        ELSE 
          IF (.NOT.do_2d) CYCLE 
        ENDIF
c 
c --- - Choose history file 
        itag=taglday
c
c --- - Check if input variable is present  
        IF (LEN_TRIM(pEday).eq.0) CALL scan_files(reset=.TRUE.)
        IF (.NOT.var_in_file(fnm,ivnm)) CYCLE
c
c --- - Prepare output file 
        CALL special_pre
c
c --- - Loop over input files 
        m=0
        DO
          m=m+1
c
c --- --- Open output file
          IF (MOD(m-1,rEday).EQ.0) CALL open_ofile
c
c --- --- Read variable into buffer 
          rec=0
          IF (LEN_TRIM(pEday).eq.0) CALL scan_files(reset=.FALSE.)
          IF (rec.EQ.0) EXIT
          tbnds(:,1)=tbnd
          tval=0.5*(tbnds(1,1)+tbnds(2,1))
c
c --- --- Read data 
          CALL read_tslice(rec,badrec,fnm)
c 
c --- --- Post processing 
          CALL special_post
c
c --- --- Write time slice to output file 
          CALL write_tslice
c
c --- --- Close output file if max rec has been reached 
          IF (MOD(m,rEday).EQ.0) CALL close_ofile
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
c --- Process table 3hr (averaged fields)
      WRITE(*,*) 'Process table 3hr (averaged fields)'
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
c
c --- - Skip variable?
        CALL get_vertcoord(TRIM(tabledir)//TRIM(table),ovnm,zcoord)
        IF (TRIM(zcoord).EQ.'sdepth') THEN 
          IF (.NOT.do_3d) CYCLE 
        ELSE 
          IF (.NOT.do_2d) CYCLE 
        ENDIF
c 
c --- - Choose history file 
        itag=tagl3hr
c
c --- - Check if input variable is present  
        IF (LEN_TRIM(p3hr).eq.0) CALL scan_files(reset=.TRUE.)
        IF (.NOT.var_in_file(fnm,ivnm)) CYCLE
c
c --- - Prepare output file 
        CALL special_pre
c
c --- - Loop over input files 
        m=0
        DO
          m=m+1
c
c --- --- Open output file
          IF (MOD(m-1,r3hr).EQ.0) CALL open_ofile
c
c --- --- Read variable into buffer 
          rec=0
          IF (LEN_TRIM(p3hr).eq.0) CALL scan_files(reset=.FALSE.)
          IF (rec.EQ.0) EXIT
          tbnds(:,1)=tbnd
          tval=0.5*(tbnds(1,1)+tbnds(2,1))
c
c --- --- Read data 
          CALL read_tslice(rec,badrec,fnm)
c 
c --- --- Post processing 
          CALL special_post
c
c --- --- Write time slice to output file 
          CALL write_tslice
c
c --- --- Close output file if max rec has been reached 
          IF (MOD(m,r3hr).EQ.0) CALL close_ofile
c
c --- - End loop over files and records
        ENDDO
c
c --- - Close output file if still open 
        IF (MOD(m,r3hr).GT.0) CALL close_ofile
c
      ENDDO
c
c
c --- Process table 3hr (instantaneous fields) 
      WRITE(*,*) 'Process table 3hr (instantaneous fields)'
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
c
c --- - Skip variable?
        CALL get_vertcoord(TRIM(tabledir)//TRIM(table),ovnm,zcoord)
        IF (TRIM(zcoord).EQ.'sdepth') THEN 
          IF (.NOT.do_3d) CYCLE 
        ELSE 
          IF (.NOT.do_2d) CYCLE 
        ENDIF
c 
c --- - Choose history file 
        itag=tagl3hri
c
c --- - Check if input variable is present  
        IF (LEN_TRIM(p3hri).eq.0) CALL scan_files(reset=.TRUE.)
        IF (.NOT.var_in_file(fnm,ivnm)) CYCLE
c
c --- - Prepare output file 
        CALL special_pre
c
c --- - Loop over input files 
        m=0
        DO
          m=m+1
c
c --- --- Open output file
          IF (MOD(m-1,r3hri).EQ.0) CALL open_ofile
c
c --- --- Read variable into buffer 
          rec=0
          IF (LEN_TRIM(p3hri).eq.0) CALL scan_files(reset=.FALSE.)
          IF (rec.EQ.0) EXIT
          tbnds(:,1)=tbnd
          tval=0.5*(tbnds(1,1)+tbnds(2,1))
c
c --- --- Read data 
          CALL read_tslice(rec,badrec,fnm)
c 
c --- --- Post processing 
          CALL special_post
          IF (badrec) fld=1e20 
c
c --- --- Write time slice to output file 
          CALL write_tslice
c
c --- --- Close output file if max rec has been reached 
          IF (MOD(m,r3hri).EQ.0) CALL close_ofile
c
c --- - End loop over files and records
        ENDDO
c
c --- - Close output file if still open 
        IF (MOD(m,r3hri).GT.0) CALL close_ofile
c
      ENDDO
c
c --- Process table E3hr (averaged fields)
      WRITE(*,*) 'Process table E3hr (averaged fields)'
      fnm=pE3hr
      table=tE3hr
      linstant=.FALSE.
      DO n=1,nE3hr
        IF (skip_variable(n,nE3hr,dE3hr)) CYCLE
c
c --- - Map namelist variables 
        ovnm=vE3hr(ovnmpos,n)
        ivnm=vE3hr(ivnmpos,n)
        special=vE3hr(3,n)
        vunits=' '
        vpositive=' '
c
c --- - Skip variable?
        CALL get_vertcoord(TRIM(tabledir)//TRIM(table),ovnm,zcoord)
        IF (TRIM(zcoord).EQ.'sdepth') THEN 
          IF (.NOT.do_3d) CYCLE 
        ELSE 
          IF (.NOT.do_2d) CYCLE 
        ENDIF
c 
c --- - Choose history file 
        itag=tagl3hr
c
c --- - Check if input variable is present  
        IF (LEN_TRIM(pE3hr).eq.0) CALL scan_files(reset=.TRUE.)
        IF (.NOT.var_in_file(fnm,ivnm)) CYCLE
c
c --- - Prepare output file 
        CALL special_pre
c
c --- - Loop over input files 
        m=0
        DO
          m=m+1
c
c --- --- Open output file
          IF (MOD(m-1,rE3hr).EQ.0) CALL open_ofile
c
c --- --- Read variable into buffer 
          rec=0
          IF (LEN_TRIM(pE3hr).eq.0) CALL scan_files(reset=.FALSE.)
          IF (rec.EQ.0) EXIT
          tbnds(:,1)=tbnd
          tval=0.5*(tbnds(1,1)+tbnds(2,1))
c
c --- --- Read data 
          CALL read_tslice(rec,badrec,fnm)
c 
c --- --- Post processing 
          CALL special_post
c
c --- --- Write time slice to output file 
          CALL write_tslice
c
c --- --- Close output file if max rec has been reached 
          IF (MOD(m,rE3hr).EQ.0) CALL close_ofile
c
c --- - End loop over files and records
        ENDDO
c
c --- - Close output file if still open 
        IF (MOD(m,rE3hr).GT.0) CALL close_ofile
c
      ENDDO
c
      END SUBROUTINE lnd2cmor 



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
c --- - Set correct units for percentage
        CASE ('percent')
          vunits='%'
c
c --- - Set correct units for percentage
        CASE ('fraction')
          vunits='1'
c    
c --- - Unit transformation: g m-2 -> kg m-2  
        CASE ('kg m-2')
          vunits='kg m-2'
c 
c --- - Unit transformation: mm s-1 -> kg m-2 s-1 
        CASE ('kg m-2 s-1')
          vunits='kg m-2 s-1'
c 
c --- - Fix micrometers units 
        CASE ('micrometer')
          vunits='micrometers'
c
c --- - Fix m-2 units 
        CASE ('m-2')
          vunits='m-2'
c        
c --- - Convert units from radians2 to m2    
        CASE ('rad2m')
          vunits='m2'
c
c --- - Set positive attribute  
        CASE ('positiveup')
          vpositive='up'
        CASE ('positivedo')
          vpositive='down'
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
c --- - Fraction to percent 
        CASE ('percent')
          fld=fld*1e2

c --- - Convert units from radians2 to m2    
        CASE ('rad2m')
          fld=fld*6.37122e6**2
c 
c --- - Unit transformation: g m-2 -> kg m-2 
        CASE ('kg m-2')
          fld=fld*1e-3
c
c --- - Unit transformation: g m-2 s-1 -> kg m-2 s-1 
        CASE ('kg m-2 s-1')
          fld=fld*1e-3

c --- - Unit transformation: mol to kg CH4
        CASE ('mol to kg CH4')
          fld=fld*16.04246*1e-3
c
c --- - Limit solid soil moisture (mask ice sheets)
        CASE ('limitmoist')
          DO k=1,kdm
            DO j=1,jj
              DO i=1,ii
                IF (fld(i,j,k).LT.1e20.AND.fld(i,j,k).GT.5000) 
     .            fld(i,j,k)=5000
              ENDDO
            ENDDO
          ENDDO
c
c --- - Set ocean points to missing value
        CASE ('missingval')
          DO k=1,kdm
            DO j=1,jj
              DO i=1,ii
                IF (fld(i,j,k).GT.1e20) fld(i,j,k)=1e20
              ENDDO
            ENDDO
          ENDDO
c
c --- - Set ocean points to zero
        CASE ('miss2zero')
          DO k=1,kdm
            DO j=1,jj
              DO i=1,ii
                IF (fld(i,j,k).GT.1e20) fld(i,j,k)=0.
              ENDDO
            ENDDO
          ENDDO
c
c --- - Compute vertical sum 
        CASE ('vertsum')
          fld(:,:,1)=sum(fld,3)
c 
        END SELECT
        IF (str1.EQ.str2) exit
      END DO
c
      END SUBROUTINE special_post



      SUBROUTINE read_gridinfo_ifile 
c
      IMPLICIT NONE
c
      LOGICAL :: check 
      INTEGER :: i,j,k
      REAL :: missing
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
      ALLOCATE(lon(idm),lon_bnds(2,idm),STAT=status) 
      IF (status.NE.0) STOP 'cannot ALLOCATE enough memory (1)'
      status=nf90_inq_varid(ncid,'lon',rhid) 
      CALL handle_ncerror(status)
      status=nf90_get_var(ncid,rhid,lon)
      CALL handle_ncerror(status)
      lon_bnds(1,1)=lon(1)-0.5*(lon(2)-lon(1))
      lon_bnds(2,1)=lon(1)+0.5*(lon(2)-lon(1)) 
      DO i=2,idm
        lon_bnds(1,i)=lon_bnds(2,i-1)
        lon_bnds(2,i)=lon(i)+0.5*(lon(2)-lon(1)) 
      ENDDO
c
      status=nf90_inq_varid(ncid,'lonrof',rhid)
      IF (status.EQ.0) THEN
        status=nf90_inq_dimid(ncid,'lonrof',dimid)
        CALL handle_ncerror(status)      
        status=nf90_inquire_dimension(ncid,dimid,len=idmrof)
        CALL handle_ncerror(status)
        ALLOCATE(lonrof(idmrof),lonrof_bnds(2,idmrof),STAT=status) 
        IF (status.NE.0) STOP 'cannot ALLOCATE enough memory (1b)'
        status=nf90_inq_varid(ncid,'lonrof',rhid)
        CALL handle_ncerror(status)
        status=nf90_get_var(ncid,rhid,lonrof)
        CALL handle_ncerror(status)
        lonrof_bnds(1,1)=lonrof(1)-0.5*(lonrof(2)-lonrof(1))
        lonrof_bnds(2,1)=lonrof(1)+0.5*(lonrof(2)-lonrof(1))
        DO i=2,idmrof
          lonrof_bnds(1,i)=lonrof_bnds(2,i-1)
          lonrof_bnds(2,i)=lonrof(i)+0.5*(lonrof(2)-lonrof(1))
        ENDDO
      ELSE 
        idmrof=idm
      ENDIF
c
c --- Read latitudes
      status=nf90_inq_dimid(ncid,'lat',dimid)
      CALL handle_ncerror(status)
      status=nf90_inquire_dimension(ncid,dimid,len=jdm)
      CALL handle_ncerror(status)
      ALLOCATE(lat(jdm),lat_bnds(2,jdm),STAT=status) 
      IF (status.NE.0) STOP 'cannot ALLOCATE enough memory (2)'
      status=nf90_inq_varid(ncid,'lat',rhid) 
      CALL handle_ncerror(status)
      status=nf90_get_var(ncid,rhid,lat)
      CALL handle_ncerror(status)
      lat_bnds(2,1)=lat(1)+90./FLOAT(jdm-1)
      lat_bnds(1,1)=max(-90.,lat(1)-90./FLOAT(jdm-1))
      DO j=2,jdm
        lat_bnds(2,j)=min(90.,lat(j)+90./FLOAT(jdm-1))
        lat_bnds(1,j)=lat_bnds(2,j-1)
      ENDDO
c
      status=nf90_inq_varid(ncid,'latrof',rhid)
      IF (status.EQ.0) THEN
        status=nf90_inq_dimid(ncid,'latrof',dimid)
        CALL handle_ncerror(status)
        status=nf90_inquire_dimension(ncid,dimid,len=jdmrof)
        CALL handle_ncerror(status)
        ALLOCATE(latrof(jdmrof),latrof_bnds(2,jdmrof),STAT=status)
        IF (status.NE.0) STOP 'cannot ALLOCATE enough memory (2b)'
        status=nf90_inq_varid(ncid,'latrof',rhid)
        CALL handle_ncerror(status)
        status=nf90_get_var(ncid,rhid,latrof)
        CALL handle_ncerror(status)
        latrof_bnds(2,1)=latrof(1)+90./FLOAT(jdmrof-1)
        latrof_bnds(1,1)=max(-90.,latrof(1)-90./FLOAT(jdmrof-1))
        DO j=2,jdmrof
          latrof_bnds(2,j)=min(90.,latrof(j)+90./FLOAT(jdmrof-1))
          latrof_bnds(1,j)=latrof_bnds(2,j-1)
        ENDDO
      ELSE 
        jdmrof=jdm
      ENDIF
c
c --- Read soil depths  
      status=nf90_inq_dimid(ncid,'levgrnd',dimid)
      IF (status.EQ.0) THEN
          status=nf90_inquire_dimension(ncid,dimid,len=kdm)
          CALL handle_ncerror(status)
          ALLOCATE(lev(kdm),lev_bnds(2,kdm),STAT=status)
          IF (status.NE.0) STOP 'cannot allocate enough memory'
          status=nf90_inq_varid(ncid,'levgrnd',rhid) 
          CALL handle_ncerror(status)
          status=nf90_get_var(ncid,rhid,lev)
          CALL handle_ncerror(status)
      ELSE
          WRITE(*,*) "WARNING: dimension 'levgrnd' is not defined"
      ENDIF

c --- Read landuse types
      status=nf90_inq_dimid(ncid,'landUse',dimid)
      IF (status.EQ.0) THEN
          status=nf90_inquire_dimension(ncid,dimid,len=ldm)
          CALL handle_ncerror(status)
          ALLOCATE(ltype(ldm),STAT=status)
          IF (status.NE.0) STOP 'cannot allocate enough memory'
c          status=nf90_inq_varid(ncid,'landUse',rhid) 
c          CALL handle_ncerror(status)
c          status=nf90_get_var(ncid,rhid,ltype)
c          CALL handle_ncerror(status)
          IF (ldm.EQ.4) THEN
              ltype(1)="primary_and_secondary_land"
              ltype(2)="pastures"
              ltype(3)="crops"
              ltype(4)="urban"
          ELSE
              WRITE(*,*) "The landUse type is hard-coded with four
     .          elements. Need update the defined variable ltype"
              STOP
          ENDIF
      ENDIF
c
c --- Compute level bounds from soil thickness      
      IF (ALLOCATED(fld)) DEALLOCATE(fld)
      ALLOCATE(fld(idm,jdm,kdm),STAT=status)
      IF (status.NE.0) STOP 'cannot allocate enough memory'
      status=nf90_inq_varid(ncid,'DZSOI',rhid) 
      IF (status.EQ.nf90_noerr) THEN 
        CALL handle_ncerror(status)
        status=nf90_get_att(ncid,rhid,'_FillValue',missing) 
        CALL handle_ncerror(status)
        status=nf90_get_var(ncid,rhid,fld)
        CALL handle_ncerror(status)
        check=.FALSE.
        DO i=1,idm
          DO j=1,jdm
            IF (fld(i,j,1).NE.missing) THEN
              lev_bnds(1,1)=0.
              lev_bnds(2,1)=fld(i,j,1)
              DO k=2,kdm 
                lev_bnds(1,k)=lev_bnds(1,k-1)+fld(i,j,k-1)
                lev_bnds(2,k)=lev_bnds(1,k)+fld(i,j,k)
              ENDDO
              check=.TRUE.
              EXIT
            ENDIF
            IF (check) EXIT
          ENDDO
        ENDDO
      ELSE
        IF (ALLOCATED(lev)) THEN
          WRITE(*,*) 'WARNING: cannot find varible DZSOI. will try to '
     .      //'guess soil depth bounds.'
          lev_bnds(1,1)=0. 
          lev_bnds(2,1)=0.5*(lev(1)+lev(2)) 
          DO k=2,kdm-1
            lev_bnds(1,k)=lev_bnds(2,k-1)
            lev_bnds(2,k)=0.5*(lev(k)+lev(k+1)) 
          ENDDO 
          lev_bnds(1,kdm)=lev_bnds(2,kdm-1)
          lev_bnds(2,kdm)=lev_bnds(1,kdm)+lev(kdm)-lev(kdm-1)
        ENDIF
      ENDIF  
      DEALLOCATE(fld)
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
      INTEGER :: physics_version=1,initialization_method=1
      CHARACTER(len=slenmax) :: ivnm1,ivnm2,ivnm3,ivnm4,ivnm5,ivnm6
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
      status=nf90_inq_varid(ncid,TRIM(ivnm1),rhid)
      IF (status.NE.nf90_noerr) THEN
        WRITE(*,*) 'cannot find input variable ',TRIM(ivnm1)
        STOP
      ENDIF
      status=nf90_inquire_variable(ncid,rhid,ndims=ndims)
      CALL handle_ncerror(status)
      IF (.NOT.fxflag.AND.ndims.lt.3) THEN
        WRITE(*,*) 'Variable ',TRIM(ivnm1),' has too few dimensions',
     .  ndims
      ENDIF
      status=nf90_inquire_variable(ncid,rhid,dimids=dimids(1:ndims))
      CALL handle_ncerror(status)
      dimlens=1
      DO n=1,ndims
        status=nf90_inquire_dimension(ncid,dimids(n),len=dimlens(n))
        CALL handle_ncerror(status)
      ENDDO 
      IF (dimlens(1).NE.idm.AND.dimlens(1).NE.idmrof) THEN
        WRITE(*,*) 'unexpected first dimension of variable ',
     .    TRIM(ivnm1),': ',dimlens(1),' versus idm=',idm
        STOP
      ENDIF
      IF (dimlens(2).NE.jdm.AND.dimlens(2).NE.jdmrof) THEN
        WRITE(*,*) 'unexpected second dimension of variable ',
     .    TRIM(ivnm1),': ',dimlens(2),' versus jdm=',idm
        STOP
      ENDIF
      IF (fxflag.AND.ndims.GT.2.OR.ndims.GT.3) THEN
        kdm=dimlens(3)
      ELSE
        kdm=1
      ENDIF
      IF (ALLOCATED(fld)) DEALLOCATE(fld,fld2,fldacc)
      IF (INDEX(ivnm,'QCHOCNR').GT.0) THEN 
        ii=idmrof
        jj=jdmrof 
      ELSE
        ii=idm
        jj=jdm 
      ENDIF
      ALLOCATE(fld(ii,jj,kdm),fld2(ii,jj,kdm),fldacc(ii,jj,kdm),
     .  STAT=status)
      IF (status.NE.0) STOP 'cannot ALLOCATE enough memory (4)'
c 
      IF (LEN_TRIM(vunits).EQ.0) THEN
        status=nf90_get_att(ncid,rhid,'units',vunits)
        CALL handle_ncerror(status)
        IF (TRIM(vunits).EQ.'mm/s') vunits='kg m-2 s-1'
      END IF 
c
      status=nf90_close(ncid)
      CALL handle_ncerror(status)
c
c --- Inquire time and vertical dimension of output variable 
      IF (.NOT.fxflag) THEN
        CALL get_timecoord(TRIM(tabledir)//TRIM(table),ovnm,tcoord)
      ENDIF
      CALL get_vertcoord(TRIM(tabledir)//TRIM(table),ovnm,zcoord)
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
c --- Derive physics_version and initialization_method from
c --- parent_experiment_rip
      IF (TRIM(parent_experiment_rip).NE.'r1i1p1'.AND.
     .    TRIM(parent_experiment_rip).NE.'N/A' .AND.
     .    TRIM(parent_experiment_rip).NE.'no parent' ) THEN
        READ(parent_experiment_rip(INDEX(parent_experiment_rip,'i')+1:
     .    INDEX(parent_experiment_rip,'p')-1),*) initialization_method
        READ(parent_experiment_rip(INDEX(parent_experiment_rip,'p')+1:),
     .    *) physics_version
      ENDIF
c
c --- Define output dataset 
#ifdef CMOR3
      CALL write_namelist_json(lndgrid,lndgrid_label,lndgrid_resolution,
     .  ovnm)
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
      IF (INDEX(ivnm,'QCHOCNR').GT.0) THEN 
        iaxid=cmor_axis(
     .    table           = TRIM(tabledir)//TRIM(table),
     .    table_entry     = 'longitude',
     .    units           = 'degrees_east',
     .    length          = idmrof,
     .    coord_vals      = lonrof,
     .    cell_bounds     = lonrof_bnds)
        jaxid=cmor_axis(
     .    table           = TRIM(tabledir)//TRIM(table),
     .    table_entry     = 'latitude', 
     .    units           = 'degrees_north',
     .    length          = jdmrof,
     .    coord_vals      = latrof,
     .    cell_bounds     = latrof_bnds)
      ELSE
        iaxid=cmor_axis(
     .    table           = TRIM(tabledir)//TRIM(table),
     .    table_entry     = 'longitude',
     .    units           = 'degrees_east',
     .    length          = idm,
     .    coord_vals      = lon,
     .    cell_bounds     = lon_bnds)
        jaxid=cmor_axis(
     .    table           = TRIM(tabledir)//TRIM(table),
     .    table_entry     = 'latitude',
     .    units           = 'degrees_north',
     .    length          = jdm,
     .    coord_vals      = lat,
     .    cell_bounds     = lat_bnds)
      ENDIF 
c
c --- Define time axis 
      IF (.NOT.fxflag) THEN
        taxid=cmor_axis(
     .    table           = TRIM(tabledir)//TRIM(table),
     .    table_entry     = TRIM(tcoord),
     .    units           = TRIM(calunits),
     .    length          = 1)
      ENDIF
c
c --- Define vertical axis 
      IF (TRIM(zcoord).EQ.'sdepth') THEN
        kaxid=cmor_axis(
     .    table           = TRIM(tabledir)//TRIM(table),
     .    table_entry     = TRIM(zcoord),
     .    units           = 'm',
     .    length          = kdm,
     .    coord_vals      = lev,
     .    cell_bounds     = lev_bnds)
      ENDIF
      IF (TRIM(zcoord).EQ.'landUse') THEN
        kaxid=cmor_axis(
     .    table           = TRIM(tabledir)//TRIM(table),
     .    table_entry     = TRIM(zcoord),
     .    units           = 'non',
     .    length          = ldm,
     .    coord_vals      = ltype)
      ENDIF
c
c --- Define output variable
      IF (fxflag) THEN
        varid=cmor_variable(
     .    table_entry     = TRIM(ovnm),
     .    units           = TRIM(vunits),
     .    axis_ids        = (/ iaxid, jaxid /),
     .    missing_value   = 1e20,
     .    original_name   = TRIM(ivnm))
      ELSE
        IF (TRIM(zcoord).EQ.'sdepth'.OR.TRIM(zcoord).EQ.'vegtype'
     .      .OR.TRIM(zcoord).EQ.'landUse') THEN
          varid=cmor_variable(
     .      table         = TRIM(tabledir)//TRIM(table),
     .      table_entry   = TRIM(ovnm),
     .       units        = TRIM(vunits),
     .      axis_ids      = (/ iaxid, jaxid, kaxid, taxid /),
     .      original_name = TRIM(ivnm), 
     .      missing_value = 1e20, 
     .      positive      = TRIM(vpositive))
        ELSE
          varid=cmor_variable(
     .      table         = TRIM(tabledir)//TRIM(table),
     .      table_entry   = TRIM(ovnm),
     .      units         = TRIM(vunits),
     .      axis_ids      = (/ iaxid, jaxid, taxid /),
     .      original_name = TRIM(ivnm),
     .      missing_value = 1e20, 
     .      positive      = TRIM(vpositive))
        ENDIF
      ENDIF
#ifdef DEFLATE
      error_flag = cmor_set_deflate(varid,1,1,5)
#endif 
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
      IF (verbose.AND.LEN_TRIM(ivnm2).NE.0) 
     .  write(*,*) 'Compound variable: ',trim(ivnm1),'*',fac1,'+',
     .  trim(ivnm2),'*',fac2,'+',trim(ivnm3),'*',fac3,
     .  trim(ivnm4),'*',fac4,'+',trim(ivnm5),'*',fac5,
     .  trim(ivnm6),'*',fac6
      status=nf90_inq_varid(ncid,TRIM(ivnm1),rhid)
      IF (status.NE.nf90_noerr) THEN
        WRITE(*,*) 'cannot find input variable ',TRIM(ivnm1)
        STOP
      ENDIF
      status=nf90_get_var(ncid,rhid,fld)
      CALL handle_ncerror(status)
      IF (fac1.ne.1) THEN
        fld=fld*fac1
      ENDIF
c 
      IF (LEN_TRIM(ivnm2).GT.0) THEN
        status=nf90_inq_varid(ncid,TRIM(ivnm2),rhid)
        IF (status.NE.nf90_noerr) THEN
          WRITE(*,*) 'cannot find input variable ',TRIM(ivnm2)
          STOP
        ENDIF
        status=nf90_get_var(ncid,rhid,fld2)
        CALL handle_ncerror(status)
        fld=fld+fld2*fac2
      ENDIF 
c
      IF (LEN_TRIM(ivnm3).GT.0) THEN
        status=nf90_inq_varid(ncid,TRIM(ivnm3),rhid)
        IF (status.NE.nf90_noerr) THEN
          WRITE(*,*) 'cannot find input variable ',TRIM(ivnm3)
          STOP
        ENDIF
        status=nf90_get_var(ncid,rhid,fld2)
        CALL handle_ncerror(status)
        fld=fld+fld2*fac3
      ENDIF
c
      IF (LEN_TRIM(ivnm4).GT.0) THEN
        status=nf90_inq_varid(ncid,TRIM(ivnm4),rhid)
        IF (status.NE.nf90_noerr) THEN
          WRITE(*,*) 'cannot find input variable ',TRIM(ivnm4)
          STOP
        ENDIF
        status=nf90_get_var(ncid,rhid,fld2)
        CALL handle_ncerror(status)
        fld=fld+fld2*fac4
      ENDIF
c
      IF (LEN_TRIM(ivnm5).GT.0) THEN
        status=nf90_inq_varid(ncid,TRIM(ivnm5),rhid)
        IF (status.NE.nf90_noerr) THEN
          WRITE(*,*) 'cannot find input variable ',TRIM(ivnm5)
          STOP
        ENDIF
        status=nf90_get_var(ncid,rhid,fld2)
        CALL handle_ncerror(status)
        fld=fld+fld2*fac5
      ENDIF
c
      IF (LEN_TRIM(ivnm6).GT.0) THEN
        status=nf90_inq_varid(ncid,TRIM(ivnm6),rhid)
        IF (status.NE.nf90_noerr) THEN
          WRITE(*,*) 'cannot find input variable ',TRIM(ivnm6)
          STOP
        ENDIF
        status=nf90_get_var(ncid,rhid,fld2)
        CALL handle_ncerror(status)
        fld=fld+fld2*fac6
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
      INTEGER :: ind,rec
      INTEGER, SAVE :: fid 
      LOGICAL :: badrec
      CHARACTER(LEN=*), INTENT(IN), OPTIONAL :: fname
      CHARACTER(LEN=slenmax) :: ivnm1,ivnm2,ivnm3,ivnm4,ivnm5,ivnm6
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
      status=nf90_inq_varid(fid,'time_bounds',rhid)
      IF (status.NE.nf90_noerr) THEN
        WRITE(*,*) 'cannot find time_bounds variable'
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
c --- correct erroneous intial time bound
      tbnds(1,1)=max(0.,tbnds(1,1))
      tval=0.5*(tbnds(1,1)+tbnds(2,1))
      ENDIF
c
c --- Read data 
      CALL resolve_vnm(slenmax,ivnm,ivnm1,ivnm2,ivnm3,ivnm4,ivnm5,ivnm6,
     .  fac1,fac2,fac3,fac4,fac5,fac6)
      IF (verbose.AND.rec.EQ.1.AND.LEN_TRIM(ivnm2).NE.0) 
     .  write(*,*) 'Compound variable: ',trim(ivnm1),'*',fac1,'+',
     .  trim(ivnm2),'*',fac2,'+',trim(ivnm3),'*',fac3,
     .  trim(ivnm4),'*',fac4,'+',trim(ivnm5),'*',fac5,
     .  trim(ivnm6),'*',fac6
      status=nf90_inq_varid(fid,TRIM(ivnm1),rhid)
      IF (status.NE.nf90_noerr) THEN
        WRITE(*,*) 'cannot find input variable ',TRIM(ivnm1)
        STOP
      ENDIF
      IF (kdm.eq.1) THEN
        IF (INDEX(ivnm,'QCHOCNR').GT.0) THEN 
          status=nf90_get_var(fid,rhid,fld,(/1,1,rec/), 
     .      (/idmrof,jdmrof,1/)) 
        ELSE
          status=nf90_get_var(fid,rhid,fld,(/1,1,rec/), 
     .      (/idm,jdm,1/)) 
        ENDIF
      ELSE 
        status=nf90_get_var(fid,rhid,fld,(/1,1,1,rec/), 
     .    (/idm,jdm,kdm,1/)) 
      ENDIF 
      CALL handle_ncerror(status) 
      IF (fac1.ne.1) THEN
        fld=fld*fac1
      ENDIF
c
      IF (LEN_TRIM(ivnm2).GT.0) THEN
        status=nf90_inq_varid(fid,TRIM(ivnm2),rhid)
        IF (status.NE.nf90_noerr) THEN
          WRITE(*,*) 'cannot find input variable ',TRIM(ivnm2)
          STOP
        ENDIF
        IF (kdm.eq.1) THEN
          IF (INDEX(ivnm,'QCHOCNR').GT.0) THEN
            status=nf90_get_var(fid,rhid,fld2,(/1,1,rec/),
     .        (/idmrof,jdmrof,1/))
          ELSE
            status=nf90_get_var(fid,rhid,fld2,(/1,1,rec/),
     .        (/idm,jdm,1/))      
          ENDIF
        ELSE
          status=nf90_get_var(fid,rhid,fld2,(/1,1,1,rec/),
     .      (/idm,jdm,kdm,1/))
        ENDIF
        CALL handle_ncerror(status)
        fld=fld+fld2*fac2
      ENDIF
c
      IF (LEN_TRIM(ivnm3).GT.0) THEN
        status=nf90_inq_varid(fid,TRIM(ivnm3),rhid)
        IF (status.NE.nf90_noerr) THEN
          WRITE(*,*) 'cannot find input variable ',TRIM(ivnm3)
          STOP
        ENDIF
        IF (kdm.eq.1) THEN
          IF (INDEX(ivnm,'QCHOCNR').GT.0) THEN
            status=nf90_get_var(fid,rhid,fld2,(/1,1,rec/),
     .        (/idmrof,jdmrof,1/))
          ELSE
            status=nf90_get_var(fid,rhid,fld2,(/1,1,rec/),
     .        (/idm,jdm,1/))  
          ENDIF 
        ELSE
          status=nf90_get_var(fid,rhid,fld2,(/1,1,1,rec/),
     .      (/idm,jdm,kdm,1/))
        ENDIF
        CALL handle_ncerror(status)
        fld=fld+fld2*fac3
      ENDIF
c
      IF (LEN_TRIM(ivnm4).GT.0) THEN
        status=nf90_inq_varid(fid,TRIM(ivnm4),rhid)
        IF (status.NE.nf90_noerr) THEN
          WRITE(*,*) 'cannot find input variable ',TRIM(ivnm4)
          STOP
        ENDIF
        IF (kdm.eq.1) THEN
          IF (INDEX(ivnm,'QCHOCNR').GT.0) THEN
            status=nf90_get_var(fid,rhid,fld2,(/1,1,rec/),
     .        (/idmrof,jdmrof,1/))
          ELSE
            status=nf90_get_var(fid,rhid,fld2,(/1,1,rec/),
     .        (/idm,jdm,1/))
          ENDIF
        ELSE
          status=nf90_get_var(fid,rhid,fld2,(/1,1,1,rec/),
     .      (/idm,jdm,kdm,1/))
        ENDIF
        CALL handle_ncerror(status)
        fld=fld+fld2*fac4
      ENDIF
c
      IF (LEN_TRIM(ivnm5).GT.0) THEN
        status=nf90_inq_varid(fid,TRIM(ivnm5),rhid)
        IF (status.NE.nf90_noerr) THEN
          WRITE(*,*) 'cannot find input variable ',TRIM(ivnm5)
          STOP
        ENDIF
        IF (kdm.eq.1) THEN
          IF (INDEX(ivnm,'QCHOCNR').GT.0) THEN
            status=nf90_get_var(fid,rhid,fld2,(/1,1,rec/),
     .        (/idmrof,jdmrof,1/))
          ELSE
            status=nf90_get_var(fid,rhid,fld2,(/1,1,rec/),
     .        (/idm,jdm,1/))
          ENDIF
        ELSE
          status=nf90_get_var(fid,rhid,fld2,(/1,1,1,rec/),
     .      (/idm,jdm,kdm,1/))
        ENDIF
        CALL handle_ncerror(status)
        fld=fld+fld2*fac5
      ENDIF
c
      IF (LEN_TRIM(ivnm6).GT.0) THEN
        status=nf90_inq_varid(fid,TRIM(ivnm6),rhid)
        IF (status.NE.nf90_noerr) THEN
          WRITE(*,*) 'cannot find input variable ',TRIM(ivnm6)
          STOP
        ENDIF
        IF (kdm.eq.1) THEN
          IF (INDEX(ivnm,'QCHOCNR').GT.0) THEN
            status=nf90_get_var(fid,rhid,fld2,(/1,1,rec/),
     .        (/idmrof,jdmrof,1/))
          ELSE
            status=nf90_get_var(fid,rhid,fld2,(/1,1,rec/),
     .        (/idm,jdm,1/))
          ENDIF
        ELSE
          status=nf90_get_var(fid,rhid,fld2,(/1,1,1,rec/),
     .      (/idm,jdm,kdm,1/))
        ENDIF
        CALL handle_ncerror(status)
        fld=fld+fld2*fac6
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
      INTEGER :: i,j,k
c
c --- Set zero on ocean grid cells
      DO k=1,kdm
        DO j=1,jj
          DO i=1,ii
            IF (ABS(fld(i,j,k)).GT.2e20) fld(i,j,k)=0.
          ENDDO
        ENDDO
      ENDDO
c      
c --- Store variable
      error_flag=cmor_write(
     .  var_id         = varid,
     .  data           = RESHAPE(fld,(/idm,jdm/)))
c
      END SUBROUTINE write_field



      SUBROUTINE write_tslice
c
      IMPLICIT NONE
c
      INTEGER :: i,j,k 
c
c --- Set zero on ocean grid cells
      DO k=1,kdm
        DO j=1,jj
          DO i=1,ii
            IF (ABS(fld(i,j,k)).GT.2e20) fld(i,j,k)=0.
          ENDDO
        ENDDO
      ENDDO
c
c --- Store variable
      IF (LEN_TRIM(zcoord).GT.0.OR.kdm.EQ.1) THEN
        IF (TRIM(tcoord).NE.'time1') THEN  
          IF (TRIM(zcoord).EQ.'typecrop') THEN  
            error_flag=cmor_write(
     .        var_id         = varid,
     .        data           = fld(1:idm,1:jdm,2),
     .        ntimes_passed  = 1,
     .        time_vals      = tval,
     .        time_bnds      = tbnds)
          ELSE
            error_flag=cmor_write(
     .        var_id         = varid,
     .        data           = fld,
     .        ntimes_passed  = 1,
     .        time_vals      = tval,
     .        time_bnds      = tbnds)
          ENDIF
        ELSE
          error_flag=cmor_write(
     .      var_id         = varid,
     .      data           = fld,
     .      ntimes_passed  = 1,
     .      time_vals      = tval)
        ENDIF
      ELSE
        IF (TRIM(tcoord).NE.'time1') THEN
          error_flag=cmor_write(
     .      var_id         = varid,
     .      data           = fld(1:idm,1:jdm,1),
     .      ntimes_passed  = 1,
     .      time_vals      = tval,
     .      time_bnds      = tbnds)
        ELSE
          error_flag=cmor_write(
     .      var_id         = varid,
     .      data           = fld(1:idm,1:jdm,1),
     .      ntimes_passed  = 1,
     .      time_vals      = tval)
        ENDIF
      ENDIF
c
      END SUBROUTINE write_tslice


      END MODULE m_modelslnd
