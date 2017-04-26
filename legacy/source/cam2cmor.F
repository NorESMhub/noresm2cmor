      PROGRAM main 
c
      USE netcdf 
      USE cam2cmor_mod_namelists
      USE cam2cmor_mod_utils
      USE cam2cmor_mod_main
      USE cam2cmor_mod_special
c
      IMPLICIT NONE
c
      LOGICAL :: badrec
      INTEGER :: n,nrec,rec,m1,m2,day
      INTEGER, PARAMETER :: monlen(12)=
     .  (/31,28,31,30,31,30,31,31,30,31,30,31/)
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
c --- Initialise pressure level dimension 
      pdm=1 
      ALLOCATE(plevs(pdm))
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
        vcomment=' '
c 
c --- - Check if 2d and/or 3d fields are to be written 
        CALL get_vertcoord(table,ovnm,zcoord)
        IF (zcoord(1:4).EQ.'plev'.OR.zcoord(2:5).EQ.'leve'.OR.
     .    zcoord(2:5).EQ.'levh') THEN
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
        ofld=ifld  
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
c --- Process table amon
      fnm=pamon
      table=tamon 
      linstant=.FALSE.
      lreadplev=.TRUE.
      DO n=1,namon 
c
c --- - Map namelist variables 
        ivnm=vamon(1,n) 
        ovnm=vamon(2,n) 
        special=vamon(3,n)
        vunits=' ' 
        vpositive=' ' 
        vcomment=' '
c 
c --- - Check if 2d and/or 3d fields are to be written 
        CALL get_vertcoord(table,ovnm,zcoord)
        IF (zcoord(1:4).EQ.'plev'.OR.zcoord(2:5).EQ.'leve'.OR.
     .    zcoord(2:5).EQ.'levh') THEN
          IF (.NOT.do_3d) CYCLE
c --- --- Read pressure levels from table 
          IF (lreadplev) THEN 
            CALL read_gridinfo_plev
            lreadplev=.FALSE.
          ENDIF
        ELSE
          IF (.NOT.do_2d) CYCLE
        ENDIF
c 
c --- - Choose history file 
        SELECT CASE (TRIM(special)) 
          CASE ('day2mon')
            itag=tagday 
          CASE ('6hr2mon') 
            itag=tag6hr
          CASE ('3hr2mon')
            itag=tag3hr
          CASE DEFAULT 
            itag=tagmon
        END SELECT
c
c --- - Check if input variable is present  
        IF (LEN_TRIM(pamon).eq.0) CALL get_filename(year1,1,fnm)
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
            IF (LEN_TRIM(pamon).eq.0) CALL get_filename(year,month,fnm)
            ifldacc=0. 
            nrec=get_nrec(fnm) 
            DO rec=1,nrec 
              CALL read_tslice(rec,nrec,badrec)
              ifldacc=ifldacc+ifld 
              IF (rec.EQ.1) tstart=tbnds(1,1)
            ENDDO 
            ifld=ifldacc/FLOAT(nrec) 
            tbnds(1,1)=tstart
            tval=0.5*(tbnds(1,1)+tbnds(2,1))
c 
c --- --- - Post processing 
            IF (zcoord(1:4).EQ.'plev') THEN 
              CALL interp_z
            ELSE
              ofld=ifld  
            ENDIF                 
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
c --- Process table aero
      fnm=paero
      table=taero
      linstant=.FALSE.
      lreadplev=.FALSE.
      DO n=1,naero
c 
c --- - Map namelist variables 
        ivnm=vaero(1,n)
        ovnm=vaero(2,n)
        special=vaero(3,n)
        vunits=' '
        vpositive=' ' 
        vcomment=' '
c 
c --- - Check if 2d and/or 3d fields are to be written 
        CALL get_vertcoord(table,ovnm,zcoord)
        WRITE(*,*) TRIM(ovnm),TRIM(zcoord),do_3d
        IF (zcoord(1:4).EQ.'plev'.OR.zcoord(2:5).EQ.'leve'.OR.
     .    zcoord(2:5).EQ.'levh') THEN
          IF (.NOT.do_3d) CYCLE
c --- --- Read pressure levels from table 
          IF (lreadplev) THEN
            CALL read_gridinfo_plev
            lreadplev=.FALSE.
          ENDIF
        ELSE
          IF (.NOT.do_2d) CYCLE
        ENDIF
c 
c --- - Choose history file 
        SELECT CASE (TRIM(special))
          CASE ('day2mon')
            itag=tagday
          CASE ('6hr2mon')
            itag=tag6hr
          CASE ('3hr2mon')
            itag=tag3hr
          CASE DEFAULT
            itag=tagmon
        END SELECT
c
c --- - Check if input variable is present  
        IF (LEN_TRIM(paero).eq.0) CALL get_filename(year1,1,fnm)
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
            IF (LEN_TRIM(paero).eq.0) CALL get_filename(year,month,fnm)
            ifldacc=0.
            nrec=get_nrec(fnm)
            DO rec=1,nrec
              CALL read_tslice(rec,nrec,badrec)
              ifldacc=ifldacc+ifld
              IF (rec.EQ.1) tstart=tbnds(1,1)
            ENDDO
            ifld=ifldacc/FLOAT(nrec)
            tbnds(1,1)=tstart
            tval=0.5*(tbnds(1,1)+tbnds(2,1))
