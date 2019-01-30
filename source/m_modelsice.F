      MODULE m_modelsice
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
      INTEGER, SAVE :: idm,jdm 
      INTEGER, PARAMETER :: ncrns=4
      REAL(KIND=8), ALLOCATABLE, SAVE, DIMENSION(:) :: xvec,yvec 
      REAL(KIND=8), ALLOCATABLE, SAVE, DIMENSION(:,:) :: angle,
     .  tlon,tlat,ulon,ulat,vlon,vlat,uvlon,uvlat,tarea,uarea,
     .  tlon2,tlat2,ulon2,ulat2,vlon2,vlat2,uvlon2,uvlat2
      REAL(KIND=8), ALLOCATABLE, SAVE, DIMENSION(:,:,:) :: 
     .  tlon_crns,tlat_crns,tlon_crnsp,tlat_crnsp,
     .  ulon_crns,ulat_crns,ulon_crnsp,ulat_crnsp,
     .  vlon_crns,vlat_crns,vlon_crnsp,vlat_crnsp,
     .  uvlon_crns,uvlat_crns,uvlon_crnsp,uvlat_crnsp
      CHARACTER(LEN=slenmax), SAVE :: tcoord,zcoord   
c
c --- Fram Strait grid info 
      INTEGER :: seclen 
      INTEGER, PARAMETER :: maxseclen=100
      INTEGER, DIMENSION(MAXSECLEN) :: iind,jind,iflg,jflg
      LOGICAL, SAVE :: lsecindex 
c 
c --- Dataset related variables 
      CHARACTER(LEN=slenmax), SAVE :: ivnm,ovnm,vunits,vpositive,
     .  vcomment 
c
c --- Table related variables 
      CHARACTER(LEN=lenmax) :: table 
c
c --- String for module special 
      CHARACTER(LEN=slenmax), SAVE :: special
c
c --- Cmor parameters 
      INTEGER, SAVE :: iaxid,jaxid,kaxid,taxid,grdid,varid,table_id,
     .  table_id_grid,error_flag

c --- Data fields
      REAL(KIND=8), ALLOCATABLE, SAVE, DIMENSION(:,:) :: fld,fld2,
     .  fld3,fldacc 
c
c --- Auxillary variables for special operations 
      CHARACTER(LEN=slenmax), SAVE :: str1,str2



c --- -----------------------------------------------------------------
      CONTAINS 
c --- -----------------------------------------------------------------



      SUBROUTINE ice2cmor 
c
      IMPLICIT NONE
c
      LOGICAL :: badrec,last
      INTEGER :: m,n,nrec
c
c --- Skip if all ice tables deactivated
      IF (.NOT.doimon) RETURN
c
c --- Print start information
      IF (verbose) THEN
        WRITE(*,*)
        WRITE(*,*) '------------------------------'
        WRITE(*,*) '--- Process sea ice output ---'
        WRITE(*,*) '------------------------------'
        WRITE(*,*)
      ENDIF
c
c --- Read grid information from input files
      WRITE(*,*) 'Read grid information from input files'
      itag=tagimon
      CALL scan_files(reset=.TRUE.)
      IF (LEN_TRIM(fnm).EQ.0) RETURN 
      CALL read_gridinfo_ifile
c 
c --- Read Fram Strait grid information from secindex.dat
      WRITE(*,*) 'Read Fram Strait grid information from secindex.dat' 
      CALL read_secindex(TRIM(griddata)//TRIM(secindexfile),lsecindex,
     .  seclen,iind,jind,iflg,jflg)
c
c
c --- Process table fx 
      WRITE(*,*) 'Process table fx'
      fnm=pfx
      table=tfx 
      DO n=1,nfx 
        IF (skip_variable(n,nfx,dfx)) CYCLE
c
c --- - Map namelist variables 
        ivnm=vfx(1,n) 
        ovnm=vfx(2,n) 
        special=vfx(3,n)
        vunits=' ' 
        vpositive=' ' 
        vcomment=' ' 
