      PROGRAM main 
c
      USE netcdf 
      USE micom2cmor_mod_namelists
      USE micom2cmor_mod_utils
      USE micom2cmor_mod_main
      USE micom2cmor_mod_special
c
      IMPLICIT NONE
c
      INTEGER :: k,n,nrec,rec,m1,m2,day1,ndaysacc
      REAL(KIND=8) :: tstart 
      INTEGER, DIMENSION(12), PARAMETER :: 
     .  ndays=(/31,28,31,30,31,30,31,30,31,31,30,31/)
c
c --- Read namelists 
      CALL read_namelists
      IF (verbose) CALL print_namelists
c
c --- Read grid information from input files
      WRITE(*,*) 'Read grid information from input files'
      itag=tagmon
      CALL read_gridinfo_ifile
c
c
c --- Process table fx 
      WRITE(*,*) 'Process table fx'
      fnm=pfx
      table=tfx 
      DO n=1,nfx 
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
        CALL get_vertcoord(table,ovnm,zcoord)
c
c --- - Check if input variable is present 
        IF (LEN_TRIM(pfx).eq.0) CALL get_filename(year1,1,fnm)
        IF (.NOT.var_in_file(fnm,ivnm)) CYCLE 
c
c --- - Prepare output file 
        CALL special_pre     
        CALL open_ofile_fixed
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
c --- Process table oyr
      WRITE(*,*) 'Process table oyr'
      fnm=poyr
      table=toyr
      DO n=1,noyr
c
c --- - Map namelist variables 
        ivnm=voyr(1,n)
        ovnm=voyr(2,n)
        special=voyr(3,n)
        vunits=' '
        vpositive=' '
        vcomment=' ' 
c
c --- - Check if vertical coordinate required        
        CALL get_vertcoord(table,ovnm,zcoord)
c 
c --- - Choose history file 
        IF (INDEX(special,'mon2yr').GT.0) THEN
          itag=tagmon
        ELSE
          itag=tagyr
        ENDIF 
c
c --- - Check if input variable is present  
        IF (LEN_TRIM(poyr).eq.0) CALL get_filename(year1,1,fnm)
        IF (.NOT.var_in_file(fnm,ivnm)) CYCLE
c
c --- - Prepare output file 
        CALL special_pre
        CALL open_ofile
c
c --- - Loop over years 
        DO year=year1,yearn
c
c --- --- Loop over months 
          IF (TRIM(itag).EQ.TRIM(tagmon)) THEN
            IF (year.EQ.year1) THEN
              m1=month1
            ELSE
              m1=1
            ENDIF
            IF (year.EQ.yearn) THEN
              m2=monthn
            ELSE
              m2=12
            ENDIF
          ELSE
            m1=1
            m2=1 
          ENDIF
          fldacc=0.
          ndaysacc=0
          rec=1
          DO month=m1,m2
            ndaysacc=ndaysacc+ndays(month)
c
c --- --- - Read variable into buffer (average if necessary)
            IF (LEN_TRIM(poyr).eq.0) CALL get_filename(year,month,fnm)
            CALL read_tslice(rec)
            IF (month.EQ.1) tstart=tbnds(1,1)
            WHERE (fld.NE.1e20) 
              fldacc=fldacc+fld*ndays(month)
            ELSEWHERE
              fldacc=1e20
            ENDWHERE 
c
c --- --- End loop over months
          ENDDO
          WHERE (fldacc.NE.1e20) fldacc=fldacc/FLOAT(ndaysacc)
          tbnds(1,1)=tstart
          tval=0.5*(tbnds(1,1)+tbnds(2,1))
c 
c --- --- Post processing 
          fld=fldacc
          CALL special_post
c
c --- --- Write time slice to output file 
          CALL write_tslice
c
c --- - End loop over years 
        ENDDO
c
c --- - Close output file 
        CALL close_ofile
c
      ENDDO
c
c 
c --- Process table oyr (bgc)
      WRITE(*,*) 'Process table oyr (bgc)'
      fnm=poyrbgc
      table=toyrbgc
      DO n=1,noyrbgc
