      MODULE cice2cmor_mod_utils 
c
      USE netcdf
      USE cice2cmor_mod_namelists
c
      IMPLICIT NONE

      
c --- -----------------------------------------------------------------
      CONTAINS
c --- -----------------------------------------------------------------

      

      INTEGER FUNCTION get_nrec(fnm)
c
      IMPLICIT NONE
c
      CHARACTER(LEN=*) :: fnm
c
      INTEGER :: ncid,dimid,status
c
      status=nf90_open(TRIM(fnm),nf90_nowrite,ncid)
      CALL handle_ncerror(status)
      status=nf90_inq_dimid(ncid,'time',dimid)
      CALL handle_ncerror(status)
      status=nf90_inquire_dimension(ncid,dimid,len=get_nrec) 
      CALL handle_ncerror(status)
      status=nf90_close(ncid)
      CALL handle_ncerror(status)
c
      END FUNCTION get_nrec



      SUBROUTINE resolve_vnm(smax,vnm,vnm1a,vnm2a,vnm1b,vnm2b,fac1,fac2)
c
      REAL :: fac1,fac2
      INTEGER :: smax
      CHARACTER(len=*) :: vnm,vnm1a,vnm2a,vnm1b,vnm2b
c 
      REAL :: r
      INTEGER :: ind
c
      vnm1a=' '
      vnm2a=' '
      vnm1b=' '
      vnm2b=' '
      fac1=1.
      fac2=1.
c
      ind=MAX(INDEX(vnm,'-'),INDEX(vnm,'+'))
      IF (INDEX(vnm,'-').GT.0) fac2=-fac2
      IF (ind.GT.0) THEN
        vnm1a=vnm(1:ind-1) 
        vnm2a=vnm(ind+1:smax)
      ELSE
        vnm1a=vnm
      ENDIF
c
      IF (INDEX(vnm1a,'*').GT.0) THEN
        READ(vnm1a(INDEX(vnm1a,'*')+1:smax),*) r
        vnm1a=vnm1a(1:INDEX(vnm1a,'*')-1)
        fac1=fac1*r
      ENDIF
      IF (INDEX(vnm2a,'*').GT.0) THEN
        READ(vnm2a(INDEX(vnm2a,'*')+1:smax),*) r
        vnm2a=vnm2a(1:INDEX(vnm2a,'*')-1)
        fac2=fac2*r
      ENDIF
c
      IF (INDEX(vnm1a,',').GT.0) THEN
        vnm1b=vnm1a(INDEX(vnm1a,',')+1:smax)
        vnm1a=vnm1a(1:INDEX(vnm1a,',')-1)
      ENDIF
      IF (INDEX(vnm2a,',').GT.0) THEN
        vnm2b=vnm2a(INDEX(vnm2a,',')+1:smax)
        vnm2a=vnm2a(1:INDEX(vnm2a,',')-1)
      ENDIF
c
      END SUBROUTINE resolve_vnm



      LOGICAL FUNCTION var_in_file(fnm,vnm) 
c
      IMPLICIT NONE
c
      REAL :: fac1,fac2
      CHARACTER(LEN=*) :: fnm,vnm
      CHARACTER(LEN=slenmax) :: vnm1a,vnm2a,vnm1b,vnm2b
c
      INTEGER :: ncid,rhid,status,ind
c 
      status=nf90_open(TRIM(fnm),nf90_nowrite,ncid)
      CALL handle_ncerror(status)
c
      var_in_file=.TRUE.
      CALL resolve_vnm(slenmax,vnm,vnm1a,vnm2a,vnm1b,vnm2b,fac1,fac2)
      status=nf90_inq_varid(ncid,TRIM(vnm1a),rhid)
      IF (status.NE.nf90_noerr) THEN
        var_in_file=.FALSE.
          IF (verbose) WRITE(*,*)
     .      'cice2cmor: skipping variable '//TRIM(vnm)
      ENDIF 
      IF (LEN_TRIM(vnm2a).GT.0) THEN
        status=nf90_inq_varid(ncid,TRIM(vnm2a),rhid)
        IF (status.NE.nf90_noerr) THEN
          var_in_file=.FALSE.
            IF (verbose) WRITE(*,*)
     .        'cice2cmor: skipping variable '//TRIM(vnm)
        ENDIF
      ENDIF
      IF (LEN_TRIM(vnm1b).GT.0) THEN
        status=nf90_inq_varid(ncid,TRIM(vnm1b),rhid)
        IF (status.NE.nf90_noerr) THEN
          var_in_file=.FALSE.
            IF (verbose) WRITE(*,*)
     .        'cice2cmor: skipping variable '//TRIM(vnm)
        ENDIF
      ENDIF
      IF (LEN_TRIM(vnm2b).GT.0) THEN
        status=nf90_inq_varid(ncid,TRIM(vnm2b),rhid)
        IF (status.NE.nf90_noerr) THEN
          var_in_file=.FALSE.
            IF (verbose) WRITE(*,*)
     .        'cice2cmor: skipping variable '//TRIM(vnm)
        ENDIF
      ENDIF
c
      status=nf90_close(ncid)
      CALL handle_ncerror(status)
