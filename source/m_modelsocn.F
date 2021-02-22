      MODULE m_modelsocn
c
      USE netcdf 
      USE cmor_users_functions
      USE m_utilities
      USE m_namelists
c
      IMPLICIT NONE 
c
c --- Netcdf variables
      INTEGER, SAVE :: ii,jj,kk,ncid,rhid,dimid,status
c
c --- Grid dimensions and variables 
      REAL(KIND=8), SAVE :: voglb,aoglb
      INTEGER, SAVE :: idm,jdm,kdm=0,ddm=0,ldm=0,rdm=0,secdm=0,slenmax2
      INTEGER, PARAMETER :: ncrns=4
      INTEGER, ALLOCATABLE, SAVE, DIMENSION(:,:) :: basin
      REAL(KIND=8), ALLOCATABLE, SAVE, DIMENSION(:) :: xvec,yvec,kvec,
     .  kvechalf,sigma,sigmahalf,depth,slat 
      REAL(KIND=8), ALLOCATABLE, SAVE, DIMENSION(:,:) :: parea,pmask,
     .  pdepth,plon,plat,ulon,ulat,vlon,vlat,slat_bnds,sigma_bnds,
     .  sigmahalf_bnds,depth_bnds,bpini,bpinit,uscaley,vscalex,udepth,
     .  vdepth
      REAL(KIND=8), ALLOCATABLE, SAVE, DIMENSION(:,:,:) :: 
     .  plon_crns,plat_crns,ulon_crns,ulat_crns,vlon_crns,vlat_crns,
     .  plon_crnsp,plat_crnsp,ulon_crnsp,ulat_crnsp,vlon_crnsp,
     .  vlat_crnsp,dzini,sini,tini
      CHARACTER(LEN=slenmax), ALLOCATABLE, SAVE, DIMENSION(:) :: 
     .  region1,section1
      CHARACTER, ALLOCATABLE, SAVE, DIMENSION(:,:) :: region,section
      CHARACTER(LEN=slenmax), SAVE :: tcoord,zcoord,s1
#ifdef CMOR3 
      CHARACTER(LEN=slenmax), SAVE :: grid, grid_label 
#endif 
c
c --- Gravity
      REAL(KIND=8), PARAMETER :: g=9.80665,ginv=1.d0/g
c 
c --- Dataset related variables 
      CHARACTER(LEN=slenmax), SAVE :: ivnm,ovnm,vunits,vpositive,vtype
      CHARACTER(LEN=slenmax*10), SAVE :: vcomment  
      LOGICAL, SAVE :: lsumz 
c
c --- Table related variables 
      CHARACTER(LEN=slenmax), SAVE :: table,tablepath
c
c --- Cmor parameters 
      CHARACTER(LEN=1024) :: fnmo  
      INTEGER, SAVE :: iaxid,jaxid,kaxid,laxid,raxid,saxid,taxid,grdid,
     .  varid,table_id,table_id_grid,error_flag
c
c --- String for module special 
      CHARACTER(LEN=slenmax), SAVE :: special
c
c --- Data fields
      REAL(KIND=8), ALLOCATABLE, SAVE, DIMENSION(:,:,:) :: fld,fld2,
     .  fldtmp,fldacc,fldhalf,dp
      REAL(KIND=8), ALLOCATABLE, SAVE, DIMENSION(:,:) :: sealv,pbot
      REAL(KIND=8) :: sfac,offs,fill 
c
c --- Auxillary variables for special operations 
      CHARACTER(LEN=slenmax), SAVE :: str1,str2



c --- -----------------------------------------------------------------
      CONTAINS 
c --- -----------------------------------------------------------------


      SUBROUTINE ocn2cmor
c
      IMPLICIT NONE
c
      LOGICAL :: badrec,last,first
      INTEGER :: k,m,n,nrec
c
c --- Skip if monthly ocean table deactivated
c     IF (.NOT.(domon.OR.dday)) RETURN
c
c --- Print start information
      IF (verbose) THEN
        WRITE(*,*)
        WRITE(*,*) '----------------------------'
        WRITE(*,*) '--- Process ocean output ---'
        WRITE(*,*) '----------------------------'
        WRITE(*,*)
      ENDIF
c
c --- Read grid information from input files
      WRITE(*,*) 'Read grid information from input files'
      itag=tagomon
      CALL scan_files(reset=.TRUE.)
      IF (LEN_TRIM(fnm).EQ.0) RETURN 
      CALL read_gridinfo_ifile
c
c --- Process table fx 
      WRITE(*,*) 'Process table fx'
      fnm=TRIM(griddata)//TRIM(ocngridfile)
      table=tfx 
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
c --- - Check if input variable is present 
        IF (.NOT.var_in_file(fnm,ivnm)) CYCLE 