c
c --- - Map namelist variables 
        ivnm=voyrbgc(1,n)
        ovnm=voyrbgc(2,n)
        special=voyrbgc(3,n)
        vunits=' '
        vpositive=' '
        vcomment=' ' 
c
c --- - Check if vertical coordinate required        
        CALL get_vertcoord(table,ovnm,zcoord)
c 
c --- - Choose history file 
        IF (INDEX(special,'mon2yr').GT.0) THEN
          itag=tagmonbgc
        ELSE
          itag=tagyrbgc
        ENDIF
c
c --- - Check if input variable is present  
        IF (LEN_TRIM(poyr).eq.0) CALL get_filename(year1,1,fnm)
        IF (.NOT.var_in_file(fnm,ivnm)) CYCLE
c
c --- - Prepare output file 
        CALL special_pre
        CALL open_ofile
c
c --- - Loop over years 
        DO year=year1,yearn
c
c --- --- Loop over months 
          IF (TRIM(itag).EQ.TRIM(tagmon)) THEN
            IF (year.EQ.year1) THEN
              m1=month1
            ELSE
              m1=1
            ENDIF
            IF (year.EQ.yearn) THEN
              m2=monthn
            ELSE
              m2=12
            ENDIF
          ELSE
            m1=1
            m2=1
          ENDIF
          fldacc=0.
          ndaysacc=0
          rec=1
          DO month=m1,m2
            ndaysacc=ndaysacc+ndays(month)
c
c --- --- - Read variable into buffer (average if necessary)
            IF (LEN_TRIM(poyrbgc).eq.0)CALL get_filename(year,month,fnm)
            CALL read_tslice(rec)
            IF (month.EQ.1) tstart=tbnds(1,1)
            WHERE (fld.NE.1e20)
              fldacc=fldacc+fld*ndays(month)
            ELSEWHERE
              fldacc=1e20
            ENDWHERE
c
c --- --- End loop over months
          ENDDO
          WHERE (fldacc.NE.1e20) fldacc=fldacc/FLOAT(ndaysacc)
          tbnds(1,1)=tstart
          tval=0.5*(tbnds(1,1)+tbnds(2,1))
c 
c --- --- Post processing 
          fld=fldacc
          CALL special_post
c
c --- --- Write time slice to output file 
          CALL write_tslice
c
c --- - End loop over years 
        ENDDO
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
c
c --- - Map namelist variables 
        ivnm=vomon(1,n) 
        ovnm=vomon(2,n) 
        special=vomon(3,n)
        vunits=' ' 
        vpositive=' ' 
        vcomment=' ' 
c
c --- - Check if vertical coordinate required        
        CALL get_vertcoord(table,ovnm,zcoord)
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
          itag=tagday 
        ELSE
          itag=tagmon
        ENDIF 
c
c --- - Check if input variable is present  
        IF (LEN_TRIM(pomon).eq.0) CALL get_filename(year1,1,fnm)
        IF (.NOT.var_in_file(fnm,ivnm)) CYCLE 
c
c --- - Prepare output file 
        CALL special_pre     
        CALL open_ofile 
c
c --- - Loop over years 
        DO year=year1,yearn
          WRITE(*,*) 'Year=',year
c
c --- --- Loop over months 
          IF (year.EQ.year1) THEN 
            m1=month1 
          ELSE
            m1=1
          ENDIF 
          IF (year.EQ.yearn) THEN 
            m2=monthn 
          ELSE
            m2=12
          ENDIF 
          DO month=m1,m2   
c
c --- --- - Read variable into buffer (average if necessary)
            IF (LEN_TRIM(pomon).eq.0) CALL get_filename(year,month,fnm)
            fldacc=0. 
            nrec=get_nrec(fnm) 
            DO rec=1,nrec 
              CALL read_tslice(rec)        
              fldacc=fldacc+fld 
              IF (rec.EQ.1) tstart=tbnds(1,1)
            ENDDO 
            fld=fldacc/FLOAT(nrec) 
            tbnds(1,1)=tstart
            tval=0.5*(tbnds(1,1)+tbnds(2,1))
c 
c --- --- - Post processing 
            CALL special_post 
c
c --- --- - Write time slice to output file 
            CALL write_tslice  
c
c --- --- End loop over months
          ENDDO 
c
c --- - End loop over years 
        ENDDO 
