      MODULE micom2cmor_mod_main 
c
      USE netcdf 
      USE cmor_users_functions
      USE micom2cmor_mod_namelists
      USE micom2cmor_mod_utils
c
      IMPLICIT NONE 
c
c --- Netcdf variables
      INTEGER, SAVE :: ncid,rhid,dimid,status
c
c --- Input file name 
      CHARACTER(LEN=slenmax) :: fnm 
c
c --- Grid dimensions and variables 
      REAL(KIND=8), SAVE :: voglb,aoglb
      INTEGER, SAVE :: idm,jdm,kdm=0,ddm=0,ldm=0,rdm=0,secdm=0,slenmax2
      INTEGER, PARAMETER :: ncrns=4
      INTEGER, ALLOCATABLE, SAVE, DIMENSION(:,:) :: basin
      REAL(KIND=8), ALLOCATABLE, SAVE, DIMENSION(:) :: xvec,yvec,kvec,
     .  kvechalf,sigma,depth,slat 
      REAL(KIND=8), ALLOCATABLE, SAVE, DIMENSION(:,:) :: parea,pmask,
     .  pdepth,plon,plat,ulon,ulat,vlon,vlat,slat_bnds,sigma_bnds,
     .  depth_bnds,bpini,bpinit,uscaley,vscalex,udepth,vdepth
      REAL(KIND=8), ALLOCATABLE, SAVE, DIMENSION(:,:,:) :: 
     .  plon_crns,plat_crns,ulon_crns,ulat_crns,vlon_crns,vlat_crns,
     .  plon_crnsp,plat_crnsp,ulon_crnsp,ulat_crnsp,vlon_crnsp,
     .  vlat_crnsp,dzini,sini,tini
      CHARACTER(LEN=slenmax), ALLOCATABLE, SAVE, DIMENSION(:) :: 
     .  region1,section1
      CHARACTER, ALLOCATABLE, SAVE, DIMENSION(:,:) :: region,section
      CHARACTER(LEN=slenmax),SAVE :: tcoord,zcoord,s1
c
c --- Gracitation
      REAL(KIND=8), PARAMETER :: g=9.80665,ginv=1.d0/g
c
c --- Time related variables 
      INTEGER, SAVE :: year,refyear,month       
      INTEGER, PARAMETER :: lom(12)=
     .  (/31,28,31,30,31 ,30 ,31 ,31 ,30 ,31 ,30 ,31 /),days(12)=
     .  (/0 ,31,59,90,120,151,181,212,243,273,304,334/)  
      REAL(KIND=8), SAVE :: tval(1),tbnds(2,1)
      CHARACTER(LEN=slenmax), SAVE :: calendar='noleap',calunits 
c 
c --- Dataset related variables 
      CHARACTER(LEN=slenmax), SAVE :: ivnm,ovnm,vunits,vpositive,vtype
      CHARACTER(LEN=slenmax*10), SAVE :: vcomment  
      LOGICAL, SAVE :: lsumz 
c
c --- Table related variables 
      CHARACTER(LEN=lenmax) :: table 
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
      REAL(KIND=8), ALLOCATABLE, SAVE, DIMENSION(:,:) :: sealv
      REAL(KIND=8) :: sfac,offs,fill 



c --- -----------------------------------------------------------------
      CONTAINS 
c --- -----------------------------------------------------------------



      SUBROUTINE read_gridinfo_ifile 
c
      IMPLICIT NONE
c
      LOGICAL :: check 
      INTEGER :: i,j,k,n
      REAL(KIND=8) :: missing,phiu,phil
c
c --- Open first input file 
      CALL get_filename(year1,1,fnm)
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
        ALLOCATE(sigma(kdm),sigma_bnds(2,kdm),STAT=status)
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
      status=nf90_inq_dimid(ncid,'region',dimid)
      IF (status.EQ.nf90_noerr) THEN
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
      ENDIF
c
      WRITE(*,*) 'read section'
      status=nf90_inq_dimid(ncid,'section',dimid)
      IF (status.EQ.nf90_noerr) THEN
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
      ENDIF
