      MODULE clm2cmor_mod_utils 
c
      USE netcdf
      USE clm2cmor_mod_namelists
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



      SUBROUTINE resolve_vnm(smax,vnm,vnm1,vnm2,vnm3,fac1,fac2,fac3)
c
      REAL :: fac1,fac2,fac3
      INTEGER :: smax
      CHARACTER(len=*) :: vnm,vnm1,vnm2,vnm3
c 
      REAL :: r
      INTEGER :: ind
c
      fac1=1.
      fac2=1.
      fac3=1. 
c  
      IF (INDEX(vnm,'-').GT.0.AND.INDEX(vnm,'+').GT.0) then
        ind=MIN(INDEX(vnm,'-'),INDEX(vnm,'+'))
      ELSE 
        ind=MAX(INDEX(vnm,'-'),INDEX(vnm,'+'))
      ENDIF
      IF (ind.GT.0) THEN
        IF (vnm(ind:ind).EQ.'-') fac2=-fac2
        vnm1=vnm(1:(ind-1)) 
        vnm2=vnm(ind+1:smax)
        IF (INDEX(vnm2,'-').GT.0.AND.INDEX(vnm2,'+').GT.0) then
          ind=MIN(INDEX(vnm2,'-'),INDEX(vnm2,'+'))
        ELSE 
          ind=MAX(INDEX(vnm2,'-'),INDEX(vnm2,'+'))
        ENDIF
        IF (ind.GT.0) THEN
          IF (vnm2(ind:ind).EQ.'-') fac3=-fac3
          vnm3=vnm2(ind+1:smax)
          vnm2=vnm2(1:ind-1)
        ELSE
          vnm3=' '
        ENDIF
      ELSE
        vnm1=vnm
        vnm2=' '
        vnm3=' '
      ENDIF
c
      IF (INDEX(vnm1,'*').GT.0) THEN
        READ(vnm1(INDEX(vnm1,'*')+1:smax),*) r
        vnm1=vnm1(1:INDEX(vnm1,'*')-1)
        fac1=fac1*r
      ENDIF
      IF (INDEX(vnm2,'*').GT.0) THEN
        READ(vnm2(INDEX(vnm2,'*')+1:smax),*) r
        vnm2=vnm2(1:INDEX(vnm2,'*')-1)
        fac2=fac2*r
      ENDIF
      IF (INDEX(vnm3,'*').GT.0) THEN
        READ(vnm3(INDEX(vnm3,'*')+1:smax),*) r
        vnm3=vnm3(1:INDEX(vnm3,'*')-1)
        fac3=fac3*r
      ENDIF
c
      END SUBROUTINE resolve_vnm



      LOGICAL FUNCTION var_in_file(fnm,vnm) 
c
      IMPLICIT NONE
c
      REAL :: fac1,fac2,fac3
      CHARACTER(LEN=*) :: fnm,vnm
      CHARACTER(LEN=slenmax) :: vnm1,vnm2,vnm3
c
      INTEGER :: ncid,rhid,status,ind
c 
      status=nf90_open(TRIM(fnm),nf90_nowrite,ncid)
      CALL handle_ncerror(status)
c
      var_in_file=.TRUE.
      CALL resolve_vnm(slenmax,vnm,vnm1,vnm2,vnm3,fac1,fac2,fac3)
      status=nf90_inq_varid(ncid,TRIM(vnm1),rhid)
      IF (status.NE.nf90_noerr) THEN
        var_in_file=.FALSE.
          IF (verbose) WRITE(*,*)
     .      'clm2cmor: skipping variable '//TRIM(vnm)
      ENDIF 
      IF (LEN_TRIM(vnm2).GT.0) THEN
        status=nf90_inq_varid(ncid,TRIM(vnm2),rhid)
        IF (status.NE.nf90_noerr) THEN
          var_in_file=.FALSE.
            IF (verbose) WRITE(*,*)
     .        'clm2cmor: skipping variable '//TRIM(vnm)
        ENDIF
      ENDIF
      IF (LEN_TRIM(vnm3).GT.0) THEN
        status=nf90_inq_varid(ncid,TRIM(vnm3),rhid)
        IF (status.NE.nf90_noerr) THEN
          var_in_file=.FALSE.
            IF (verbose) WRITE(*,*)
     .        'clm2cmor: skipping variable '//TRIM(vnm)
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
     . '/lnd/hist/',trim(casename),'.clm2.',trim(itag),'.',y,'-',m,'.nc'
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
          c80=c80((INDEX(c80,' ')+1):)
          c80=c80((INDEX(c80,' ')+1):)
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


      END MODULE clm2cmor_mod_utils
