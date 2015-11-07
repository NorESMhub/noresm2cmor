      MODULE cam2cmor_mod_main 
c
      USE netcdf 
      USE cmor_users_functions
      USE cam2cmor_mod_namelists
      USE cam2cmor_mod_utils
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
      INTEGER, SAVE :: idm,jdm,kdm,ldm,pdm 
      REAL(KIND=8), SAVE :: p0
      REAL(KIND=8), ALLOCATABLE, SAVE, DIMENSION(:) :: 
     .  lon,slon,lat,slat,lev,ilev,hyam,hybm,hyai,hybi,plevs,
     .  iilev,hyaii,hybii
      REAL(KIND=8), ALLOCATABLE, SAVE, DIMENSION(:,:) :: 
     .  lon_bnds,lat_bnds 
      CHARACTER(LEN=slenmax) :: zcoord,tcoord   
c
c --- Time related variables 
      LOGICAL, SAVE :: linstant 
      INTEGER, SAVE :: year,month       
      REAL(KIND=8), SAVE :: tval(1),tval2(2),tbnds(2,1)
      CHARACTER(LEN=slenmax), SAVE :: calendar='noleap',calunits 
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


c --- -----------------------------------------------------------------
      CONTAINS 
c --- -----------------------------------------------------------------



      SUBROUTINE read_gridinfo_ifile 
c
      IMPLICIT NONE
c
      INTEGER :: i,j
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
      ALLOCATE(lon(idm),slon(idm),lon_bnds(2,idm),STAT=status) 
      IF (status.NE.0) STOP 'cannot ALLOCATE enough memory (1)'
c
      status=nf90_inq_varid(ncid,'lon',rhid) 
      CALL handle_ncerror(status)
      status=nf90_get_var(ncid,rhid,lon)
      CALL handle_ncerror(status)
      status=nf90_inq_varid(ncid,'slon',rhid) 
      CALL handle_ncerror(status)
      status=nf90_get_var(ncid,rhid,slon)
      CALL handle_ncerror(status)
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
      CALL handle_ncerror(status)
      status=nf90_get_var(ncid,rhid,slat)
      CALL handle_ncerror(status)
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
      status=nf90_get_att(ncid,rhid,'units',calunits) 
      CALL handle_ncerror(status)
c
c --- Close file 
      status=nf90_close(ncid)
      CALL handle_ncerror(status)
c
      END SUBROUTINE read_gridinfo_ifile



      SUBROUTINE read_gridinfo_plev
c
      IMPLICIT NONE
c
      INTEGER,PARAMETER :: kmax=200 
      REAL(KIND=8) :: kvec(kmax)
      CHARACTER(LEN=200) :: c200
      LOGICAL :: fexists
c
      INQUIRE(FILE=TRIM(table),EXIST=fexists) 
      IF (.NOT.fexists) THEN
        WRITE(*,*) 'Table ',TRIM(table), ' does not exist' 
      ENDIF  
      pdm=0
      OPEN(10,FILE=TRIM(table),STATUS='OLD')
      DO
        READ(10,'(a200)') c200
        IF (INDEX(c200,'axis_entry: plev').LE.0) CYCLE
        DO
          READ(10,'(a200)') c200
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
      CLOSE(10)
c
      IF (ALLOCATED(plevs)) DEALLOCATE(plevs) 
      ALLOCATE(plevs(pdm)) 
      IF (status.NE.0) STOP 'cannot ALLOCATE enough memory (3)'  
      plevs=kvec(1:pdm)
c    
      END SUBROUTINE read_gridinfo_plev



      SUBROUTINE open_ofile_fixed 
c 
      IMPLICIT NONE
