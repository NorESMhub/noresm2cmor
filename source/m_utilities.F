      MODULE m_utilities
c
      USE netcdf
      USE m_namelists
c
      IMPLICIT NONE
c 
c --- -----------------------------------------------------------------
      CONTAINS
c --- -----------------------------------------------------------------



      SUBROUTINE resolve_vnm(smax,vnm,vnm1,vnm2,vnm3,vnm4,vnm5,vnm6,
     .  fac1,fac2,fac3,fac4,fac5,fac6)
c
      REAL :: fac1,fac2,fac3,fac4,fac5,fac6
      INTEGER :: smax
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
        IF (INDEX(vnm,',').GT.0) THEN
          vnm1=vnm(1:INDEX(vnm,',')-1)
          vnm2=vnm(INDEX(vnm,',')+1:smax)
        ELSE
          vnm1=vnm
          vnm2=' '
        ENDIF
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



      SUBROUTINE resolve_vnm2(smax,vnm,vnm1a,vnm2a,vnm1b,vnm2b,fac1,
     .  fac2)
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
      END SUBROUTINE resolve_vnm2



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
      IF (status.NE.nf90_noerr) THEN
        IF (verbose) WRITE(*,*) 
     .    'WARNING: no file found for tag=',TRIM(itag),
     .    '. Will skip respective output group.' 
        var_in_file=.FALSE.
        RETURN 
      ENDIF  
c
      var_in_file=.TRUE.
      CALL resolve_vnm(slenmax,vnm,vnm1,vnm2,vnm3,vnm4,vnm5,vnm6,fac1,
     .  fac2,fac3,fac4,fac5,fac6)
      status=nf90_inq_varid(ncid,TRIM(vnm1),rhid)
      IF (status.NE.nf90_noerr) THEN
        var_in_file=.FALSE.
          IF (verbose) WRITE(*,*)
     .      'skipping variable '//TRIM(vnm)
      ENDIF
      IF (LEN_TRIM(vnm2).GT.0) THEN
        status=nf90_inq_varid(ncid,TRIM(vnm2),rhid)
        IF (status.NE.nf90_noerr) THEN
          var_in_file=.FALSE.
            IF (verbose) WRITE(*,*)
     .        'skipping variable '//TRIM(vnm)
        ENDIF
      ENDIF
      IF (LEN_TRIM(vnm3).GT.0) THEN
        status=nf90_inq_varid(ncid,TRIM(vnm3),rhid)
        IF (status.NE.nf90_noerr) THEN
          var_in_file=.FALSE.
            IF (verbose) WRITE(*,*)
     .        'skipping variable '//TRIM(vnm)
        ENDIF
      ENDIF
      IF (LEN_TRIM(vnm4).GT.0) THEN
        status=nf90_inq_varid(ncid,TRIM(vnm4),rhid)
        IF (status.NE.nf90_noerr) THEN
          var_in_file=.FALSE.
            IF (verbose) WRITE(*,*)
     .        'skipping variable '//TRIM(vnm)
        ENDIF
      ENDIF
      IF (LEN_TRIM(vnm5).GT.0) THEN
        status=nf90_inq_varid(ncid,TRIM(vnm5),rhid)
        IF (status.NE.nf90_noerr) THEN
          var_in_file=.FALSE.
            IF (verbose) WRITE(*,*)
     .        'skipping variable '//TRIM(vnm)
        ENDIF
      ENDIF
      IF (LEN_TRIM(vnm6).GT.0) THEN
        status=nf90_inq_varid(ncid,TRIM(vnm6),rhid)
        IF (status.NE.nf90_noerr) THEN
          var_in_file=.FALSE.
            IF (verbose) WRITE(*,*)
     .        'skipping variable '//TRIM(vnm)
        ENDIF
      ENDIF
c
      status=nf90_close(ncid)
      CALL handle_ncerror(status)
c
      END FUNCTION var_in_file



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



      SUBROUTINE get_vertcoord(tnm,vnm,cnm)
c  
      IMPLICIT NONE
c
      CHARACTER(LEN=*)  :: tnm,vnm,cnm
c
      CHARACTER(LEN=80) :: c80
c
cdiag WRITE(*,*) 'getvertcoord:tnm,vnm=',tnm(1:lenmax),vnm(1:lenmax)
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
     .      .AND.TRIM(VNM).NE.'masso'.AND.TRIM(VNM).NE.'volo'
     .      .AND.TRIM(VNM).NE.'transifs') THEN
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



      SUBROUTINE scan_files(reset)
