      MODULE cice2cmor_mod_main 
c
      USE netcdf 
      USE cmor_users_functions
      USE cice2cmor_mod_namelists
      USE cice2cmor_mod_utils
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
      CHARACTER(LEN=slenmax) :: tcoord,zcoord   
c
c --- Fram Strait grid info 
      INTEGER :: seclen 
      INTEGER, PARAMETER :: maxseclen=100
      INTEGER, DIMENSION(MAXSECLEN) :: iind,jind,iflg,jflg
      LOGICAL, SAVE :: lsecindex 
c
c --- Time related variables 
      INTEGER, SAVE :: year,month,expstartyearold       
      REAL(KIND=8), SAVE :: tval(1),tbnds(2,1)
      CHARACTER(LEN=slenmax), SAVE :: calendar='noleap',calunits 
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
c
c --- Data fields
      REAL(KIND=8), ALLOCATABLE, SAVE, DIMENSION(:,:) :: fld,fld2,
     .  fld3,fldacc 



c --- -----------------------------------------------------------------
      CONTAINS 
c --- -----------------------------------------------------------------



      SUBROUTINE read_gridinfo_ifile 
c
      IMPLICIT NONE
c
      LOGICAL :: check 
      INTEGER :: i,j,n
      REAL :: missing,theta,lambda
c
c --- Open first input file 
      CALL get_filename(year1,1,fnm)
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
      FORALL (i=1:idm) xvec(i)=i 
      FORALL (j=1:jdm) yvec(j)=j 
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
      CALL handle_ncerror(status)
      status=nf90_get_var(ncid,rhid,angle)
      CALL handle_ncerror(status)
      status=nf90_inq_varid(ncid,'tarea',rhid) 
      CALL handle_ncerror(status)
      status=nf90_get_var(ncid,rhid,tarea)
      CALL handle_ncerror(status)
      status=nf90_inq_varid(ncid,'uarea',rhid) 
      CALL handle_ncerror(status)
      status=nf90_get_var(ncid,rhid,uarea)
      CALL handle_ncerror(status)
c
c --- Read calendar info (override/change units)
      status=nf90_inq_varid(ncid,'time',rhid)
      CALL handle_ncerror(status)
      status=nf90_get_att(ncid,rhid,'calendar',calendar)
      CALL handle_ncerror(status)
      status=nf90_get_att(ncid,rhid,'units',calunits)
      CALL handle_ncerror(status)
      READ(calunits(12:15),*) expstartyearold 
      WRITE(calunits(12:15),'(i4.4)') expstartyear 
c     calunits='days since 0001-01-01 00:00:00'
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



      SUBROUTINE open_ofile_fixed 
c 
      IMPLICIT NONE
c
      REAL :: fac1,fac2
      INTEGER, PARAMETER :: ndimmax=10
      INTEGER :: n,ndims,dimids(ndimmax),dimlens(ndimmax)
      CHARACTER(len=slenmax) :: coord,ivnm1a,ivnm2a,ivnm1b,ivnm2b
c
c --- Inquire variable units and dimensions in input file 
      status=nf90_open(fnm,nf90_nowrite,ncid)
      CALL handle_ncerror(status)
c
      CALL resolve_vnm(slenmax,ivnm,ivnm1a,ivnm2a,ivnm1b,ivnm2b,fac1,
     .  fac2)
      status=nf90_inq_varid(ncid,TRIM(ivnm1a),rhid)
      IF (status.NE.nf90_noerr) THEN
        WRITE(*,*) 'cannot find input variable ',TRIM(ivnm1a)
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
     .    TRIM(ivnm1a),': ',dimlens(1),' versus idm=',idm
        STOP
      ENDIF
      IF (dimlens(2).NE.jdm) THEN
        WRITE(*,*) 'unexpected second dimension of variable ',
     .    TRIM(ivnm1a),': ',dimlens(2),' versus jdm=',idm
        STOP
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
      table_id_grid=cmor_load_table(TRIM(gridtable))
      IF (error_flag.NE.0) STOP 'Problem with loading grid table'
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
      CALL cmor_set_table(table_id_grid)
      IF (error_flag.NE.0) STOP 'Problem with activating grid table'
c
      iaxid=cmor_axis(
     .  table           = TRIM(gridtable),
     .  table_entry     = 'i_index',
     .  units           = '1',
     .  length          = idm,
     .  coord_vals      = xvec)
c
      jaxid=cmor_axis(
     .  table           = TRIM(gridtable),
     .  table_entry     = 'j_index',
     .  units           = '1',
     .  length          = jdm, 
     .  coord_vals      = yvec)
c
      IF (coord(1:1).EQ.'T') THEN
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
      CALL cmor_set_table(table_id)
      IF (error_flag.NE.0) STOP 'Problem with reactivating CMOR table'
c
c --- Define output variable
      varid=cmor_variable(
     .  table_entry    = TRIM(ovnm),
     .  units          = TRIM(vunits),
     .  axis_ids       = (/ grdid /),
     .  missing_value  = 1e20, 
     .  original_name  = TRIM(ivnm),
     .  comment        = TRIM(vcomment))