c
c --- - Check if vertical coordinate required        
        CALL get_vertcoord(TRIM(tabledir)//TRIM(table),ovnm,zcoord)
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
c --- Process table Ofx 
      WRITE(*,*) 'Process table Ofx'
      fnm=TRIM(griddata)//TRIM(ocngridfile)
      table=tofx
      DO n=1,nofx
        IF (skip_variable(n,nofx,dofx)) CYCLE
c
c --- - Map namelist variables 
        ovnm=vofx(ovnmpos,n)
        ivnm=vofx(ivnmpos,n)
        special=vofx(3,n)
        vunits=' '
        vpositive=' '
        vcomment=' '

c --- - Use oceanregnfile for region
        IF (ovnm.EQ.'basin') THEN
          fnm=TRIM(griddata)//TRIM(ocnregnfile)
        ELSE
          fnm=TRIM(griddata)//TRIM(ocngridfile)
        ENDIF
c
c --- - Check if input variable is present 
        IF (.NOT.var_in_file(fnm,ivnm)) CYCLE
c
c --- - Check if vertical coordinate required        
        CALL get_vertcoord(TRIM(tabledir)//TRIM(table),ovnm,zcoord)
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
#endif 
c --- Process table Oyr
      WRITE(*,*) 'Process table Oyr'
      fnm=poyr
      table=toyr
      DO n=1,noyr
        IF (skip_variable(n,noyr,doyr)) CYCLE
c
c --- - Map namelist variables 
        ovnm=voyr(ovnmpos,n)
        ivnm=voyr(ivnmpos,n)
        special=voyr(3,n)
        vunits=' '
        vpositive=' '
        vcomment=' ' 
c
c --- - Check if vertical coordinate required        
        CALL get_vertcoord(TRIM(tabledir)//TRIM(table),ovnm,zcoord)
c 
c --- - Choose history file 
        IF (INDEX(special,'mon2yr').GT.0) THEN
          itag=tagomon
        ELSE
          itag=tagoyr
        ENDIF 
c
c --- - Check if input variable is present  
        IF (LEN_TRIM(poyr).eq.0) CALL scan_files(reset=.TRUE.)
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
          IF (MOD(m-1,royr).EQ.0) CALL open_ofile
c 
c --- --- Read variable into buffer (average if necessary)
          rec=0
          nrec=0
          fldacc=0.
          last=.FALSE.
          first=.TRUE.
          DO
            IF (LEN_TRIM(poyr).eq.0) CALL scan_files(reset=.FALSE.)
            IF (rec.EQ.0) then
              last=.TRUE.
              EXIT
            ENDIF
            nrec=nrec+1
cdiag       write(*,*) 'DEBUG: ',trim(fnm),rec,nrec,tbnd,mbnd,year,month
            CALL read_tslice(rec,badrec,fnm)
            fldacc=fldacc+fld
            IF (INDEX(special,'mon2yr').GT.0) THEN 
              IF (first) tbnds(1,1)=mbnd(1) 
              tbnds(2,1)=mbnd(2) 
            ELSE 
              tbnds(1,1)=tval(1)-365./2. 
              tbnds(2,1)=tval(1)+365./2. 
              EXIT
            ENDIF
            first=.FALSE. 
            IF (month.EQ.12) EXIT
          ENDDO
          IF (last) EXIT
          fld=fldacc/FLOAT(nrec)
          tval=0.5*(tbnds(1,1)+tbnds(2,1))
c 
c --- --- Post processing 
          CALL special_post
c
c --- --- Write time slice to output file 
          CALL write_tslice
c
c --- --- Close output file if max rec has been reached 
          IF (MOD(m,royr).EQ.0) CALL close_ofile
c
c --- - End loop over files and records
        ENDDO
c
c --- - Close output file if still open 
        IF (MOD(m,royr).GT.0) CALL close_ofile
c
      ENDDO
c
c 
c --- Process table oyr (bgc)
      WRITE(*,*) 'Process table oyr (bgc)'
      fnm=poyrbgc
      table=toyrbgc
      DO n=1,noyrbgc
        IF (skip_variable(n,noyrbgc,doyrbgc)) CYCLE
c
c --- - Map namelist variables 
        ovnm=voyrbgc(ovnmpos,n)
        ivnm=voyrbgc(ivnmpos,n)
        special=voyrbgc(3,n)
        vunits=' '
        vpositive=' '
        vcomment=' ' 
c 
c --- - Choose history file 
        IF (INDEX(special,'mon2yr').GT.0) THEN
          itag=tagomonbgc
        ELSE
          itag=tagoyrbgc
        ENDIF
c
c --- - Check if input variable is present  
        IF (LEN_TRIM(poyrbgc).eq.0) CALL scan_files(reset=.TRUE.)
        IF (.NOT.var_in_file(fnm,ivnm)) CYCLE
c
c --- - Check if vertical coordinate required        
        CALL get_vertcoord(TRIM(tabledir)//TRIM(table),ovnm,zcoord)
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
          IF (MOD(m-1,royrbgc).EQ.0) CALL open_ofile
c 
c --- --- Read variable into buffer (average if necessary)
          rec=0
          nrec=0
          fldacc=0.
          last=.FALSE.
          first=.TRUE.
          DO
            IF (LEN_TRIM(poyrbgc).eq.0) CALL scan_files(reset=.FALSE.)
            IF (rec.EQ.0) then
              last=.TRUE.
              EXIT
            ENDIF
            nrec=nrec+1
cdiag       write(*,*) 'DEBUG: ',trim(fnm),rec,nrec,tbnd,mbnd,year,month
            CALL read_tslice(rec,badrec,fnm)
            fldacc=fldacc+fld
            IF (INDEX(special,'mon2yr').GT.0) THEN
              IF (first) tbnds(1,1)=mbnd(1)
              tbnds(2,1)=mbnd(2)
            ELSE
              tbnds(1,1)=tval(1)-365./2.
              tbnds(2,1)=tval(1)+365./2.
              EXIT
            ENDIF
            first=.FALSE.
            IF (month.EQ.12) EXIT
          ENDDO
          IF (last) EXIT
          fld=fldacc/FLOAT(nrec)
          tval=0.5*(tbnds(1,1)+tbnds(2,1))
c 
c --- --- Post processing 
          CALL special_post
c
c --- --- Write time slice to output file 
          CALL write_tslice
c
c --- --- Close output file if max rec has been reached 
          IF (MOD(m,royrbgc).EQ.0) CALL close_ofile
c
c --- - End loop over files and records
        ENDDO
c
c --- - Close output file if still open 
        IF (MOD(m,royrbgc).GT.0) CALL close_ofile
c
      ENDDO
c
c 
c --- Process table Omon
      WRITE(*,*) 'Process table Omon'
      fnm=pomon
      table=tomon 
      DO n=1,nomon 
        IF (skip_variable(n,nomon,domon)) CYCLE
c
c --- - Map namelist variables 
        ovnm=vomon(ovnmpos,n) 
        ivnm=vomon(ivnmpos,n) 
        special=vomon(3,n)
        vunits=' ' 
        vpositive=' ' 
        vcomment=' ' 
c
c --- - Check if vertical coordinate required        
        CALL get_vertcoord(TRIM(tabledir)//TRIM(table),ovnm,zcoord)
c
c --- - Check if we should skip variable 
        WRITE(*,*) TRIM(ovnm),TRIM(zcoord),do_3d,do_xd
        IF (.NOT.do_3d.AND.do_xd) THEN
          IF (zcoord(1:6).EQ.'olevel'.AND.ovnm(1:5).NE.'mmflx'
     .      .AND.ovnm(1:8).NE.'ficeberg'.AND.
     .      ovnm(1:11).NE.'hfsithermds') CYCLE
        ELSEIF (do_3d.AND..NOT.do_xd) THEN 
          IF (zcoord(1:6).NE.'olevel'.OR.ovnm(1:5).EQ.'mmflx'
     .      .OR.ovnm(1:8).EQ.'ficeberg'.OR.
     .      ovnm(1:11).EQ.'hfsithermds') CYCLE
        ELSEIF (.NOT.do_3d.AND..NOT.do_xd) THEN 
          CYCLE
        ENDIF
c 
c --- - Choose history file 
        IF (INDEX(special,'day2mon').GT.0) THEN
          itag=tagoday 
        ELSE
          itag=tagomon
        ENDIF 
c
c --- - Check if input variable is present  
        IF (LEN_TRIM(pomon).eq.0) CALL scan_files(reset=.TRUE.)
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
          IF (MOD(m-1,romon).EQ.0) CALL open_ofile
c 
c --- --- Read variable into buffer (average if necessary)
          rec=0
          nrec=0
          fldacc=0.
          last=.FALSE.
          DO
            IF (LEN_TRIM(pomon).eq.0) CALL scan_files(reset=.FALSE.)
            IF (rec.EQ.0) then
              last=.TRUE.
              EXIT
            ENDIF
            nrec=nrec+1
cdiag       write(*,*) 'DEBUG: ',trim(fnm),rec,nrec,tbnd,mbnd,year,month
            CALL read_tslice(rec,badrec,fnm)
            fldacc=fldacc+fld
            IF (INDEX(special,'day2mon').GT.0) THEN
              IF (tbnd(2)+0.5.GE.mbnd(2)) EXIT 
            ELSE
              EXIT
            ENDIF
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
          IF (MOD(m,romon).EQ.0) CALL close_ofile
c
c --- - End loop over files and records
        ENDDO
c
c --- - Close output file if still open 
        IF (MOD(m,romon).GT.0) CALL close_ofile
c
      ENDDO
c
c 
c --- Process table Emon
      WRITE(*,*) 'Process table Emon'
      fnm=pEmon
      table=tEmon
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
c --- - Check if vertical coordinate required        
        CALL get_vertcoord(TRIM(tabledir)//TRIM(table),ovnm,zcoord)
c
c --- - Check if we should skip variable 
        WRITE(*,*) TRIM(ovnm),TRIM(zcoord),do_3d,do_xd
        IF (.NOT.do_3d.AND.do_xd) THEN
          IF (zcoord(1:6).EQ.'olevel'.AND.ovnm(1:5).NE.'mmflx'
     .      .AND.ovnm(1:8).NE.'ficeberg'.AND.
     .      ovnm(1:11).NE.'hfsithermds') CYCLE
        ELSEIF (do_3d.AND..NOT.do_xd) THEN
          IF (zcoord(1:6).NE.'olevel'.OR.ovnm(1:5).EQ.'mmflx'
     .      .OR.ovnm(1:8).EQ.'ficeberg'.OR.
     .      ovnm(1:11).EQ.'hfsithermds') CYCLE
        ELSEIF (.NOT.do_3d.AND..NOT.do_xd) THEN
          CYCLE
        ENDIF
c 
c --- - Choose history file 
        IF (INDEX(special,'day2mon').GT.0) THEN
          itag=tagoday
        ELSE
          itag=tagomon
        ENDIF
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
          last=.FALSE.
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
            IF (INDEX(special,'day2mon').GT.0) THEN
              IF (tbnd(2)+0.5.GE.mbnd(2)) EXIT
            ELSE
              EXIT
            ENDIF
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
c
c
c --- Process table omon (bgc)
      WRITE(*,*) 'Process table omon (bgc)'
      fnm=pomonbgc
      table=tomonbgc
      DO n=1,nomonbgc
        IF (skip_variable(n,nomonbgc,domonbgc)) CYCLE
c
c --- - Map namelist variables 
        ovnm=vomonbgc(ovnmpos,n)
        ivnm=vomonbgc(ivnmpos,n)
        special=vomonbgc(3,n)
        vunits=' '
        vpositive=' '
        vcomment=' ' 
c
c --- - Check if vertical coordinate required     
        write(*,*) trim(ovnm)   
        CALL get_vertcoord(TRIM(tabledir)//TRIM(table),ovnm,zcoord)
c
c --- - Check if we should skip variable 
        WRITE(*,*) TRIM(ovnm),TRIM(zcoord),do_3d,do_xd
        IF (.NOT.do_3d.AND.do_xd) THEN
          IF (zcoord(1:6).EQ.'olevel') CYCLE
        ELSEIF (do_3d.AND..NOT.do_xd) THEN
          IF (zcoord(1:6).NE.'olevel') CYCLE
        ELSEIF (.NOT.do_3d.AND..NOT.do_xd) THEN
          CYCLE
        ENDIF
c 
c --- - Choose history file 
        IF (INDEX(special,'day2mon').GT.0) THEN
          itag=tagodaybgc
        ELSE
          itag=tagomonbgc
        ENDIF
c
c --- - Check if input variable is present  
        IF (LEN_TRIM(pomonbgc).eq.0) CALL scan_files(reset=.TRUE.)
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
          IF (MOD(m-1,romonbgc).EQ.0) CALL open_ofile
c 
c --- --- Read variable into buffer (average if necessary)
          rec=0
          nrec=0
          fldacc=0.
          last=.FALSE.
          DO
            IF (LEN_TRIM(pomonbgc).eq.0) CALL scan_files(reset=.FALSE.)
            IF (rec.EQ.0) then
              last=.TRUE.
              EXIT
            ENDIF
            nrec=nrec+1
cdiag       write(*,*) 'DEBUG: ',trim(fnm),rec,nrec,tbnd,mbnd,year,month
            CALL read_tslice(rec,badrec,fnm)
            fldacc=fldacc+fld
            IF (INDEX(special,'day2mon').GT.0) THEN
              IF (tbnd(2)+0.5.GE.mbnd(2)) EXIT
            ELSE
              EXIT
            ENDIF
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
          IF (MOD(m,romonbgc).EQ.0) CALL close_ofile
c
c --- - End loop over files and records
        ENDDO
c
c --- - Close output file if still open 
        IF (MOD(m,romonbgc).GT.0) CALL close_ofile
c
      ENDDO
c
c
c --- Process table day
      WRITE(*,*) 'Process table day'
      fnm=pday
      table=tday
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
c --- - Check if vertical coordinate required        
        CALL get_vertcoord(TRIM(tabledir)//TRIM(table),ovnm,zcoord)
c 
c --- - Choose history file 
        itag=tagoday
c
c --- - Check if input variable is present  
        IF (LEN_TRIM(pday).eq.0) CALL scan_files(reset=.TRUE.)
        IF (.NOT.var_in_file(fnm,ivnm)) CYCLE
c
c --- - Prepare output file 
        CALL special_pre
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
          IF (LEN_TRIM(pday).eq.0) CALL scan_files(reset=.false.)
          IF (rec.EQ.0) EXIT
          tbnds(1,1)=tval(1)-0.5
          tbnds(2,1)=tval(1)+0.5
          tval=0.5*(tbnds(1,1)+tbnds(2,1))
c
c --- --- Read data 
          CALL read_tslice(rec,badrec,fnm)
c 
c --- --- Post processing 
          CALL special_post
c
c --- --- Write time slice to output file 
          IF (badrec) fld=1e20
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
c
c
#ifdef CMOR3
c --- Process table Oday
      WRITE(*,*) 'Process table Oday'
      fnm=pOday
      table=tOday
      DO n=1,nOday
        IF (skip_variable(n,nOday,dOday)) CYCLE
c
c --- - Map namelist variables 
        ovnm=vOday(ovnmpos,n)
        ivnm=vOday(ivnmpos,n)
        special=vOday(3,n)
        vunits=' '
        vpositive=' '
        vcomment=' '
c
c --- - Check if vertical coordinate required        
        CALL get_vertcoord(TRIM(tabledir)//TRIM(table),ovnm,zcoord)
c 
c --- - Choose history file 
        itag=tagoday
c
c --- - Check if input variable is present  
        IF (LEN_TRIM(pOday).eq.0) CALL scan_files(reset=.TRUE.)
        IF (.NOT.var_in_file(fnm,ivnm)) CYCLE
c
c --- - Prepare output file 
        CALL special_pre
c --- - Loop over input files 
        m=0
        DO
          m=m+1
c
c --- --- Open output file
          IF (MOD(m-1,rOday).EQ.0) CALL open_ofile
c
c --- --- Read variable into buffer 
          rec=0
          IF (LEN_TRIM(pOday).eq.0) CALL scan_files(reset=.false.)
          IF (rec.EQ.0) EXIT
          tbnds(1,1)=tval(1)-0.5
          tbnds(2,1)=tval(1)+0.5
          tval=0.5*(tbnds(1,1)+tbnds(2,1))
c
c --- --- Read data 
          CALL read_tslice(rec,badrec,fnm)
c 
c --- --- Post processing 
          CALL special_post
c
c --- --- Write time slice to output file 
          IF (badrec) fld=1e20
          CALL write_tslice
c
c --- --- Close output file if max rec has been reached 
          IF (MOD(m,rOday).EQ.0) CALL close_ofile
c
c --- - End loop over files and records
        ENDDO
c
c --- - Close output file if still open 
        IF (MOD(m,rOday).GT.0) CALL close_ofile
c
      ENDDO

c --- Process table Odaybgc
      WRITE(*,*) 'Process table Odaybgc'
      fnm=pOdaybgc
      table=tOdaybgc
      DO n=1,nOdaybgc
        IF (skip_variable(n,nOdaybgc,dOdaybgc)) CYCLE
c
c --- - Map namelist variables 
        ovnm=vOdaybgc(ovnmpos,n)
        ivnm=vOdaybgc(ivnmpos,n)
        special=vOdaybgc(3,n)
        vunits=' '
        vpositive=' '
        vcomment=' '
c
c --- - Check if vertical coordinate required        
        CALL get_vertcoord(TRIM(tabledir)//TRIM(table),ovnm,zcoord)
c 
c --- - Choose history file 
        itag=tagodaybgc
c
c --- - Check if input variable is present  
        IF (LEN_TRIM(pOdaybgc).eq.0) CALL scan_files(reset=.TRUE.)
        IF (.NOT.var_in_file(fnm,ivnm)) CYCLE
c
c --- - Prepare output file 
        CALL special_pre
c --- - Loop over input files 
        m=0
        DO
          m=m+1
c
c --- --- Open output file
          IF (MOD(m-1,rOdaybgc).EQ.0) CALL open_ofile
c
c --- --- Read variable into buffer 
          rec=0
          IF (LEN_TRIM(pOdaybgc).eq.0) CALL scan_files(reset=.false.)
          IF (rec.EQ.0) EXIT
          tbnds(1,1)=tval(1)-0.5
          tbnds(2,1)=tval(1)+0.5
          tval=0.5*(tbnds(1,1)+tbnds(2,1))
c
c --- --- Read data 
          CALL read_tslice(rec,badrec,fnm)
c 
c --- --- Post processing 
          CALL special_post
c
c --- --- Write time slice to output file 
          IF (badrec) fld=1e20
          CALL write_tslice
c
c --- --- Close output file if max rec has been reached 
          IF (MOD(m,rOdaybgc).EQ.0) CALL close_ofile
c
c --- - End loop over files and records
        ENDDO
c
c --- - Close output file if still open 
        IF (MOD(m,rOdaybgc).GT.0) CALL close_ofile
c
      ENDDO
c
c --- Process table Eday
      WRITE(*,*) 'Process table Eday'
      fnm=pEday
      table=tEday
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
c --- - Check if vertical coordinate required        
        CALL get_vertcoord(TRIM(tabledir)//TRIM(table),ovnm,zcoord)
c 
c --- - Choose history file 
        itag=tagoday
c
c --- - Check if input variable is present  
        IF (LEN_TRIM(pEday).eq.0) CALL scan_files(reset=.TRUE.)
        IF (.NOT.var_in_file(fnm,ivnm)) CYCLE
c
c --- - Prepare output file 
        CALL special_pre
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
          IF (LEN_TRIM(pEday).eq.0) CALL scan_files(reset=.false.)
          IF (rec.EQ.0) EXIT
          tbnds(1,1)=tval(1)-0.5
          tbnds(2,1)=tval(1)+0.5
          tval=0.5*(tbnds(1,1)+tbnds(2,1))
c
c --- --- Read data 
          CALL read_tslice(rec,badrec,fnm)
c 
c --- --- Post processing 
          CALL special_post
c
c --- --- Write time slice to output file 
          IF (badrec) fld=1e20
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
#endif 
c
c           exception for fill day 
c           IF (year.EQ.year1.AND.month.EQ.month1.AND.add_fill_day) THEN
c             day1=0
c           ELSE
c             day1=1
c           ENDIF
c --- --- --- Set fill value for dummy day 
c             IF (rec.EQ.0) fld=1e20
c
c
      END SUBROUTINE ocn2cmor 



      SUBROUTINE special_pre
c
      IMPLICIT NONE
c
      INTEGER :: i,j,k 
c
      lsumz=.FALSE.
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
c --- - atm to Pa
        CASE ('atm2Pa')
          vunits='Pa'
c
c --- - uatm to Pa
        CASE ('uatm2Pa')
          vunits='Pa'
c 
c --- - Unit transformation: mol cfcXX m-3 -> mol cfcXX kg-1
        CASE ('cfcunits')
          vunits='mol kg-1'
c
c --- - CFC11 comment
        CASE ('cfc11comment')
          vcomment='In this simulation, annual means of reconstructed'//
     .' Northern Hemisphere CFC-11 are applied globally to the ocean.'//
     .' Reference: Walker S.J., Weiss R.F., Salameh P.K. (2000)'//
     .' Reconstructed histories of the annual mean atmospheric mole'//
     .' fractions for the halocarbons CFC-11, CFC-12, CFC-113 and'//
     .' carbon tetrachloride. J. Geophys. Res. 105(C6): 14285-14296.'//
     .' CFC-11 data in ppt (1910.5-2008.5):'//
     .' 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,'//
     .' 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,'//
     .' 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,'//
     .' 0.0, 0.0, 0.0, 0.0, 0.0, 0.1, 0.1, 0.1, 0.2, 0.4, 0.7, 1.0,'//
     .' 1.5, 2.2, 3.0, 4.1, 5.4, 6.8, 8.1, 9.4, 11.1, 13.3, 16.1,'//
     .' 19.6, 23.8, 28.4, 33.6, 39.5, 46.1, 53.7, 62.5, 72.0, 82.7,'//
     .' 94.9, 108.4, 121.4, 133.9, 145.9, 156.6, 168.3, 176.7, 184.3,'//
     .' 191.4, 199.4, 208.1, 218.1, 229.5, 241.7, 253.0, 259.5,'//
     .' 266.0, 268.4, 268.3, 269.7, 269.8, 268.5, 267.3, 265.9,'//
     .' 264.4, 262.9, 262.0, 260.3, 258.1, 256.0, 254.1, 252.0,'//
     .' 248.9, 246.9, 245.3'
c
c --- - CFC12 comment
        CASE ('cfc12comment')
          vcomment='In this simulation, annual means of reconstructed'//
     .' Northern Hemisphere CFC-12 are applied globally to the ocean.'//
     .' Reference: Walker S.J., Weiss R.F., Salameh P.K. (2000)'//
     .' Reconstructed histories of the annual mean atmospheric mole'//
     .' fractions for the halocarbons CFC-11, CFC-12, CFC-113 and'//
     .' carbon tetrachloride. J. Geophys. Res. 105(C6): 14285-14296.'//
     .' CFC-12 data in ppt (1910.5-2008.5):'//
     .' 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,'//
     .' 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,'//
     .' 0.0, 0.0, 0.1, 0.1, 0.2, 0.3, 0.4, 0.5, 0.7, 0.9, 1.2, 1.7,'//
     .' 2.3, 3.4, 4.8, 6.1, 7.6, 9.2, 11.0, 12.8, 15.0, 17.4, 20.2,'//
     .' 23.4, 26.8, 30.5, 35.0, 40.0, 45.8, 52.5, 60.4, 69.3, 79.2,'//
     .' 90.3, 102.8, 116.7, 132.0, 148.3, 166.1, 185.7, 207.1, 228.1,'//
     .' 248.0, 266.9, 284.2, 305.9, 323.0, 339.6, 353.3, 369.0,'//
     .' 385.7, 403.4, 424.3, 444.0, 465.4, 483.6, 497.7, 506.0,'//
     .' 516.4, 523.2, 528.9, 533.9, 537.6, 540.5, 542.5, 544.1,'//
     .' 546.4, 546.9, 546.8, 546.5, 547.2, 546.5, 544.5, 541.8, 540.6'
c
c --- - mol m-3 
        CASE ('mol m-3')
          vunits='mol m-3'
c
c --- - mol m-2 s-1
        CASE ('mol m-2 s-1')
          vunits='mol m-2 s-1'
c
c --- - mol m-3 s-1
        CASE ('mol m-3 s-1')
          vunits='mol m-3 s-1'
c
c --- - Salinity has to be in practical salinity units 
        CASE ('psu')
          vunits='psu'
c
c --- - Fix unitless units 
        CASE ('unitless')
          vunits='1'
c
c --- - Set correct units for percentage
        CASE ('percent')
          vunits='%'
c
c --- - Set correct units for fraction
        CASE ('fraction')
          vunits='1'
c
c --- - Unit transformation: kg m-2  
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
c --- - Fix wo units 
        CASE ('wflx2wo')
          vunits='m s-1'
c
c --- - Set units to kg 
        CASE ('kg')
          vunits='kg'
c
c --- - Set units to m^3 
        CASE ('m3')
          vunits='m3'
c        
c --- - Convert units from radians2 to m2    
        CASE ('rad2m')
          vunits='m2'
c        
c --- - Set units for streamfunction    
        CASE ('strmf')
          vunits='kg s-1'
          lsumz=.TRUE.
c
c --- - Set positive attribute  
        CASE ('positiveup')
          vpositive='up'
        CASE ('positivedo')
          vpositive='down'
c
c --- - Compute vertical sum 
        CASE ('sumz')
          lsumz=.TRUE.
c
c --- - Compute density 
        CASE ('ts2rho0')
          vunits='kg m-3'
c
c --- - Compute steric sea level change from density 
        CASE ('ts2zossga','t2zostoga')
          vunits='m'
c
c --- - Compute fixed cell volume of interpolated grid
        CASE ('volcello')
          vunits='m3'

c --- - Compute fixed cell volume of interpolated grid
        CASE ('volcellomon')
          vunits='m3'

c --- - Compute fixed cell thickness
        CASE ('thkcello')
          vunits='m'

c --- - Compute depth of local mimina
        CASE ('locminz')
          vunits='m'

c --- - Compute depth of local mimina
        CASE ('omega2z')
          vunits='m'

c --- - Convert units from [mol P/m3] to [kg Chl/m3] using [60 gC/gChl]
        CASE ('kg m-3')
          vunits='kg m-3'
c
c --- - Convert units from [m3] to [1e3 km3]
        CASE ('1e3 km3')
          vunits='1e3 km3'
c
c --- - Convert units from [s-1] to [s-2], fix bug for the units of bfsq in micom
        CASE ('s-2')
          vunits='s-2'
c
c --- - Set unit g m-2
        CASE ('g m-2')
          vunits='g m-2'
c
c --- - Set unit degC kg m-2
        CASE ('degC kg m-2')
          vunits='degC kg m-2'
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
      REAL :: r,rd,p,ptoptmp,pbottmp,sref=35.
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
c --- - Compute depth below geoid from dz or pddpo 
        CASE ('dz2zfull')
          fldacc(:,:,1)=fld(:,:,1)*0.5-sealv
          DO k=2,kdm
            fldacc(:,:,k)=fldacc(:,:,k-1)+(fld(:,:,k-1)+fld(:,:,k))*0.5
          ENDDO
          fld=fldacc
c
c --- - Compute depth below geoid at interfaces from dz      
        CASE ('dz2zhalf')
          fldacc(:,:,1)=-sealv
          DO k=2,kdm
            fldacc(:,:,k)=fldacc(:,:,k-1)+fld(:,:,k-1)
          ENDDO
          fld=fldacc
c
c --- - Convert units from radians2 to m2    
        CASE ('rad2m')
          DO k=1,kk
            DO j=1,jj 
              DO i=1,ii    
                IF (fld(i,j,k).LT.1e20) 
     .              fld(i,j,k)=fld(i,j,k)*6.37122e6**2
              ENDDO  
            ENDDO 
          ENDDO
c
c --- - Unit transformation: cm day-1 -> kg m-2 s-1 
c       CASE ('kg m-2 s-1')
c         fld=fld/(10.*24.*3600.) 
c
c --- - Set ice free points to missing value
        CASE ('zero2missing')       
          DO k=1,kk 
            DO j=1,jj 
              DO i=1,ii    
                IF (ABS(fld(i,j,k)).LT.1e-6) fld(i,j,k)=1e20
              ENDDO  
            ENDDO 
          ENDDO 
c
c --- - Set ice free points to missing value
        CASE ('pmask')
          DO k=1,kk
            DO j=1,jj 
              DO i=1,ii    
                IF (pmask(i,j).LT.0.5) fld(i,j,k)=1e20
              ENDDO  
            ENDDO 
          ENDDO
c
c --- - Compute vertical sum 
        CASE ('sumz')
          DO k=2,kk
            DO j=1,jj 
              DO i=1,ii    
                IF (ABS(fld(i,j,k)).LT.1e20) 
     .            fld(i,j,1)=fld(i,j,1)+fld(i,j,k)
              ENDDO  
            ENDDO 
          ENDDO
c
c --- - Compute local minima
        CASE ('locmin')
          DO j=1,jj 
            DO i=1,ii    
              DO k=2,kk
                IF (fld(i,j,1).GT.fld(i,j,k)) THEN
                  fld(i,j,1)=fld(i,j,k)
                ELSE
                  EXIT
                END IF
              ENDDO  
            ENDDO 
          ENDDO
c
c --- - Compute local minima depth
        CASE ('locminz')
          fld2=fld
          DO j=1,jj 
            DO i=1,ii    
              fld2(i,j,1)=depth(1)
              DO k=2,kk
                IF (fld(i,j,1).GT.fld(i,j,k)) THEN
                  fld(i,j,1)=fld(i,j,k)
                  fld2(i,j,1)=depth(k)
                ELSE
                  EXIT
                END IF
              ENDDO  
            ENDDO 
          ENDDO
          fld=fld2
c
c --- - Compute Aragonite Saturation Depth
        CASE ('omega2z')
          fldtmp=1e20
          DO j=1,jj 
            DO i=1,ii    
              DO k=1,kk
                IF (fld(i,j,k).LT.1.0) THEN
                  IF (k.EQ.1) THEN
                    fldtmp(i,j,1)=0.0
                  ELSE
                    fldtmp(i,j,1)=depth(k)
                  END IF
                END IF
              ENDDO  
            ENDDO 
          ENDDO
          fld=fldtmp
c
c --- - Multiply with global ocean area 
        CASE ('xglbarea')
          fld=fld*aoglb
c
c --- - Multiply gravity constant 
        CASE ('xg')
          DO k=1,kk
            DO j=1,jj 
              DO i=1,ii    
                IF (fld(i,j,k).LT.1e20) fld(i,j,k)=fld(i,j,k)*9.806
              ENDDO  
            ENDDO 
          ENDDO
c
c --- - Devide by gravity constant 
        CASE ('xginv')
          DO k=1,kk
            DO j=1,jj 
              DO i=1,ii    
                IF (fld(i,j,k).LT.1e20) fld(i,j,k)=fld(i,j,k)/9.806
              ENDDO  
            ENDDO 
          ENDDO
c
c --- - Flip sign 
        CASE ('flipsign')
          DO k=1,kk
            DO j=1,jj 
              DO i=1,ii    
                IF (fld(i,j,k).LT.1e20) fld(i,j,k)=-fld(i,j,k)
              ENDDO  
            ENDDO 
          ENDDO
c
c --- - Compute global 2d average 
        CASE ('glbave2d')
          fld(1,1,1)=SUM(fld(:,:,1)*parea)/SUM(parea)
c
c --- - Compute global 3d average 
        CASE ('glbave3d')
          r=0.
          rd=0.
          DO k=1,kk
            r=r+SUM(fld(:,:,k)*dp(:,:,k)*parea)
            rd=rd+SUM(dp(:,:,k)*parea)
          ENDDO
          fld(1,1,1)=r/MAX(1e-10,rd)
c
c --- - Compute potential density 
        CASE ('ts2rho0')
c         WRITE(*,*) 'rho_ref(0Pa,15degC,35psu)=',rho(0.,15.,35.)*1e3 
          DO k=1,kk
            DO j=1,jj
              DO i=1,ii
                IF (fld(i,j,k).NE.1e20)
     .            fld(i,j,k)=1e3*rho(0.,fld(i,j,k),fld2(i,j,k))
              ENDDO
            ENDDO
          ENDDO
c
c --- - Compute steric sea level
        CASE ('ts2zossga')
          IF (vtype.EQ.'layer') THEN
            r=0.
            DO j=1,jj
              DO i=1,ii
                pbottmp=0.
                DO k=1,kk
                  ptoptmp=pbottmp
                  pbottmp=ptoptmp+dp(i,j,k)
                  IF (fld(i,j,k).NE.1e20) THEN
                    r=r+1e-2*(1e-2*ginv)*parea(i,j)*
     .                p_alpha(ptoptmp,pbottmp,fld(i,j,k),fld2(i,j,k))
                  ENDIF
                ENDDO
              ENDDO
            ENDDO
            fld(1,1,1)=(r-voglb)/aoglb
            WRITE(*,*) 'zossga=',fld(1,1,1)
          ELSE
            STOP 'input variables for zossga must be of type layer'
          ENDIF
c
c --- - Compute thermo-steric sea level
        CASE ('t2zostoga')
          IF (vtype.EQ.'layer') THEN
            r=0.
            DO j=1,jj
              DO i=1,ii
                pbottmp=0.
                DO k=1,kk
                  ptoptmp=pbottmp
                  pbottmp=ptoptmp+dp(i,j,k)
                  IF (fld(i,j,k).NE.1e20)
     .              r=r+1e-2*(1e-2*ginv)*parea(i,j)*
     .                p_alpha(ptoptmp,pbottmp,fld(i,j,k),sref)
                ENDDO
              ENDDO
            ENDDO
            fld(1,1,1)=(r-voglb)/aoglb
            WRITE(*,*) 'zostoga',fld(1,1,1)
          ELSE
            STOP 'input variable for zostoga must be of type layer'
          ENDIF
c 
c --- - Set land mask of streamfunction 
        CASE ('strmf')
          DO j=1,jj
            DO i=1,ii    
              if (pmask(i,j).EQ.0) fld(i,j,1)=1e20
            ENDDO
          ENDDO
c
c --- - Compute fixed cell volume of interpolated grid
        CASE ('volcello')
          DO j=1,jj
            DO i=1,ii
              DO k=ddm,1,-1
                IF (fld(i,j,1).EQ.0.) THEN
                  fld(i,j,k)=1e20
                ELSE
                  ptoptmp=MIN(depth_bnds(1,k),fld(i,j,1))
                  pbottmp=MIN(depth_bnds(2,k),fld(i,j,1))
                  fld(i,j,k)=(pbottmp-ptoptmp)*fld2(i,j,1)
                ENDIF
              ENDDO
            ENDDO
          ENDDO
c
c --- - Compute fixed cell volume of interpolated grid
        CASE ('volcellomon')
          DO j=1,jj
            DO i=1,ii
              DO k=ddm,1,-1
                IF (fld(i,j,1).EQ.0.) THEN
                  fld(i,j,k)=1e20
                ELSE
                  fld(i,j,k)=fld(i,j,k)*fld2(i,j,1)
                ENDIF
              ENDDO
            ENDDO
          ENDDO
c
c --- - Compute vertical velocity form vertical mass flux
        CASE ('wflx2wo')
          DO j=1,jj
            DO i=1,ii
              DO k=1,kk
                IF (fld(i,j,1).EQ.0.) THEN
                  fld(i,j,k)=1e20
                ELSE
                  fld(i,j,k)=fld(i,j,k)/(1035.*parea(i,j))
                ENDIF
              ENDDO
            ENDDO
          ENDDO

c
c --- - Compute fixed cell thickness
        CASE ('thkcello')
          DO j=1,jj
            DO i=1,ii
              DO k=ddm,1,-1
                IF (fld(i,j,1).EQ.0.) THEN
                  fld(i,j,k)=1e20
                ELSE
                  fld(i,j,k)=MIN(fld(i,j,1),depth_bnds(2,k))-
     .                       MIN(fld(i,j,1),depth_bnds(1,k)) 
                ENDIF
              ENDDO
            ENDDO
          ENDDO

c 
c --- - Compute basin index
        CASE ('basin')
          OPEN(10,FILE=TRIM(griddata)//TRIM(ocnmertfile))
          READ(10,'(2i6)') i,j
          IF (i.NE.idm.OR.j.NE.jdm)
     .      STOP 'mertraocean: incorrect indexes in mertraoceans.dat!'
          str1=' '
          WRITE(str1,*) '(',jdm,'i1)'
          READ(10,str1) ((basin(i,j),j=1,jdm),i=1,idm)
          CLOSE(10)
          fld=0
          DO j=1,jdm
            DO i=1,idm
c --- --- --- Southern Ocean 
              IF (plat(i,j).LT.0.AND.basin(i,j).EQ.1) fld(i,j,1)=1
c --- --- --- Pacific Ocean 
              IF (basin(i,j).EQ.3) fld(i,j,1)=3
c --- --- --- Arctic Ocean
              IF (plat(i,j).GT.60.AND.basin(i,j).EQ.1) fld(i,j,1)=4
c --- --- --- Indian Ocean 
              IF (basin(i,j).EQ.4) fld(i,j,1)=5
c --- --- --- Mediterranean Sea
              IF (basin(i,j).EQ.2.AND.plat(i,j).GT.30.5.AND.
     .          plat(i,j).LT.40.5.AND.(plon(i,j).GT.354.5.OR.
     .          plon(i,j).LT.37)) fld(i,j,1)=6
              IF (basin(i,j).EQ.2.AND.plat(i,j).GT.40.5.AND.
     .          plat(i,j).LT.46.AND.(plon(i,j).GT.359.OR.
     .          plon(i,j).LT.27.5)) fld(i,j,1)=6
c --- --- --- Black Sea  
              IF (basin(i,j).EQ.1.AND.plat(i,j).GT.40.5.AND.
     .          plat(i,j).LT.48.AND.plon(i,j).GT.27.5.AND.
     .          plon(i,j).LT.45) fld(i,j,1)=7
c --- --- --- Hudson Bay   
              IF (basin(i,j).EQ.2.AND.plat(i,j).GT.50.AND.
     .          plat(i,j).LT.70.AND.plon(i,j).GT.265.AND.
     .          plon(i,j).LT.295) fld(i,j,1)=8
c --- --- --- Baltic Sea  
              IF (basin(i,j).EQ.2.AND.plat(i,j).GT.53.AND.
     .          plat(i,j).LT.62.AND.plon(i,j).GT.10.AND.
     .          plon(i,j).LT.30) fld(i,j,1)=9
              IF (basin(i,j).EQ.2.AND.plat(i,j).GT.62.AND.
     .          plat(i,j).LT.66.5.AND.plon(i,j).GT.17.AND.
     .          plon(i,j).LT.30) fld(i,j,1)=9
c --- --- --- Red Sea  
              IF (basin(i,j).EQ.4.AND.plat(i,j).GT.13.AND.
     .          plat(i,j).LT.30.AND.plon(i,j).GT.31.AND.
     .          plon(i,j).LT.44) fld(i,j,1)=10
c --- --- --- Atlantic ocean        
              IF (basin(i,j).EQ.2.AND.fld(i,j,1).EQ.0) fld(i,j,1)=2
            ENDDO
          ENDDO
c 
c --- - Multiple a second field
        CASE ('Xfield2')
          DO k=1,kk
            DO j=1,jj
              DO i=1,ii
                IF (fld(i,j,k).NE.1e20)
     .            fld(i,j,k)=fld(i,j,k)*fld2(i,j,k)
              ENDDO
            ENDDO
          ENDDO
c
c --- - Divide a second field
        CASE ('Dfield2')
          DO k=1,kk
            DO j=1,jj
              DO i=1,ii
                IF (fld(i,j,k).NE.1e20)
     .            fld(i,j,k)=fld(i,j,k)/fld2(i,j,k)
              ENDDO
            ENDDO
          ENDDO
c
c --- - Integratal with respect to depth
        CASE ('dpint')
          DO j=1,jj
            DO i=1,ii
              IF (fld(i,j,1).NE.1e20)
     .          fld(i,j,1)=fld(i,j,1)*fld2(i,j,1)/9.806
              DO k=2,kk
                IF (fld(i,j,k).NE.1e20)
     .            fld(i,j,k)=fld(i,j,k-1)+fld(i,j,k)*fld2(i,j,k)/9.806
              ENDDO
            ENDDO
          ENDDO
c
c --- - Integratal with respect to depth
        CASE ('dpavg')
          DO j=1,jj
            DO i=1,ii
              IF (fld(i,j,1).NE.1e20)
     .          fld(i,j,1)=fld(i,j,1)*fld2(i,j,1)
              DO k=2,kk
                IF (fld(i,j,k).NE.1e20) THEN
                  fld(i,j,k)=fld(i,j,k-1)+fld(i,j,k)*fld2(i,j,k)
                  fld2(i,j,1)=fld2(i,j,1)+fld2(i,j,k)
                ENDIF
              ENDDO
              IF (fld(i,j,1).NE.1e20)
     .          fld(i,j,1)=fld(i,j,1)/fld2(i,j,1)
            ENDDO
          ENDDO
c
c --- - Average over upper 300 m
        CASE ('dzavg300')
          fldtmp=1e20
          DO j=1,jj
            DO i=1,ii
              IF (fld(i,j,1).NE.1e20) THEN
                fldtmp(i,j,1)= (min(300.,pdepth(i,j),depth_bnds(2,1))
     .                         -min(300.,pdepth(i,j),depth_bnds(1,1)))
     .                         *pbot(i,j)/pdepth(i,j)
                fld(i,j,1)=fld(i,j,1)*fldtmp(i,j,1)
              END IF
              DO k=2,kk
                IF (fld(i,j,k).NE.1e20) THEN
                  fldtmp(i,j,k)= (min(300.,pdepth(i,j),depth_bnds(2,k))
     .                           -min(300.,pdepth(i,j),depth_bnds(1,k)))
     .                           *pbot(i,j)/pdepth(i,j)
                  fld(i,j,k)=fld(i,j,k-1)+fld(i,j,k)*fldtmp(i,j,k)
                  fldtmp(i,j,1)=fldtmp(i,j,1)+fldtmp(i,j,k)
                ENDIF
              ENDDO
              IF (fld(i,j,1).NE.1e20)
     .          fld(i,j,1)=fld(i,j,1)/fldtmp(i,j,1)
            ENDDO
          ENDDO
c
c --- - Average over upper 700 m
        CASE ('dzavg700')
          fldtmp=1e20
          DO j=1,jj
            DO i=1,ii
              IF (fld(i,j,1).NE.1e20) THEN
                fldtmp(i,j,1)= (min(700.,pdepth(i,j),depth_bnds(2,1))
     .                         -min(700.,pdepth(i,j),depth_bnds(1,1)))
     .                         *pbot(i,j)/pdepth(i,j)
                fld(i,j,1)=fld(i,j,1)*fldtmp(i,j,1)
              END IF
              DO k=2,kk
                IF (fld(i,j,k).NE.1e20) THEN
                  fldtmp(i,j,k)= (min(700.,pdepth(i,j),depth_bnds(2,k))
     .                           -min(700.,pdepth(i,j),depth_bnds(1,k)))
     .                           *pbot(i,j)/pdepth(i,j)
                  fld(i,j,k)=fld(i,j,k-1)+fld(i,j,k)*fldtmp(i,j,k)
                  fldtmp(i,j,1)=fldtmp(i,j,1)+fldtmp(i,j,k)
                ENDIF
              ENDDO
              IF (fld(i,j,1).NE.1e20)
     .          fld(i,j,1)=fld(i,j,1)/fldtmp(i,j,1)
            ENDDO
          ENDDO
c
c --- - Average over upper 2000 m
        CASE ('dzavg2000')
          fldtmp=1e20
          DO j=1,jj
            DO i=1,ii
              IF (fld(i,j,1).NE.1e20) THEN
                fldtmp(i,j,1)= (min(2000.,pdepth(i,j),depth_bnds(2,1))
     .                         -min(2000.,pdepth(i,j),depth_bnds(1,1)))
     .                         *pbot(i,j)/pdepth(i,j)
                fld(i,j,1)=fld(i,j,1)*fldtmp(i,j,1)
              END IF
              DO k=2,kk
                IF (fld(i,j,k).NE.1e20) THEN
                  fldtmp(i,j,k)= (min(2000.,pdepth(i,j),depth_bnds(2,k))
     .                          -min(2000.,pdepth(i,j),depth_bnds(1,k)))
     .                           *pbot(i,j)/pdepth(i,j)
                  fld(i,j,k)=fld(i,j,k-1)+fld(i,j,k)*fldtmp(i,j,k)
                  fldtmp(i,j,1)=fldtmp(i,j,1)+fldtmp(i,j,k)
                ENDIF
              ENDDO
              IF (fld(i,j,1).NE.1e20)
     .          fld(i,j,1)=fld(i,j,1)/fldtmp(i,j,1)
            ENDDO
          ENDDO
c
c --- - Unit transformation: mol cfcXX m-3 -> mol cfcXX kg-1
        CASE ('cfcunits')
          DO k=1,kk
            DO j=1,jj
              DO i=1,ii
                IF (fld(i,j,k).NE.1e20) fld(i,j,k)=fld(i,j,k)/1027.
              ENDDO
            ENDDO
          ENDDO
c
c --- - atm to Pa
        CASE ('atm2Pa')
          DO k=1,kk
            DO j=1,jj
              DO i=1,ii
                IF (fld(i,j,k).NE.1e20) fld(i,j,k)=fld(i,j,k)*101325
              ENDDO
            ENDDO
          ENDDO
c
c --- - uatm to Pa 
        CASE ('uatm2Pa')
          DO k=1,kk
            DO j=1,jj
              DO i=1,ii
                IF (fld(i,j,k).NE.1e20) fld(i,j,k)=fld(i,j,k)*0.101325
              ENDDO
            ENDDO
          ENDDO
c
c --- - Convert units from [mol P/m3] to [kg Chl/m3] using [60 gC/gChl]
        CASE ('mol P m-3 -> kg Chl m-3')
          DO k=1,kk
            DO j=1,jj
              DO i=1,ii
                IF (fld(i,j,k).NE.1e20)
     .            fld(i,j,k)=fld(i,j,k)*122*12/60/1000
              ENDDO
            ENDDO
          ENDDO
c
c --- - Convert units from [m3] to [1e3 km3]
        CASE ('1e3 km3')
          DO k=1,kk
            DO j=1,jj
              DO i=1,ii
                IF (fld(i,j,k).NE.1e20)
     .            fld(i,j,k)=fld(i,j,k)/1e3/1e9
              ENDDO
            ENDDO
          ENDDO
c
c --- - Mask grid points in the southern hemisphere
        CASE ('masks')
          DO k=1,kk
            DO j=1,jj 
              DO i=1,ii    
                IF (plat(i,j).LT.0.0) fld(i,j,k)=1e20
              ENDDO  
            ENDDO 
          ENDDO
c
c --- - Mask grid points in the southern hemisphere
        CASE ('maskn')
          DO k=1,kk
            DO j=1,jj 
              DO i=1,ii    
                IF (plat(i,j).GT.0.0) fld(i,j,k)=1e20
              ENDDO  
            ENDDO 
          ENDDO
c
c --- - Multiple parea
        CASE ('xparea')
          DO k=1,kk
            DO j=1,jj 
              DO i=1,ii    
                IF (fld(i,j,k).NE.1e20) fld(i,j,k)=fld(i,j,k)*parea(i,j)
              ENDDO  
            ENDDO 
          ENDDO

c --- - Iron to phosphorous ratio in organic matter
        CASE ('fe2ph')
          DO k=1,kk
            DO j=1,jj 
              DO i=1,ii    
                IF (fld(i,j,k).NE.1e20)
     .              fld(i,j,k)=fld(i,j,k)*5.*122*1.e-6
              ENDDO  
            ENDDO 
          ENDDO


c --- - Carbon to iron 
        CASE ('c2fe')
          DO k=1,kk
            DO j=1,jj 
              DO i=1,ii    
                IF (fld(i,j,k).NE.1e20) fld(i,j,k)=fld(i,j,k)*5.*1.e-6
              ENDDO  
            ENDDO 
          ENDDO

c --- - epc100 to epn100
        CASE ('epc100toepn100')
          DO k=1,kk
            DO j=1,jj 
              DO i=1,ii    
                IF (fld(i,j,k).NE.1e20) fld(i,j,k)=fld(i,j,k)/122.*16.
              ENDDO  
            ENDDO 
          ENDDO

c --- - epc100 to epp100
        CASE ('epc100toepp100')
          DO k=1,kk
            DO j=1,jj 
              DO i=1,ii    
                IF (fld(i,j,k).NE.1e20) fld(i,j,k)=fld(i,j,k)/122.
              ENDDO  
            ENDDO 
          ENDDO

c --- - percent
        CASE ('percent')
          DO k=1,kk
            DO j=1,jj 
              DO i=1,ii    
                IF (fld(i,j,k).NE.1e20) fld(i,j,k)=fld(i,j,k)*100.
              ENDDO  
            ENDDO 
          ENDDO

c
        END SELECT
c
        IF (str1.EQ.str2) exit
      END DO
c
      END SUBROUTINE special_post



      SUBROUTINE read_gridinfo_ifile 
c
      IMPLICIT NONE
c
      LOGICAL :: check 
      INTEGER :: i,j,k,n,fid
      REAL(KIND=8) :: missing,phiu,phil
c
c --- Open first input file 
      CALL scan_files(reset=.TRUE.)
      status=nf90_open(fnm,nf90_nowrite,ncid)
      CALL handle_ncerror(status)
c
c --- Read dimensions
      status=nf90_inq_dimid(ncid,'x',dimid)
      CALL handle_ncerror(status)
      status=nf90_inquire_dimension(ncid,dimid,len=idm)
      CALL handle_ncerror(status)
c
      status=nf90_inq_dimid(ncid,'y',dimid)
      CALL handle_ncerror(status)
      status=nf90_inquire_dimension(ncid,dimid,len=jdm)
      CALL handle_ncerror(status)
c
      status=nf90_inq_dimid(ncid,'sigma',dimid)
      IF (status.EQ.nf90_noerr) THEN
        status=nf90_inquire_dimension(ncid,dimid,len=kdm)
        CALL handle_ncerror(status)
        ALLOCATE(sigma(kdm),sigmahalf(kdm+1),sigma_bnds(2,kdm),
     .    sigmahalf_bnds(2,kdm+1),STAT=status)
        IF (status.NE.0) STOP 'cannot ALLOCATE enough memory (1b)'
        status=nf90_inq_varid(ncid,'sigma',rhid)
        CALL handle_ncerror(status)
        status=nf90_get_var(ncid,rhid,sigma)
        CALL handle_ncerror(status)
        sigma_bnds(1,1)=sigma(1)-0.5*(sigma(2)-sigma(1)) 
        sigma_bnds(2,1)=0.5*(sigma(2)+sigma(1)) 
        DO k=2,kdm-1 
          sigma_bnds(1,k)=0.5*(sigma(k)+sigma(k-1)) 
          sigma_bnds(2,k)=0.5*(sigma(k)+sigma(k+1)) 
        ENDDO
        sigma_bnds(1,kdm)=0.5*(sigma(kdm)+sigma(kdm-1))
        sigma_bnds(2,kdm)=sigma(kdm)+0.5*(sigma(kdm)-sigma(kdm-1)) 
        sigmahalf(1:kdm)=sigma_bnds(1,1:kdm) 
        sigmahalf(kdm+1)=sigma_bnds(2,kdm)
        sigmahalf_bnds(1,2:kdm+1)=sigma
        sigmahalf_bnds(2,1:kdm)=sigma
        sigmahalf_bnds(1,1)=sigmahalf(1)
        sigmahalf_bnds(2,kdm+1)=sigmahalf(kdm+1)
      ENDIF
c
      status=nf90_inq_dimid(ncid,'depth',dimid)
      IF (status.EQ.nf90_noerr) THEN
        status=nf90_inquire_dimension(ncid,dimid,len=ddm)
        CALL handle_ncerror(status)
        ALLOCATE(depth(ddm),depth_bnds(2,ddm),STAT=status)
        IF (status.NE.0) STOP 'cannot ALLOCATE enough memory (1c)'
        status=nf90_inq_varid(ncid,'depth',rhid)
        CALL handle_ncerror(status)
        status=nf90_get_var(ncid,rhid,depth)
        CALL handle_ncerror(status)
        status=nf90_inq_varid(ncid,'depth_bnds',rhid)
        CALL handle_ncerror(status)
        status=nf90_get_var(ncid,rhid,depth_bnds)
        CALL handle_ncerror(status)
      ENDIF
c
      WRITE(*,*) 'read lat'
      status=nf90_inq_dimid(ncid,'lat',dimid)
      IF (status.EQ.nf90_noerr) THEN
        status=nf90_inquire_dimension(ncid,dimid,len=ldm)
        CALL handle_ncerror(status)
        ALLOCATE(slat(ldm),slat_bnds(2,ldm),STAT=status)
        IF (status.NE.0) STOP 'cannot ALLOCATE enough memory (1c)'
        status=nf90_inq_varid(ncid,'lat',rhid)
        CALL handle_ncerror(status)
        status=nf90_get_var(ncid,rhid,slat)
        CALL handle_ncerror(status)
        slat_bnds(1,1)=slat(1)-0.5*(slat(2)-slat(1)) 
        slat_bnds(2,1)=0.5*(slat(2)+slat(1)) 
        DO j=2,ldm-1 
          slat_bnds(1,j)=0.5*(slat(j)+slat(j-1)) 
          slat_bnds(2,j)=0.5*(slat(j)+slat(j+1)) 
        ENDDO 
        slat_bnds(1,ldm)=0.5*(slat(ldm)+slat(ldm-1))
        slat_bnds(2,ldm)=slat(ldm)+0.5*(slat(ldm)-slat(ldm-1)) 
      ENDIF
c
      WRITE(*,*) 'read region'
      status=nf90_inq_varid(ncid,'region',rhid)
      IF (model_id.NE.'NorESM1-F'.AND.status.EQ.nf90_noerr) THEN
        status=nf90_inq_dimid(ncid,'region',dimid)
        CALL handle_ncerror(status)
        status=nf90_inquire_dimension(ncid,dimid,len=rdm)
        CALL handle_ncerror(status)
        status=nf90_inq_dimid(ncid,'slenmax',dimid)
        status=nf90_inquire_dimension(ncid,dimid,len=slenmax2)
        CALL handle_ncerror(status)
        ALLOCATE(region(slenmax2,rdm),region1(rdm),STAT=status)
        IF (status.NE.0) STOP 'cannot ALLOCATE enough memory (1d)'
        status=nf90_inq_varid(ncid,'region',rhid)
        CALL handle_ncerror(status)
        WRITE(*,*) 'read region',slenmax2,rdm,shape(region)
        status=nf90_get_var(ncid,rhid,region,(/1,1/),(/slenmax2,rdm/))
        CALL handle_ncerror(status)
        region1=' ' 
        DO i=1,rdm
          DO j=1,slenmax2 
            region1(i)(j:j)=region(j,i)
          ENDDO
        ENDDO 
      ELSE 
        status=nf90_open(TRIM(griddata)//TRIM(ocngridfile),nf90_nowrite,
     .  fid)
        CALL handle_ncerror(status)
        status=nf90_inq_dimid(fid,'region',dimid)
        CALL handle_ncerror(status)
        status=nf90_inquire_dimension(fid,dimid,len=rdm)
        CALL handle_ncerror(status)
        status=nf90_inq_dimid(fid,'slenmax',dimid)
        status=nf90_inquire_dimension(fid,dimid,len=slenmax2)
        CALL handle_ncerror(status)
        ALLOCATE(region(slenmax2,rdm),region1(rdm),STAT=status)
        IF (status.NE.0) STOP 'cannot ALLOCATE enough memory (1d)'
        status=nf90_inq_varid(fid,'region',rhid)
        CALL handle_ncerror(status)
        WRITE(*,*) 'read region',slenmax2,rdm,shape(region)
        status=nf90_get_var(fid,rhid,region,(/1,1/),(/slenmax2,rdm/))
        CALL handle_ncerror(status)
        status=nf90_close(fid)
        CALL handle_ncerror(status)
        region1=' '
        DO i=1,rdm
          DO j=1,slenmax2
            region1(i)(j:j)=region(j,i)
          ENDDO
        ENDDO
      ENDIF
c
      WRITE(*,*) 'read section'
      status=nf90_inq_varid(ncid,'section',rhid)
      IF (model_id.NE.'NorESM1-F'.AND.status.EQ.nf90_noerr) THEN
        status=nf90_inq_dimid(ncid,'section',dimid)
        CALL handle_ncerror(status)
        status=nf90_inquire_dimension(ncid,dimid,len=secdm)
        CALL handle_ncerror(status)
        status=nf90_inq_dimid(ncid,'slenmax',dimid)
        status=nf90_inquire_dimension(ncid,dimid,len=slenmax2)
        CALL handle_ncerror(status)
        ALLOCATE(section(slenmax2,secdm),section1(secdm),
     .    STAT=status)
        IF (status.NE.0) STOP 'cannot ALLOCATE enough memory (1d)'
        status=nf90_inq_varid(ncid,'section',rhid)
        CALL handle_ncerror(status)
        status=nf90_get_var(ncid,rhid,section,(/1,1/),
     .    (/slenmax2,secdm/))
        CALL handle_ncerror(status)
        section1=' '
        DO i=1,secdm
          s1=' '
          DO j=1,slenmax2
            s1(j:j)=section(j,i)  
          ENDDO
          IF (TRIM(s1).EQ.'equatorial_undercurrent') THEN    
            section1(i)='pacific_equatorial_undercurrent'
          ELSEIF (TRIM(s1).EQ.'florida_bahamas') THEN  
            section1(i)='florida_bahamas_strait'
          ELSEIF (TRIM(s1).EQ.'taiwan_and_luzon_straits') THEN  
            section1(i)='taiwan_luzon_straits'
          ELSE
            section1(i)=TRIM(s1)
          ENDIF
          k=k+1
        ENDDO
      ELSE
        status=nf90_open(TRIM(griddata)//TRIM(ocngridfile),nf90_nowrite,
     .  fid)
        CALL handle_ncerror(status)
        status=nf90_inq_dimid(fid,'section',dimid)
        CALL handle_ncerror(status)
        status=nf90_inquire_dimension(fid,dimid,len=secdm)
        CALL handle_ncerror(status)
        status=nf90_inq_dimid(fid,'slenmax',dimid)
        status=nf90_inquire_dimension(fid,dimid,len=slenmax2)
        CALL handle_ncerror(status)
        ALLOCATE(section(slenmax2,secdm),section1(secdm),
     .    STAT=status)
        IF (status.NE.0) STOP 'cannot ALLOCATE enough memory (1d)'
        status=nf90_inq_varid(fid,'section',rhid)
        CALL handle_ncerror(status)
        status=nf90_get_var(fid,rhid,section,(/1,1/),
     .    (/slenmax2,secdm/))
        CALL handle_ncerror(status)
        status=nf90_close(fid)
        CALL handle_ncerror(status)
        section1=' '
        DO i=1,secdm
          s1=' '
          DO j=1,slenmax2
            s1(j:j)=section(j,i)
          ENDDO
          IF (TRIM(s1).EQ.'equatorial_undercurrent') THEN
            section1(i)='pacific_equatorial_undercurrent'
          ELSEIF (TRIM(s1).EQ.'florida_bahamas') THEN
            section1(i)='florida_bahamas_strait'
          ELSEIF (TRIM(s1).EQ.'taiwan_and_luzon_straits') THEN
            section1(i)='taiwan_luzon_straits'
          ELSE
            section1(i)=TRIM(s1)
          ENDIF
          k=k+1
        ENDDO
      ENDIF
c
c --- Read calendar information (change reference year)
      status=nf90_inq_varid(ncid,'time',rhid)
      CALL handle_ncerror(status)
      status=nf90_get_att(ncid,rhid,'calendar',calendar)
      CALL handle_ncerror(status)
      status=nf90_get_att(ncid,rhid,'units',calunits)
      CALL handle_ncerror(status)
      READ(calunits(12:15),'(i4.4)') exprefyear 
c
c --- Close first file
      status=nf90_close(ncid)
      CALL handle_ncerror(status)
c
c --- Read longitudes, latitudes
      ALLOCATE(parea(idm,jdm),pmask(idm,jdm),pdepth(idm,jdm),
     .  plon(idm,jdm),plat(idm,jdm),bpini(idm,jdm),bpinit(idm,jdm),
     .  ulon(idm,jdm),ulat(idm,jdm),vlon(idm,jdm),vlat(idm,jdm),
     .  plon_crns(idm,jdm,ncrns),plat_crns(idm,jdm,ncrns),
     .  ulon_crns(idm,jdm,ncrns),ulat_crns(idm,jdm,ncrns),
     .  vlon_crns(idm,jdm,ncrns),vlat_crns(idm,jdm,ncrns),
     .  plon_crnsp(ncrns,idm,jdm),plat_crnsp(ncrns,idm,jdm),
     .  ulon_crnsp(ncrns,idm,jdm),ulat_crnsp(ncrns,idm,jdm),
     .  vlon_crnsp(ncrns,idm,jdm),vlat_crnsp(ncrns,idm,jdm),
     .  sealv(idm,jdm),xvec(idm),yvec(jdm),kvec(kdm),pbot(idm,jdm),
     .  dzini(idm,jdm,kdm),sini(idm,jdm,kdm),tini(idm,jdm,kdm),
     .  kvechalf(kdm+1),uscaley(idm,jdm),vscalex(idm,jdm),
     .  udepth(idm,jdm),vdepth(idm,jdm),basin(idm,jdm),STAT=status) 
      IF (status.NE.0) STOP 'cannot ALLOCATE enough memory (1)'
c
      FORALL (i=1:idm) xvec(i)=i 
      FORALL (j=1:jdm) yvec(j)=j 
      FORALL (k=1:kdm) kvec(k)=k-0.5
      FORALL (k=1:kdm+1) kvechalf(k)=k-1 
c
c --- Open grid file 
      status=nf90_open(TRIM(griddata)//TRIM(ocngridfile),nf90_nowrite,
     .  ncid) 
      CALL handle_ncerror(status)
c
c --- Read grid cell mask, area and bathymetry
      status=nf90_inq_varid(ncid,'pdepth',rhid) 
      CALL handle_ncerror(status)
      status=nf90_get_var(ncid,rhid,pdepth)
      CALL handle_ncerror(status)
      status=nf90_inq_varid(ncid,'udepth',rhid) 
      CALL handle_ncerror(status)
      status=nf90_get_var(ncid,rhid,udepth)
      CALL handle_ncerror(status)
      status=nf90_inq_varid(ncid,'vdepth',rhid) 
      CALL handle_ncerror(status)
      status=nf90_get_var(ncid,rhid,vdepth)
      CALL handle_ncerror(status)
      status=nf90_inq_varid(ncid,'pmask',rhid) 
      CALL handle_ncerror(status)
      status=nf90_get_var(ncid,rhid,pmask)
      CALL handle_ncerror(status)
      status=nf90_inq_varid(ncid,'parea',rhid) 
      CALL handle_ncerror(status)
      status=nf90_get_var(ncid,rhid,parea)
      CALL handle_ncerror(status)
      status=nf90_inq_varid(ncid,'udy',rhid) 
      CALL handle_ncerror(status)
      status=nf90_get_var(ncid,rhid,uscaley)
      CALL handle_ncerror(status)
      status=nf90_inq_varid(ncid,'vdx',rhid) 
      CALL handle_ncerror(status)
      status=nf90_get_var(ncid,rhid,vscalex)
      CALL handle_ncerror(status)
      parea=parea*pmask
c
c --- Compute global ocean volume and area
      voglb=SUM(parea*pdepth)
      aoglb=SUM(parea)
c
c --- Read coordinates
      status=nf90_inq_varid(ncid,'plon',rhid) 
      CALL handle_ncerror(status)
      status=nf90_get_var(ncid,rhid,plon)
      CALL handle_ncerror(status)
      status=nf90_inq_varid(ncid,'plat',rhid) 
      CALL handle_ncerror(status)
      status=nf90_get_var(ncid,rhid,plat)
      CALL handle_ncerror(status)
      status=nf90_inq_varid(ncid,'ulon',rhid) 
      CALL handle_ncerror(status)
      status=nf90_get_var(ncid,rhid,ulon)
      CALL handle_ncerror(status)
      status=nf90_inq_varid(ncid,'ulat',rhid) 
      CALL handle_ncerror(status)
      status=nf90_get_var(ncid,rhid,ulat)
      CALL handle_ncerror(status)
      status=nf90_inq_varid(ncid,'vlon',rhid)
      CALL handle_ncerror(status)
      status=nf90_get_var(ncid,rhid,vlon)
      CALL handle_ncerror(status)
      status=nf90_inq_varid(ncid,'vlat',rhid)
      CALL handle_ncerror(status)
      status=nf90_get_var(ncid,rhid,vlat)
      CALL handle_ncerror(status)
c
c --- Read grid cell vertices 
      status=nf90_inq_varid(ncid,'pclon',rhid) 
      CALL handle_ncerror(status)
      status=nf90_get_var(ncid,rhid,plon_crns)
      CALL handle_ncerror(status)
      status=nf90_inq_varid(ncid,'pclat',rhid) 
      CALL handle_ncerror(status)
      status=nf90_get_var(ncid,rhid,plat_crns)
      CALL handle_ncerror(status)
      status=nf90_inq_varid(ncid,'uclon',rhid) 
      CALL handle_ncerror(status)
      status=nf90_get_var(ncid,rhid,ulon_crns)
      CALL handle_ncerror(status)
      status=nf90_inq_varid(ncid,'uclat',rhid) 
      CALL handle_ncerror(status)
      status=nf90_get_var(ncid,rhid,ulat_crns)
      CALL handle_ncerror(status)
      status=nf90_inq_varid(ncid,'vclon',rhid)
      CALL handle_ncerror(status)
      status=nf90_get_var(ncid,rhid,vlon_crns)
      CALL handle_ncerror(status)
      status=nf90_inq_varid(ncid,'vclat',rhid)
      CALL handle_ncerror(status)
      status=nf90_get_var(ncid,rhid,vlat_crns)
      CALL handle_ncerror(status)
c
c --- Permute to compensate for dimension bug in CMOR
      DO j=1,jdm 
        DO i=1,idm 
          DO n=1,ncrns
              plon_crnsp(n,i,j)=plon_crns(i,j,n)             
              plat_crnsp(n,i,j)=plat_crns(i,j,n)             
              ulon_crnsp(n,i,j)=ulon_crns(i,j,n)             
              ulat_crnsp(n,i,j)=ulat_crns(i,j,n)     
              vlon_crnsp(n,i,j)=vlon_crns(i,j,n)             
              vlat_crnsp(n,i,j)=vlat_crns(i,j,n)     
              IF (plon_crnsp(n,i,j).LT.0.)
     .          plon_crnsp(n,i,j)=plon_crnsp(n,i,j)+360                 
              IF (ulon_crnsp(n,i,j).LT.0.)
     .          ulon_crnsp(n,i,j)=ulon_crnsp(n,i,j)+360                 
              IF (vlon_crnsp(n,i,j).LT.0.)
     .          vlon_crnsp(n,i,j)=vlon_crnsp(n,i,j)+360                 
          ENDDO 
          IF (plon(i,j).LT.0.) plon(i,j)=plon(i,j)+360                 
          IF (ulon(i,j).LT.0.) ulon(i,j)=ulon(i,j)+360                 
          IF (vlon(i,j).LT.0.) vlon(i,j)=vlon(i,j)+360                 
        ENDDO 
      ENDDO
c
c --- Close grid file 
      status=nf90_close(ncid)
      CALL handle_ncerror(status)
c
c --- Read initial layer profile from inicon.nc
      status=nf90_open(TRIM(griddata)//TRIM(ocninitfile),nf90_nowrite,
     .  ncid) 
      CALL handle_ncerror(status)
c
      status=nf90_inq_varid(ncid,'dz',rhid)
      CALL handle_ncerror(status)
      status=nf90_get_var(ncid,rhid,dzini)
      CALL handle_ncerror(status)
      status=nf90_inq_varid(ncid,'saln',rhid)
      CALL handle_ncerror(status)
      status=nf90_get_var(ncid,rhid,sini)
      CALL handle_ncerror(status)
      status=nf90_inq_varid(ncid,'temp',rhid)
      CALL handle_ncerror(status)
      status=nf90_get_var(ncid,rhid,tini)
      CALL handle_ncerror(status)
c
      status=nf90_close(ncid)
      CALL handle_ncerror(status)
c
c --- Compute initial bottom pressure
      bpini=0.
      bpinit=0. 
      DO j=1,jdm 
        DO i=1,idm 
          IF (pmask(i,j).GT.0.5) THEN  
            phil=0.
            DO k=1,kdm 
              phiu=phil
              phil=phiu-1e+4*g*dzini(i,j,k)
              bpini(i,j)=getlpi(tini(i,j,k),sini(i,j,k),phiu,phil,
     .          bpini(i,j))
              bpinit(i,j)=getlpi(tini(i,j,k),35.,phiu,phil,bpinit(i,j))
            ENDDO
          ENDIF
        ENDDO
      ENDDO
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
      INTEGER :: i,j,k,n,ndims,dimids(ndimmax),dimlens(ndimmax)
      CHARACTER(len=slenmax) :: coord,ivnm1,ivnm2,ivnm3,ivnm4,ivnm5,
     .  ivnm6
c
      REAL(KIND=8), ALLOCATABLE   :: tmp1d(:),tmp2d(:,:)
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
      status=nf90_inq_varid(ncid,TRIM(ivnm1),rhid)
      IF (status.NE.nf90_noerr) THEN
        WRITE(*,*) 'cannot find input variable ',TRIM(ivnm1)
        STOP
      ENDIF
      status=nf90_inquire_variable(ncid,rhid,ndims=ndims)
      CALL handle_ncerror(status)
      status=nf90_inquire_variable(ncid,rhid,dimids=dimids(1:ndims))
      CALL handle_ncerror(status)
      dimlens=1
      DO n=1,ndims
        status=nf90_inquire_dimension(ncid,dimids(n),len=dimlens(n))
        CALL handle_ncerror(status)
      ENDDO
      IF (.NOT.ALLOCATED(dp)) ALLOCATE(dp(idm,jdm,kdm))
      IF (ALLOCATED(fld)) DEALLOCATE(fld,fld2,fldacc,fldtmp)
      ii=idm
      jj=jdm
      kk=kdm
      IF (dimlens(3).EQ.kdm.AND.kdm.GT.0) THEN
        vtype='layer'
      ELSEIF (dimlens(3).EQ.ddm.AND.ddm.GT.0.OR.
     .  INDEX(special,'volcello').GT.0.OR.
     .  INDEX(special,'thkcello').GT.0.OR.
     .  INDEX(special,'masscello').GT.0) THEN
        vtype='level'
        kk=ddm
      ELSEIF (dimlens(1).EQ.idm.AND.dimlens(2).EQ.jdm.AND.ndims.LE.3)
     .  THEN
        vtype='2d'
        kk=1
      ELSEIF (dimlens(1).EQ.ldm.AND.dimlens(2).EQ.kdm) THEN
        vtype='merk'
        ii=ldm
        kk=rdm
      ELSEIF (dimlens(1).EQ.ldm.AND.dimlens(2).EQ.ddm) THEN
        vtype='merd'
        ii=ldm
        jj=ddm
        kk=rdm
      ELSEIF (dimlens(1).EQ.ldm.AND.dimlens(2).EQ.rdm) THEN
        vtype='mert'
        ii=ldm
        jj=rdm
        kk=1
      ELSEIF (dimlens(1).EQ.secdm.AND.ndims.EQ.2) THEN
        vtype='sect'
        ii=secdm
        jj=1
        kk=1
      ELSEIF (dimlens(1).EQ.1.AND.ndims.EQ.1) THEN
        vtype='1d'
        ii=1
        jj=1
        kk=1
      ENDIF
      ALLOCATE(fld(ii,jj,kk),fld2(ii,jj,kk),fldacc(ii,jj,kk),
     .    fldtmp(ii,jj,kk),STAT=status)
      IF (status.NE.0) STOP 'cannot ALLOCATE enough memory (4)'
      IF (INDEX(special,'half').GT.0) THEN
        IF (ALLOCATED(fldhalf)) DEALLOCATE(fldhalf)
        ALLOCATE(fldhalf(idm,jdm,kdm+1),STAT=status)
        IF (status.NE.0) STOP 'cannot ALLOCATE enough memory (5)'
      ENDIF
c 
      IF (LEN_TRIM(vunits).EQ.0) THEN
        status=nf90_get_att(ncid,rhid,'units',vunits)
        CALL handle_ncerror(status)
        IF (TRIM(vunits).EQ.'mm/s') vunits='kg m-2 s-1'
      END IF 
c
      coord=' '
      status=nf90_get_att(ncid,rhid,'coordinates',coord)
      IF (status.NE.nf90_noerr) coord(1:1)=ivnm(1:1)
c
      status=nf90_close(ncid)
      CALL handle_ncerror(status)
c
c --- Derive path of CMOR table 
      IF (TRIM(vtype).EQ.'layer'.AND..NOT.
     .  (lsumz.OR.INDEX(special,'glbave').GT.0
     .  .OR.INDEX(special,'2zos').GT.0
     .  .OR.INDEX(special,'level1').GT.0)) THEN
#ifdef CMOR3
        tablepath=TRIM(tabledir)//TRIM(table)
#else 
        tablepath=TRIM(tabledir)//TRIM(table)//TRIM(rhotablesuff)
#endif
      ELSE
        tablepath=TRIM(tabledir)//TRIM(table)
      ENDIF
c
c --- Inquire time dimension of output variable 
      IF (.NOT.fxflag) CALL get_timecoord(TRIM(tablepath),ovnm,tcoord)
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
c --- Derive path to CMOR table 
      IF (TRIM(vtype).EQ.'layer'.AND..NOT.
     .  (lsumz.OR.INDEX(special,'glbave').GT.0
     .  .OR.INDEX(special,'2zos').GT.0 
     .  .OR.INDEX(special,'level1').GT.0)) THEN
#ifdef CMOR3
        tablepath=TRIM(tabledir)//TRIM(table)
#else 
        tablepath=TRIM(tabledir)//TRIM(table)//TRIM(rhotablesuff)
#endif 
      ELSE
        tablepath=TRIM(tabledir)//TRIM(table)
      ENDIF
c
c --- Define output dataset 
#ifdef CMOR3
      grid_label=ocngrid_label
      grid=TRIM(ocngrid) 
      IF (TRIM(vtype).EQ.'layer'.AND..NOT.
     .  (lsumz.OR.INDEX(special,'glbave').GT.0
     .  .OR.INDEX(special,'2zos').GT.0 
     .  .OR.INDEX(special,'level1').GT.0)) THEN
        grid=TRIM(ocngrid)//', vertical density coordinate' 
      ELSE 
        IF (INDEX(special,'glbave').GT.0
     .     .OR.INDEX(special,'2zos').GT.0) THEN 
          grid_label='gm'
          grid='global mean or integral'  
        ELSE
          IF (vtype(1:3).EQ.'mer'.OR.ovnm(1:7).EQ.'hfbasin') THEN 
            grid_label='grz' 
            grid='zonal mean or integral'  
          ELSEIF (TRIM(vtype).EQ.'level') THEN 
            grid_label='gr' 
            grid=TRIM(ocngrid)//', interpolated to z-levels'
          ENDIF 
        ENDIF 
      ENDIF 
      CALL write_namelist_json(grid,grid_label,ocngrid_resolution,ovnm)
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
      write(*,*) 'Define horizontal axes'
      IF (vtype(1:3).NE.'mer'.AND.vtype(1:3).NE.'sec') THEN
        iaxid=cmor_axis(
     .    table           = TRIM(tabledir)//TRIM(tgrids),  
     .    table_entry     = 'i_index',
     .    units           = '1',
     .    length          = idm,
     .    coord_vals      = xvec)
        jaxid=cmor_axis(
     .    table           = TRIM(tabledir)//TRIM(tgrids),
     .    table_entry     = 'j_index',
     .    units           = '1',
     .    length          = jdm,
     .    coord_vals      = yvec)
c
        write(*,*) 'Define horizontal grid '//coord(1:1)
        IF (coord(1:1).EQ.'p') THEN
          grdid=cmor_grid(
     .      axis_ids=(/iaxid,jaxid/),
     .      latitude=plat,
     .      longitude=plon,
     .    latitude_vertices=plat_crnsp,
     .    longitude_vertices=plon_crnsp)
        ELSEIF (coord(1:1).EQ.'u') THEN
          grdid=cmor_grid( 
     .      axis_ids=(/iaxid,jaxid/),
     .      latitude=ulat,
     .      longitude=ulon,
     .      latitude_vertices=ulat_crnsp,
     .      longitude_vertices=ulon_crnsp)
        ELSEIF (coord(1:1).EQ.'v') THEN
          grdid=cmor_grid(
     .      axis_ids=(/iaxid,jaxid/),
     .      latitude=vlat,
     .      longitude=vlon,
     .      latitude_vertices=vlat_crnsp,
     .      longitude_vertices=vlon_crnsp)
        ENDIF
      ENDIF 
c
      IF (vtype(1:3).EQ.'mer') THEN
        laxid=cmor_axis(
     .    table           = TRIM(tablepath),
     .    table_entry     = 'latitude',
     .    units           = 'degrees_north',
     .    length          = ldm,
     .    coord_vals      = slat,
     .    cell_bounds     = slat_bnds)
        raxid=cmor_axis(
     .    table           = TRIM(tablepath),
     .    table_entry     = 'basin',
     .    units           = '1',
     .    coord_vals      = region1)
      ENDIF            
c
c --- Define vertical axis 
      IF (TRIM(vtype).EQ.'layer'.AND..NOT.
     .  (lsumz.OR.INDEX(special,'glbave').GT.0
     .  .OR.INDEX(special,'2zos').GT.0
     .  .OR.INDEX(special,'level1').GT.0)) THEN 
        IF (INDEX(special,'half').GT.0) THEN 
#ifdef CMOR3
          kaxid=cmor_axis(
     .      table           = TRIM(tablepath),
     .      table_entry     = 'rho',
     .      units           = 'kg m-3',
     .      length          = kdm+1,
     .      coord_vals      = 1000.+sigmahalf,
     .      cell_bounds     = 1000.+sigmahalf_bnds)
#else 
          kaxid=cmor_axis(
     .      table           = TRIM(tablepath),
     .      table_entry     = 'olev',
     .      units           = '1',
     .      length          = kdm+1,
     .      coord_vals      = kvechalf)
#endif 
        ELSE
#ifdef CMOR3
          kaxid=cmor_axis(
     .      table           = TRIM(tablepath),
     .      table_entry     = 'rho',
     .      units           = 'kg m-3',
     .      length          = kdm,
     .      coord_vals      = 1000.+sigma,
     .      cell_bounds     = 1000.+sigma_bnds)
#else 
          kaxid=cmor_axis(
     .      table           = TRIM(tablepath),
     .      table_entry     = 'olev',
     .      units           = '1',
     .      length          = kdm,
     .      coord_vals      = kvec(1:kdm))
#endif 
        ENDIF
      ELSEIF (INDEX(special,'level1').GT.0) THEN 
        kaxid=cmor_axis(
     .    table           = TRIM(tablepath),
     .    table_entry     = 'depth0m',
     .    units           = 'm',
     .    length          = 1,
     .    coord_vals      = (/0/))
      ELSEIF (INDEX(special,'dzavg300').GT.0) THEN 
        kaxid=cmor_axis(
     .    table           = TRIM(tablepath),
     .    table_entry     = 'depth300m',
     .    units           = 'm',
     .    length          = 1,
     .    coord_vals      = (/150./),
     .    cell_bounds     = (/0.,300./))
      ELSEIF (INDEX(special,'dzavg700').GT.0) THEN 
        kaxid=cmor_axis(
     .    table           = TRIM(tablepath),
     .    table_entry     = 'depth700m',
     .    units           = 'm',
     .    length          = 1,
     .    coord_vals      = (/350./),
     .    cell_bounds     = (/0.,700./))
      ELSEIF (INDEX(special,'dzavg2000').GT.0) THEN 
        kaxid=cmor_axis(
     .    table           = TRIM(tablepath),
     .    table_entry     = 'depth2000m',
     .    units           = 'm',
     .    length          = 1,
     .    coord_vals      = (/1000./),
     .    cell_bounds     = (/0.,2000./))
      ELSEIF (TRIM(vtype).EQ.'level'.OR.vtype(1:4).EQ.'merd') THEN
        kaxid=cmor_axis(
     .    table           = TRIM(tablepath),
     .    table_entry     = 'depth_coord',
     .    units           = 'm',
     .    length          = ddm,
     .    coord_vals      = depth,
     .    cell_bounds     = depth_bnds)
      ELSEIF (vtype(1:4).EQ.'merk') THEN
        kaxid=cmor_axis(
     .    table           = TRIM(tablepath),
     .    table_entry     = 'rho',
     .    units           = 'kg m-3',
     .    length          = kdm,
     .    coord_vals      = sigma+1000.,
     .    cell_bounds     = sigma_bnds+1000.)
      ELSEIF (TRIM(zcoord).EQ.'olevel') THEN
        ALLOCATE (tmp1d(1),tmp2d(2,1))
        tmp1d(:) = (/5.d0/)
        tmp2d(:,1) = (/0.d0,10.d0/)
        kaxid=cmor_axis(
     .    table           = TRIM(tablepath),
     .    table_entry     = 'depth_coord',
     .    units           = 'm',
     .    length          = 1,
     .    coord_vals      = tmp1d, !(/5.d0/),
     .    cell_bounds     = tmp2d ) !reshape((/0.d0,10.d0/),(/2,1/)))
        DEALLOCATE(tmp1d,tmp2d)
        ELSEIF (vtype(1:3).EQ.'sec') THEN
        saxid=cmor_axis(
     .    table           = TRIM(tablepath),
     .    table_entry     = 'oline',
     .    units           = '1',
     .    coord_vals      = section1) 
      ENDIF
c   
c --- Define time axis 
      IF (.NOT.fxflag) THEN
        write(*,*) 'Define time axis ' 
          taxid=cmor_axis(
     .      table          = TRIM(tablepath),
     .      table_entry    = TRIM(tcoord),
     .      units          = TRIM(calunits),
     .      length         = 1)
      ENDIF 
c
c --- Define output variable
      write(*,*) 'Define output variable'
      IF (fxflag) THEN 
        IF ((TRIM(vtype).EQ.'2d'.AND..NOT.(TRIM(zcoord).EQ.'olevel'.OR.
     .    INDEX(special,'glbave').GT.0.OR.INDEX(special,'2zos').GT.0.))
     .    .OR.lsumz) THEN
          varid=cmor_variable(
     .      table          = TRIM(tablepath),
     .      table_entry    = TRIM(ovnm),
     .      units          = TRIM(vunits),
     .      axis_ids       = (/grdid/),
     .      missing_value  = 1e20,
     .      comment        = TRIM(vcomment),
     .      original_name  = TRIM(ivnm))
        ELSEIF (INDEX(special,'glbave').GT.0
     .    .OR.INDEX(special,'2zos').GT.0.) THEN
          varid=cmor_variable(
     .      table          = TRIM(tablepath),
     .      table_entry    = TRIM(ovnm),
     .      units          = TRIM(vunits),
     .      axis_ids       = (/taxid/),
     .      original_name  = TRIM(ivnm),
     .      missing_value  = 1e20,
     .      comment        = TRIM(vcomment),
     .      positive       = TRIM(vpositive))
        ELSE
          varid=cmor_variable(
     .      table          = TRIM(tablepath),
     .      table_entry    = TRIM(ovnm),
     .      units          = TRIM(vunits),
     .      axis_ids       = (/grdid,kaxid/),
     .      missing_value  = 1e20,
     .      comment        = TRIM(vcomment),
     .      original_name  = TRIM(ivnm))
        ENDIF
      ELSE
        IF ((TRIM(vtype).EQ.'2d'.AND..NOT.(TRIM(zcoord).EQ.'olevel'.OR.
     .    INDEX(special,'glbave').GT.0.OR.INDEX(special,'2zos').GT.0.
     .  )).OR.lsumz.AND..NOT.INDEX(special,'glbave').GT.0
     .    .OR.INDEX(special,'lvl2srf').GT.0
     .    .OR.INDEX(special,'locmin').GT.0
     .    .OR.INDEX(special,'dpint').GT.0
     .    .OR.INDEX(special,'dpavg').GT.0
     .    .OR.INDEX(special,'omega2z').GT.0) THEN 
          varid=cmor_variable(
     .      table          = TRIM(tablepath),
     .      table_entry    = TRIM(ovnm),
     .      units          = TRIM(vunits),
     .      axis_ids       = (/grdid,taxid/),
     .      original_name  = TRIM(ivnm),
     .      missing_value  = 1e20, 
     .      comment        = TRIM(vcomment),
     .      positive       = TRIM(vpositive))
        ELSEIF (INDEX(special,'dzavg').GT.0.) THEN
          varid=cmor_variable(
     .      table          = TRIM(tablepath),
     .      table_entry    = TRIM(ovnm),
     .      units          = TRIM(vunits),
     .      axis_ids       = (/grdid,taxid,kaxid/),
     .      original_name  = TRIM(ivnm),
     .      missing_value  = 1e20, 
     .      comment        = TRIM(vcomment),
     .      positive       = TRIM(vpositive))
        ELSEIF (TRIM(vtype).EQ.'layer'.AND..NOT.(TRIM(ovnm).EQ.'zfull'
     .    .OR.TRIM(ovnm).EQ.'half'.OR.INDEX(special,'glbave').GT.0
     .    .OR.INDEX(special,'2zos').GT.0.)) THEN
          varid=cmor_variable(
     .      table          = TRIM(tablepath),
     .      table_entry    = TRIM(ovnm),
     .      units          = TRIM(vunits),
     .      axis_ids       = (/grdid,kaxid,taxid/),
     .      original_name  = TRIM(ivnm),
     .      missing_value  = 1e20,
     .      positive       = TRIM(vpositive),
     .      comment        = 'Please note that the layer depth '
     .                     //'information is stored '
     .                     //'separately in "zfull" '
     .                     //'and "zhalf" while approximate layer '
     .                     //'density values are stored together '
     .                     //'with "msftmrhoz". '//TRIM(vcomment))
        ELSEIF (vtype(1:4).EQ.'merd'.OR.vtype(1:4).EQ.'merk') THEN
          varid=cmor_variable(
     .      table          = TRIM(tablepath),
     .      table_entry    = TRIM(ovnm),
     .      units          = TRIM(vunits),
     .      axis_ids       = (/laxid,kaxid,raxid,taxid/),
     .      original_name  = TRIM(ivnm),
     .      missing_value  = 1e20, 
     .      comment        = TRIM(vcomment),
     .      positive       = TRIM(vpositive))
        ELSEIF (vtype(1:4).EQ.'mert') THEN 
          varid=cmor_variable(
     .      table          = TRIM(tablepath),
     .      table_entry    = TRIM(ovnm),
     .      units          = TRIM(vunits),
     .      axis_ids       = (/laxid,raxid,taxid/),
     .      original_name  = TRIM(ivnm),
     .      missing_value  = 1e20, 
     .      comment        = TRIM(vcomment),
     .      positive       = TRIM(vpositive))
        ELSEIF (vtype(1:4).EQ.'sect') THEN 
          varid=cmor_variable(
     .      table          = TRIM(tablepath),
     .      table_entry    = TRIM(ovnm),
     .      units          = TRIM(vunits),
     .      axis_ids       = (/saxid,taxid/),
     .      original_name  = TRIM(ivnm),
     .      missing_value  = 1e20, 
     .      comment        = TRIM(vcomment),
     .      positive       = TRIM(vpositive))
        ELSEIF (INDEX(special,'glbave').GT.0
     .    .OR.INDEX(special,'2zos').GT.0.) THEN
          varid=cmor_variable(
     .      table          = TRIM(tablepath),
     .      table_entry    = TRIM(ovnm),
     .      units          = TRIM(vunits),
     .      axis_ids       = (/taxid/),
     .      original_name  = TRIM(ivnm),
     .      missing_value  = 1e20,
     .      comment        = TRIM(vcomment),
     .      positive       = TRIM(vpositive))
        ELSE 
          varid=cmor_variable(
     .      table          = TRIM(tablepath),
     .      table_entry    = TRIM(ovnm),
     .      units          = TRIM(vunits),
     .      axis_ids       = (/grdid,kaxid,taxid/),
     .      original_name  = TRIM(ivnm),
     .      missing_value  = 1e20, 
     .      comment        = TRIM(vcomment),
     .      positive       = TRIM(vpositive))
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
      status=cmor_close(varid,fnmo,1)
      IF (status.NE.0) STOP 'problem closing CMOR output file'
c
      END SUBROUTINE close_ofile



      SUBROUTINE read_field
c
      IMPLICIT NONE
c
      REAL :: fac1,fac2,fac3,fac4,fac5,fac6
      INTEGER :: i,j,k,ind
      CHARACTER(len=slenmax) :: coord,ivnm1,ivnm2,ivnm3,ivnm4,ivnm5,
     .  ivnm6
c
c --- Open input file 
      status=nf90_open(fnm,nf90_nowrite,ncid)
      CALL handle_ncerror(status)
c
c --- Read data
      IF (INDEX(special,'glbave3d').GT.0) THEN 
        fld=0. 
        s1='dp'
        CALL add_fixed(s1,1.,ncid)
        DO k=1,kk
          DO j=1,jj
            DO i=1,ii 
              IF (fld(i,j,k).EQ.1e20) THEN 
                dp(i,j,k)=0.
              ELSE
                dp(i,j,k)=fld(i,j,k)
              ENDIF
            ENDDO
          ENDDO 
        ENDDO 
      ENDIF 
c
      CALL resolve_vnm(slenmax,ivnm,ivnm1,ivnm2,ivnm3,ivnm4,ivnm5,ivnm6,
     .  fac1,fac2,fac3,fac4,fac5,fac6)
      fld=0.
      CALL add_fixed(ivnm1,fac1,ncid)
      IF (INDEX(special,'volcello').GT.0) THEN
        fld2=fld
        fld=0. 
      ENDIF 
      CALL add_fixed(ivnm2,fac2,ncid)
      CALL add_fixed(ivnm3,fac3,ncid)
      CALL add_fixed(ivnm4,fac4,ncid)
      CALL add_fixed(ivnm5,fac5,ncid)
      CALL add_fixed(ivnm6,fac6,ncid)
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
      INTEGER :: ind,rec,rec1,i,j,k
      INTEGER, SAVE :: fid
      CHARACTER(LEN=*), INTENT(IN), OPTIONAL :: fname
      CHARACTER(len=slenmax) :: ivnm1,ivnm2,ivnm3,ivnm4,ivnm5,
     .  ivnm6
      LOGICAL :: badrec
c
c --- Exception for fill day
      rec1=max(rec,1)
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
      status=nf90_inq_varid(fid,'time',rhid)
      IF (status.NE.nf90_noerr) THEN
        WRITE(*,*) 'cannot find time variable'
        STOP
      ENDIF 
      status=nf90_get_var(fid,rhid,tval,(/rec1/),(/1/))
      CALL handle_ncerror(status)
      IF (rec.EQ.0) tval=tval-1
c 
c --- Guess time bounds 
c     IF (itag.EQ.tagoyr.OR.itag.EQ.tagoyrbgc) THEN 
c       tbnds(1,1)=tval(1)-365*0.5       
c       tbnds(2,1)=tval(1)+365*0.5       
c     ELSEIF (itag.EQ.tagomon.OR.itag.EQ.tagomonbgc) THEN 
c       recompute micom's time stamp 
c       tval=(year-refyear)*365+days(month)+lom(month)*0.5
c       tbnds(1,1)=tval(1)-lom(month)*0.5       
c       tbnds(2,1)=tval(1)+lom(month)*0.5
c     ELSE
c       tbnds(1,1)=tval(1)-0.5      
c       tbnds(2,1)=tval(1)+0.5
c     ENDIF
c
c --- correct erroneous intial time bound
      tbnds(1,1)=max(0.,tbnds(1,1))
      tval=0.5*(tbnds(1,1)+tbnds(2,1))
      END IF
c
c --- Read data 
      IF (INDEX(special,'glbave3d').GT.0.OR.
     .  (INDEX(special,'2rho').GT.0.AND.vtype.EQ.'layer')
     .  .OR.INDEX(special,'2zos').GT.0) THEN 
        fld=0. 
        s1='dp'
        CALL add_tslice(s1,1.,rec1,fid)  
        DO k=1,kk 
          DO j=1,jj 
            DO i=1,ii 
              IF (fld(i,j,k).EQ.1e20) then 
                dp(i,j,k)=0.
              ELSE
                dp(i,j,k)=fld(i,j,k)
              ENDIF
            ENDDO
          ENDDO 
        ENDDO
c --- - Compute rescaled dp 
        IF (INDEX(special,'2zoss').GT.0) THEN
          DO j=1,jdm
            DO i=1,idm 
              IF (pmask(i,j).GT.0.5) 
     .          dp(i,j,:)=dp(i,j,:)*bpini(i,j)/SUM(dp(i,j,:))
            ENDDO
          ENDDO
        ELSEIF (INDEX(special,'2zost').GT.0) THEN
          DO j=1,jdm
            DO i=1,idm 
              IF (pmask(i,j).GT.0.5) 
     .          dp(i,j,:)=dp(i,j,:)*bpinit(i,j)/SUM(dp(i,j,:))
            ENDDO
          ENDDO
        ENDIF 
      ENDIF 
c
      CALL resolve_vnm(slenmax,ivnm,ivnm1,ivnm2,ivnm3,ivnm4,ivnm5,ivnm6,
     .  fac1,fac2,fac3,fac4,fac5,fac6)
      IF (INDEX(special,'2rho').GT.0.OR.INDEX(special,'2zoss').GT.0.OR.
     . INDEX(special,'strmf').GT.0.OR.INDEX(special,'Xfield2').GT.0.OR.
     . INDEX(special,'Dfield2').GT.0.OR.INDEX(special,'dpint').GT.0.OR.
     . INDEX(special,'dpavg').GT.0) THEN
        fld=0.
        CALL add_tslice(ivnm2,fac2,rec1,fid)
        fld2=fld
        fld=0.
        CALL add_tslice(ivnm1,fac1,rec1,fid)
        IF (INDEX(special,'strmf').GT.0) THEN
          fldtmp=0.
          CALL strmf_eval(idm,jdm,kdm,fld,fld2,fldtmp)
          fld=fldtmp 
        ENDIF 
      ELSE
        fld=0. 
        CALL add_tslice(ivnm1,fac1,rec1,fid)  
        CALL add_tslice(ivnm2,fac2,rec1,fid)  
        CALL add_tslice(ivnm3,fac3,rec1,fid)  
        CALL add_tslice(ivnm4,fac4,rec1,fid)  
        CALL add_tslice(ivnm5,fac5,rec1,fid)  
        CALL add_tslice(ivnm6,fac6,rec1,fid)  
      ENDIF
c
c --- Read sea level height if necessary 
      IF (INDEX(special,'dz2').GT.0) THEN
        status=nf90_inq_varid(fid,'sealv',rhid)
        IF (status.NE.nf90_noerr) THEN
          WRITE(*,*) 'cannot find input variable sealv '
          STOP
        ENDIF
        status=nf90_get_var(fid,rhid,sealv,(/1,1,rec1/),
     .    (/idm,jdm,1/))
        CALL handle_ncerror(status)
        status=nf90_get_att(fid,rhid,'scale_factor',sfac)
        IF (status.NE.NF90_NOERR) sfac=1.
        status=nf90_get_att(fid,rhid,'add_offset',offs)
        IF (status.NE.NF90_NOERR) offs=0.
        status=nf90_get_att(fid,rhid,'_FillValue',fill)  
        DO j=1,jj 
          DO i=1,ii 
            IF (sealv(i,j).EQ.fill) THEN
              sealv(i,j)=1e20
            ELSE
              sealv(i,j)=sealv(i,j)*sfac+offs
            ENDIF
          ENDDO
        ENDDO
      ENDIF
c
c --- Read bottom pressure if necessary 
      IF (INDEX(special,'dzavg').GT.0) THEN
        status=nf90_inq_varid(fid,'pbot',rhid)
        IF (status.NE.nf90_noerr) THEN
          WRITE(*,*) 'cannot find input variable pbot '
          STOP
        ENDIF
        status=nf90_get_var(fid,rhid,pbot,(/1,1,rec1/),
     .    (/idm,jdm,1/))
        CALL handle_ncerror(status)
        status=nf90_get_att(fid,rhid,'scale_factor',sfac)
        IF (status.NE.NF90_NOERR) sfac=1.
        status=nf90_get_att(fid,rhid,'add_offset',offs)
        IF (status.NE.NF90_NOERR) offs=0.
        status=nf90_get_att(fid,rhid,'_FillValue',fill)  
        DO j=1,jj 
          DO i=1,ii 
            IF (pbot(i,j).EQ.fill) THEN
              pbot(i,j)=1e20
            ELSE
              pbot(i,j)=pbot(i,j)*sfac+offs
            ENDIF
          ENDDO
        ENDDO
      ENDIF
c
      status=nf90_close(fid)
      CALL handle_ncerror(status)
c
      END SUBROUTINE read_tslice



      SUBROUTINE add_tslice(vnm,fac,rec,fid)
c
c --- Description: add one time slice to output variable fld
c 
      IMPLICIT NONE 
c
      CHARACTER(LEN=slenmax) :: vnm
      REAL :: fac 
      INTEGER :: i,j,k,rec,fid
c
c --- Return if variable name is empty 
      IF (LEN(TRIM(vnm)).EQ.0) RETURN 
c
c --- Read time sclice  
      status=nf90_inq_varid(fid,TRIM(vnm),rhid)
      IF (status.NE.nf90_noerr) THEN
        WRITE(*,*) 'cannot find input variable ',TRIM(vnm)
        STOP
      ENDIF
      IF (TRIM(vtype).EQ.'2d') THEN
        status=nf90_get_var(fid,rhid,fldtmp,(/1,1,rec/),
     .    (/idm,jdm,1/))
      ELSEIF (TRIM(vtype).EQ.'1d') THEN
        status=nf90_get_var(fid,rhid,fldtmp,(/1,1,rec/),
     .    (/1,1,1/))
      ELSEIF (TRIM(vtype).EQ.'layer') THEN
        status=nf90_get_var(fid,rhid,fldtmp,(/1,1,1,rec/),
     .    (/idm,jdm,kdm,1/))
      ELSEIF (TRIM(vtype).EQ.'level') THEN
        status=nf90_get_var(fid,rhid,fldtmp,(/1,1,1,rec/),
     .    (/idm,jdm,ddm,1/))
      ELSEIF (TRIM(vtype).EQ.'merk') THEN
        status=nf90_get_var(fid,rhid,fldtmp,(/1,1,1,rec/),
     .    (/ldm,kdm,rdm,1/))
      ELSEIF (TRIM(vtype).EQ.'merd') THEN
        status=nf90_get_var(fid,rhid,fldtmp,(/1,1,1,rec/),
     .    (/ldm,ddm,rdm,1/))
      ELSEIF (TRIM(vtype).EQ.'mert') THEN
        status=nf90_get_var(fid,rhid,fldtmp,(/1,1,rec/),
     .    (/ldm,rdm,1/))
      ELSEIF (TRIM(vtype).EQ.'sect') THEN
        WRITE(*,*) 'read sections ',secdm
        status=nf90_get_var(fid,rhid,fldtmp,(/1,rec/),
     .    (/secdm,1/))
      ENDIF
      CALL handle_ncerror(status)
      status=nf90_get_att(fid,rhid,'scale_factor',sfac)
      IF (status.NE.NF90_NOERR) sfac=1.
      status=nf90_get_att(fid,rhid,'add_offset',offs)
      IF (status.NE.NF90_NOERR) offs=0.
      status=nf90_get_att(fid,rhid,'_FillValue',fill)
      IF (status.NE.NF90_NOERR) THEN 
        DO k=1,kk
          DO j=1,jj
            DO i=1,ii
              fld(i,j,k)=fld(i,j,k)+(fldtmp(i,j,k)*sfac+offs)*fac
            ENDDO 
          ENDDO 
        ENDDO 
      ELSE
        DO k=1,kk
          DO j=1,jj
            DO i=1,ii
              IF (fldtmp(i,j,k).EQ.fill) THEN 
                fld(i,j,k)=1e20 
              ELSE 
                fld(i,j,k)=fld(i,j,k)+(fldtmp(i,j,k)*sfac+offs)*fac
              ENDIF 
            ENDDO 
          ENDDO 
        ENDDO 
      ENDIF
c
      END SUBROUTINE add_tslice



      SUBROUTINE add_fixed(vnm,fac,fid)
c
c --- Description: add one time slice to output variable fld
c 
      IMPLICIT NONE
c
      CHARACTER(LEN=slenmax) :: vnm
      REAL :: fac
      INTEGER :: i,j,k,rec,fid
c
c --- Return if variable name is empty 
      IF (LEN(TRIM(vnm)).EQ.0) RETURN
c
c --- Read time sclice  
      status=nf90_inq_varid(fid,TRIM(vnm),rhid)
      IF (status.NE.nf90_noerr) THEN
        WRITE(*,*) 'cannot find input variable ',TRIM(vnm)
        STOP
      ENDIF
      status=nf90_get_var(fid,rhid,fldtmp)
      CALL handle_ncerror(status)
      status=nf90_get_att(fid,rhid,'scale_factor',sfac)
      IF (status.NE.NF90_NOERR) sfac=1.
      status=nf90_get_att(fid,rhid,'add_offset',offs)
      IF (status.NE.NF90_NOERR) offs=0.
      status=nf90_get_att(fid,rhid,'_FillValue',fill)
      IF (status.NE.NF90_NOERR) THEN
        DO k=1,kk
          DO j=1,jj
            DO i=1,ii
              fld(i,j,k)=fld(i,j,k)+(fldtmp(i,j,k)*sfac+offs)*fac
            ENDDO
          ENDDO
        ENDDO
      ELSE
        DO k=1,kk
          DO j=1,jj
            DO i=1,ii
              IF (fldtmp(i,j,k).EQ.fill) THEN
                fld(i,j,k)=1e20
              ELSE
                fld(i,j,k)=fld(i,j,k)+(fldtmp(i,j,k)*sfac+offs)*fac
              ENDIF
            ENDDO
          ENDDO
        ENDDO
      ENDIF
c
      END SUBROUTINE add_fixed



      SUBROUTINE write_field
c
      IMPLICIT NONE
c
      INTEGER :: i,j,k 
c
c --- Set zero on ocean grid cells
      DO k=1,kk
        DO j=1,jj
          DO i=1,ii
            IF (ABS(fld(i,j,k)).GT.2e20) fld(i,j,k)=0. 
          ENDDO
        ENDDO
      ENDDO
c      
c --- Store variable
      IF (INDEX(special,'glbave')
     .  .GT.0.OR.INDEX(special,'2zos').GT.0.) THEN
        error_flag=cmor_write(
     .    var_id         = varid,
     .    data           = (/fld(1,1,1)/))
      ELSEIF (VTYPE.EQ.'2d') THEN
        error_flag=cmor_write(
     .    var_id         = varid,
     .    data           = reshape(fld,(/idm,jdm/)))
      ELSE
        error_flag=cmor_write(
     .    var_id         = varid,
     .    data           = fld)
      ENDIF
c
      END SUBROUTINE write_field



      SUBROUTINE write_tslice
c
      IMPLICIT NONE
c
      INTEGER :: i,j,k 
c
c --- Populate field defined at interface level 
      IF (INDEX(special,'zhalf').GT.0) THEN 
        fldhalf(:,:,1)=sealv 
        fldhalf(:,:,2:kdm+1)=fld
        DO k=1,kk+1
          DO j=1,jj
            DO i=1,ii
              IF (ABS(fldhalf(i,j,k)).GT.2e20) fldhalf(i,j,k)=0. 
            ENDDO
          ENDDO
        ENDDO
      ELSEIF (INDEX(special,'halfl').GT.0) THEN
        fldhalf(:,:,2:kdm+1)=fld
        DO j=1,jj
          DO i=1,ii
            IF (ABS(fldhalf(i,j,2)).GE.1e20) THEN 
              fldhalf(i,j,1)=1e20 
            ELSE
              fldhalf(i,j,1)=0. 
            ENDIF
          ENDDO
        ENDDO
      ENDIF
c
c --- Set missing on land grid cells
      IF (INDEX(special,'glbave').LE.0) THEN 
        DO k=1,kk
          DO j=1,jj
            DO i=1,ii
              IF (ABS(fld(i,j,k)).GT.1e20) fld(i,j,k)=1e20
            ENDDO 
          ENDDO 
        ENDDO
      ENDIF 
c
c --- Store variable
      IF (INDEX(special,'half').GT.0) THEN
        IF (TRIM(tcoord).NE.'time1') THEN
          error_flag=cmor_write(
     .      var_id         = varid,
     .      data           = fldhalf,
     .      ntimes_passed  = 1,
     .      time_vals      = tval,
     .      time_bnds      = tbnds)
        ELSE
          error_flag=cmor_write(
     .      var_id         = varid,
     .      data           = fldhalf,
     .      ntimes_passed  = 1,
     .      time_vals      = tval)
        ENDIF
      ELSE
        IF (TRIM(tcoord).EQ.'time1') THEN
          error_flag=cmor_write(
     .      var_id         = varid,
     .      data           = fld,
     .      ntimes_passed  = 1,
     .      time_vals      = tval)
        ELSE
          IF ((lsumz.OR.INDEX(special,'level1').GT.0).AND.
     .      .NOT.INDEX(special,'glbave').GT.0
     .      .OR.INDEX(special,'lvl2srf').GT.0
     .      .OR.INDEX(special,'dpint').GT.0
     .      .OR.INDEX(special,'dpavg').GT.0
     .      .OR.INDEX(special,'locmin').GT.0
     .      .OR.INDEX(special,'omega2z').GT.0) THEN
            error_flag=cmor_write(
     .        var_id         = varid,
     .        data           = fld(:,:,1),
     .        ntimes_passed  = 1,
     .        time_vals      = tval,
     .        time_bnds      = tbnds)
          ELSEIF (INDEX(special,'glbave').GT.0
     .     .OR.INDEX(special,'2zos').GT.0.) THEN
            error_flag=cmor_write(
     .        var_id         = varid,
     .        data           = (/fld(1,1,1)/),
     .        ntimes_passed  = 1,
     .        time_vals      = tval,
     .        time_bnds      = tbnds)
          ELSEIF (INDEX(special,'dzavg').GT.0) THEN
            error_flag=cmor_write(
     .        var_id         = varid,
     .        data           = (reshape(fld(:,:,1),(/idm,jdm,1/))),
     .        ntimes_passed  = 1,
     .        time_vals      = tval,
     .        time_bnds      = tbnds)
          ELSEIF (vtype(1:4).EQ.'sect') THEN
            error_flag=cmor_write(
     .        var_id         = varid,
     .        data           = fld(:,1,1),
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
        ENDIF
      ENDIF
c
      END SUBROUTINE write_tslice


      END MODULE m_modelsocn