c
      REAL :: fac1,fac2,fac3,fac4,fac5,fac6
      INTEGER, PARAMETER :: ndimmax=10
      INTEGER :: n,ndims,dimids(ndimmax),dimlens(ndimmax)
      CHARACTER(len=slenmax) :: ivnm1,ivnm2,ivnm3,ivnm4,ivnm5,ivnm6
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
      IF (ALLOCATED(ifld)) DEALLOCATE(ifld,ifld2,ifldacc)
      ALLOCATE(ifld(idm,jdm,1),ifld2(idm,jdm,1),ifldacc(idm,jdm,1),
     .  STAT=status)
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
     .  original_name  = TRIM(ivnm),
     .  missing_value  = 1e20,
     .  comment        = TRIM(vcomment))

c --- Allocate memory for output variable
      IF (ALLOCATED(ofld)) DEALLOCATE(ofld)
      ALLOCATE(ofld(idm,jdm,1),STAT=status)
      IF (status.NE.0) STOP 'cannot allocate enough memory (0)'
c
      END SUBROUTINE open_ofile_fixed



      SUBROUTINE open_ofile
c 
      IMPLICIT NONE
c
      REAL :: fac1,fac2,fac3,fac4,fac5,fac6
      INTEGER, PARAMETER :: ndimmax=10
      INTEGER :: n,ndims,dimids(ndimmax),dimlens(ndimmax)
      INTEGER :: physics_version=1,initialization_method=1
      CHARACTER(len=slenmax) :: ivnm1,ivnm2,ivnm3,ivnm4,ivnm5,ivnm6
      REAL(KIND=8), DIMENSION(:), ALLOCATABLE :: tmp1d, tmp1d_2
      REAL(KIND=8), DIMENSION(:), ALLOCATABLE :: tmp2d
c
c --- Inquire variable units and dimensions in input file 
      CALL get_filename(year1,1,fnm)
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
      CALL get_timecoord(table,ovnm,tcoord)
      IF (LEN_TRIM(tcoord).EQ.0) tcoord='time'
      CALL get_vertcoord(table,ovnm,zcoord)
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
      IF (zcoord(1:4).EQ.'plev') THEN
        kaxid=cmor_axis(
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
     .    zfactor_name  = 'ps',
     .    axis_ids      = (/iaxid,jaxid,taxid/),
     .    units         = 'Pa' )
      ELSEIF (TRIM(zcoord).EQ.'alevel') THEN
        ALLOCATE (tmp1d(SIZE(lev)),tmp1d_2(SIZE(ilev)))
        tmp1d(:) =   1.d-3*lev(:)
        tmp1d_2(:) = 1.d-3*ilev(:)
        kaxid=cmor_axis(
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
     .    zfactor_name  = 'ps',                      
     .    axis_ids      = (/iaxid,jaxid,taxid/),        
     .    units         = 'Pa' )
      ELSEIF (TRIM(zcoord).EQ.'alevhalf') THEN
        ALLOCATE (tmp1d(size(ilev)),tmp1d_2(size(iilev)))
        tmp1d(:) = ilev(:)*1.d-3
        tmp1d_2(:) = iilev(:)*1.d-3 
        kaxid=cmor_axis(
     .    table_entry   = 'standard_hybrid_sigma',
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
     .    zfactor_name  = 'b',
     .    axis_ids      = (/kaxid/),
     .    zfactor_values= hybi,
     .    zfactor_bounds= hybii )
        error_flag=cmor_zfactor(
     .    zaxis_id      = kaxid,
     .    zfactor_name  = 'a',
     .    axis_ids      = (/kaxid/),
     .    zfactor_values= hyai,
     .    zfactor_bounds= hyaii )
        zfacid=cmor_zfactor(
     .    zaxis_id      = kaxid,
     .    zfactor_name  = 'ps',
     .    axis_ids      = (/iaxid,jaxid,taxid/),
     .    units         = 'Pa' )
      ENDIF