c
c --- - Close output file 
        CALL close_ofile
c
      ENDDO    
c
c 
c --- Process table omon (bgc)
      WRITE(*,*) 'Process table omon (bgc)'
      fnm=pomonbgc
      table=tomonbgc
      DO n=1,nomonbgc
c
c --- - Map namelist variables 
        ivnm=vomonbgc(1,n)
        ovnm=vomonbgc(2,n)
        special=vomonbgc(3,n)
        vunits=' '
        vpositive=' '
        vcomment=' ' 
c
c --- - Check if vertical coordinate required        
        CALL get_vertcoord(table,ovnm,zcoord)
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
          itag=tagdaybgc
        ELSE
          itag=tagmonbgc
        ENDIF
c
c --- - Check if input variable is present  
        IF (LEN_TRIM(pomonbgc).eq.0) CALL get_filename(year1,1,fnm)
        IF (.NOT.var_in_file(fnm,ivnm)) CYCLE
c
c --- - Prepare output file 
        CALL special_pre
        CALL open_ofile
c
c --- - Loop over years 
        DO year=year1,yearn
          WRITE(*,*) 'Year=',year
c
c --- --- Loop over months 
          IF (year.EQ.year1) THEN
            m1=month1
          ELSE
            m1=1
          ENDIF
          IF (year.EQ.yearn) THEN
            m2=monthn
          ELSE
            m2=12
          ENDIF
          DO month=m1,m2
c
c --- --- - Read variable into buffer (average if necessary)
            IF(LEN_TRIM(pomonbgc).eq.0)CALL get_filename(year,month,fnm)
            fldacc=0.
            nrec=get_nrec(fnm)
            DO rec=1,nrec
              CALL read_tslice(rec)
              fldacc=fldacc+fld
              IF (rec.EQ.1) tstart=tbnds(1,1)
            ENDDO
            fld=fldacc/FLOAT(nrec)
            tbnds(1,1)=tstart
            tval=0.5*(tbnds(1,1)+tbnds(2,1))
c 
c --- --- - Post processing 
            CALL special_post
c
c --- --- - Write time slice to output file 
            CALL write_tslice
c
c --- --- End loop over months
          ENDDO
c
c --- - End loop over years 
        ENDDO
c
c --- - Close output file 
        CALL close_ofile
c
      ENDDO
c
c
c --- Process table day
      WRITE(*,*) 'Process table day'
      fnm=pday
      table=tday
      DO n=1,nday
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
        CALL get_vertcoord(table,ovnm,zcoord)
c 
c --- - Choose history file 
        itag=tagday
c
c --- - Check if input variable is present  
        IF (LEN_TRIM(pday).eq.0) CALL get_filename(year1,1,fnm)
        IF (.NOT.var_in_file(fnm,ivnm)) CYCLE
c
c --- - Prepare output file 
        CALL special_pre
        CALL open_ofile
c
c --- - Loop over years 
        DO year=year1,yearn
c
c --- --- Loop over months 
          IF (year.EQ.year1) THEN
            m1=month1
          ELSE
            m1=1
          ENDIF
          IF (year.EQ.yearn) THEN
            m2=monthn
          ELSE
            m2=12
          ENDIF
          DO month=m1,m2
c
c --- --- - Loop over days 
            IF (LEN_TRIM(pday).eq.0) CALL get_filename(year,month,fnm)
c           exception for fill day 
            IF (year.EQ.year1.AND.month.EQ.month1.AND.add_fill_day) THEN
              day1=0
            ELSE 
              day1=1
            ENDIF
            DO rec=day1,get_nrec(fnm)
c
c --- --- --- Read data 
              CALL read_tslice(rec)
c
c --- --- --- Post processing 
              CALL special_post
c 
c --- --- --- Set fill value for dummy day 
              IF (rec.EQ.0) fld=1e20 
c
c --- --- --- Write time slice to output file 
              CALL write_tslice
c
c --- --- - End loop over days
            ENDDO 
c
c --- --- End loop over months
          ENDDO
c
c --- - End loop over years 
        ENDDO
c
c --- - Close output file 
        CALL close_ofile
c
      ENDDO
c
      END PROGRAM main 

