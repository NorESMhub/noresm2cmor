      MODULE micom2cmor_mod_utils 
c
      USE netcdf
      USE micom2cmor_mod_namelists
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



      SUBROUTINE resolve_vnm(smax,vnm,vnm1,vnm2,vnm3,vnm4,vnm5,vnm6,
     .  fac1,fac2,fac3,fac4,fac5,fac6)
c
      REAL :: fac1,fac2,fac3,fac4,fac5,fac6
      INTEGER :: smax,i
      CHARACTER(len=*) :: vnm,vnm1,vnm2,vnm3,vnm4,vnm5,vnm6
c 
      REAL :: r
      INTEGER :: ind
c
      fac1=1.
      fac2=1.
      fac3=1.
      fac4=1.
      fac5=1.
      fac6=1.
c
c --- Convert "," to "+" 
      DO i=1,smax 
        IF (vnm(i:i).EQ.',') vnm(i:i)='+'    
      ENDDO     
c
      IF (INDEX(vnm,'-').GT.0.AND.INDEX(vnm,'+').GT.0) then
        ind=MIN(INDEX(vnm,'-'),INDEX(vnm,'+'))
      ELSE
        ind=MAX(INDEX(vnm,'-'),INDEX(vnm,'+'))
      ENDIF
      IF (ind.GT.0) THEN
        IF (vnm(ind:ind).EQ.'-') fac2=-fac2
        vnm1=vnm(1:ind-1)
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
          IF (INDEX(vnm3,'-').GT.0.AND.INDEX(vnm3,'+').GT.0) then
            ind=MIN(INDEX(vnm3,'-'),INDEX(vnm3,'+'))
          ELSE
            ind=MAX(INDEX(vnm3,'-'),INDEX(vnm3,'+'))
          ENDIF
          IF (ind.GT.0) THEN
            IF (vnm3(ind:ind).EQ.'-') fac4=-fac4
            vnm4=vnm3(ind+1:smax)
            vnm3=vnm3(1:ind-1)
            IF (INDEX(vnm4,'-').GT.0.AND.INDEX(vnm4,'+').GT.0) then
              ind=MIN(INDEX(vnm4,'-'),INDEX(vnm4,'+'))
            ELSE
              ind=MAX(INDEX(vnm4,'-'),INDEX(vnm4,'+'))
            ENDIF
            IF (ind.GT.0) THEN
              IF (vnm4(ind:ind).EQ.'-') fac5=-fac5
              vnm5=vnm4(ind+1:smax)
              vnm4=vnm4(1:ind-1)
              IF (INDEX(vnm5,'-').GT.0.AND.INDEX(vnm5,'+').GT.0) then
                ind=MIN(INDEX(vnm5,'-'),INDEX(vnm5,'+'))
              ELSE
                ind=MAX(INDEX(vnm5,'-'),INDEX(vnm5,'+'))
              ENDIF
              IF (ind.GT.0) THEN
                IF (vnm5(ind:ind).EQ.'-') fac6=-fac6
                vnm6=vnm5(ind+1:smax)
                vnm5=vnm5(1:ind-1)
              ELSE
                vnm6=' '
              ENDIF
            ELSE
              vnm5=' '
              vnm6=' '
            ENDIF
          ELSE
            vnm4=' '
            vnm5=' '
            vnm6=' '
          ENDIF
        ELSE
          vnm3=' '
          vnm4=' '
          vnm5=' '
          vnm6=' '
        ENDIF
      ELSE
        vnm1=vnm
        vnm2=' '
        vnm3=' '
        vnm4=' '
        vnm5=' '
        vnm6=' '
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
      IF (INDEX(vnm4,'*').GT.0) THEN
        READ(vnm4(INDEX(vnm4,'*')+1:smax),*) r
        vnm4=vnm4(1:INDEX(vnm4,'*')-1)
        fac4=fac4*r
      ENDIF
      IF (INDEX(vnm5,'*').GT.0) THEN
        READ(vnm5(INDEX(vnm5,'*')+1:smax),*) r
        vnm5=vnm5(1:INDEX(vnm5,'*')-1)
        fac5=fac5*r
      ENDIF
      IF (INDEX(vnm6,'*').GT.0) THEN
        READ(vnm6(INDEX(vnm6,'*')+1:smax),*) r
        vnm6=vnm6(1:INDEX(vnm6,'*')-1)
        fac6=fac6*r
      ENDIF
c
      END SUBROUTINE resolve_vnm



      LOGICAL FUNCTION var_in_file(fnm,vnm) 