c
c --- Read calendar information 
      status=nf90_inq_varid(ncid,'time',rhid)
      CALL handle_ncerror(status)
      status=nf90_get_att(ncid,rhid,'calendar',calendar)
      CALL handle_ncerror(status)
      status=nf90_get_att(ncid,rhid,'units',calunits)
      CALL handle_ncerror(status)
      READ(calunits(12:15),*) refyear 
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
     .  sealv(idm,jdm),xvec(idm),yvec(jdm),kvec(kdm),
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
      status=nf90_open(ocngridfile,nf90_nowrite,ncid) 
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
      status=nf90_open(ocninitfile,nf90_nowrite,ncid) 
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



      SUBROUTINE open_ofile_fixed 
c 
      IMPLICIT NONE
c
      REAL :: fac1,fac2,fac3,fac4,fac5,fac6
      INTEGER, PARAMETER :: ndimmax=10
      INTEGER :: n,ndims,dimids(ndimmax),dimlens(ndimmax)
      CHARACTER(len=slenmax) :: coord,ivnm1,ivnm2,ivnm3,ivnm4,ivnm5,
     .  ivnm6
      REAL(KIND=8), DIMENSION(:), ALLOCATABLE   :: tmp1d
      REAL(KIND=8), DIMENSION(:,:), ALLOCATABLE :: tmp2d
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
      if (.NOT.ALLOCATED(dp)) ALLOCATE(dp(idm,jdm,kdm))
      IF (ALLOCATED(fld)) DEALLOCATE(fld,fld2,fldacc,fldtmp)
      IF (dimlens(3).EQ.kdm.AND.kdm.GT.0) THEN
        vtype='layer'
        ALLOCATE(fld(idm,jdm,kdm),fld2(idm,jdm,kdm),fldacc(idm,jdm,kdm),
     .    fldtmp(idm,jdm,kdm),STAT=status)
      ELSEIF (dimlens(3).EQ.ddm.AND.ddm.GT.0.OR.
     .  INDEX(special,'volcello').GT.0) THEN
        vtype='level'
        ALLOCATE(fld(idm,jdm,ddm),fld2(idm,jdm,ddm),fldacc(idm,jdm,ddm),
     .    fldtmp(idm,jdm,ddm),STAT=status)
      ELSEIF (dimlens(1).EQ.idm.AND.dimlens(2).EQ.jdm.AND.ndims.LE.3) 
     .  THEN
        vtype='2d'
        ALLOCATE(fld(idm,jdm,1),fld2(idm,jdm,1),fldacc(idm,jdm,1),
     .    fldtmp(idm,jdm,1),STAT=status)
      ELSEIF (dimlens(1).EQ.ldm.AND.dimlens(2).EQ.kdm) THEN
        vtype='merk'
        ALLOCATE(fld(ldm,kdm,rdm),fld2(ldm,kdm,rdm),fldacc(ldm,kdm,rdm),
     .    fldtmp(ldm,kdm,rdm),STAT=status)
      ELSEIF (dimlens(1).EQ.ldm.AND.dimlens(2).EQ.ddm) THEN
        vtype='merd'
        ALLOCATE(fld(ldm,ddm,rdm),fld2(ldm,ddm,rdm),fldacc(ldm,ddm,rdm),
     .    fldtmp(ldm,ddm,rdm),STAT=status)
      ELSEIF (dimlens(1).EQ.ldm.AND.dimlens(2).EQ.rdm) THEN
        vtype='mert'
        ALLOCATE(fld(ldm,rdm,1),fld2(ldm,rdm,1),fldacc(ldm,rdm,1),
     .    fldtmp(ldm,rdm,1),STAT=status)
      ELSEIF (dimlens(1).EQ.secdm.AND.ndims.EQ.2) THEN
        vtype='sect'
        ALLOCATE(fld(secdm,1,1),fld2(secdm,1,1),fldacc(secdm,1,1),
     .    fldtmp(secdm,1,1),STAT=status)
      ENDIF
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
      IF (TRIM(vtype).EQ.'layer'.AND..NOT.
     .  (lsumz.OR.INDEX(special,'glbave').GT.0
     .  .OR.INDEX(special,'2zos').GT.0 
     .  .OR.INDEX(special,'level1').GT.0)) THEN
        table_id=cmor_load_table(TRIM(table)//TRIM(rhotablesuff))
      ELSE 
        table_id=cmor_load_table(TRIM(table))
      ENDIF
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
      write(*,*) 'Define horizontal axes '
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
      write(*,*) 'Define horizontal grid ',TRIM(coord)
      IF (coord(1:1).EQ.'p') THEN
        grdid=cmor_grid(
     .    axis_ids=(/iaxid,jaxid/),
     .    latitude=plat,
     .    longitude=plon,
     .    latitude_vertices=plat_crnsp,
     .    longitude_vertices=plon_crnsp)
      ELSEIF (coord(1:1).EQ.'u') THEN
        grdid=cmor_grid(
     .    axis_ids=(/iaxid,jaxid/),
     .    latitude=ulat,
     .    longitude=ulon,
     .    latitude_vertices=ulat_crnsp,
     .    longitude_vertices=ulon_crnsp)
      ELSEIF (coord(1:1).EQ.'v') THEN
        grdid=cmor_grid(
     .    axis_ids=(/iaxid,jaxid/),
     .    latitude=vlat,
     .    longitude=vlon,
     .    latitude_vertices=vlat_crnsp,
     .    longitude_vertices=vlon_crnsp)
      ENDIF
c   
      CALL cmor_set_table(table_id)
      IF (error_flag.NE.0) STOP 'Problem with reactivating CMOR table'
c
c --- Define vertical axis 
      IF (TRIM(vtype).EQ.'layer'.AND..NOT.
     .  (lsumz.OR.INDEX(special,'glbave').GT.0
     .  .OR.INDEX(special,'2zos').GT.0.)) THEN 
        kaxid=cmor_axis(
     .    table           = TRIM(gridtable),
     .    table_entry     = 'olev',
     .    units           = '1',
     .    length          = kdm, 
     .    coord_vals      = kvec(1:kdm))
      ELSEIF (TRIM(vtype).EQ.'level') THEN
        kaxid=cmor_axis(
     .    table_entry     = 'depth_coord',
     .    units           = 'm',
     .    length          = ddm, 
     .    coord_vals      = depth,
     .    cell_bounds     = depth_bnds)
      ELSEIF (TRIM(zcoord).EQ.'olevel') THEN
        ALLOCATE (tmp1d(1),tmp2d(2,1))
        tmp1d(:) = (/5.d0/)
        tmp2d(:,1)=(/0.d0,10.d0/) 
        kaxid=cmor_axis(
     .    table_entry     = 'depth_coord',
     .    units           = 'm',
     .    length          = 1,
     .    coord_vals      = tmp1d, ! (/5.d0/),
     .    cell_bounds     = tmp2d) !depth_bnds) !reshape((/0.d0,10.d0/),(/2,1/)))
        DEALLOCATE (tmp1d,tmp2d)
      ENDIF
