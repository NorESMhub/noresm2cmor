      MODULE clm2cmor_mod_main 
c
      USE netcdf 
      USE cmor_users_functions
      USE clm2cmor_mod_namelists
      USE clm2cmor_mod_utils
c
      IMPLICIT NONE 
c
c --- Netcdf variables
      INTEGER :: ncid,rhid,dimid,status
c
c --- Input file name 
      CHARACTER(LEN=slenmax) :: fnm 
c
c --- Grid dimensions and variables 
      INTEGER, SAVE :: idm,jdm,kdm 
      REAL(KIND=8), ALLOCATABLE, SAVE, DIMENSION(:) :: lon,lat,lev
      REAL(KIND=8), ALLOCATABLE, SAVE, DIMENSION(:,:) :: 
     .  lon_bnds,lat_bnds,lev_bnds
      CHARACTER(LEN=slenmax) :: zcoord,tcoord   
c
c --- Time related variables 
      LOGICAL, SAVE :: linstant
      INTEGER, SAVE :: year,month       
      REAL(KIND=8), SAVE :: tval(1),tval2(2),tbnds(2,1)
      CHARACTER(LEN=slenmax), SAVE :: calendar='noleap',calunits 
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



c --- -----------------------------------------------------------------
      CONTAINS 
c --- -----------------------------------------------------------------



      SUBROUTINE read_gridinfo_ifile 
c
      IMPLICIT NONE
c
      LOGICAL :: check 
      INTEGER :: i,j,k
      REAL :: missing
c
c --- Open first input file 
      CALL get_filename(year1,1,fnm)
      status=nf90_open(fnm,nf90_nowrite,ncid) 
      CALL handle_ncerror(status)
c
c --- Read longitudes 
      status=nf90_inq_dimid(ncid,'lon',dimid)
      CALL handle_ncerror(status)
      status=nf90_inquire_dimension(ncid,dimid,len=idm)
      CALL handle_ncerror(status)
c
      ALLOCATE(lon(idm),lon_bnds(2,idm),STAT=status) 
      IF (status.NE.0) STOP 'cannot ALLOCATE enough memory (1)'
c
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
c --- Read soil depths  
      status=nf90_inq_dimid(ncid,'levgrnd',dimid)
      CALL handle_ncerror(status)
      status=nf90_inquire_dimension(ncid,dimid,len=kdm)
      CALL handle_ncerror(status)
      ALLOCATE(lev(kdm),lev_bnds(2,kdm),STAT=status)
      IF (status.NE.0) STOP 'cannot allocate enough memory'
      status=nf90_inq_varid(ncid,'levgrnd',rhid) 
      CALL handle_ncerror(status)
      status=nf90_get_var(ncid,rhid,lev)
      CALL handle_ncerror(status)
c
c --- Compute level bounds from soil thickness      
      IF (ALLOCATED(fld)) DEALLOCATE(fld)
      ALLOCATE(fld(idm,jdm,kdm),STAT=status)
      IF (status.NE.0) STOP 'cannot allocate enough memory'
      status=nf90_inq_varid(ncid,'DZSOI',rhid) 
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
      DEALLOCATE(fld)
c
c --- Read calendar info 
      status=nf90_inq_varid(ncid,'time',rhid) 
      CALL handle_ncerror(status)
      status=nf90_get_att(ncid,rhid,'calendar',calendar) 
      CALL handle_ncerror(status)
      status=nf90_get_att(ncid,rhid,'units',calunits) 
      CALL handle_ncerror(status)
c
c --- Close file 
      status=nf90_close(ncid)
      CALL handle_ncerror(status)
c
      END SUBROUTINE read_gridinfo_ifile



      SUBROUTINE open_ofile_fixed 
c 
      IMPLICIT NONE
c
      REAL :: fac1,fac2,fac3
      INTEGER, PARAMETER :: ndimmax=10
      INTEGER :: n,ndims,dimids(ndimmax),dimlens(ndimmax)
      CHARACTER(len=slenmax) :: ivnm1,ivnm2,ivnm3
c
c --- Inquire variable units and dimensions in input file 
      status=nf90_open(fnm,nf90_nowrite,ncid)
      CALL handle_ncerror(status)