c
      IMPLICIT NONE
c
      REAL :: fac1,fac2,fac3,fac4,fac5,fac6
      CHARACTER(LEN=*) :: fnm,vnm
      CHARACTER(LEN=slenmax) :: vnm1,vnm2,vnm3,vnm4,vnm5,vnm6
c
      INTEGER :: ncid,rhid,status,ind
c 
      status=nf90_open(TRIM(fnm),nf90_nowrite,ncid)
      CALL handle_ncerror(status)
c
      WRITE(*,*) TRIM(FNM)
      var_in_file=.TRUE.
      CALL resolve_vnm(slenmax,vnm,vnm1,vnm2,vnm3,vnm4,vnm5,vnm6,
     .  fac1,fac2,fac3,fac4,fac5,fac6)
      status=nf90_inq_varid(ncid,TRIM(vnm1),rhid)
      IF (status.NE.nf90_noerr) THEN
        var_in_file=.FALSE.
          IF (verbose) WRITE(*,*)
     .      'micom2cmor: skipping variable '//TRIM(vnm1)
      ENDIF 
      IF (LEN_TRIM(vnm2).GT.0) THEN
        status=nf90_inq_varid(ncid,TRIM(vnm2),rhid)
        IF (status.NE.nf90_noerr) THEN
          var_in_file=.FALSE.
            IF (verbose) WRITE(*,*)
     .        'micom2cmor: skipping variable '//TRIM(vnm2)
        ENDIF
      ENDIF
      IF (LEN_TRIM(vnm3).GT.0) THEN
        status=nf90_inq_varid(ncid,TRIM(vnm3),rhid)
        IF (status.NE.nf90_noerr) THEN
          var_in_file=.FALSE.
            IF (verbose) WRITE(*,*)
     .        'micom2cmor: skipping variable '//TRIM(vnm)
        ENDIF
      ENDIF
      IF (LEN_TRIM(vnm4).GT.0) THEN
        status=nf90_inq_varid(ncid,TRIM(vnm4),rhid)
        IF (status.NE.nf90_noerr) THEN
          var_in_file=.FALSE.
            IF (verbose) WRITE(*,*)
     .        'micom2cmor: skipping variable '//TRIM(vnm)
        ENDIF
      ENDIF
      IF (LEN_TRIM(vnm5).GT.0) THEN
        status=nf90_inq_varid(ncid,TRIM(vnm5),rhid)
        IF (status.NE.nf90_noerr) THEN
          var_in_file=.FALSE.
            IF (verbose) WRITE(*,*)
     .        'micom2cmor: skipping variable '//TRIM(vnm)
        ENDIF
      ENDIF
      IF (LEN_TRIM(vnm6).GT.0) THEN
        status=nf90_inq_varid(ncid,TRIM(vnm6),rhid)
        IF (status.NE.nf90_noerr) THEN
          var_in_file=.FALSE.
            IF (verbose) WRITE(*,*)
     .        'micom2cmor: skipping variable '//TRIM(vnm)
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
      write(*,'(8a,i4.4,a,i2.2,a)') 
     .   trim(ibasedir),'/',
     .    trim(casename),'/ocn/hist/',trim(casename),'.micom.',
     .    trim(itag),'.',y,'-',m,'.nc'

      IF (INDEX(itag,'y').GT.0) THEN
        WRITE(fnm,'(8a,i4.4,a)') trim(ibasedir),'/',
     .    trim(casename),'/ocn/hist/',trim(casename),'.micom.',
     .    trim(itag),'.',y,'.nc' 
      ELSE
        WRITE(fnm,'(8a,i4.4,a,i2.2,a)') trim(ibasedir),'/',
     .    trim(casename),'/ocn/hist/',trim(casename),'.micom.',
     .    trim(itag),'.',y,'-',m,'.nc'
      ENDIF 
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
      WRITE(*,*) 'getvertcoord:tnm,vnm=',tnm(1:lenmax),vnm(1:lenmax)
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
          IF (TRIM(VNM).NE.'mfo'.AND.TRIM(VNM).NE.'thetaoga'
     .      .AND.TRIM(VNM).NE.'soga'.AND.TRIM(VNM).NE.'zosga'
     .      .AND.TRIM(VNM).NE.'zossga'.AND.TRIM(VNM).NE.'zostoga'
     .      .AND.TRIM(VNM).NE.'masso'.AND.TRIM(VNM).NE.'volo') THEN
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



      SUBROUTINE strmf_eval(idm,jdm,kdm,umflx,vmflx,strmf)