c
      END SUBROUTINE open_ofile_fixed



      SUBROUTINE open_ofile
c 
      IMPLICIT NONE
c
      REAL :: fac1,fac2
      INTEGER, PARAMETER :: ndimmax=10
      INTEGER :: n,ndims,dimids(ndimmax),dimlens(ndimmax)
      INTEGER :: physics_version=1,initialization_method=1
      CHARACTER(len=slenmax) :: coord,ivnm1a,ivnm2a,ivnm1b,ivnm2b
      REAL(KIND=8), DIMENSION(:), ALLOCATABLE :: tmp1d, tmp1d_2
      REAL(KIND=8), DIMENSION(:,:), ALLOCATABLE :: tmp2d
c
c --- Inquire variable units and dimensions in input file 
      CALL get_filename(year1,1,fnm)
      status=nf90_open(fnm,nf90_nowrite,ncid)
      CALL handle_ncerror(status)
c
      CALL resolve_vnm(slenmax,ivnm,ivnm1a,ivnm2a,ivnm1b,ivnm2b,fac1,
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
      CALL get_timecoord(table,ovnm,tcoord)
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
      table_id_grid=cmor_load_table(TRIM(gridtable))
      IF (error_flag.NE.0) STOP 'Problem with loading grid table'
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
      CALL cmor_set_table(table_id_grid)
      IF (error_flag.NE.0) STOP 'Problem with activating grid table'
c
      IF (TRIM(ovnm).NE.'transifs') THEN
        iaxid=cmor_axis(
     .    table           = TRIM(gridtable),
     .    table_entry     = 'i_index',
     .    units           = '1',
     .    length          = idm,
     .    coord_vals      = xvec)
        jaxid=cmor_axis(
     .    table           = TRIM(gridtable),
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
      CALL cmor_set_table(table_id)
      IF (error_flag.NE.0) STOP 'Problem with reactivating CMOR table'

c --- Define vertical dummy coordinate
      IF (TRIM(zcoord).EQ.'olevel') THEN
        ALLOCATE (tmp1d(1),tmp2d(2,1))
        tmp1d(:) = (/5.d0/)
        tmp2d(:,1) = (/0.d0,10.d0/)
        kaxid=cmor_axis(
     .    table_entry     = 'depth_coord',
     .    units           = 'm',
     .    length          = 1,
     .    coord_vals      = tmp1d, !(/5.d0/),
     .    cell_bounds     = tmp2d)! reshape((/0.d0,10.d0/),(/2,1/)))
        DEALLOCATE(tmp1d,tmp2d)
      ENDIF
c
c --- Define time axis 
      taxid=cmor_axis(
     .  table_entry    = TRIM(tcoord),
     .  units          = TRIM(calunits))
c
c --- Define output variable
      IF (TRIM(ovnm).EQ.'transifs') THEN
        varid=cmor_variable(
     .    table_entry    = TRIM(ovnm),
     .    units          = TRIM(vunits),
     .    axis_ids       = (/ taxid /),
     .    missing_value  = 1e20, 
     .    comment        = TRIM(vcomment))
      ELSE
        IF (TRIM(zcoord).EQ.'olevel') THEN
          varid=cmor_variable(
     .      table_entry    = TRIM(ovnm),
     .      units          = TRIM(vunits),
     .      axis_ids       = (/ grdid, kaxid, taxid /),
     .      original_name  = TRIM(ivnm),
     .      missing_value  = 1e20, 
     .      positive       = TRIM(vpositive),
     .      comment        = TRIM(vcomment))
        ELSE
          varid=cmor_variable(
     .      table_entry    = TRIM(ovnm),
     .      units          = TRIM(vunits),
     .      axis_ids       = (/ grdid, taxid /),
     .      original_name  = TRIM(ivnm),
     .      missing_value  = 1e20, 
     .      positive       = TRIM(vpositive),
     .      comment        = TRIM(vcomment))
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
      CALL resolve_vnm(slenmax,ivnm,ivnm1a,ivnm2a,ivnm1b,ivnm2b,fac1,
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



      SUBROUTINE read_tslice(rec)
c
      IMPLICIT NONE
c
      REAL :: fac1,fac2
      INTEGER :: ind,rec,i,j,i1,j1
      CHARACTER(len=slenmax) :: ivnm1a,ivnm2a,ivnm1b,ivnm2b
c
c --- Open input file 
      CALL get_filename(year,month,fnm)
      status=nf90_open(fnm,nf90_nowrite,ncid)
      CALL handle_ncerror(status)
c
c --- Read time information
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
c     WRITE(*,*) 'tbnds=',tbnds
c --- shift reference year according to new experiment start year
      tbnds=tbnds+365.*(expstartyearold-expstartyear)
c --- correct erroneous intial time bound
      tbnds(1,1)=max(0.,tbnds(1,1))
      tval=0.5*(tbnds(1,1)+tbnds(2,1))
c     WRITE(*,*) 'tbnds=',tbnds
c
c --- Read data 
      CALL resolve_vnm(slenmax,ivnm,ivnm1a,ivnm2a,ivnm1b,ivnm2b,fac1,
     .  fac2)
      IF (TRIM(ovnm).EQ.'transifs') THEN
        status=nf90_inq_varid(ncid,'transix',rhid)
        IF (status.NE.nf90_noerr) THEN
          WRITE(*,*) 'cannot find input variable transix'
          STOP
        ENDIF
        status=nf90_get_var(ncid,rhid,fld,(/1,1,rec/), 
     .    (/idm,jdm,1/)) 
        CALL handle_ncerror(status) 
        status=nf90_inq_varid(ncid,'transiy',rhid)
        IF (status.NE.nf90_noerr) THEN
          WRITE(*,*) 'cannot find input variable transiy'
          STOP
        ENDIF
        status=nf90_get_var(ncid,rhid,fld2,(/1,1,rec/), 
     .    (/idm,jdm,1/)) 
        CALL handle_ncerror(status) 
c --- - Compute Fram Strait transport 
        fld(1,1)=transifs(seclen,iind,jind,iflg,jflg,fld,fld2)
        WRITE(*,*) 'transifs=',fld(1,1)
        vunits='kg/s'
      ELSE
        status=nf90_inq_varid(ncid,TRIM(ivnm1a),rhid)
        IF (status.NE.nf90_noerr) THEN
          WRITE(*,*) 'cannot find input variable ',TRIM(ivnm1a)
          STOP
        ENDIF
        status=nf90_get_var(ncid,rhid,fld,(/1,1,rec/), 
     .    (/idm,jdm,1/)) 
        CALL handle_ncerror(status) 
      ENDIF 
c
c --- Rotate to east/north alignment if variable is a velocity (BYPASSED)
      IF (.FALSE.) THEN 
      IF (ivnm1a(1:4).EQ.'uvel'.OR.ivnm1a(1:4).EQ.'vvel') THEN
        IF (ivnm1a(1:4).EQ.'uvel') THEN
          status=nf90_inq_varid(ncid,'v'//TRIM(ivnm1a(2:)),rhid)
          IF (status.NE.nf90_noerr) THEN
            WRITE(*,*) 'cannot find input variable ',
     .        'v'//TRIM(ivnm1a(2:))
            STOP
          ENDIF
        ELSE   
          status=nf90_inq_varid(ncid,'u'//TRIM(ivnm1a(2:)),rhid)
          IF (status.NE.nf90_noerr) THEN
            WRITE(*,*) 'cannot find input variable ',
     .        'u'//TRIM(ivnm1a(2:))
            STOP
          ENDIF
        ENDIF 
c
        status=nf90_get_var(ncid,rhid,fld2,(/1,1,rec/), 
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
        status=nf90_inq_varid(ncid,TRIM(ivnm1b),rhid)
        IF (status.NE.nf90_noerr) THEN
          WRITE(*,*) 'cannot find input variable ',TRIM(ivnm1b)
          STOP
        ENDIF
        status=nf90_get_var(ncid,rhid,fld2,(/1,1,rec/),
     .    (/idm,jdm,1/))
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
        status=nf90_get_var(ncid,rhid,fld2,(/1,1,rec/),
     .    (/idm,jdm,1/))
        CALL handle_ncerror(status)
        IF (LEN_TRIM(ivnm2b).GT.0) THEN
          status=nf90_inq_varid(ncid,TRIM(ivnm2b),rhid)
          IF (status.NE.nf90_noerr) THEN
            WRITE(*,*) 'cannot find input variable ',TRIM(ivnm2b)
            STOP
          ENDIF
          status=nf90_get_var(ncid,rhid,fld3,(/1,1,rec/),(/idm,jdm,1/))
          CALL handle_ncerror(status)
          fld2=fld2*fld3
        ENDIF
        fld=fld+fld2*fac2
      ENDIF
c
c --- Do sea ice fraction weighting if required 
      IF (INDEX(special,'Xaiu-1').GT.0) THEN 
        ivnm1a='aice'
        status=nf90_inq_varid(ncid,TRIM(ivnm1a),rhid)
        IF (status.NE.nf90_noerr) THEN
          WRITE(*,*) 'cannot find input variable ',TRIM(ivnm1a)
          STOP
        ENDIF
        status=nf90_get_var(ncid,rhid,fld2,(/1,1,rec/),(/idm,jdm,1/))
        CALL handle_ncerror(status)
        WHERE (fld2.GT.1e20) fld2=0
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
     .  data           = fld)
c
      END SUBROUTINE write_field



      SUBROUTINE write_tslice
c
      IMPLICIT NONE
c
c --- Set missing on land grid cells
      WHERE (ABS(fld).GT.1e20)
        fld=1e20
      END WHERE
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


      END MODULE cice2cmor_mod_main