c
c --- - Check if vertical coordinate required        
        CALL get_vertcoord(TRIM(tabledir)//TRIM(table),ovnm,zcoord)
c
c --- - Check if input variable is present 
        IF (LEN_TRIM(pfx).eq.0) CYCLE
        IF (.NOT.var_in_file(fnm,ivnm)) CYCLE 
c
c --- - Skip if ouput variable is atmosphere cell area 
        IF (INDEX(ovnm,'areacella').gt.0) CYCLE
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
c --- Process table omon
      WRITE(*,*) 'Process table omon'
      fnm=pomon
      table=tomon
      DO n=1,nomon
        IF (skip_variable(n,nomon,domon)) CYCLE
c
c --- - Map namelist variables 
        ivnm=vomon(1,n)
        ovnm=vomon(2,n)
        special=vomon(3,n)
        vunits=' '
        vpositive=' '
        vcomment=' ' 
c
c --- - Do not process ocean current fields uvel,vvel 
        IF(TRIM(ivnm).EQ.'uvel'.OR.TRIM(ivnm).EQ.'vvel') EXIT
c
c --- - Check if vertical coordinate required        
        CALL get_vertcoord(TRIM(tabledir)//TRIM(table),ovnm,zcoord)
c 
c --- - Choose history file 
        SELECT CASE (TRIM(special))
          CASE ('day2mon')
            itag=tagiday
          CASE DEFAULT
            itag=tagimon
        END SELECT
c
c --- - Check if input variable is present  
        IF (LEN_TRIM(pomon).eq.0) CALL scan_files(reset=.TRUE.)
        IF (.NOT.var_in_file(fnm,ivnm).AND..NOT.TRIM(ivnm).EQ.'transifs'
     .    .OR.TRIM(ivnm).EQ.'transifs'.AND..NOT.lsecindex) CYCLE
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
c --- --- Choose history file 
          SELECT CASE (TRIM(special))
          CASE ('day2mon')
            itag=tagiday
          CASE DEFAULT
            itag=tagimon
          END SELECT
c
c --- --- Read variable into buffer (average if necessary)
          rec=0
          nrec=0
          fldacc=0.
          LAST=.FALSE.
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
c --- Process table oimon
      WRITE(*,*) 'Process table oimon'
      fnm=poimon
      table=toimon
      DO n=1,noimon
        IF (skip_variable(n,noimon,doimon)) CYCLE
c
c --- - Map namelist variables 
        ivnm=voimon(1,n)
        ovnm=voimon(2,n)
        special=voimon(3,n)
        vunits=' '
        vpositive=' '
        vcomment=' '
c
c --- - Check if vertical coordinate required        
        CALL get_vertcoord(TRIM(tabledir)//TRIM(table),ovnm,zcoord)
c 
c --- - Choose history file 
        SELECT CASE (TRIM(special))
          CASE ('day2mon')
            itag=tagiday
          CASE DEFAULT
            itag=tagimon
        END SELECT
c
c --- - Check if input variable is present  
        IF (LEN_TRIM(poimon).eq.0) CALL scan_files(reset=.TRUE.)
        IF (.NOT.var_in_file(fnm,ivnm).AND..NOT.TRIM(ivnm).EQ.'transifs'
     .    .OR.TRIM(ivnm).EQ.'transifs'.AND..NOT.lsecindex) CYCLE
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
          IF (MOD(m-1,roimon).EQ.0) CALL open_ofile
c 
c --- --- Choose history file 
          SELECT CASE (TRIM(special))
          CASE ('day2mon')
            itag=tagiday
          CASE DEFAULT
            itag=tagimon
          END SELECT
c
c --- --- Read variable into buffer (average if necessary)
          rec=0
          nrec=0
          fldacc=0.
          LAST=.FALSE.
          DO
            IF (LEN_TRIM(poimon).eq.0) CALL scan_files(reset=.FALSE.)
            IF (rec.EQ.0) then
              last=.TRUE.
              EXIT
            ENDIF
            nrec=nrec+1
cdiag      write(*,*) 'DEBUG: ',trim(fnm),rec,nrec,tbnd,mbnd,year,month
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
          IF (MOD(m,roimon).EQ.0) CALL close_ofile
c
c --- - End loop over files and records
        ENDDO
c
c --- - Close output file if still open 
        IF (MOD(m,roimon).GT.0) CALL close_ofile
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
        ivnm=vday(1,n)
        ovnm=vday(2,n)
        special=vday(3,n)
        vunits=' '
        vpositive=' '
        vcomment=' '
c
c --- - Check if vertical coordinate required        
        CALL get_vertcoord(TRIM(tabledir)//TRIM(table),ovnm,zcoord)
c
c --- - Choose history file 
        itag=tagiday
c
c --- - Check if input variable is present  
        IF (LEN_TRIM(pday).eq.0) CALL scan_files(reset=.TRUE.)
        IF (.NOT.var_in_file(fnm,ivnm).AND..NOT.TRIM(ivnm).EQ.'transifs'
     .    .OR.TRIM(ivnm).EQ.'transifs'.AND..NOT.lsecindex) CYCLE
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
c
c
#ifdef CMOR3 
c --- Process table SIday
      WRITE(*,*) 'Process table SIday'
      fnm=pSIday
      table=tSIday
      DO n=1,nSIday
        IF (skip_variable(n,nSIday,dSIday)) CYCLE
c
c --- - Map namelist variables 
        ivnm=vSIday(1,n)
        ovnm=vSIday(2,n)
        special=vSIday(3,n)
        vunits=' '
        vpositive=' '
        vcomment=' '
c
c --- - Check if vertical coordinate required        
        CALL get_vertcoord(TRIM(tabledir)//TRIM(table),ovnm,zcoord)
c
c --- - Choose history file 
        itag=tagiday
c
c --- - Check if input variable is present  
        IF (LEN_TRIM(pSIday).eq.0) CALL scan_files(reset=.TRUE.)
        IF (.NOT.var_in_file(fnm,ivnm).AND..NOT.TRIM(ivnm).EQ.'transifs'
     .    .OR.TRIM(ivnm).EQ.'transifs'.AND..NOT.lsecindex) CYCLE
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
          IF (MOD(m-1,rSIday).EQ.0) CALL open_ofile
c
c --- --- Read variable into buffer 
          rec=0
          IF (LEN_TRIM(pSIday).eq.0) CALL scan_files(reset=.FALSE.)
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
          IF (MOD(m,rSIday).EQ.0) CALL close_ofile
c
c --- - End loop over files and records
        ENDDO
c
c --- - Close output file if still open 
        IF (MOD(m,rSIday).GT.0) CALL close_ofile
c
      ENDDO
#endif
c
      END SUBROUTINE ice2cmor 



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
c --- - Unit transformation: kg m-2  
        CASE ('kg m-2')
          vunits='kg m-2'
c 
c --- - Unit transformation: cm/day -> kg m-2 s-1 
        CASE ('cmFW day-1 -> kg m-2 s-1','cmICE day-1 -> kg m-2 s-1',
     .    'cmSNOW day-1 -> kg m-2 s-1')
          vunits='kg m-2 s-1'
c 
c --- - Unit transformation: kg/m^2/day -> kg m-2 s-1 
        CASE ('kg m-2 day-1 -> kg m-2 s-1')
          vunits='kg m-2 s-1'
c 
c --- - Fix micrometers units 
        CASE ('micrometer')
          vunits='micrometers'
c 
c --- - Convert degC to K 
        CASE ('Celsius2Kelvin')
          vunits='K'
c
c --- - Fix m-2 units 
        CASE ('m-2')
          vunits='m-2'
c        
c --- - Convert units from radians2 to m2    
        CASE ('rad2m')
          vunits='m2'
c
c --- - Fix hcice units 
        CASE ('J m-2')
          vunits='J m-2'
c
c --- - Set positive attribute  
        CASE ('positiveup')
          vpositive='up'
        CASE ('positivedo')
          vpositive='down'
c
c --- - Write comment for hur and hurs
        CASE ('tsicecomment')
          vcomment='This field differs from the CMOR-definition '
     .           //'because at every time-step, the field has been '
     .           //'put to 271.314 K in grid-cells without sea ice. '
     .           //'The time-mean has been calculated from these '
     .           //'values without taking care of when a grid-cell is '
     .           //'free of sea ice.'
c
c --- - Write comment for streng and divice
        CASE ('tavecomment')
          vcomment='During the time-averaging there was no weighting '
     .           //'with respect to the ice concentration in this '
     .           //'field. A value of zero was used over open water.'
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
      INTEGER :: i,j
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
c --- - Convert units from radians2 to m2    
        CASE ('rad2m')
          fld=fld*6.37122e6**2
c 
c --- - Convert degC to K 
        CASE ('Celsius2Kelvin')
          fld=fld+273.15
c
c --- - Unit transformation: cm day-1 -> kg m-2 s-1 
        CASE ('cmFW day-1 -> kg m-2 s-1')
          fld=fld/100./(24.*3600.)*1000.
        CASE ('cmICE day-1 -> kg m-2 s-1')
          fld=fld/100./(24.*3600.)*917.
        CASE ('cmSNOW day-1 -> kg m-2 s-1')
          fld=fld/100./(24.*3600.)*330.
c 
c --- - Unit transformation: kg/m^2/day -> kg m-2 s-1 
        CASE ('kg m-2 day-1 -> kg m-2 s-1')
          fld=fld/(24.*3600.)
c
c --- - Flip sign
        CASE ('flipsign')
          DO j=1,jdm
            DO i=1,idm
              IF (fld(i,j).LT.1e20) fld(i,j)=-fld(i,j)
            ENDDO
          ENDDO
c
c --- - Set ice free points to missing value
        CASE ('zero2missing')
          DO j=1,jdm
            DO i=1,idm
              IF (abs(fld(i,j)).LT.1e-6) fld(i,j)=1e20
            ENDDO
          ENDDO
c
c --- - Divide by cell area 
        CASE ('Xcellarea-1')
          DO j=1,jdm
            DO i=1,idm
              IF (abs(fld(i,j)).LT.1e20) fld(i,j)=fld(i,j)/tarea(i,j)
            ENDDO
          ENDDO
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
      INTEGER :: i,j,n
      REAL :: missing,theta,lambda
c
c --- Open first input file 
      CALL scan_files(reset=.TRUE.)
      status=nf90_open(fnm,nf90_nowrite,ncid) 
      CALL handle_ncerror(status)
c
c --- Read longitudes and latitudes
      status=nf90_inq_dimid(ncid,'ni',dimid)
      CALL handle_ncerror(status)
      status=nf90_inquire_dimension(ncid,dimid,len=idm)
      CALL handle_ncerror(status)
      status=nf90_inq_dimid(ncid,'nj',dimid)
      CALL handle_ncerror(status)
      status=nf90_inquire_dimension(ncid,dimid,len=jdm)
      CALL handle_ncerror(status)
c
      ALLOCATE(tlon(idm,jdm),tlat(idm,jdm),ulon(idm,jdm),ulat(idm,jdm),
     .  vlon(idm,jdm),vlat(idm,jdm),uvlon(idm,jdm),uvlat(idm,jdm),
     .  tlon2(0:idm+2,0:jdm+2),tlat2(0:idm+2,0:jdm+2),
     .  ulon2(0:idm+2,0:jdm+2),ulat2(0:idm+2,0:jdm+2),
     .  vlon2(0:idm+2,0:jdm+2),vlat2(0:idm+2,0:jdm+2),
     .  uvlon2(0:idm+2,0:jdm+2),uvlat2(0:idm+2,0:jdm+2),
     .  tlon_crns(idm,jdm,ncrns),tlat_crns(idm,jdm,ncrns),
     .  ulon_crns(idm,jdm,ncrns),ulat_crns(idm,jdm,ncrns),
     .  vlon_crns(idm,jdm,ncrns),vlat_crns(idm,jdm,ncrns),
     .  uvlon_crns(idm,jdm,ncrns),uvlat_crns(idm,jdm,ncrns),
     .  tlon_crnsp(ncrns,idm,jdm),tlat_crnsp(ncrns,idm,jdm),
     .  ulon_crnsp(ncrns,idm,jdm),ulat_crnsp(ncrns,idm,jdm),
     .  vlon_crnsp(ncrns,idm,jdm),vlat_crnsp(ncrns,idm,jdm),
     .  uvlon_crnsp(ncrns,idm,jdm),uvlat_crnsp(ncrns,idm,jdm),
     .  xvec(idm),yvec(jdm),angle(idm,jdm),tarea(idm,jdm),
     .  uarea(idm,jdm),STAT=status) 
      IF (status.NE.0) STOP 'cannot ALLOCATE enough memory (1)'
c
      DO i=1,idm 
        xvec(i)=i
      ENDDO 
      DO j=1,jdm 
        yvec(j)=j
      ENDDO 
c
      status=nf90_inq_varid(ncid,'TLON',rhid) 
      CALL handle_ncerror(status)
      status=nf90_get_var(ncid,rhid,tlon)
      CALL handle_ncerror(status)
      status=nf90_inq_varid(ncid,'TLAT',rhid) 
      CALL handle_ncerror(status)
      status=nf90_get_var(ncid,rhid,tlat)
      CALL handle_ncerror(status)
      status=nf90_inq_varid(ncid,'ULON',rhid) 
      CALL handle_ncerror(status)
      status=nf90_get_var(ncid,rhid,uvlon)
      CALL handle_ncerror(status)
      status=nf90_inq_varid(ncid,'ULAT',rhid) 
      CALL handle_ncerror(status)
      status=nf90_get_var(ncid,rhid,uvlat)
      CALL handle_ncerror(status)
      status=nf90_inq_varid(ncid,'ANGLE',rhid) 
      IF (status.EQ.NF90_NOERR) THEN 
        status=nf90_get_var(ncid,rhid,angle)
        CALL handle_ncerror(status)
      ELSE 
        WRITE(*,*) 'ANGLE not in sea ice file. Setting to zero.'
        angle=0 
      ENDIF
      status=nf90_inq_varid(ncid,'tarea',rhid) 
      IF (status.EQ.NF90_NOERR) THEN 
        status=nf90_get_var(ncid,rhid,tarea)
        CALL handle_ncerror(status)
      ELSE 
        WRITE(*,*) 'tarea not in sea ice file. Setting to one.'
        tarea=1
      ENDIF
      status=nf90_inq_varid(ncid,'uarea',rhid) 
      IF (status.EQ.NF90_NOERR) THEN 
        status=nf90_get_var(ncid,rhid,uarea)
        CALL handle_ncerror(status)
      ELSE 
        WRITE(*,*) 'uarea not in sea ice file. Setting to one.'
        uarea=1
      ENDIF
c
c --- Read calendar info (override/change units)
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
c --- Compute extended coordinate fields 
      tlat2(1:idm,1:jdm)=tlat
      tlon2(1:idm,1:jdm)=tlon
      uvlat2(1:idm,1:jdm)=uvlat
      uvlon2(1:idm,1:jdm)=uvlon
      DO i=1,idm 
        CALL sphextpnt(tlat2(i,2),tlon2(i,2),
     .    tlat2(i,1),tlon2(i,1),tlat2(i,0),tlon2(i,0))
        CALL sphextpnt(tlat2(i,jdm-1),tlon2(i,jdm-1),
     .    tlat2(i,jdm),tlon2(i,jdm),tlat2(i,jdm+1),tlon2(i,jdm+1))
c
        CALL sphextpnt(uvlat2(i,2),uvlon2(i,2),
     .    uvlat2(i,1),uvlon2(i,1),uvlat2(i,0),uvlon2(i,0))
        CALL sphextpnt(uvlat2(i,jdm-1),uvlon2(i,jdm-1),
     .    uvlat2(i,jdm),uvlon2(i,jdm),uvlat2(i,jdm+1),uvlon2(i,jdm+1))
        CALL sphextpnt(uvlat2(i,jdm),uvlon2(i,jdm),uvlat2(i,jdm+1),
     .    uvlon2(i,jdm+1),uvlat2(i,jdm+2),uvlon2(i,jdm+2))
      ENDDO 
      DO j=0,jdm+2
        CALL sphextpnt(tlat2(2,j),tlon2(2,j),
     .    tlat2(1,j),tlon2(1,j),tlat2(0,j),tlon2(0,j))
        CALL sphextpnt(tlat2(idm-1,j),tlon2(idm-1,j),
     .    tlat2(idm,j),tlon2(idm,j),tlat2(idm+1,j),tlon2(idm+1,j))
c
        CALL sphextpnt(uvlat2(2,j),uvlon2(2,j),
     .    uvlat2(1,j),uvlon2(1,j),uvlat2(0,j),uvlon2(0,j))
        CALL sphextpnt(uvlat2(idm-1,j),uvlon2(idm-1,j),
     .    uvlat2(idm,j),uvlon2(idm,j),uvlat2(idm+1,j),uvlon2(idm+1,j))
        CALL sphextpnt(uvlat2(idm,j),uvlon2(idm,j),uvlat2(idm+1,j),
     .    uvlon2(idm+1,j),uvlat2(idm+2,j),uvlon2(idm+2,j))
      ENDDO 
      ulon2=uvlon2
      ulat2=uvlat2
      vlon2=uvlon2
      vlat2=uvlat2
c
c --- Interpolate u,v points 
      DO j=0,jdm+1
        DO i=0,idm+1
          CALL sphmidpnt(ulat2(i,j),ulon2(i,j),ulat2(i+1,j),
     .      ulon2(i+1,j),theta,lambda)
          ulat2(i,j)=theta
          ulon2(i,j)=lambda 
          CALL sphmidpnt(vlat2(i,j),vlon2(i,j),vlat2(i,j+1),
     .      vlon2(i,j+1),theta,lambda)
          vlat2(i,j)=theta
          vlon2(i,j)=lambda 
        ENDDO
      ENDDO
      ulat=ulat2(1:idm,1:jdm)
      ulon=ulon2(1:idm,1:jdm)
      vlat=vlat2(1:idm,1:jdm)
      vlon=vlon2(1:idm,1:jdm)
c
c --- Compute corner points 
      DO j=1,jdm
        DO i=1,idm
          CALL sphmidpnt(tlat2(i-1,j),tlon2(i-1,j),tlat2(i,j-1),
     .      tlon2(i,j-1),tlat_crns(i,j,1),tlon_crns(i,j,1))
          CALL sphmidpnt(tlat2(i-1,j),tlon2(i-1,j),tlat2(i,j+1),
     .      tlon2(i,j+1),tlat_crns(i,j,2),tlon_crns(i,j,2))
          CALL sphmidpnt(tlat2(i+1,j),tlon2(i+1,j),tlat2(i,j+1),
     .      tlon2(i,j+1),tlat_crns(i,j,3),tlon_crns(i,j,3))
          CALL sphmidpnt(tlat2(i+1,j),tlon2(i+1,j),tlat2(i,j-1),
     .      tlon2(i,j-1),tlat_crns(i,j,4),tlon_crns(i,j,4))
c
          CALL sphmidpnt(ulat2(i-1,j),ulon2(i-1,j),ulat2(i,j-1),
     .      ulon2(i,j-1),ulat_crns(i,j,1),ulon_crns(i,j,1))
          CALL sphmidpnt(ulat2(i-1,j),ulon2(i-1,j),ulat2(i,j+1),
     .      ulon2(i,j+1),ulat_crns(i,j,2),ulon_crns(i,j,2))
          CALL sphmidpnt(ulat2(i+1,j),ulon2(i+1,j),ulat2(i,j+1),
     .      ulon2(i,j+1),ulat_crns(i,j,3),ulon_crns(i,j,3))
          CALL sphmidpnt(ulat2(i+1,j),ulon2(i+1,j),ulat2(i,j-1),
     .      ulon2(i,j-1),ulat_crns(i,j,4),ulon_crns(i,j,4))
c
          CALL sphmidpnt(vlat2(i-1,j),vlon2(i-1,j),vlat2(i,j-1),
     .      vlon2(i,j-1),vlat_crns(i,j,1),vlon_crns(i,j,1))
          CALL sphmidpnt(vlat2(i-1,j),vlon2(i-1,j),vlat2(i,j+1),
     .      vlon2(i,j+1),vlat_crns(i,j,2),vlon_crns(i,j,2))
          CALL sphmidpnt(vlat2(i+1,j),vlon2(i+1,j),vlat2(i,j+1),
     .      vlon2(i,j+1),vlat_crns(i,j,3),vlon_crns(i,j,3))
          CALL sphmidpnt(vlat2(i+1,j),vlon2(i+1,j),vlat2(i,j-1),
     .      vlon2(i,j-1),vlat_crns(i,j,4),vlon_crns(i,j,4))
c
          CALL sphmidpnt(uvlat2(i-1,j),uvlon2(i-1,j),uvlat2(i,j-1),
     .      uvlon2(i,j-1),uvlat_crns(i,j,1),uvlon_crns(i,j,1))
          CALL sphmidpnt(uvlat2(i-1,j),uvlon2(i-1,j),uvlat2(i,j+1),
     .      uvlon2(i,j+1),uvlat_crns(i,j,2),uvlon_crns(i,j,2))
          CALL sphmidpnt(uvlat2(i+1,j),uvlon2(i+1,j),uvlat2(i,j+1),
     .      uvlon2(i,j+1),uvlat_crns(i,j,3),uvlon_crns(i,j,3))
          CALL sphmidpnt(uvlat2(i+1,j),uvlon2(i+1,j),uvlat2(i,j-1),
     .      uvlon2(i,j-1),uvlat_crns(i,j,4),uvlon_crns(i,j,4))
        ENDDO
      ENDDO
c
c --- Permute to compensate for dimension bug in CMOR
      DO n=1,ncrns
        DO j=1,jdm 
          DO i=1,idm 
              tlon_crnsp(n,i,j)=tlon_crns(i,j,n)             
              tlat_crnsp(n,i,j)=tlat_crns(i,j,n)             
              ulon_crnsp(n,i,j)=ulon_crns(i,j,n)             
              ulat_crnsp(n,i,j)=ulat_crns(i,j,n)     
              vlon_crnsp(n,i,j)=vlon_crns(i,j,n)             
              vlat_crnsp(n,i,j)=vlat_crns(i,j,n)     
              uvlon_crnsp(n,i,j)=uvlon_crns(i,j,n)             
              uvlat_crnsp(n,i,j)=uvlat_crns(i,j,n)     
              IF (tlon_crnsp(n,i,j).LT.0.)
     .          tlon_crnsp(n,i,j)=tlon_crnsp(n,i,j)+360                 
              IF (ulon_crnsp(n,i,j).LT.0.)
     .          ulon_crnsp(n,i,j)=ulon_crnsp(n,i,j)+360                 
              IF (vlon_crnsp(n,i,j).LT.0.)
     .          vlon_crnsp(n,i,j)=vlon_crnsp(n,i,j)+360                 
              IF (uvlon_crnsp(n,i,j).LT.0.)
     .          uvlon_crnsp(n,i,j)=uvlon_crnsp(n,i,j)+360              
              IF (ulon(i,j).LT.0.) ulon(i,j)=ulon(i,j)+360   
              IF (vlon(i,j).LT.0.) vlon(i,j)=vlon(i,j)+360   
          ENDDO 
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
      REAL :: fac1,fac2
      INTEGER, PARAMETER :: ndimmax=10
      INTEGER :: n,ndims,dimids(ndimmax),dimlens(ndimmax)
      INTEGER :: physics_version=1,initialization_method=1
      CHARACTER(len=slenmax) :: coord,ivnm1a,ivnm2a,ivnm1b,ivnm2b
      REAL(KIND=8), DIMENSION(:), ALLOCATABLE :: tmp1d, tmp1d_2
      REAL(KIND=8), DIMENSION(:,:), ALLOCATABLE :: tmp2d
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
      CALL resolve_vnm2(slenmax,ivnm,ivnm1a,ivnm2a,ivnm1b,ivnm2b,fac1,
     .  fac2)
      IF (TRIM(ovnm).NE.'transifs') THEN
        IF(verbose)write(*,*)'Resolve variable term: ',trim(ivnm1a),'*',
     .  trim(ivnm1b),'*',fac1,'+',trim(ivnm2a),'*',trim(ivnm2b),'*',fac2
        status=nf90_inq_varid(ncid,TRIM(ivnm1a),rhid)
        IF (status.NE.nf90_noerr) THEN
          WRITE(*,*) 'cannot find input variable ',TRIM(ivnm1a)
          STOP
        ENDIF
        status=nf90_inquire_variable(ncid,rhid,ndims=ndims)
        CALL handle_ncerror(status)
        status=nf90_inquire_variable(ncid,rhid,dimids=dimids(1:ndims))
        CALL handle_ncerror(status)
        IF (ndims.lt.3) THEN
          WRITE(*,*) 'Variable ',TRIM(ivnm1a),' has too few dimensions'
        ENDIF
        dimlens=1
        DO n=1,ndims
          status=nf90_inquire_dimension(ncid,dimids(n),len=dimlens(n))
          CALL handle_ncerror(status)
        ENDDO
        IF (dimlens(1).NE.idm) THEN
          WRITE(*,*) 'unexpected first dimension of variable ',
     .    TRIM(ivnm1a),': ',dimlens(1),' versus idm=',idm
          STOP
        ENDIF
        IF (dimlens(2).NE.jdm) THEN
          WRITE(*,*) 'unexpected second dimension of variable ',
     .      TRIM(ivnm1a),': ',dimlens(2),' versus jdm=',idm
          STOP
        ENDIF
      ENDIF 
      IF (ALLOCATED(fld)) DEALLOCATE(fld,fld2,fld3,fldacc)
      ALLOCATE(fld(idm,jdm),fld2(idm,jdm),fld3(idm,jdm),
     .  fldacc(idm,jdm),STAT=status)
      IF (status.NE.0) STOP 'cannot ALLOCATE enough memory (4)'
c 
      IF (LEN_TRIM(vunits).EQ.0) THEN
        status=nf90_get_att(ncid,rhid,'units',vunits)
        CALL handle_ncerror(status)
        IF (TRIM(vunits).EQ.'mm/s') vunits='kg m-2 s-1'
      END IF 
c
      coord=' '
      status=nf90_get_att(ncid,rhid,'coordinates',coord)
c
      status=nf90_close(ncid)
      CALL handle_ncerror(status)
c
c --- Inquire time dimension of output variable 
      IF (.NOT.fxflag) THEN 
        CALL get_timecoord(TRIM(tabledir)//TRIM(table),ovnm,tcoord)
      ENDIF
c
c --- Call CMOR setup 
      IF (verbose) THEN
        IF (createsubdirs) THEN  
          error_flag=cmor_setup(inpath=TRIM(ibasedir),
     .      netcdf_file_action=CMOR_REPLACE,set_verbosity=CMOR_NORMAL, 
     .      create_subdirectories=1)
        ELSE
          error_flag=cmor_setup(inpath=TRIM(ibasedir),
     .      netcdf_file_action=CMOR_REPLACE,set_verbosity=CMOR_NORMAL, 
     .      create_subdirectories=0)
        ENDIF
      ELSE
        IF (createsubdirs) THEN
          error_flag=cmor_setup(inpath=TRIM(ibasedir),
     .      netcdf_file_action=CMOR_REPLACE,set_verbosity=CMOR_QUIET,
     .      create_subdirectories=1)
        ELSE
          error_flag=cmor_setup(inpath=TRIM(ibasedir),
     .      netcdf_file_action=CMOR_REPLACE,set_verbosity=CMOR_QUIET,
     .      create_subdirectories=0)
        ENDIF
      ENDIF
      IF (error_flag.NE.0) STOP 'Problem setting up CMOR'
c
c --- Derive physics_version and initialization_method from
c --- parent_experiment_rip
      IF (TRIM(parent_experiment_rip).NE.'r1i1p1'.AND.
     .    TRIM(parent_experiment_rip).NE.'N/A') THEN
        READ(parent_experiment_rip(INDEX(parent_experiment_rip,'i')+1:
     .    INDEX(parent_experiment_rip,'p')-1),*) initialization_method
        READ(parent_experiment_rip(INDEX(parent_experiment_rip,'p')+1:),
     .    *) physics_version
      ENDIF
c
c --- Define output dataset 
#ifdef CMOR3
      CALL write_namelist_json(icegrid,icegrid_label,icegrid_resolution,
     .  ovnm)
      error_flag=cmor_dataset_json('namelist_'//TRIM(casename)//'_'//
     .  TRIM(ovnm)//'.json')
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
      IF (TRIM(ovnm).NE.'transifs') THEN
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
      ENDIF
c
      IF (coord(1:1).EQ.'T'.AND.ovnm(1:6).NE.'transi') THEN
        grdid=cmor_grid(
     .    axis_ids=(/iaxid,jaxid/),
     .    latitude=tlat,
     .    longitude=tlon,
     .    latitude_vertices=tlat_crnsp,
     .    longitude_vertices=tlon_crnsp)
      ELSEIF (TRIM(ovnm).EQ.'transix') THEN
        grdid=cmor_grid(
     .    axis_ids=(/iaxid,jaxid/),
     .    latitude=ulat,
     .    longitude=ulon,
     .    latitude_vertices=ulat_crnsp,
     .    longitude_vertices=ulon_crnsp)
      ELSEIF (TRIM(ovnm).EQ.'transiy') THEN
        grdid=cmor_grid(
     .    axis_ids=(/iaxid,jaxid/),
     .    latitude=vlat,
     .    longitude=vlon, 
     .    latitude_vertices=vlat_crnsp,
     .    longitude_vertices=vlon_crnsp)
      ELSEIF (TRIM(ovnm).EQ.'transifs') THEN
        CONTINUE
      ELSE
        grdid=cmor_grid(
     .    axis_ids=(/iaxid,jaxid/),
     .    latitude=uvlat,
     .    longitude=uvlon,
     .    latitude_vertices=uvlat_crnsp,
     .    longitude_vertices=uvlon_crnsp)
      ENDIF
c
c --- Define vertical dummy coordinate
      IF (TRIM(zcoord).EQ.'olevel') THEN
        ALLOCATE (tmp1d(1),tmp2d(2,1))
        tmp1d(:) = (/5.d0/)
        tmp2d(:,1) = (/0.d0,10.d0/)
        kaxid=cmor_axis(
     .    table           = TRIM(tabledir)//TRIM(table),
     .    table_entry     = 'depth_coord',
     .    units           = 'm',
     .    length          = 1,
     .    coord_vals      = tmp1d, !(/5.d0/),
     .    cell_bounds     = tmp2d)! reshape((/0.d0,10.d0/),(/2,1/)))
        DEALLOCATE(tmp1d,tmp2d)
      ENDIF
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
c --- Define output variable
      IF (fxflag) THEN 
        varid=cmor_variable(
     .    table          = TRIM(tabledir)//TRIM(table),
     .    table_entry    = TRIM(ovnm),
     .    units          = TRIM(vunits),
     .    axis_ids       = (/ grdid /),
     .    missing_value  = 1e20,
     .    original_name  = TRIM(ivnm),
     .    comment        = TRIM(vcomment))
      ELSE
        IF (TRIM(ovnm).EQ.'transifs') THEN
          varid=cmor_variable(
     .      table          = TRIM(tabledir)//TRIM(table),
     .      table_entry    = TRIM(ovnm),
     .      units          = TRIM(vunits),
     .      axis_ids       = (/ taxid /),
     .      missing_value  = 1e20, 
     .      comment        = TRIM(vcomment))
        ELSE
          IF (TRIM(zcoord).EQ.'olevel') THEN
            varid=cmor_variable(
     .        table          = TRIM(tabledir)//TRIM(table),
     .        table_entry    = TRIM(ovnm),
     .        units          = TRIM(vunits),
     .        axis_ids       = (/ grdid, kaxid, taxid /),
     .        original_name  = TRIM(ivnm),
     .        missing_value  = 1e20, 
     .        positive       = TRIM(vpositive),
     .        comment        = TRIM(vcomment))
          ELSE
            varid=cmor_variable(
     .        table          = TRIM(tabledir)//TRIM(table),
     .        table_entry    = TRIM(ovnm),
     .        units          = TRIM(vunits),
     .        axis_ids       = (/ grdid, taxid /),
     .        original_name  = TRIM(ivnm),
     .        missing_value  = 1e20, 
     .        positive       = TRIM(vpositive),
     .        comment        = TRIM(vcomment))
          ENDIF
        ENDIF
      ENDIF
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
      REAL :: fac1,fac2
      INTEGER :: ind
      CHARACTER(len=slenmax) :: ivnm1a,ivnm2a,ivnm1b,ivnm2b
c
c --- Open input file 
      status=nf90_open(fnm,nf90_nowrite,ncid)
      CALL handle_ncerror(status)
c
c --- Read data
      CALL resolve_vnm2(slenmax,ivnm,ivnm1a,ivnm2a,ivnm1b,ivnm2b,fac1,
     .  fac2)
      status=nf90_inq_varid(ncid,TRIM(ivnm1a),rhid)
      IF (status.NE.nf90_noerr) THEN
        WRITE(*,*) 'cannot find input variable ',TRIM(ivnm1a)
        STOP
      ENDIF
      status=nf90_get_var(ncid,rhid,fld)
      CALL handle_ncerror(status)
      IF (fac1.ne.1) THEN
        fld=fld*fac1
      ENDIF
c
      IF (LEN_TRIM(ivnm1b).GT.0) THEN
        status=nf90_inq_varid(ncid,TRIM(ivnm1b),rhid)
        IF (status.NE.nf90_noerr) THEN
          WRITE(*,*) 'cannot find input variable ',TRIM(ivnm1b)
          STOP
        ENDIF
        status=nf90_get_var(ncid,rhid,fld2)
        CALL handle_ncerror(status)
        fld=fld*fld2
      ENDIF
c 
      IF (LEN_TRIM(ivnm2a).GT.0) THEN
        status=nf90_inq_varid(ncid,TRIM(ivnm2a),rhid)
        IF (status.NE.nf90_noerr) THEN
          WRITE(*,*) 'cannot find input variable ',TRIM(ivnm2a)
          STOP
        ENDIF
        status=nf90_get_var(ncid,rhid,fld2)
        CALL handle_ncerror(status)
        IF (LEN_TRIM(ivnm2b).GT.0) THEN
          status=nf90_inq_varid(ncid,TRIM(ivnm2b),rhid)
          IF (status.NE.nf90_noerr) THEN
            WRITE(*,*) 'cannot find input variable ',TRIM(ivnm2b)
            STOP
          ENDIF
          status=nf90_get_var(ncid,rhid,fld3)
          CALL handle_ncerror(status)
          fld2=fld2*fld3
        ENDIF
        fld=fld+fld2*fac2
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
      REAL :: fac1,fac2
      INTEGER :: ind,rec,i,j,i1,j1
      INTEGER, SAVE :: fid
      CHARACTER(LEN=*), INTENT(IN), OPTIONAL :: fname
      CHARACTER(len=slenmax) :: ivnm1a,ivnm2a,ivnm1b,ivnm2b
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
      IF(.FALSE.) THEN
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
      tval=0.5*(tbnds(1,1)+tbnds(2,1))
c
c --- correct erroneous intial time bound
      tbnds(1,1)=max(0.,tbnds(1,1))
      tval=0.5*(tbnds(1,1)+tbnds(2,1))
c     WRITE(*,*) 'tbnds=',tbnds
      ENDIF
c
c --- Read data 
      CALL resolve_vnm2(slenmax,ivnm,ivnm1a,ivnm2a,ivnm1b,ivnm2b,fac1,
     .  fac2)
      IF (TRIM(ovnm).EQ.'transifs') THEN
        status=nf90_inq_varid(fid,'transix',rhid)
        IF (status.NE.nf90_noerr) THEN
          WRITE(*,*) 'cannot find input variable transix'
          STOP
        ENDIF
        status=nf90_get_var(fid,rhid,fld,(/1,1,rec/), 
     .    (/idm,jdm,1/)) 
        CALL handle_ncerror(status) 
        status=nf90_inq_varid(fid,'transiy',rhid)
        IF (status.NE.nf90_noerr) THEN
          WRITE(*,*) 'cannot find input variable transiy'
          STOP
        ENDIF
        status=nf90_get_var(fid,rhid,fld2,(/1,1,rec/), 
     .    (/idm,jdm,1/)) 
        CALL handle_ncerror(status) 
c --- - Compute Fram Strait transport 
        fld(1,1)=transifs(seclen,iind,jind,iflg,jflg,fld,fld2)
        WRITE(*,*) 'transifs=',fld(1,1)
        vunits='kg/s'
      ELSE
        status=nf90_inq_varid(fid,TRIM(ivnm1a),rhid)
        IF (status.NE.nf90_noerr) THEN
          WRITE(*,*) 'cannot find input variable ',TRIM(ivnm1a),status
          STOP
        ENDIF
        status=nf90_get_var(fid,rhid,fld,(/1,1,rec/), 
     .    (/idm,jdm,1/)) 
        CALL handle_ncerror(status) 
      ENDIF 
c
c --- Rotate to east/north alignment if variable is a velocity (BYPASSED)
      IF (.FALSE.) THEN 
      IF (ivnm1a(1:4).EQ.'uvel'.OR.ivnm1a(1:4).EQ.'vvel') THEN
        IF (ivnm1a(1:4).EQ.'uvel') THEN
          status=nf90_inq_varid(fid,'v'//TRIM(ivnm1a(2:)),rhid)
          IF (status.NE.nf90_noerr) THEN
            WRITE(*,*) 'cannot find input variable ',
     .        'v'//TRIM(ivnm1a(2:))
            STOP
          ENDIF
        ELSE   
          status=nf90_inq_varid(fid,'u'//TRIM(ivnm1a(2:)),rhid)
          IF (status.NE.nf90_noerr) THEN
            WRITE(*,*) 'cannot find input variable ',
     .        'u'//TRIM(ivnm1a(2:))
            STOP
          ENDIF
        ENDIF 
c
        status=nf90_get_var(fid,rhid,fld2,(/1,1,rec/), 
     .    (/idm,jdm,1/)) 
        CALL handle_ncerror(status) 
c
        IF (ivnm1a(1:4).EQ.'uvel') THEN
          CALL rotate_uv(idm,jdm,angle,fld,fld2)
        ELSE
          CALL rotate_uv(idm,jdm,angle,fld2,fld)
        ENDIF
      ENDIF
      ENDIF
c
c --- Apply user defined factors and linear combinations
      IF (fac1.ne.1) THEN
        fld=fld*fac1
      ENDIF
c
      IF (LEN_TRIM(ivnm1b).GT.0) THEN
        status=nf90_inq_varid(fid,TRIM(ivnm1b),rhid)
        IF (status.NE.nf90_noerr) THEN
          WRITE(*,*) 'cannot find input variable ',TRIM(ivnm1b)
          STOP
        ENDIF
        status=nf90_get_var(fid,rhid,fld2,(/1,1,rec/),
     .    (/idm,jdm,1/))
        CALL handle_ncerror(status)
        fld=fld*fld2
      ENDIF
c
      IF (LEN_TRIM(ivnm2a).GT.0) THEN
        status=nf90_inq_varid(fid,TRIM(ivnm2a),rhid)
        IF (status.NE.nf90_noerr) THEN
          WRITE(*,*) 'cannot find input variable ',TRIM(ivnm2a)
          STOP
        ENDIF
        status=nf90_get_var(fid,rhid,fld2,(/1,1,rec/),
     .    (/idm,jdm,1/))
        CALL handle_ncerror(status)
        IF (LEN_TRIM(ivnm2b).GT.0) THEN
          status=nf90_inq_varid(fid,TRIM(ivnm2b),rhid)
          IF (status.NE.nf90_noerr) THEN
            WRITE(*,*) 'cannot find input variable ',TRIM(ivnm2b)
            STOP
          ENDIF
          status=nf90_get_var(fid,rhid,fld3,(/1,1,rec/),(/idm,jdm,1/))
          CALL handle_ncerror(status)
          fld2=fld2*fld3
        ENDIF
        fld=fld+fld2*fac2
      ENDIF
c
c --- Do sea ice fraction weighting if required 
      IF (INDEX(special,'Xaiu-1').GT.0) THEN 
        ivnm1a='aice'
        status=nf90_inq_varid(fid,TRIM(ivnm1a),rhid)
        IF (status.NE.nf90_noerr) THEN
          WRITE(*,*) 'cannot find input variable ',TRIM(ivnm1a)
          STOP
        ENDIF
        status=nf90_get_var(fid,rhid,fld2,(/1,1,rec/),(/idm,jdm,1/))
        CALL handle_ncerror(status)
        DO j=1,jdm 
          DO i=1,idm   
            IF (fld2(i,j).GT.1e20) fld2(i,j)=0
          ENDDO
        ENDDO 
        DO j=1,jdm 
          j1=MIN(j+1,jdm)
          DO i=1,idm   
            i1=MOD(i,idm)+1
            fac1=0.01*0.25*(tarea(i,j)*fld2(i,j)+tarea(i1,j)*fld2(i1,j)+
     .        tarea(i,j1)*fld2(i,j1)+tarea(i1,j1)*fld2(i1,j1))/
     .        uarea(i,j)
            IF (fac1.GT.0.001.AND.fld(i,j).LT.1e20) THEN
              fld(i,j)=fld(i,j)/fac1
            ELSE
              fld(i,j)=1e20
            ENDIF
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
      INTEGER :: i,j 
c
c --- Set zero on ocean grid cells
      DO j=1,jdm
        DO i=1,idm
          IF (ABS(fld(i,j)).GT.2e20) fld(i,j)=0.
        ENDDO
      ENDDO
c      
c --- Store variable
      error_flag=cmor_write(
     .  var_id         = varid,
     .  data           = fld)
c
      END SUBROUTINE write_field



      SUBROUTINE write_tslice
c
      IMPLICIT NONE
c
      INTEGER :: i,j 
c
c --- Set missing on land grid cells
      DO j=1,jdm
        DO i=1,idm
          IF (ABS(fld(i,j)).GT.1e20) fld(i,j)=1e20
        ENDDO
      ENDDO
c
c --- Store variable
c     WRITE(*,*) 'tbnds=',tbnds  
      IF (TRIM(ovnm).EQ.'transifs') THEN
        error_flag=cmor_write(
     .    var_id         = varid,
     .    data           = reshape(fld(1:1,1:1),(/1/)),
     .    ntimes_passed  = 1,
     .    time_vals      = tval,
     .    time_bnds      = tbnds)
      ELSEIF (TRIM(tcoord).EQ.'time1') THEN
        error_flag=cmor_write(
     .    var_id         = varid,
     .    data           = fld,
     .    ntimes_passed  = 1,
     .    time_vals      = tval)
      ELSE
        IF (TRIM(zcoord).EQ.'olevel') THEN
          error_flag=cmor_write(
     .      var_id         = varid,
     .      data           = reshape(fld,(/idm,jdm,1/)),
     .      ntimes_passed  = 1,
     .      time_vals      = tval,
     .      time_bnds      = tbnds)
        ELSE
          error_flag=cmor_write(
     .      var_id         = varid,
     .      data           = fld,
     .      ntimes_passed  = 1,
     .      time_vals      = tval,
     .      time_bnds      = tbnds)
        ENDIF
      ENDIF
c
      END SUBROUTINE write_tslice


      END MODULE m_modelsice