c
      IMPLICIT NONE
c
      LOGICAL, INTENT(IN), OPTIONAL :: reset
c
      IF (PRESENT(reset)) THEN
        CALL get_file_info(ibasedir,casename,itag,fnm,
     .    year1,month1,yearn,monthn,exprefyear,reset,rec,tval(1),tbnd,
     .    mbnd,year,month)
      ELSE
        CALL get_file_info(ibasedir,casename,itag,fnm,
     .    year1,month1,yearn,monthn,exprefyear,.false.,rec,tval(1),tbnd,
     .    mbnd,year,month)
      ENDIF
      IF(LEN_TRIM(fnm).eq.0) THEN 
        IF (.FALSE.) WRITE(*,*) 'WARNING: no file found for ' 
     .//'case dir|tag|year1|month1|yearn|monthn: ',
     .  TRIM(ibasedir)//'/'//TRIM(casename),'|',TRIM(itag),'|',year1,'|'
     .  ,month1,'|',yearn,'|',monthn     
      ENDIF 
c
      END SUBROUTINE scan_files



      subroutine get_file_info(idir,cnam,ftag,fnam,y1,m1,y2,m2,yr,
     .  lreset,irec,tval,tbnd,mbnd,year,month)
c
      use netcdf
      implicit none
c 
      character*500 :: idir,cnam,ftag,fpre,fnam,listpath=' '
      integer :: y1,m1,y2,m2,yref,mref,dref,yr,irec
      integer,save :: y1old=0,m1old=0,y2old=0,m2old=0
      integer :: year,month
      real*8 :: tval,tbnd(2),mbnd(2)
      logical :: lreset
c
      character*500, save :: fpreold='xxx',units,calendar
      integer, save :: fstat,n,nrec,unlimdimid,ncid,rhid,rhid2,
     .           status,sstartend(2,10),nskip,irecold,toff,ndays
      real*8,save :: dnumlo,dnumhi, tbndold(2)=(/-999999.,-999999./)
      logical, save :: ltimebnds,ldone,lexist
c
c --- create file list if it does not exist already 
      listpath='/tmp/filelist_'//trim(cnam)
      inquire(file=trim(listpath),exist=lexist)
      if ((.not.lexist).or.forcefilescan) then 