c
c --- Define output variable
      write(*,*) 'Define output variable ',TRIM(vtype)
      IF ((TRIM(vtype).EQ.'2d'.AND..NOT.(TRIM(zcoord).EQ.'olevel'.OR.
     .  INDEX(special,'glbave').GT.0.OR.INDEX(special,'2zos').GT.0.))
     .  .OR.lsumz) THEN 
        varid=cmor_variable(
     .    table_entry    = TRIM(ovnm),
     .    units          = TRIM(vunits),
     .    axis_ids       = (/grdid/),
     .    missing_value  = 1e20, 
     .    comment        = TRIM(vcomment),
     .    original_name  = TRIM(ivnm))
      ELSEIF (INDEX(special,'glbave').GT.0
     .  .OR.INDEX(special,'2zos').GT.0.) THEN
        varid=cmor_variable(
     .    table_entry    = TRIM(ovnm),
     .    units          = TRIM(vunits),
     .    axis_ids       = (/taxid/),
     .    original_name  = TRIM(ivnm),
     .    missing_value  = 1e20,
     .    comment        = TRIM(vcomment),
     .    positive       = TRIM(vpositive))
      ELSE
        varid=cmor_variable(
     .    table_entry    = TRIM(ovnm),
     .    units          = TRIM(vunits),
     .    axis_ids       = (/grdid,kaxid/),
     .    missing_value  = 1e20, 
     .    comment        = TRIM(vcomment),
     .    original_name  = TRIM(ivnm))
      ENDIF
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
      CHARACTER(len=slenmax) :: coord,ivnm1,ivnm2,ivnm3,ivnm4,ivnm5,
     .  ivnm6

      REAL(KIND=8), ALLOCATABLE   :: tmp1d(:),tmp2d(:,:)
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
      dimlens=1
      DO n=1,ndims
        status=nf90_inquire_dimension(ncid,dimids(n),len=dimlens(n))
        CALL handle_ncerror(status)
      ENDDO
      IF (.NOT.ALLOCATED(dp)) ALLOCATE(dp(idm,jdm,kdm))
      IF (ALLOCATED(fld)) DEALLOCATE(fld,fld2,fldacc,fldtmp)
      IF (dimlens(3).EQ.kdm.AND.kdm.GT.0) THEN
        vtype='layer'
        ALLOCATE(fld(idm,jdm,kdm),fld2(idm,jdm,kdm),fldacc(idm,jdm,kdm),
     .    fldtmp(idm,jdm,kdm),STAT=status)
      ELSEIF (dimlens(3).EQ.ddm.AND.ddm.GT.0) THEN
        vtype='level'
        ALLOCATE(fld(idm,jdm,ddm),fld2(idm,jdm,ddm),fldacc(idm,jdm,ddm),
     .    fldtmp(idm,jdm,ddm),STAT=status)
      ELSEIF (dimlens(1).EQ.idm.AND.dimlens(2).EQ.jdm.AND.ndims.EQ.3)
     .  THEN
        vtype='2d'
        ALLOCATE(fld(idm,jdm,1),fld2(idm,jdm,1),fldacc(idm,jdm,1),
     .    fldtmp(idm,jdm,1),STAT=status)
      ELSEIF (dimlens(1).EQ.ldm.AND.dimlens(2).EQ.kdm) THEN
        vtype='merk'
        ALLOCATE(fld(ldm,kdm,rdm),fld2(ldm,kdm,rdm),fldacc(ldm,kdm,rdm),
     .    fldtmp(ldm,kdm,rdm),STAT=status)
      ELSEIF (dimlens(1).EQ.ldm.AND.dimlens(2).EQ.ddm) THEN
        vtype='merd'
        ALLOCATE(fld(ldm,ddm,rdm),fld2(ldm,ddm,rdm),fldacc(ldm,ddm,rdm),
     .    fldtmp(ldm,ddm,rdm),STAT=status)
      ELSEIF (dimlens(1).EQ.ldm.AND.dimlens(2).EQ.rdm) THEN
        vtype='mert'
        ALLOCATE(fld(ldm,rdm,1),fld2(ldm,rdm,1),fldacc(ldm,rdm,1),
     .    fldtmp(ldm,rdm,1),STAT=status)
      ELSEIF (dimlens(1).EQ.secdm.AND.ndims.EQ.2) THEN
        vtype='sect'
        ALLOCATE(fld(secdm,1,1),fld2(secdm,1,1),fldacc(secdm,1,1),
     .    fldtmp(secdm,1,1),STAT=status)
      ENDIF
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
      IF (TRIM(vtype).EQ.'layer'.AND..NOT.
     .  (lsumz.OR.INDEX(special,'glbave').GT.0
     .  .OR.INDEX(special,'2zos').GT.0 
     .  .OR.INDEX(special,'level1').GT.0)) THEN
        table_id=cmor_load_table(TRIM(table)//TRIM(rhotablesuff))
      ELSE
        table_id=cmor_load_table(TRIM(table))
      ENDIF
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
      write(*,*) 'Define horizontal axes'
      CALL cmor_set_table(table_id_grid)
      IF (error_flag.NE.0) STOP 'Problem with activating grid table'
c
      IF (vtype(1:3).NE.'mer'.AND.vtype(1:3).NE.'sec') THEN
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
      CALL cmor_set_table(table_id)
      IF (error_flag.NE.0) STOP 'Problem with reactivating CMOR table'
c
      IF (vtype(1:3).EQ.'mer') THEN
        laxid=cmor_axis(
     .    table_entry     = 'latitude',
     .    units           = 'degrees_north',
     .    length          = ldm,
     .    coord_vals      = slat,
     .    cell_bounds     = slat_bnds)
        raxid=cmor_axis(
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
          kaxid=cmor_axis(
     .      table_entry     = 'olev',
     .      units           = '1',
     .      length          = kdm+1,
     .      coord_vals      = kvechalf)
        ELSE
          kaxid=cmor_axis(
     .      table_entry     = 'olev',
     .      units           = '1',
     .      length          = kdm,
     .      coord_vals      = kvec(1:kdm))
        ENDIF
      ELSEIF (INDEX(special,'level1').GT.0) THEN 
        kaxid=cmor_axis(
     .    table_entry     = 'depth0m',
     .    units           = 'm',
     .    length          = 1,
     .    coord_vals      = (/0/))
      ELSEIF (TRIM(vtype).EQ.'level'.OR.vtype(1:4).EQ.'merd') THEN
        kaxid=cmor_axis(
     .    table_entry     = 'depth_coord',
     .    units           = 'm',
     .    length          = ddm,
     .    coord_vals      = depth,
     .    cell_bounds     = depth_bnds)
      ELSEIF (vtype(1:4).EQ.'merk') THEN
        kaxid=cmor_axis(
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
     .    table_entry     = 'depth_coord',
     .    units           = 'm',
     .    length          = 1,
     .    coord_vals      = tmp1d, !(/5.d0/),
     .    cell_bounds     = tmp2d ) !reshape((/0.d0,10.d0/),(/2,1/)))
        DEALLOCATE(tmp1d,tmp2d)
        ELSEIF (vtype(1:3).EQ.'sec') THEN
        saxid=cmor_axis(
     .    table_entry     = 'oline',
     .    units           = '1',
     .    coord_vals      = section1) 
      ENDIF
c   
c --- Define time axis 
      write(*,*) 'Define time axis '
      taxid=cmor_axis(
     .  table_entry    = TRIM(tcoord),
     .  units          = TRIM(calunits))
c
c --- Define output variable
      write(*,*) 'Define output variable '
      IF ((TRIM(vtype).EQ.'2d'.AND..NOT.(TRIM(zcoord).EQ.'olevel'.OR.
     .  INDEX(special,'glbave').GT.0.OR.INDEX(special,'2zos').GT.0.
     .  )).OR.lsumz.AND..NOT.INDEX(special,'glbave').GT.0) THEN 
        varid=cmor_variable(
     .    table_entry    = TRIM(ovnm),
     .    units          = TRIM(vunits),
     .    axis_ids       = (/grdid,taxid/),
     .    original_name  = TRIM(ivnm),
     .    missing_value  = 1e20, 
     .    comment        = TRIM(vcomment),
     .    positive       = TRIM(vpositive))
      ELSEIF (TRIM(vtype).EQ.'layer'.AND..NOT.(TRIM(ovnm).EQ.'zfull'.OR.
     .  TRIM(ovnm).EQ.'half'.OR.INDEX(special,'glbave').GT.0
     .  .OR.INDEX(special,'2zos').GT.0.)) THEN
        varid=cmor_variable(
     .    table_entry    = TRIM(ovnm),
     .    units          = TRIM(vunits),
     .    axis_ids       = (/grdid,kaxid,taxid/),
     .    original_name  = TRIM(ivnm),
     .    missing_value  = 1e20,
     .    positive       = TRIM(vpositive), 
     .    comment        = 'Please note that the layer depth '
     .                   //'information is stored ' 
     .                   //'separately in "zfull" '
     .                   //'and "zhalf" while approximate layer '
     .                   //'density values are stored together '
     .                   //'with "msftmrhoz". '//TRIM(vcomment))      
      ELSEIF (vtype(1:4).EQ.'merd'.OR.vtype(1:4).EQ.'merk') THEN
        varid=cmor_variable(
     .    table_entry    = TRIM(ovnm),
     .    units          = TRIM(vunits),
     .    axis_ids       = (/laxid,kaxid,raxid,taxid/),
     .    original_name  = TRIM(ivnm),
     .    missing_value  = 1e20, 
     .    comment        = TRIM(vcomment),
     .    positive       = TRIM(vpositive))
      ELSEIF (vtype(1:4).EQ.'mert') THEN 
        varid=cmor_variable(
     .    table_entry    = TRIM(ovnm),
     .    units          = TRIM(vunits),
     .    axis_ids       = (/laxid,raxid,taxid/),
     .    original_name  = TRIM(ivnm),
     .    missing_value  = 1e20, 
     .    comment        = TRIM(vcomment),
     .    positive       = TRIM(vpositive))
      ELSEIF (vtype(1:4).EQ.'sect') THEN 
        varid=cmor_variable(
     .    table_entry    = TRIM(ovnm),
     .    units          = TRIM(vunits),
     .    axis_ids       = (/saxid,taxid/),
     .    original_name  = TRIM(ivnm),
     .    missing_value  = 1e20, 
     .    comment        = TRIM(vcomment),
     .    positive       = TRIM(vpositive))
      ELSEIF (INDEX(special,'glbave').GT.0
     .  .OR.INDEX(special,'2zos').GT.0.) THEN
        varid=cmor_variable(
     .    table_entry    = TRIM(ovnm),
     .    units          = TRIM(vunits),
     .    axis_ids       = (/taxid/),
     .    original_name  = TRIM(ivnm),
     .    missing_value  = 1e20,
     .    comment        = TRIM(vcomment),
     .    positive       = TRIM(vpositive))
      ELSE 
        varid=cmor_variable(
     .    table_entry    = TRIM(ovnm),
     .    units          = TRIM(vunits),
     .    axis_ids       = (/grdid,kaxid,taxid/),
     .    original_name  = TRIM(ivnm),
     .    missing_value  = 1e20, 
     .    comment        = TRIM(vcomment),
     .    positive       = TRIM(vpositive))
      ENDIF
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
      INTEGER :: ind
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
        CALL add_fixed(s1,1.)
        WHERE (fld.EQ.1e20) 
          dp=0.
        ELSEWHERE
          dp=fld
        ENDWHERE
      ENDIF 
c
      CALL resolve_vnm(slenmax,ivnm,ivnm1,ivnm2,ivnm3,ivnm4,ivnm5,ivnm6,
     .  fac1,fac2,fac3,fac4,fac5,fac6)
      fld=0.
      CALL add_fixed(ivnm1,fac1)
      CALL add_fixed(ivnm2,fac2)
      CALL add_fixed(ivnm3,fac3)
      CALL add_fixed(ivnm4,fac4)
      CALL add_fixed(ivnm5,fac5)
      CALL add_fixed(ivnm6,fac6)
c
      status=nf90_close(ncid)
      CALL handle_ncerror(status)
c
      END SUBROUTINE read_field



      SUBROUTINE read_tslice(rec)
c
      IMPLICIT NONE
c
      REAL :: fac1,fac2,fac3,fac4,fac5,fac6
      INTEGER :: ind,rec,rec1,i,j,k
      CHARACTER(len=slenmax) :: ivnm1,ivnm2,ivnm3,ivnm4,ivnm5,
     .  ivnm6
c
c --- Exception for fill day
      rec1=max(rec,1)
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
      status=nf90_get_var(ncid,rhid,tval,(/rec1/),(/1/))
      CALL handle_ncerror(status)
      IF (rec.EQ.0) tval=tval-1
c 
c --- Guess time bounds 
      IF (itag.EQ.tagyr.OR.itag.EQ.tagyrbgc) THEN 
        tbnds(1,1)=tval(1)-365*0.5       
        tbnds(2,1)=tval(1)+365*0.5       
      ELSEIF (itag.EQ.tagmon.OR.itag.EQ.tagmonbgc) THEN 
c       recompute micom's time stamp 
        tval=(year-refyear)*365+days(month)+lom(month)*0.5
        tbnds(1,1)=tval(1)-lom(month)*0.5       
        tbnds(2,1)=tval(1)+lom(month)*0.5
      ELSE
        tbnds(1,1)=tval(1)-0.5      
        tbnds(2,1)=tval(1)+0.5
      ENDIF
c
c --- correct erroneous intial time bound
      tbnds(1,1)=max(0.,tbnds(1,1))
      tval=0.5*(tbnds(1,1)+tbnds(2,1))
c
c --- Read data 
      IF (INDEX(special,'glbave3d').GT.0.OR.
     .  (INDEX(special,'2rho').GT.0.AND.vtype.EQ.'layer')
     .  .OR.INDEX(special,'2zos').GT.0) THEN 
        fld=0. 
        s1='dp'
        CALL add_tslice(s1,1.,rec1)  
        WHERE (fld.EQ.1e20) 
          dp=0.
        ELSEWHERE
          dp=fld
        ENDWHERE
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
     . INDEX(special,'strmf').GT.0.OR.INDEX(special,'Xfield2').GT.0)THEN
        fld=0.
        CALL add_tslice(ivnm2,fac2,rec1)
        fld2=fld
        fld=0.
        CALL add_tslice(ivnm1,fac1,rec1)
        IF (INDEX(special,'strmf').GT.0) THEN
          fldtmp=0.
          CALL strmf_eval(idm,jdm,kdm,fld,fld2,fldtmp)
          fld=fldtmp 
        ENDIF 
      ELSE
        fld=0. 
        CALL add_tslice(ivnm1,fac1,rec1)  
        CALL add_tslice(ivnm2,fac2,rec1)  
        CALL add_tslice(ivnm3,fac3,rec1)  
        CALL add_tslice(ivnm4,fac4,rec1)  
        CALL add_tslice(ivnm5,fac5,rec1)  
        CALL add_tslice(ivnm6,fac6,rec1)  
      ENDIF
c
c --- Read sea level height if necessary 
      IF (INDEX(special,'dz2').GT.0) THEN
        status=nf90_inq_varid(ncid,'sealv',rhid)
        IF (status.NE.nf90_noerr) THEN
          WRITE(*,*) 'cannot find input variable sealv '
          STOP
        ENDIF
        status=nf90_get_var(ncid,rhid,sealv,(/1,1,rec1/),
     .    (/idm,jdm,1/))
        CALL handle_ncerror(status)
        status=nf90_get_att(ncid,rhid,'scale_factor',sfac)
        IF (status.NE.NF90_NOERR) sfac=1.
        status=nf90_get_att(ncid,rhid,'add_offset',offs)
        IF (status.NE.NF90_NOERR) offs=0.
        status=nf90_get_att(ncid,rhid,'_FillValue',fill)
        WHERE (sealv.EQ.fill)
          sealv=1e20
        ELSEWHERE
          sealv=sealv*sfac+offs
        ENDWHERE
      ENDIF
c
      status=nf90_close(ncid)
      CALL handle_ncerror(status)
c
      END SUBROUTINE read_tslice



      SUBROUTINE add_tslice(vnm,fac,rec)
c
c --- Description: add one time slice to output variable fld
c 
      IMPLICIT NONE 
c
      CHARACTER(LEN=slenmax) :: vnm
      REAL :: fac 
      INTEGER :: rec
c
c --- Return if variable name is empty 
      IF (LEN(TRIM(vnm)).EQ.0) RETURN 
c
c --- Read time sclice  
      status=nf90_inq_varid(ncid,TRIM(vnm),rhid)
      IF (status.NE.nf90_noerr) THEN
        WRITE(*,*) 'cannot find input variable ',TRIM(vnm)
        STOP
      ENDIF
      IF (TRIM(vtype).EQ.'2d') THEN
        status=nf90_get_var(ncid,rhid,fldtmp,(/1,1,rec/),
     .    (/idm,jdm,1/))
      ELSEIF (TRIM(vtype).EQ.'layer') THEN
        status=nf90_get_var(ncid,rhid,fldtmp,(/1,1,1,rec/),
     .    (/idm,jdm,kdm,1/))
      ELSEIF (TRIM(vtype).EQ.'level') THEN
        status=nf90_get_var(ncid,rhid,fldtmp,(/1,1,1,rec/),
     .    (/idm,jdm,ddm,1/))
      ELSEIF (TRIM(vtype).EQ.'merk') THEN
        status=nf90_get_var(ncid,rhid,fldtmp,(/1,1,1,rec/),
     .    (/ldm,kdm,rdm,1/))
      ELSEIF (TRIM(vtype).EQ.'merd') THEN
        status=nf90_get_var(ncid,rhid,fldtmp,(/1,1,1,rec/),
     .    (/ldm,ddm,rdm,1/))
      ELSEIF (TRIM(vtype).EQ.'mert') THEN
        status=nf90_get_var(ncid,rhid,fldtmp,(/1,1,rec/),
     .    (/ldm,rdm,1/))
      ELSEIF (TRIM(vtype).EQ.'sect') THEN
        WRITE(*,*) 'read sections ',secdm
        status=nf90_get_var(ncid,rhid,fldtmp,(/1,rec/),
     .    (/secdm,1/))
      ENDIF
      CALL handle_ncerror(status)
      status=nf90_get_att(ncid,rhid,'scale_factor',sfac)
      IF (status.NE.NF90_NOERR) sfac=1.
      status=nf90_get_att(ncid,rhid,'add_offset',offs)
      IF (status.NE.NF90_NOERR) offs=0.
      status=nf90_get_att(ncid,rhid,'_FillValue',fill)
c
      WHERE (fldtmp.EQ.fill)
        fld=1e20
      ELSEWHERE
        fld=fld+(fldtmp*sfac+offs)*fac
      ENDWHERE
c
      END SUBROUTINE add_tslice



      SUBROUTINE add_fixed(vnm,fac)
c
c --- Description: add one time slice to output variable fld
c 
      IMPLICIT NONE
c
      CHARACTER(LEN=slenmax) :: vnm
      REAL :: fac
      INTEGER :: rec
c
c --- Return if variable name is empty 
      IF (LEN(TRIM(vnm)).EQ.0) RETURN
c
c --- Read time sclice  
      status=nf90_inq_varid(ncid,TRIM(vnm),rhid)
      IF (status.NE.nf90_noerr) THEN
        WRITE(*,*) 'cannot find input variable ',TRIM(vnm)
        STOP
      ENDIF
      status=nf90_get_var(ncid,rhid,fldtmp)
      CALL handle_ncerror(status)
      status=nf90_get_att(ncid,rhid,'scale_factor',sfac)
      IF (status.NE.NF90_NOERR) sfac=1.
      status=nf90_get_att(ncid,rhid,'add_offset',offs)
      IF (status.NE.NF90_NOERR) offs=0.
      status=nf90_get_att(ncid,rhid,'_FillValue',fill)
c
      WHERE (fldtmp.EQ.fill)
        fld=1e20
      ELSEWHERE
        fld=fld+(fldtmp*sfac+offs)*fac
      ENDWHERE
c
      END SUBROUTINE add_fixed



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
c --- Allocate field defined at interface level 
      IF (INDEX(special,'zhalf').GT.0) THEN 
        fldhalf(:,:,1)=sealv 
        fldhalf(:,:,2:kdm+1)=fld
        WHERE (ABS(fldhalf).GT.1e20) fldhalf=1e20
      ELSEIF (INDEX(special,'halfl').GT.0) THEN
        fldhalf(:,:,2:kdm+1)=fld
        WHERE (ABS(fldhalf(:,:,2)).GE.1e20) 
          fldhalf(:,:,1)=1e20
        ELSEWHERE
          fldhalf(:,:,1)=0
        ENDWHERE
      ENDIF
c
c --- Set missing on land grid cells
      IF (INDEX(special,'glbave').LE.0)  
     .  WHERE (ABS(fld).GT.1e20) fld=1e20
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
     .      .NOT.INDEX(special,'glbave').GT.0) THEN
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


      END MODULE micom2cmor_mod_main