c 
c --- --- - Post processing 
            ofld=ifld
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
      lreadplev=.TRUE.
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
c --- - Check if 2d and/or 3d fields are to be written 
        CALL get_vertcoord(table,ovnm,zcoord)
        IF (zcoord(1:4).EQ.'plev'.OR.zcoord(2:5).EQ.'leve'.OR.
     .    zcoord(2:5).EQ.'levh') THEN
          IF (.NOT.do_3d) CYCLE
c --- --- Read pressure levels from table 
          IF (lreadplev) THEN
            CALL read_gridinfo_plev
            lreadplev=.FALSE.
          ENDIF
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
            nrec=get_nrec(fnm)
            DO day=1,nrec
c
c --- --- --- Read data 
              CALL read_tslice(day,nrec,badrec)
c
c --- --- --- Post processing 
              IF (zcoord(1:4).EQ.'plev') THEN
                CALL interp_z
              ELSE
                ofld=ifld
              ENDIF
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
c --- Process table 6hrlev
      fnm=p6hrlev
      table=t6hrlev
      linstant=.TRUE.
      DO n=1,n6hrlev
c
c --- - Map namelist variables 
        ivnm=v6hrlev(1,n)
        ovnm=v6hrlev(2,n)
        special=v6hrlev(3,n)
        vunits=' '
        vpositive=' '
        vcomment=' '
c 
c --- - Check if 2d and/or 3d fields are to be written 
        CALL get_vertcoord(table,ovnm,zcoord)
        IF (zcoord(1:4).EQ.'plev'.OR.zcoord(2:5).EQ.'leve'.OR.
     .    zcoord(2:5).EQ.'levh') THEN
          IF (.NOT.do_3d) CYCLE
        ELSE
          IF (.NOT.do_2d) CYCLE
        ENDIF
c 
c --- - Choose history file 
        itag=tag6hr
c
c --- - Check if input variable is present  
        IF (LEN_TRIM(p6hrlev).eq.0) CALL get_filename(year1,1,fnm)
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
            IF (LEN_TRIM(p6hrlev).eq.0) 
     .        CALL get_filename(year,month,fnm)
            nrec=get_nrec(fnm) 
            DO rec=1,nrec
c
c --- --- --- Read data 
              CALL read_tslice(rec,nrec,badrec) 
c
c --- --- --- Post processing 
              ofld=ifld
              CALL special_post
              IF (badrec) ofld=1e20
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
c --- Process table 6hrplev
      fnm=p6hrplev
      table=t6hrplev
      linstant=.TRUE.
      lreadplev=.TRUE.
      DO n=1,n6hrplev
c
c --- - Map namelist variables 
        ivnm=v6hrplev(1,n)
        ovnm=v6hrplev(2,n)
        special=v6hrplev(3,n)
        vunits=' '
        vpositive=' '
        vcomment=' '
c 
c --- - Check if 2d and/or 3d fields are to be written 
        CALL get_vertcoord(table,ovnm,zcoord)
        IF (zcoord(1:4).EQ.'plev'.OR.zcoord(2:5).EQ.'leve'.OR.
     .    zcoord(2:5).EQ.'levh') THEN
          IF (.NOT.do_3d) CYCLE
c --- --- Read pressure levels from table 
          IF (lreadplev) THEN 
            CALL read_gridinfo_plev
            lreadplev=.FALSE.
          ENDIF
        ELSE
          IF (.NOT.do_2d) CYCLE
        ENDIF
c 
c --- - Choose history file 
        itag=tag6hr
c
c --- - Check if input variable is present  
        IF (LEN_TRIM(p6hrplev).eq.0) CALL get_filename(year1,1,fnm)
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
            IF (LEN_TRIM(p6hrplev).eq.0)
     .        CALL get_filename(year,month,fnm)
            nrec=get_nrec(fnm)
            DO rec=1,nrec
c
c --- --- --- Read data 
              CALL read_tslice(rec,nrec,badrec)
c
c --- --- --- Post processing 
              IF (zcoord(1:4).EQ.'plev') THEN     
                CALL interp_z
              ELSE
                ofld=ifld
              ENDIF
              CALL special_post
              IF (badrec) ofld=1e20
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
c --- Process table 3hr 
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
        vcomment=' '
c 
c --- - Check if 2d and/or 3d fields are to be written 
        CALL get_vertcoord(table,ovnm,zcoord)
        IF (zcoord(1:4).EQ.'plev'.OR.zcoord(2:5).EQ.'leve'.OR.
     .    zcoord(2:5).EQ.'levh') THEN
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
            nrec=get_nrec(fnm) 
            DO rec=1,nrec
c
c --- --- --- Read data 
              CALL read_tslice(rec,nrec,badrec)
c
c --- --- --- Post processing 
              ofld=ifld
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
c --- Process table 3hr (instantaneous)
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
        vcomment=' '
c 
c --- - Check if 2d and/or 3d fields are to be written 
        CALL get_vertcoord(table,ovnm,zcoord)
        IF (zcoord(1:4).EQ.'plev'.OR.zcoord(2:5).EQ.'leve'.OR.
     .    zcoord(2:5).EQ.'levh') THEN
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
            nrec=get_nrec(fnm) 
            DO rec=1,nrec
c
c --- --- --- Read data 
              CALL read_tslice(rec,nrec,badrec)
c
c --- --- --- Post processing 
              ofld=ifld
              CALL special_post
              IF (badrec) ofld=1e20
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
      END PROGRAM main 