c
c --- Define output variable
      IF (zcoord(1:4).EQ.'plev'.OR.zcoord(1:4).EQ.'alev') THEN
        varid=cmor_variable(
     .    table_entry    = TRIM(ovnm),
     .    units          = TRIM(vunits),
     .    axis_ids       = (/ iaxid, jaxid, kaxid, taxid /),
     .    original_name  = TRIM(ivnm), 
     .    missing_value  = 1e20,
     .    comment        = TRIM(vcomment),
     .    positive       = TRIM(vpositive))
      ELSEIF (ndims.EQ.1) THEN
          varid=cmor_variable(
     .      table_entry    = TRIM(ovnm),
     .      units          = TRIM(vunits),
     .      axis_ids       = (/ taxid /),
     .      original_name  = TRIM(ivnm),
     .      missing_value  = 1e20,
     .      comment        = TRIM(vcomment),
     .      positive       = TRIM(vpositive))
      ELSE
        IF (lreqsst) THEN 
          varid=cmor_variable(
     .      table_entry    = TRIM(ovnm),
     .      units          = TRIM(vunits),
     .      axis_ids       = (/ iaxid, jaxid, taxid /),
     .      original_name  = TRIM(ivnm),
     .      missing_value  = 1e20,
     .      comment        = TRIM(vcomment),
     .      positive       = TRIM(vpositive))
        ELSE
          varid=cmor_variable(
     .      table_entry    = TRIM(ovnm),
     .      units          = TRIM(vunits),
     .      axis_ids       = (/ iaxid, jaxid, taxid /),
     .      original_name  = TRIM(ivnm),
     .      missing_value  = 1e20,
     .      comment        = TRIM(vcomment),
     .      positive       = TRIM(vpositive))
        ENDIF
      ENDIF

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



      SUBROUTINE read_tslice(rec,nrec,badrec)
c
      IMPLICIT NONE
c
      REAL :: fac1,fac2,fac3,fac4,fac5,fac6
      INTEGER :: ind,rec,nrec,i,j
      INTEGER, SAVE :: fid
      CHARACTER(LEN=slenmax) :: ivnm1,ivnm2,ivnm3,ivnm4,ivnm5,ivnm6
      LOGICAL :: badrec    
c
c --- Open input file 
      IF (rec.EQ.1) THEN
        CALL get_filename(year,month,fnm)
        status=nf90_open(fnm,nf90_nowrite,fid)
        CALL handle_ncerror(status)
      ENDIF
c
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
c
c --- Read data 
      CALL resolve_vnm(slenmax,ivnm,ivnm1,ivnm2,ivnm3,ivnm4,ivnm5,ivnm6,
     .  fac1,fac2,fac3,fac4,fac5,fac6)
      status=nf90_inq_varid(fid,TRIM(ivnm1),rhid)
      IF (INDEX(ivnm1,'vmr').GT.0) THEN 
          status=nf90_get_var(fid,rhid,ifld,(/rec/),(/1/))
      ELSE
        IF (status.NE.nf90_noerr) THEN
          WRITE(*,*) 'cannot find input variable ',TRIM(ivnm1)
          STOP
        ENDIF
        IF (.NOT.readdummy) THEN
          IF (kdm.eq.1) THEN
            status=nf90_get_var(fid,rhid,ifld,(/1,1,rec/), 
     .        (/idm,jdm,1/)) 
          ELSE 
            status=nf90_get_var(fid,rhid,ifld,(/1,1,1,rec/), 
     .        (/idm,jdm,kdm,1/)) 
          ENDIF 
          CALL handle_ncerror(status)
        ELSE 
          ifld=0.
        ENDIF
        IF (fac1.ne.1) THEN
          ifld=ifld*fac1
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
          CALL handle_ncerror(status)
          status=nf90_get_var(fid,rhid,phis,(/1,1,rec/),(/idm,jdm,1/))
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
      IF (rec.EQ.nrec) THEN
        status=nf90_close(fid)
        CALL handle_ncerror(status)
      ENDIF
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


      END MODULE cam2cmor_mod_main