c
      END FUNCTION var_in_file 



      SUBROUTINE get_filename(y,m,fnm)
c
      IMPLICIT NONE
c
      INTEGER :: y,m
      CHARACTER(LEN=*) :: fnm
c 
      LOGICAL :: fexists
c
      fnm=' '
      WRITE(fnm,'(8a,i4.4,a,i2.2,a)') trim(ibasedir),'/',trim(casename),
     . '/ice/hist/',trim(casename),'.cice.',trim(itag),'.',y,'-',m,'.nc'
      INQUIRE(FILE=TRIM(fnm),EXIST=fexists)
      IF (.NOT.fexists) THEN
        WRITE(*,*) 'File ',TRIM(fnm),' does not exist'
        STOP
      ENDIF
c
      END SUBROUTINE get_filename



      SUBROUTINE get_vertcoord(tnm,vnm,cnm)
c  
      IMPLICIT NONE
c
      CHARACTER(LEN=*)  :: tnm,vnm,cnm
c
      CHARACTER(LEN=80) :: c80
c
      OPEN(10,FILE=TRIM(tnm))
      DO
        READ(10,'(a80)') c80
        IF (INDEX(c80,'variable_entry:').LE.0) CYCLE
        c80=ADJUSTL(TRIM(c80(16:)))
        IF (c80(1:lenmax).NE.vnm(1:lenmax)) CYCLE
        DO
          READ(10,'(a80)') c80
          IF (INDEX(c80,'dimensions:').LE.0) CYCLE
          c80=ADJUSTL(TRIM(c80(12:)))
          c80=c80((INDEX(c80,' ')+1):)
          c80=c80((INDEX(c80,' ')+1):)
          IF (c80(1:4).NE.'time') THEN
            cnm=c80(1:(INDEX(c80,' ')-1))
          ELSE
            cnm=c80((INDEX(c80,' ')+1):)
          END IF
          EXIT
        END DO
        EXIT
      END DO
      CLOSE(10)
c
      END SUBROUTINE get_vertcoord



      SUBROUTINE get_timecoord(tnm,vnm,cnm)
c  
      IMPLICIT NONE
c
      CHARACTER(LEN=*)  :: tnm,vnm,cnm
c
      CHARACTER(LEN=80) :: c80
c
      OPEN(10,FILE=TRIM(tnm))
      DO
        READ(10,'(a80)') c80
        IF (INDEX(c80,'variable_entry:').LE.0) CYCLE
        c80=ADJUSTL(TRIM(c80(16:)))
        IF (c80(1:lenmax).NE.vnm(1:lenmax)) CYCLE
        DO
          READ(10,'(a80)') c80
          IF (INDEX(c80,'dimensions:').LE.0) CYCLE
          c80=ADJUSTL(TRIM(c80(12:)))
          IF (TRIM(vnm).NE.'transifs') THEN
            c80=c80((INDEX(c80,' ')+1):)
            c80=c80((INDEX(c80,' ')+1):)
          ENDIF
          IF (c80(1:4).NE.'time') THEN
            cnm=c80((INDEX(c80,' ')+1):)
          ELSE
            cnm=TRIM(c80(1:5))
          END IF
          EXIT
        END DO
        EXIT
      END DO
      CLOSE(10)
c
      END SUBROUTINE get_timecoord



      SUBROUTINE handle_ncerror(status)
c 
      IMPLICIT NONE
c
      INTEGER status
c
      IF (STATUS.NE.nf90_noerr) THEN
        WRITE(*,*) TRIM(nf90_strerror(status))
        STOP
      ENDIF
c
      END SUBROUTINE handle_ncerror



      SUBROUTINE rotate_uv(idm,jdm,angle,u,v)
c 
      IMPLICIT NONE
c
      INTEGER :: idm,jdm
      REAL, DIMENSION(idm,jdm) :: angle,u,v
c
      INTEGER :: i,j
      REAL :: urot  
c
      DO j=1,jdm
        DO i=1,idm
           urot=u(i,j)*COS(angle(i,j))-v(i,j)*SIN(angle(i,j))
           v(i,j)=u(i,j)*SIN(angle(i,j))+v(i,j)*COS(angle(i,j))
           u(i,j)=urot
        ENDDO
      ENDDO 
c
      END SUBROUTINE rotate_uv



      SUBROUTINE sphmidpnt(lambda_a, theta_a, lambda_b, theta_b,  
     .  lambda_c, theta_c)
c
c --- This subroutine computes a point (theta_c, lambda_c) on the unit
c --- sphere so that it lies on the geodesic curve defined by the points
c --- (theta_a, lambda_a) and (theta_b, lambda_b) and midway between
c --- (theta_b, lambda_b) as (theta_a, lambda_a). (Mats Bentsen 2010)
c
      IMPLICIT NONE
c
      REAL, INTENT(IN) :: theta_a, lambda_a, theta_b, lambda_b
      REAL, INTENT(OUT) :: theta_c, lambda_c
c
      REAL :: x_a, y_a, z_a, x_b, y_b, z_b, beta, x_c, y_c, z_c