cdiag   write(*,*) 'get_file_info: create new file list '
cdiag.    //trim(listpath)
        call system('find '//trim(idir)//'/'//trim(cnam)//
     .    ' -path "*/hist/*" -name "*.nc"'
     .    //' | sort > '//trim(listpath))
      else 
        continue  
cdiag   write(*,*) 'get_file_info: read existing file list '   
cdiag.    //trim(listpath)
      endif
c 
c --- check whether to start file list read from beginning or to resume 
      fpre=trim(cnam)//'.'//trim(ftag)//'.'    
      if (y1old.ne.y1.or.y2old.ne.y2.or.m1old.ne.m1
     .     .or.m2old.ne.m2.or.index(fpreold,trim(fpre))
     .     .le.0.or.tbndold(2).le.-999998..or.lreset) then
        IF (.false.) write(*,*) 'reset nskip and irecold'
        nskip=0
        irecold=0      ! CORRECT?
      endif
      if (lreset) then 
        y1old=0
        y2old=0
        m1old=0
        m2old=0
        fpreold=' '
      else
        y1old=y1
        y2old=y2
        m1old=m1
        m2old=m2
        fpreold=fpre
      endif
c
c --- loop over files 
      open(10,FILE=trim(listpath),FORM='formatted')
c     skip all files that have already been scanned       
      do n=1,nskip
        read(10,'(a500)',iostat=fstat) fnam
        if (fstat.ne.0) stop 'unexpected end of list file'
      enddo
c     continue with files that have not yet been scanned 
      ldone=.false.
      do
        read(10,'(a500)',iostat=fstat) fnam
        if (fstat.ne.0) then
          fnam=' '
          irec=0
          exit
        endif
c --- - pick out files that match fpre
        if (index(fnam,trim(fpre)).le.0) then
          nskip=nskip+1
          irecold=0
          cycle
        endif
c --- - read time information from files 
cdiag   IF (verbose) WRITE(*,*) 'Scanning file ',TRIM(fnam)
        call handle_ncerror(nf90_open(trim(fnam),nf90_nowrite,ncid))
c
        call handle_ncerror(nf90_inquire(ncid,
     .    unlimiteddimid=unlimdimid))
        call handle_ncerror(nf90_inquire_dimension(ncid,unlimdimid,
     .    len=nrec))
c
        call handle_ncerror(nf90_inq_varid(ncid,'time',rhid))
        units=' '
        call handle_ncerror(nf90_get_att(ncid,rhid,'units',units))
        call ncsevl(units,n,sstartend)
        read(units(sstartend(1,3):sstartend(1,3)+3),*) yref
        read(units(sstartend(1,4):sstartend(1,4)+1),*) mref
        read(units(sstartend(1,5):sstartend(1,5)+1),*) dref
        calendar=' '
        call handle_ncerror(nf90_get_att(ncid,rhid,'calendar',calendar))
c --- - translate time limits to date numbers
        call nccaln(trim(calendar),y1,m1,1,yref,mref,dref,ndays)
        dnumlo=ndays
        if (m2.lt.12) then
          call nccaln(trim(calendar),y2,m2+1,1,yref,mref,dref,ndays)
        else
          call nccaln(trim(calendar),y2+1,1,1,yref,mref,dref,ndays)
        endif
        dnumhi=ndays
        call nccaln(trim(calendar),y1,m1,1,yr,1,1,ndays)
        toff=dnumlo-ndays
c
        ltimebnds=.true.
        status=nf90_inq_varid(ncid,'time_bnds',rhid2)
        if (status.ne.nf90_noerr) then
          status=nf90_inq_varid(ncid,'time_bounds',rhid2)
          if (status.ne.nf90_noerr) ltimebnds=.false.
        endif
        do n=irecold+1,nrec
          irecold=n
          call handle_ncerror(nf90_get_var(ncid,rhid,tval,start=(/n/)))
          if (ltimebnds) then
            call handle_ncerror(nf90_get_var(ncid,rhid2,tbnd,
     .        start=(/1,n/),count=(/2,1/)))
          else
            tbnd=tval
          endif
c --- --- check if time value lies within limits
          call nccaln(trim(calendar),yref,mref,dref,y1,m1,1,ndays)
          dnumlo=ndays
          if (m2.lt.12) then
            call nccaln(trim(calendar),yref,mref,dref,y2,m2+1,1,ndays)
          else
            call nccaln(trim(calendar),yref,mref,dref,y2+1,1,1,ndays)
          endif
          dnumhi=ndays
          if (tbnd(1).ge.dnumlo.and.tbnd(2).le.dnumhi) then
            irec=n
            tval=tval+toff
            tbnd=tbnd+toff
            tbndold=tbnd+toff
            ldone=.true.
            exit
          elseif (tbnd(1).ge.dnumhi) then
            irec=0
            tval=-999.
            tbnd=-999.
            ldone=.true.
            exit
          endif
        enddo
        if (irecold.eq.nrec) then
          irecold=0
          nskip=nskip+1
        endif
        call handle_ncerror(nf90_close(ncid))
        if (ldone) then
          exit
        endif
      enddo
      close(10)
c 
c --- get bounds of month 
      call tbndmon(calendar,yr,0.5*(tbnd(1)+tbnd(2)),mbnd,year,month)
c
      end subroutine get_file_info



      subroutine tbndmon(calendar,yref,tval,tbnd,year,month)
c
      implicit none
c
      character(*) :: calendar
      integer :: yref,year,month
      real*8 :: tval,tbnd(2)
c
      integer :: y1,m1,y2,m2,ndays,ndayslast
c
      ndays=0
      y2=yref
      m2=1
      do while (ndays.lt.tval)
        ndayslast=ndays
        call nccaln(calendar,yref,1,1,y2,m2,1,ndays)
        year=y1
        month=m1
        y1=y2
        m1=m2
        if (m2.eq.12) then
          y2=y2+1
          m2=1
        else
          m2=m2+1
        endif
      end do
      tbnd(1)=ndayslast
      tbnd(2)=ndays
c 
      end subroutine



      subroutine ncsevl(strg,strgn,strgind)
c
c ----------------------------------------------------------------------
c --- Description:
c       Finds the number and the locations of sub-strings. 
c       Valid deliminators are ' ', '-' and ':'.  
c
c --- Arguments:
c       char(*) strg   (in)  -  input string
c       int strgn      (out) -  number of sub-strings
c       int strgind(*) (out) -  start/end locations of sub-strings (the
c                              dimension must at least equal to strgn*2)
c ----------------------------------------------------------------------
c
      implicit none
c
      character*(*) strg
      character charold,charnew
      integer strgn,strgind(*),i
c
      charold=' '
      strgn=0
      do i=1,len(strg)
         charnew=strg(i:i)
         if((charold.eq.' '.or.charold.eq.'-'.or.charold.eq.':').and.
     .      (charnew.ne.' '.and.charnew.ne.'-'.and.charnew.ne.':'))then
            strgn=strgn+1
            strgind(strgn)=i
         elseif((charnew.eq.' '.or.charnew.eq.'-'.or.charnew.eq.':')
     .    .and.(charold.ne.' '.and.charold.ne.'-'.and.charold.ne.':'))
     .   then
            strgn=strgn+1
            strgind(strgn)=i-1
         endif
         charold=charnew
      enddo
      if(mod(strgn,2).eq.1)then
         strgn=strgn+1
         strgind(strgn)=len(strg)
      endif
      strgn=int(strgn/2.)
c
      end subroutine ncsevl



      subroutine ncdnum(calendar,year,month,day,ndays)
c
c ----------------------------------------------------------------------
c --- Description:
c       Auxilary subroutine for nccaln which calculates the number
c       of days between a given date and a reference date. Thereby the
c       reference date varies from calendar to calendar and is not
c       standerized. The purpose is more of differential nature rather
c       than to create an absolute time axis.
c ----------------------------------------------------------------------
c
      implicit none
c
      character*(*) calendar
      integer y,m,year,month,day,yr1,yr4,yr100,yr400,ndays
      integer acc_leap(12),acc_noleap(12),yoffset
      parameter(yoffset=1000000,yr1=365,yr4=1461,yr100=36524,
     .   yr400=146097)
      data acc_leap   /0,31,60,91,121,152,182,213,244,274,305,335/
      data acc_noleap /0,31,59,90,120,151,181,212,243,273,304,334/
c
      y=year+yoffset
      if(calendar(1:3).eq.'pro')then
         ndays=int((y-1)/400.)*yr400
     .      + int(mod((y-1),400)/100.)*yr100
     .      + int(mod(mod((y-1),400),100)/4.)*yr4
     .      + mod(mod(mod((y-1),400),100),4)*yr1
         if(month.gt.2.and.((mod(y,4).eq.0.and.mod(y,100).ne.0).or.
     .      mod(y,400).eq.0))then
            ndays=ndays+acc_leap(month)+day
         else
            ndays=ndays+acc_noleap(month)+day
         endif
      elseif(calendar(1:3).eq.'jul')then
         ndays=int((y-1)/4.)*yr4+mod(y,4)*yr1
         if(month.gt.2.and.mod(y,4).eq.0)then
            ndays=ndays+acc_leap(month)+day
         else
            ndays=ndays+acc_noleap(month)+day
         endif
      elseif(calendar(1:3).eq.'360')then
         ndays=(y-1)*360+30*(month-1)+day
      elseif(calendar(1:2).eq.'no'.or.calendar(1:3).eq.'365')then
         ndays=(y-1)*365+acc_noleap(month)+day
      elseif(calendar(1:3).eq.'all'.or.calendar(1:3).eq.'366')then
         ndays=(y-1)*366+acc_leap(month)+day
      endif
c
      end subroutine ncdnum



      subroutine nccaln(calendar,y1,m1,d1,y2,m2,d2,ndays)
c
c ----------------------------------------------------------------------
c --- Description:
c       nccaln calculates the number of days between two
c       dates. Valid calendars are '360_day', 'noleap' = '365_day',
c       'all_leap' = '366_day', 'julian', 'proleptic_gregorian' and
c       'standard' = 'mixed' = 'gregorian'.
c
c --- Arguments:
c       int nccaln       (out) -  number of days
c       char(*) calendar (in)  -  choice of calendar
c       int y1           (in)  -  start year
c       int m1           (in)  -  start month
c       int d1           (in)  -  start day
c       int y2           (in)  -  last year
c       int m2           (in)  -  last month
c       int d2           (in)  -  last day
c ----------------------------------------------------------------------
c
      implicit none
c
      character*(*) calendar
      integer n1,y1,m1,d1,n2,y2,m2,d2,nd1,nd2,nd3,ndays
c
      if(calendar(1:3).eq.'sta'.or.calendar(1:3).eq.'mix'.or.
     .   calendar(1:3).eq.'gre')then
         if(y1.lt.1582.or.(y1.eq.1582.and.m1.lt.10).or.
     .      (y1.eq.1582.and.m1.eq.10.and.d1.le.15))then
            call ncdnum('julian',y1,m1,d1,n1)
         else
            call ncdnum('julian',1582,10,15,nd1)
            call ncdnum('proleptic',1582,10,15,nd2)
            call ncdnum('proleptic',y1,m1,d1,nd3)
            n1=nd1-nd2+nd3-10
         endif
         if(y2.lt.1582.or.(y2.eq.1582.and.m2.lt.10).or.
     .      (y2.eq.1582.and.m2.eq.10.and.d2.le.15))then
            call ncdnum('julian',y2,m2,d2,n2)
         else
            call ncdnum('julian',1582,10,15,nd1)
            call ncdnum('proleptic',1582,10,15,nd2)
            call ncdnum('proleptic',y2,m2,d2,nd3)
            n2=nd1-nd2+nd3-10
         endif
      else
         call ncdnum(calendar,y1,m1,d1,n1)
         call ncdnum(calendar,y2,m2,d2,n2)
      endif
      ndays=n2-n1
c
      end subroutine nccaln



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



      SUBROUTINE VINTH2PECMWF(DATI,DATO,HBCOFA,HBCOFB,P0,PLEVI,PLEVO,
     +                         INTYP,PSFC,SPVL,KXTRP,IMAX,NLAT,
     +                         NLEVI,NLEVIP1,NLEVO,VARFLG,TBOT,PHIS)
C
C****     THIS ROUTINE INTERPLOATES CCM2/3 HYBRID COORDINATE DATA
C****     TO PRESSURE COORDINATES USING PRESSURE SURFACES AS THE
C****     COORDINATE SURFACE WHERE THE INTERPOLATION IS DONE.  THE
C****     TYPE OF INTERPOLATION IS CURRENTLY A VARIANT OF TRANSFORMED
C****     PRESSURE COORDINATES WITH THE  INTERPOLATION TYPE
C****     SPECIFIED BY INTYP.  ALL HYBRID COORDINATE VALUES ARE
C****     TRANSFORMED TO PRESSURE VALUES. WHERE THE
C****     FORMULA FOR THE PRESSURE OF A HYBRID SURFACE IS;
C****          P(K) = HBCOFA(LEVH,K)*P0 + HBCOFB(LEVH,K)*PSFC
C****     WHERE, 
C****          HBCOFA - IS THE "A" OR PRESSURE HYBRID COEF
C****          LEVH   - IS THE LAYER SURFACE (INTERFACE=1 MIDPOINT=2)
C****          P0     - IS THE BASE PRESSURE IN MB
C****          K      - THE LEVEL INDEX (RUNNING FROM TOP TO BOTTOM)
C****          HBCOFB - IS THE "B" OR SIGMA COEFICIENT
C****          P(K)   - IS THE PRESSURE OF A HYBRID SURFACE IN MB.
C****          PSFC   - IS THE SURFACE PRESSURE IN PASCALS
C****                   (MB = .01*PASCALS
C
C****     FOR HYBRID DATA AT LEVEL INTERFACES SINCE THERE IS ONE
C****     MORE VERTICAL LEVEL FOR INTERFACES THAN FOR LEVEL MIDPOINTS
C****     IT IS ASSUNMED THAT THE FIRST INTERFACE LEVEL WITH A DATA
C****     VALUE IS THE SECOND LEVEL FROM THE TOP.
C
C****     ON INPUT-
C****        DATI    - 3 DIMENSIONAL ARRAY (I,J,KI) CONTAINING DATA
C****                  ON HYBRID SURFACES  WHERE I IS LONGTIUDE, J
C****                  IS LATITUDE AND K IS THE VERTICAL HYBRID
C****                  COORDINATE.  THE VERTICAL DATA RUN TOP TO BOTTOM.
C****                  SIGMA DATA WITH THE DATA ORDERED TOP TO BOTTOM.
C****        HBCOFA  - 2 DIMENSIONAL ARRAY CONTAINING "A" OR PRESSURE
C****                  COEFICIENTS FOR COMPUTING PRESSURE AT A LEVEL.
C****                  ARRAY IS 2XNLEVIP1.  THE 1ST INDEX TAKES ON
C****                  THE VALUE OF EITHER
C****                   1 - FOR LEVEL INTERFACES (OR 1/2 LEVELS) OR;
C****                   2 - FOR LEVEL MIDPOINTS  (OR FULL LEVELS WHERE
C****                       VIRTUALLY ALL VARIABLES ARE LOCATED)
C****                  NOTE THAT COEFICIENTS ARE SCALED TO YIELD A
C****                  PRESSURE IN MB.  THEY ARE ORDERED FROM TOP
C****                  OF THE MODEL TO THE BOTTOM.
C****        HBCOFB  - SAME AS HCOFA BUT FOR THE "B" OR SIGMA COEFICIENT
C****        P0      - BASE PRESSURE IN MB FOR COMPUTING PRESSURE
C****                  OF A HYBRID COORDINATE LEVEL
C****        PLEVI -  1 DIMENSIONAL ARRAY TO HOLD PRESSURE VALUES
C****                  OF HYBRID SURFACES FOR A VERTICAL COLUMN
C****                  SLICE
C****        PLEVO   - LIST OF OUTPUT PRESSURE SURFACES IN MB
C****                  LOW TO HIGH PRESSURE
C****        INTYP   - A FLAG INDICATING INTERPOLATION FOR EACH
C****                  FIELD (1 - LINEAR,2 - LOG ,3 - LOG LOG)
C****                  WHERE EACH INTERPOLATION IS DONE IN TRANSFORMED
C****                  PRESSURE COORDINATES.
C****        PSFC    - MODEL SFC PRESSURE IN PASCALS (WILL BE CONVERTED
C****                  TO MB)
C****        VCOLI   - ARRAY TO STORE A LONGITUDINAL VERTICAL SLICE OF
C****                  INPUT DATA (IMAX BY NLEVI).
C****        VCOLO   - SAME BUT FOR OUTPUT DATA (IMAX BY NLEVO)
C****        IMAX    - LONGITUDINAL DIMENSION OF THE DATA.
C****        NLAT    - LATITUDINAL DIMENSION OF THE DATA.
C****        NLEVI   - NO. OF LEVELS FOR THE HYBRID DATA
C****        NLEVIP1 - NLEVI + 1
C****        NLEVO   - NUMBER OF OUTPUT LEVELS FOR PRESSURE DATA
C****        KXTRP   - FLAG WHICH INDICATES WHETHER OR NOT
C****                  EXTRAPOLATION WILL BE USED WHEN THE OUTPUT
C****                  PRESSURE SURFACE IS BELOW THE LOWEST LEVEL
C****                  OF THE MODEL.
C****                     0 - DON'T EXTRAPOLATE USE SPECIAL VALUE SPVL
C****                     1 - EXTRAPOLATE DATA using ECMWF formulation
c****                         below PSFC
C****        SPVL    - SPECIAL VALUE TO USE WHEN DATA IS NOT
C****                  EXTRAPOLATED
C****        varflg  - flag which indicates the name of the variable
c****                  -1 means geopotential (Z)
c****                  +1 means geopotential (T)
c****                   0 any other variable
c****        tbot    - temperature at level closest to ground
c****        phis    - surface geopotential
C
C****     ON OUTPUT-
C****        DATO  - 3 DIMENSIONAL ARRAY TO HOLD DATA INTERPOLATED
C****                TO PRESSURE SURFACES.
C
      IMPLICIT NONE
      REAL*8 DATI,DATO,SPVL,HBCOFA,HBCOFB,PLEVI,PLEVO,PSFC,P0
      REAL*8 A2LN,A1
      INTEGER INTYP,ILEV,IMAX,NLAT,NLEVI,NLEVIP1,NLEVO,KXTRP
      INTEGER I,J,K,KP,KPI,IPRINT
C
      DIMENSION DATI(IMAX,NLAT,NLEVI),DATO(IMAX,NLAT,NLEVO),
     +          HBCOFA(NLEVIP1),HBCOFB(NLEVIP1),PLEVI(NLEVIP1),
     +          PLEVO(NLEVO),PSFC(IMAX,NLAT)

      INTEGER VARFLG
      REAL*8 TBOT,PHIS,TSTAR,HGT,ALNP,T0,TPLAT,TPRIME0,ALPHA,
     +                 ALPH,PSFCMB
      DIMENSION TBOT(IMAX,NLAT),PHIS(IMAX,NLAT)
C NCLEND

c for ecmwf extrapolation
      REAL*8 RD,GINV
      PARAMETER (RD=287.04D0)
      PARAMETER (GINV=1.D0/9.80616D0)
      PARAMETER (ALPHA=0.0065D0*RD*GINV)
C
C
C
C****     STATEMENT FCN. FOR DOUBLE LOG. INTERP ON PRESSURE SURFACES
C****     PRESUMES PRESSURE IS IN MB
C
      A2LN(A1) = LOG(LOG(A1+2.72D0))
C
C****     STATEMENT FCN. FOR DOUBLE LOG. INTERP ON SIGMA SURFACES.
C****     SETS UP ROUGH UPPER BPOUND SIMILAR TO STATEMENT FCN FOR
C****     PRESSURE. I.E.    FIXED VALUE LN(LN(P) = LN(LN(FIXED VAL)
C****     AT .001 SIGMA OR ABOUT 1 MB
C
C     A2LN(A1)=LOG(LOG(A1+1.001))

C****
C
      DO 70 J = 1,NLAT
          DO 60 I = 1,IMAX
c =======================================DJS special case===
              IF (PSFC(I,J).EQ.SPVL) THEN
                  DO K = 1,NLEVO
                      DATO(I,J,K) = SPVL
                  END DO
                  GO TO 60
              END IF
c =========================================================

C
C****     GET PRESSURE VALUES FOR HYBRID SURFACES FOR THIS POINT
C****     AND FOR THE TYPE OF MODEL SURFACE THE DATA IS ON.
C****     INTERFACE DATA STARTS AT THE SECOND INTERFACE LEVEL SO
C****     IF THE DATA IS ON THOSE LEVELS START THE
C
              DO K = 1,NLEVI
                  KPI = K
                  PLEVI(K) = (HBCOFA(KPI)*P0) +
     +                       HBCOFB(KPI)* (PSFC(I,J)*.01D0)
              END DO
C
C****     CALL P2HBD TO PERFORM VERTICAL INTERP. THEN TRANSFER DATA TO
C****     THE OUTPUT ARRAY
C
              DO 50 K = 1,NLEVO
C
C****     CHECK FOR BRACKETING LEVEL KP WILL BE THE INPUT LEVEL THAT
C****     IS THE UPPER PORTION OF 2 INPUT BRACKETING LEVELS.
C
C****     IF BRANCH FOR MODEL TOP
C
                  IF (PLEVO(K).LE.PLEVI(1)) THEN
                      KP = 1
                      GO TO 30
C
C****     IF BRANCH FOR LEVEL BELOW LOWEST HYBRID LEVEL
C
                  ELSE IF (PLEVO(K).GT.PLEVI(NLEVI)) THEN
                      IF (KXTRP.EQ.0) THEN
                          DATO(I,J,K) = SPVL
                          GO TO 40
                      ELSE IF (VARFLG.GT.0) THEN
c Variable is "T" and ECMWF extrapolation is desired
                          PSFCMB = PSFC(I,J)*0.01D0
                          TSTAR = DATI(I,J,NLEVI)*
     +                            (1.D0+ALPHA* (PSFCMB/PLEVI(NLEVI)-1))
                          HGT = PHIS(I,J)*GINV
                          IF (HGT.LT.2000.D0) THEN
                              ALNP = ALPHA*LOG(PLEVO(K)/PSFCMB)
                          ELSE
                              T0 = TSTAR + 0.0065D0*HGT
                              TPLAT = MIN(T0,298.D0)
                              IF (HGT.LE.2500.D0) THEN
                                  TPRIME0 = 0.002D0*
     +                                      ((2500.D0-HGT)*T0+ (HGT-
     +                                      2000.D0)*TPLAT)
                              ELSE
                                  TPRIME0 = TPLAT
                              END IF
                              IF (TPRIME0.LT.TSTAR) THEN
                                  ALNP = 0.D0
                              ELSE
                                  ALNP = RD* (TPRIME0-TSTAR)/PHIS(I,J)*
     +                                   LOG(PLEVO(K)/PSFCMB)
                              END IF
                          END IF
                          DATO(I,J,K) = TSTAR* (1.D0+ALNP+.5D0*ALNP**2+
     +                                  1.D0/6.D0*ALNP**3)
                          GO TO 40

                      ELSE IF (VARFLG.LT.0) THEN
c Variable is "Z" and ECMWF extrapolation is desired
                          PSFCMB = PSFC(I,J)*0.01D0
                          HGT = PHIS(I,J)*GINV
                          TSTAR = TBOT(I,J)* (1.D0+
     +                            ALPHA* (PSFCMB/PLEVI(NLEVI)-1.D0))
                          T0 = TSTAR + 0.0065D0*HGT

                          IF (TSTAR.LE.290.5D0 .AND. T0.GT.290.5D0) THEN
                              ALPH = RD/PHIS(I,J)* (290.5D0-TSTAR)
                          ELSE IF (TSTAR.GT.290.5D0 .AND.
     +                             T0.GT.290.5D0) THEN
                              ALPH = 0
                              TSTAR = 0.5D0* (290.5D0+TSTAR)
                          ELSE
                              ALPH = ALPHA
                          END IF

                          IF (TSTAR.LT.255.D0) THEN
                              TSTAR = 0.5D0* (TSTAR+255.D0)
                          END IF
                          ALNP = ALPH*LOG(PLEVO(K)/PSFCMB)
                          DATO(I,J,K) = HGT - RD*TSTAR*GINV*
     +                                  LOG(PLEVO(K)/PSFCMB)*
     +                                  (1.D0+.5D0*ALNP+
     +                                  1.D0/6.D0*ALNP**2)
                          GO TO 40
                      ELSE
C Use lowest sigma layer
                          DATO(I,J,K) = DATI(I,J,NLEVI)
                          GO TO 40
                      END IF
C
C****     IF BRANCH FOR TO CHECK IF OUTPUT LEVEL IN BETWEEN
C****     2 LOWEST HYBRID LEVELS
C
                  ELSE IF (PLEVO(K).GE.PLEVI(NLEVI-1)) THEN
                      KP = NLEVI - 1
                      GO TO 30
C
C****     IF BRANCH FOR MODEL INTERIOR
C****     LOOP THROUGH INPUT LEVELS TILL YOU ARE BRACKETING
C****     OUTPUT LEVEL
C
                  ELSE
                      KP = 0
   20                 CONTINUE
                      KP = KP + 1
                      IF (PLEVO(K).LE.PLEVI(KP+1)) GO TO 30
                      IF (KP.GT.NLEVI) THEN
                          WRITE (6,FMT=25) KP,NLEVI
   25                     FORMAT (' KP.GT.KLEVI IN P2HBD.  KP,KLEVI= ',
     +                           2I5)
C            CALL ABORT(' KP.GT.NLEVI IN P2HBD')
                      END IF
                      GO TO 20
                  END IF
   30             CONTINUE
C
C****     LEVEL BRACKETED PICK TYPE OF INTERP.
C
C
C****     LINEAR INTERP.
C
                  IF (INTYP.EQ.1) THEN
                      DATO(I,J,K) = DATI(I,J,KP) +
     +                              (DATI(I,J,KP+1)-DATI(I,J,KP))*
     +                              (PLEVO(K)-PLEVI(KP))/
     +                              (PLEVI(KP+1)-PLEVI(KP))
C
C****     LOG INTERPOLATION.
C
                  ELSE IF (INTYP.EQ.2) THEN
                      IPRINT = 1
                      DATO(I,J,K) = DATI(I,J,KP) +
     +                              (DATI(I,J,KP+1)-DATI(I,J,KP))*
     +                              LOG(PLEVO(K)/PLEVI(KP))/
     +                              LOG(PLEVI(KP+1)/PLEVI(KP))
C
C****     FOR LOG LOG INTERP. NOTE A2LN IS A STATEMENT FCN.
C
                  ELSE IF (INTYP.EQ.3) THEN
                      DATO(I,J,K) = DATI(I,J,KP) +
     +                              (DATI(I,J,KP+1)-DATI(I,J,KP))*
     +                              (A2LN(PLEVO(K))-A2LN(PLEVI(KP)))/
     +                              (A2LN(PLEVI(KP+1))-A2LN(PLEVI(KP)))
                  END IF
   40             CONTINUE
C
   50         CONTINUE
   60     CONTINUE
   70 CONTINUE
      END SUBROUTINE VINTH2PECMWF


      END MODULE m_utilities
