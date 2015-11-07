      PROGRAM main 
c
      USE netcdf 
      USE clm2cmor_mod_namelists
      USE clm2cmor_mod_utils
      USE clm2cmor_mod_main
      USE clm2cmor_mod_special
c
      IMPLICIT NONE
c
      LOGICAL :: badrec
      INTEGER :: n,nrec,rec,m1,m2
      REAL :: tstart 
c
c --- Read namelists 
      CALL read_namelists
      IF (verbose) CALL print_namelists
c
c --- Read grid information from input files
      itag=tagmon
      CALL read_gridinfo_ifile
c
c
c --- Process table fx 
      fnm=pfx
      table=tfx 
      linstant=.FALSE.
      DO n=1,nfx 
c
c --- - Map namelist variables 
        ivnm=vfx(1,n) 
        ovnm=vfx(2,n) 
        special=vfx(3,n)
        vunits=' ' 
        vpositive=' ' 
c
c --- - Skip variable?
        CALL get_vertcoord(table,ovnm,zcoord)
        IF (TRIM(zcoord).EQ.'sdepth') THEN 
          IF (.NOT.do_3d) CYCLE 
        ELSE 
          IF (.NOT.do_2d) CYCLE 
        ENDIF
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
c --- Process table lmon
      fnm=plmon
      table=tlmon 
      linstant=.FALSE.
      DO n=1,nlmon 
c
c --- - Map namelist variables 
        ivnm=vlmon(1,n) 
        ovnm=vlmon(2,n) 
        special=vlmon(3,n)
        vunits=' ' 
        vpositive=' ' 
c
c --- - Skip variable?
        CALL get_vertcoord(table,ovnm,zcoord)
        IF (TRIM(zcoord).EQ.'sdepth') THEN 
          IF (.NOT.do_3d) CYCLE 
        ELSE 
          IF (.NOT.do_2d) CYCLE 
        ENDIF
c 
c --- - Choose history file 
        SELECT CASE (TRIM(special)) 
          CASE ('day2mon')
            itag=tagday 
          CASE ('3hr2mon')
            itag=tag3hr
          CASE DEFAULT 
            itag=tagmon
        END SELECT
c
c --- - Check if input variable is present  
        IF (LEN_TRIM(plmon).eq.0) CALL get_filename(year1,1,fnm)
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
c --- --- - Read variable into buffer (average if necessary)
            IF (LEN_TRIM(plmon).eq.0) CALL get_filename(year,month,fnm)
            fldacc=0. 
            nrec=get_nrec(fnm) 
            DO rec=1,nrec 
              CALL read_tslice(rec,badrec)        
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
c --- Process table limon
      fnm=plimon
      table=tlimon
      linstant=.FALSE.
      DO n=1,nlimon
c
c --- - Map namelist variables 
        ivnm=vlimon(1,n)
        ovnm=vlimon(2,n)
        special=vlimon(3,n)
        vunits=' '
        vpositive=' '
c
c --- - Skip variable?
        CALL get_vertcoord(table,ovnm,zcoord)
        IF (TRIM(zcoord).EQ.'sdepth') THEN 
          IF (.NOT.do_3d) CYCLE 
        ELSE 
          IF (.NOT.do_2d) CYCLE 
        ENDIF
c 
c --- - Choose history file 
        SELECT CASE (TRIM(special))
          CASE ('day2mon')
            itag=tagday
          CASE ('3hr2mon')
            itag=tag3hr
          CASE DEFAULT
            itag=tagmon
        END SELECT
c
c --- - Check if input variable is present  
        IF (LEN_TRIM(plimon).eq.0) CALL get_filename(year1,1,fnm)
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
c --- --- - Read variable into buffer (average if necessary)
            IF (LEN_TRIM(plimon).eq.0) CALL get_filename(year,month,fnm)
            fldacc=0.
            nrec=get_nrec(fnm)
            DO rec=1,nrec
              CALL read_tslice(rec,badrec)
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
      fnm=pday
      table=tday
      linstant=.FALSE.
      DO n=1,nday
c
c --- - Map namelist variables 
        ivnm=vday(1,n)
        ovnm=vday(2,n)
        special=vday(3,n)
        vunits=' '
        vpositive=' '
c
c --- - Skip variable?
        CALL get_vertcoord(table,ovnm,zcoord)
        IF (TRIM(zcoord).EQ.'sdepth') THEN 
          IF (.NOT.do_3d) CYCLE 
        ELSE 
          IF (.NOT.do_2d) CYCLE 
        ENDIF
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
            DO rec=1,get_nrec(fnm)
c
c --- --- --- Read data 
              CALL read_tslice(rec,badrec)
c
c --- --- --- Post processing 
              CALL special_post
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
c
c --- Process table 3hr (averaged fields)
      fnm=p3hr
      table=t3hr
      linstant=.FALSE.
      DO n=1,n3hr
c
c --- - Map namelist variables 
        ivnm=v3hr(1,n)
        ovnm=v3hr(2,n)
        special=v3hr(3,n)
        vunits=' '
        vpositive=' '
c
c --- - Skip variable?
        CALL get_vertcoord(table,ovnm,zcoord)
        IF (TRIM(zcoord).EQ.'sdepth') THEN 
          IF (.NOT.do_3d) CYCLE 
        ELSE 
          IF (.NOT.do_2d) CYCLE 
        ENDIF
c 
c --- - Choose history file 
        itag=tag3hr
c
c --- - Check if input variable is present  
        IF (LEN_TRIM(p3hr).eq.0) CALL get_filename(year1,1,fnm)
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
            IF (LEN_TRIM(p3hr).eq.0) CALL get_filename(year,month,fnm)
            DO rec=1,get_nrec(fnm)
c
c --- --- --- Read data 
              CALL read_tslice(rec,badrec)
c
c --- --- --- Post processing 
              CALL special_post
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
c
c --- Process table 3hr (instantaneous fields) 
      fnm=p3hri
      table=t3hri
      linstant=.TRUE.
      DO n=1,n3hri
c
c --- - Map namelist variables 
        ivnm=v3hri(1,n)
        ovnm=v3hri(2,n)
        special=v3hri(3,n)
        vunits=' '
        vpositive=' '
c
c --- - Skip variable?
        CALL get_vertcoord(table,ovnm,zcoord)
        IF (TRIM(zcoord).EQ.'sdepth') THEN 
          IF (.NOT.do_3d) CYCLE 
        ELSE 
          IF (.NOT.do_2d) CYCLE 
        ENDIF
c 
c --- - Choose history file 
        itag=tag3hri
c
c --- - Check if input variable is present  
        IF (LEN_TRIM(p3hri).eq.0) CALL get_filename(year1,1,fnm)
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
            IF (LEN_TRIM(p3hri).eq.0) CALL get_filename(year,month,fnm)
            DO rec=1,get_nrec(fnm)
c
c --- --- --- Read data 
              CALL read_tslice(rec,badrec)
c
c --- --- --- Post processing 
              CALL special_post
              IF (badrec) fld=1e20 
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