c
c-----------------------------------------------------------------------
c --- DESCRIPTION: computes stream function from h. velocity components      
c --- AUTHOR:      Mats Bentsen
c --- DATE:        feb2005  
c-----------------------------------------------------------------------
c
c
      implicit none
c
      integer idm,jdm,kdm
      real*8 umflx(idm,jdm,kdm),vmflx(idm,jdm,kdm),strmf(idm,jdm,kdm)
c
      integer i,j,ip1,jp1
c
c --- ------------------------------------------------------------------
c --- integrate the stream function with boundary condition strmf(1,1)=0
c --- ------------------------------------------------------------------
c
      WHERE (umflx.EQ.1e20) umflx=0
      WHERE (vmflx.EQ.1e20) vmflx=0
      umflx(:,:,1)=SUM(umflx,3)
      vmflx(:,:,1)=SUM(vmflx,3)
      strmf(1,1,1)=0.
c
      do j=2,jdm
        strmf(1,j,1)=strmf(1,j-1,1)-umflx(1,j-1,1)
      enddo
c
      do j=jdm,1,-1
        do i=2,idm
          strmf(i,j,1)=strmf(i-1,j,1)+vmflx(i-1,j,1) 
        enddo
      enddo
c
c --- Move reference to Greenland
      strmf=strmf-strmf(idm,jdm,1)
c
c --- ------------------------------------------------------------------
c --- interpolate the streamfunction to the p-point (also smooths)
c --- ------------------------------------------------------------------
c
      do j=1,jdm
        jp1=mod(j,jdm)+1
        do i=1,idm-1
          ip1=mod(i,idm)+1
          strmf(i,j,1)=.25*(strmf(i,j,1)+strmf(ip1,j,1)
     .                   +strmf(i,jp1,1)+strmf(ip1,jp1,1))
        enddo
      enddo
c
      END SUBROUTINE strmf_eval



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



      REAL FUNCTION rho(p,th,s)
c
c --- Description: computes in-situ density from potential temperature
c ---              and salinity 
c --- Comment: units are in cgs 
c
      IMPLICIT NONE
c
      REAL :: p,th,s
c
      REAL, PARAMETER :: 
     . a11= 9.9985372432159340e-01,a12= 1.0380621928183473e-02
     .,a13= 1.7073577195684715e-03,a14=-3.6570490496333680e-05
     .,a15=-7.3677944503527477e-06,a16=-3.5529175999643348e-06
     .,b11= 1.7083494994335439e-10,b12= 7.1567921402953455e-13
     .,b13= 1.2821026080049485e-13,a21= 1.0                   
     .,a22= 1.0316374535350838e-02,a23= 8.9521792365142522e-04
     .,a24=-2.8438341552142710e-05,a25=-1.1887778959461776e-05
     .,a26=-4.0163964812921489e-06,b21= 1.1995545126831476e-10
     .,b22= 5.5234008384648383e-13,b23= 8.4310335919950873e-14
c
      rho=(a11+(a12+a14*th+a15*s)*th+(a13+a16*s)*s+(b11+b12*th+b13*s)*p)
     .   /(a21+(a22+a24*th+a25*s)*th+(a23+a26*s)*s+(b21+b22*th+b23*s)*p)
c
      END FUNCTION rho



      REAL function p_alpha(p1,p2,th,s)
c
c --- Description: integrate specific volume with respect to pressure
c --- Comment: units are in cgs 
c
      IMPLICIT NONE
c
      REAL :: p1,p2,th,s
c
      REAL, PARAMETER ::
     . a11= 9.9985372432159340e-01,a12= 1.0380621928183473e-02
     .,a13= 1.7073577195684715e-03,a14=-3.6570490496333680e-05
     .,a15=-7.3677944503527477e-06,a16=-3.5529175999643348e-06
     .,b11= 1.7083494994335439e-10,b12= 7.1567921402953455e-13
     .,b13= 1.2821026080049485e-13,a21= 1.0
     .,a22= 1.0316374535350838e-02,a23= 8.9521792365142522e-04
     .,a24=-2.8438341552142710e-05,a25=-1.1887778959461776e-05
     .,a26=-4.0163964812921489e-06,b21= 1.1995545126831476e-10
     .,b22= 5.5234008384648383e-13,b23= 8.4310335919950873e-14
c
      REAL, PARAMETER :: r1_3=1./3.,r1_5=1./5.,r1_7=1./7.,r1_9=1./9.