c
      REAL, PARAMETER :: deg2rad=3.141592654/180.,rad2deg=1./deg2rad
c
c --- Represent the spherical coordinates as Cartesian coordinates on a
c --- unit sphere.
      x_a = cos(lambda_a*deg2rad)*cos(theta_a*deg2rad)
      y_a = cos(lambda_a*deg2rad)*sin(theta_a*deg2rad)
      z_a = sin(lambda_a*deg2rad)
c
      x_b = cos(lambda_b*deg2rad)*cos(theta_b*deg2rad)
      y_b = cos(lambda_b*deg2rad)*sin(theta_b*deg2rad)
      z_b = sin(lambda_b*deg2rad)
c
      x_c = x_a + x_b
      y_c = y_a + y_b
      z_c = z_a + z_b
c
c --- Convert from Cartesian coordinates to spherical coordinates
      theta_c = atan2(y_c, x_c)*rad2deg
      lambda_c = atan2(z_c, sqrt(x_c*x_c + y_c*y_c))*rad2deg
c
      END SUBROUTINE sphmidpnt



      SUBROUTINE sphextpnt(lambda_a, theta_a, lambda_b, theta_b,  
     .  lambda_c, theta_c)
c
c --- Description: This subroutine computes a point (theta_c, lambda_c) 
c --- on the unit sphere so that it lies on the geodesic curve defined 
c --- by the points (theta_a, lambda_a) and (theta_b, lambda_b), at 
c --- the same distance from (theta_b, lambda_b) as (theta_a, lambda_a), 
c --- but on the opposite side. (Mats Bentsen 2010) 
c
c
      IMPLICIT NONE
c
      REAL, INTENT(IN) :: theta_a, lambda_a, theta_b, lambda_b
      REAL, INTENT(OUT) :: theta_c, lambda_c
c
      REAL :: x_a, y_a, z_a, x_b, y_b, z_b, beta, x_c, y_c, z_c
c
      REAL, PARAMETER :: deg2rad=3.141592654/180.,rad2deg=1./deg2rad
c
c --- Represent the spherical coordinates as Cartesian coordinates on 
c --- a unit sphere.
      x_a = cos(lambda_a*deg2rad)*cos(theta_a*deg2rad)
      y_a = cos(lambda_a*deg2rad)*sin(theta_a*deg2rad)
      z_a = sin(lambda_a*deg2rad)
c
      x_b = cos(lambda_b*deg2rad)*cos(theta_b*deg2rad)
      y_b = cos(lambda_b*deg2rad)*sin(theta_b*deg2rad)
      z_b = sin(lambda_b*deg2rad)
c
      beta = 2*(x_a*x_b + y_a*y_b + z_a*z_b)
c
      x_c = beta*x_b - x_a
      y_c = beta*y_b - y_a
      z_c = beta*z_b - z_a
c
c --- Convert from Cartesian coordinates to spherical coordinates
      theta_c = atan2(y_c, x_c)*rad2deg
      lambda_c = atan2(z_c, sqrt(x_c*x_c + y_c*y_c))*rad2deg
c
      END SUBROUTINE sphextpnt



      SUBROUTINE read_secindex(fname,fexist,seclen,iind,jind,iflg,jflg)
c
      IMPLICIT NONE 
c
      LOGICAL :: fexist
      CHARACTER (LEN=*) :: fname 
      INTEGER :: iind(*),jind(*),iflg(*),jflg(*),seclen
c
      CHARACTER (LEN=100) :: c100
      INTEGER :: iostatus
c 
      INQUIRE(FILE=TRIM(fname),EXIST=fexist)
      IF (.NOT.fexist) RETURN 
c
      seclen=0
      OPEN(10,FILE=TRIM(fname)) 
      DO 
        c100=' '
        READ(10,'(a100)',IOSTAT=iostatus) c100 
        IF (iostatus.LT.0) EXIT 
        IF (INDEX(c100,'fram_strait').GT.0) THEN
          DO 
            c100=' '
            READ(10,'(a100)',IOSTAT=iostatus) c100 
            IF (iostatus.LT.0) EXIT 
            IF (INDEX(c100,'Name').GT.0) EXIT
            seclen=seclen+1
            READ(c100,*,IOSTAT=iostatus) iind(seclen),jind(seclen),
     .        iflg(seclen),jflg(seclen) 
            IF (iostatus.LT.0) EXIT 
          ENDDO    
        ENDIF
      ENDDO 
      CLOSE(10)
c
      END SUBROUTINE read_secindex 



      REAL FUNCTION transifs(seclen,iind,jind,iflg,jflg,fldx,fldy)
c
      IMPLICIT NONE 
c 
      INTEGER :: iind(*),jind(*),iflg(*),jflg(*),seclen
      REAL, DIMENSION(:,:) :: fldx,fldy 
c
      INTEGER :: n 
c
      transifs=0
      DO n=1,seclen 
        transifs=transifs-
     .    fldx(iind(n)-1,jind(n))*iflg(n)-  
     .    fldy(iind(n),jind(n)-1)*jflg(n) 
      ENDDO             
c
      END FUNCTION transifs


      END MODULE cice2cmor_mod_utils