c
      CALL resolve_vnm(slenmax,ivnm,ivnm1,ivnm2,ivnm3,fac1,fac2,fac3)
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
      IF (dimlens(1).NE.idm) THEN
        WRITE(*,*) 'unexpected first dimension of variable ',
     .    TRIM(ivnm1),': ',dimlens(1),' versus idm=',idm
        STOP
      ENDIF
      IF (dimlens(2).NE.jdm) THEN
        WRITE(*,*) 'unexpected second dimension of variable ',
     .    TRIM(ivnm1),': ',dimlens(2),' versus jdm=',idm
        STOP
      ENDIF
      IF (ALLOCATED(fld)) DEALLOCATE(fld,fld2,fldacc)
      ALLOCATE(fld(idm,jdm,1),fld2(idm,jdm,1),fldacc(idm,jdm,1),
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
c --- Call CMOR setup 
      IF (verbose) THEN
        IF (createsubdirs) THEN
          error_flag=cmor_setup(inpath=TRIM(ibasedir),
     .      netcdf_file_action=CMOR_REPLACE,set_verbosity=CMOR_NORMAL,
     .      exit_control=CMOR_EXIT_ON_MAJOR,create_subdirectories=1)
        ELSE
          error_flag=cmor_setup(inpath=TRIM(ibasedir),
     .      netcdf_file_action=CMOR_REPLACE,set_verbosity=CMOR_NORMAL,
     .      exit_control=CMOR_EXIT_ON_MAJOR,create_subdirectories=0)
        ENDIF
      ELSE
        IF (createsubdirs) THEN
          error_flag=cmor_setup(inpath=TRIM(ibasedir),
     .      netcdf_file_action=CMOR_REPLACE,set_verbosity=CMOR_QUIET,
     .      exit_control=CMOR_EXIT_ON_MAJOR,create_subdirectories=1)
        ELSE
          error_flag=cmor_setup(inpath=TRIM(ibasedir),
     .      netcdf_file_action=CMOR_REPLACE,set_verbosity=CMOR_QUIET,
     .      exit_control=CMOR_EXIT_ON_MAJOR,create_subdirectories=0)
        ENDIF
      ENDIF
      IF (error_flag.NE.0) STOP 'Problem setting up CMOR'
c
c --- Load CMOR table 
      table_id=cmor_load_table(TRIM(table))
      IF (error_flag.NE.0) STOP 'Problem with loading CMOR table'
c
c --- Activate CMOR table
      CALL cmor_set_table(table_id)
      IF (error_flag.NE.0) STOP 'Problem with activating CMOR table'
c
c --- Define output dataset 
      error_flag=cmor_dataset(
     .  outpath         = obasedir,
     .  experiment_id   = experiment_id,
     .  institute_id    = institute_id,
     .  institution     = institution1,
     .  source          = source1,
     .  calendar        = calendar,
     .  realization     = realization,
     .  contact         = contact1,
     .  history         = history1,
     .  comment         = comment1,
     .  references      = references1,
     .  model_id        = model_id,
     .  forcing         = forcing1,
     .  branch_time     = branch_time, 
     .  parent_experiment_id = parent_experiment_id, 
     .  parent_experiment_rip = parent_experiment_rip)
c
c --- Define horizontal axes 
      iaxid=cmor_axis(
     .  table_entry     = 'longitude',
     .  units           = 'degrees_east',
     .  length          = idm,
     .  coord_vals      = lon,
     .  cell_bounds     = lon_bnds)
c
      jaxid=cmor_axis(
     .  table_entry     = 'latitude',
     .  units           = 'degrees_north',
     .  length          = jdm,
     .  coord_vals      = lat,
     .  cell_bounds     = lat_bnds)
c
c --- Define output variable
      varid=cmor_variable(
     .  table_entry    = TRIM(ovnm),
     .  units          = TRIM(vunits),
     .  axis_ids       = (/ iaxid, jaxid /),
     .  missing_value  = 1e20, 
     .  original_name  = TRIM(ivnm))
c
      END SUBROUTINE open_ofile_fixed



      SUBROUTINE open_ofile
c 
      IMPLICIT NONE
c
      REAL :: fac1,fac2,fac3
      INTEGER, PARAMETER :: ndimmax=10
      INTEGER :: n,ndims,dimids(ndimmax),dimlens(ndimmax)
      INTEGER :: physics_version=1,initialization_method=1
      CHARACTER(len=slenmax) :: ivnm1,ivnm2,ivnm3
c
c --- Inquire variable units and dimensions in input file 
      CALL get_filename(year1,1,fnm)
      status=nf90_open(fnm,nf90_nowrite,ncid)
      CALL handle_ncerror(status)
c
      CALL resolve_vnm(slenmax,ivnm,ivnm1,ivnm2,ivnm3,fac1,fac2,fac3)
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
        STOP
      ENDIF
      IF (dimlens(2).NE.jdm) THEN
        WRITE(*,*) 'unexpected second dimension of variable ',
     .    TRIM(ivnm1),': ',dimlens(2),' versus jdm=',idm
        STOP
      ENDIF
      IF (ndims.GT.3) THEN
        kdm=dimlens(3)
      ELSE
        kdm=1
      ENDIF
      IF (ALLOCATED(fld)) DEALLOCATE(fld,fld2,fldacc)
      ALLOCATE(fld(idm,jdm,kdm),fld2(idm,jdm,kdm),
     .  fldacc(idm,jdm,kdm),STAT=status)
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
      CALL get_timecoord(table,ovnm,tcoord)
      CALL get_vertcoord(table,ovnm,zcoord)
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
c --- Load CMOR table 
      table_id=cmor_load_table(TRIM(table))
      IF (error_flag.NE.0) STOP 'Problem with loading CMOR table'
c
c --- Activate CMOR table
      CALL cmor_set_table(table_id)
      IF (error_flag.NE.0) STOP 'Problem with activating CMOR table'
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
c
c --- Define horizontal axes 
      iaxid=cmor_axis(
     .  table_entry     = 'longitude',
     .  units           = 'degrees_east',
     .  length          = idm,
     .  coord_vals      = lon,
     .  cell_bounds     = lon_bnds)
c
      jaxid=cmor_axis(
     .  table_entry     = 'latitude', 
     .  units           = 'degrees_north',
     .  length          = jdm,
     .  coord_vals      = lat,
     .  cell_bounds     = lat_bnds)
c
c --- Define time axis 
      taxid=cmor_axis(
     .  table_entry    = TRIM(tcoord),
     .  units          = TRIM(calunits))
c
c --- Define vertical axis 
      IF (TRIM(zcoord).EQ.'sdepth') THEN
        kaxid=cmor_axis(
     .    table_entry   = TRIM(zcoord),
     .    units         = 'm',
     .    length        = kdm,
     .    coord_vals    = lev,
     .    cell_bounds   = lev_bnds)
      ENDIF
c
c --- Define output variable
      IF (TRIM(zcoord).EQ.'sdepth'.OR.TRIM(zcoord).EQ.'vegtype') THEN
        varid=cmor_variable(
     .    table_entry    = TRIM(ovnm),
     .    units          = TRIM(vunits),
     .    axis_ids       = (/ iaxid, jaxid, kaxid, taxid /),
     .    original_name  = TRIM(ivnm), 
     .    missing_value  = 1e20, 
     .    positive       = TRIM(vpositive))
      ELSE
        varid=cmor_variable(
     .    table_entry    = TRIM(ovnm),
     .    units          = TRIM(vunits),
     .    axis_ids       = (/ iaxid, jaxid, taxid /),
     .    original_name  = TRIM(ivnm),
     .    missing_value  = 1e20, 
     .    positive       = TRIM(vpositive))
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
      REAL :: fac1,fac2,fac3
      INTEGER :: ind
      CHARACTER(LEN=slenmax) :: ivnm1,ivnm2,ivnm3 
c
c --- Open input file 
      status=nf90_open(fnm,nf90_nowrite,ncid)
      CALL handle_ncerror(status)
c
c --- Read data
      CALL resolve_vnm(slenmax,ivnm,ivnm1,ivnm2,ivnm3,fac1,fac2,fac3)
      IF (verbose.AND.LEN_TRIM(ivnm2).NE.0) 
     .  write(*,*) 'Compound variable: ',trim(ivnm1),'*',
     .  fac1,'+',trim(ivnm2),'*',fac2,trim(ivnm3),'*',fac3
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
      status=nf90_close(ncid)
      CALL handle_ncerror(status)
c
      END SUBROUTINE read_field



      SUBROUTINE read_tslice(rec,badrec)
c
      IMPLICIT NONE
c
      REAL :: fac1,fac2,fac3
      INTEGER :: ind,rec
      LOGICAL :: badrec
      CHARACTER(LEN=slenmax) :: ivnm1,ivnm2,ivnm3
c
c --- Open input file 
      CALL get_filename(year,month,fnm)
      status=nf90_open(fnm,nf90_nowrite,ncid)
      CALL handle_ncerror(status)
c
c --- Read time information
      badrec=.FALSE. 
      status=nf90_inq_varid(ncid,'time',rhid)
      IF (status.NE.nf90_noerr) THEN
        WRITE(*,*) 'cannot find time variable'
        STOP
      ENDIF
      status=nf90_get_var(ncid,rhid,tval,(/rec/),(/1/))
      CALL handle_ncerror(status)
      status=nf90_inq_varid(ncid,'time_bounds',rhid)
      IF (status.NE.nf90_noerr) THEN
        WRITE(*,*) 'cannot find time_bounds variable'
        STOP
      ENDIF
      status=nf90_get_var(ncid,rhid,tbnds,(/1,rec/),(/2,1/))
      CALL handle_ncerror(status)
      IF (linstant) THEN
c --- - Exception for instantaneous 6+3 hourly data
        IF (rec.eq.1) THEN
          status=nf90_inq_varid(ncid,'time',rhid)
          CALL handle_ncerror(status)
          status=nf90_get_var(ncid,rhid,tval2,(/2/),(/2/))
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
c
c --- Read data 
      CALL resolve_vnm(slenmax,ivnm,ivnm1,ivnm2,ivnm3,fac1,fac2,fac3)
      IF (verbose.AND.rec.EQ.1.AND.LEN_TRIM(ivnm2).NE.0) 
     .  write(*,*) 'Compound variable: ',trim(ivnm1),'*',
     .  fac1,'+',trim(ivnm2),'*',fac2,trim(ivnm3),'*',fac3
      status=nf90_inq_varid(ncid,TRIM(ivnm1),rhid)
      IF (status.NE.nf90_noerr) THEN
        WRITE(*,*) 'cannot find input variable ',TRIM(ivnm1)
        STOP
      ENDIF
      IF (kdm.eq.1) THEN
        status=nf90_get_var(ncid,rhid,fld,(/1,1,rec/), 
     .    (/idm,jdm,1/)) 
      ELSE 
        status=nf90_get_var(ncid,rhid,fld,(/1,1,1,rec/), 
     .    (/idm,jdm,kdm,1/)) 
      ENDIF 
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
        IF (kdm.eq.1) THEN
          status=nf90_get_var(ncid,rhid,fld2,(/1,1,rec/),
     .      (/idm,jdm,1/))
        ELSE
          status=nf90_get_var(ncid,rhid,fld2,(/1,1,1,rec/),
     .      (/idm,jdm,kdm,1/))
        ENDIF
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
        IF (kdm.eq.1) THEN
          status=nf90_get_var(ncid,rhid,fld2,(/1,1,rec/),
     .      (/idm,jdm,1/))
        ELSE
          status=nf90_get_var(ncid,rhid,fld2,(/1,1,1,rec/),
     .      (/idm,jdm,kdm,1/))
        ENDIF
        CALL handle_ncerror(status)
        fld=fld+fld2*fac3
      ENDIF
c
      status=nf90_close(ncid)
      CALL handle_ncerror(status)
c
      END SUBROUTINE read_tslice



      SUBROUTINE write_field
c
      IMPLICIT NONE
c
c --- Set zero on ocean grid cells
      WHERE (ABS(fld).GT.2e20) 
        fld=0.
      END WHERE
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
c --- Set zero on ocean grid cells
      WHERE (ABS(fld).GT.2e20)
        fld=0.
      END WHERE
c
c --- Store variable
      IF (LEN_TRIM(zcoord).GT.0.OR.kdm.EQ.1) THEN
        IF (TRIM(tcoord).NE.'time1') THEN  
          error_flag=cmor_write(
     .      var_id         = varid,
     .      data           = fld,
     .      ntimes_passed  = 1,
     .      time_vals      = tval,
     .      time_bnds      = tbnds)
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


      END MODULE clm2cmor_mod_main