c
      REAL a1,a2,b1,b2,pm,r,q,qq
c
      a1=a11+(a12+a14*th+a15*s)*th+(a13+a16*s)*s
      a2=a21+(a22+a24*th+a25*s)*th+(a23+a26*s)*s
      b1=b11+b12*th+b13*s
      b2=b21+b22*th+b23*s
c
c --- the analytic solution of the integral is
c       p_alpha=(b2*(p2-p1)
c               +(a2-a1*b2/b1)*log((a1+b1*p2)/(a1+b1*p1)))/b1
c --- a truncated series expansion of the integral is used that provide
c --- better computational efficiency and accuarcy for most relevant
c --- parameters
c
      pm=.5*(p2+p1)
      r=.5*(p2-p1)/(a1+b1*pm)
      q=b1*r
      qq=q*q
c
      p_alpha=2.*r*(a2+b2*pm
     .             +(a2-a1*b2/b1)*qq*(r1_3+qq*(r1_5+qq*(r1_7+qq*r1_9))))
c
      END FUNCTION p_alpha



      REAL FUNCTION getlpi(temp,saln,phiu,phil,pu)
c
c --- get lower pressure interface of a layer knowing the temperature,
c --- salinity of the layer and the geopotential at upper and lower
c --- interface
c
      IMPLICIT NONE
c
      REAL :: temp,saln,phiu,phil,pu
c
      REAL :: pl,q,dphi,alpu,alpl
c
c --- first guess on pressure interface
      pl=pu-rho(pu,temp,saln)*(phil-phiu)
c
c --- improve the accuracy of the pressure interface by an
c --- iterative procedure
      q=1.
      DO WHILE (ABS(q).GT.1.e-4)
        CALL delphi(pu,pl,temp,saln,dphi,alpu,alpl)
        q=(phil-phiu-dphi)/alpl
        pl=pl-q
      ENDDO
c
      getlpi=pl
c
      END FUNCTION getlpi



      SUBROUTINE delphi(p1,p2,th,s,dphi,alp1,alp2)
c
c --- integrate specific volume with respect to pressure to find the
c --- difference in geopotential between two pressure levels
c
      IMPLICIT NONE
c
      REAL p1,p2,th,s,dphi,alp1,alp2
c
      REAL, PARAMETER ::
     . a11= 9.9985372432159340e-01,a12= 1.0380621928183473e-02
     .,a13= 1.7073577195684715e-03,a14=-3.6570490496333680e-05
     .,a15=-7.3677944503527477e-06,a16=-3.5529175999643348e-06
     .,b11= 1.7083494994335439e-10,b12= 7.1567921402953455e-13
     .,b13= 1.2821026080049485e-13,a21= 1.0
     .,a22= 1.0316374535350838e-02,a23= 8.9521792365142522e-04
     .,a24=-2.8438341552142710e-05,a25=-1.1887778959461776e-05
     .,a26=-4.0163964812921489e-06,b21= 1.1995545126831476e-10
     .,b22= 5.5234008384648383e-13,b23= 8.4310335919950873e-14
c
      REAL, PARAMETER :: r1_3=1./3.,r1_5=1./5.,r1_7=1./7.,r1_9=1./9.
c
      REAL a1,a2,b1,b2,pm,r,q,qq
c
      a1=a11+(a12+a14*th+a15*s)*th+(a13+a16*s)*s
      a2=a21+(a22+a24*th+a25*s)*th+(a23+a26*s)*s
      b1=b11+b12*th+b13*s
      b2=b21+b22*th+b23*s
c
c --- the analytic solution of the integral is
c       dphi=-(b2*(p2-p1)
c             +(a2-a1*b2/b1)*log((a1+b1*p2)/(a1+b1*p1)))/b1
c --- a truncated series expansion of the integral is used that provide
c --- better computational efficiency and accuarcy for most relevant
c --- parameters
c
      pm=.5*(p2+p1)
      r=.5*(p2-p1)/(a1+b1*pm)
      q=b1*r
      qq=q*q
c
      dphi=-2.*r*(a2+b2*pm
     .           +(a2-a1*b2/b1)*qq*(r1_3+qq*(r1_5+qq*(r1_7+qq*r1_9))))
c
      alp1=(a2+b2*p1)/(a1+b1*p1)
      alp2=(a2+b2*p2)/(a1+b1*p2)
c
      END SUBROUTINE delphi

      END MODULE micom2cmor_mod_utils
