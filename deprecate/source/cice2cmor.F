      PROGRAM main 
c
      USE netcdf 
      USE cice2cmor_mod_namelists
      USE cice2cmor_mod_utils
      USE cice2cmor_mod_main
      USE cice2cmor_mod_special
c
      IMPLICIT NONE
c
      INTEGER :: n,nrec,rec,m1,m2
      REAL :: tstart 
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
c --- Read Fram Strait grid information from secindex.dat
      WRITE(*,*) 'Read Fram Strait grid information from secindex.dat' 
      CALL read_secindex(secindexfile,lsecindex,seclen,iind,jind,iflg,
     .  jflg)
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
        IF (LEN_TRIM(pomon).eq.0) CALL get_filename(year1,1,fnm)
        IF (.NOT.var_in_file(fnm,ivnm).AND..NOT.TRIM(ivnm).EQ.'transifs'
     .    .OR.TRIM(ivnm).EQ.'transifs'.AND..NOT.lsecindex) CYCLE
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
c --- Process table oimon
      WRITE(*,*) 'Process table oimon'
      fnm=poimon
      table=toimon 
      DO n=1,noimon 
c
c --- - Map namelist variables 
        ivnm=voimon(1,n) 
        ovnm=voimon(2,n) 
        special=voimon(3,n)
        vunits=' ' 
        vpositive=' ' 
        vcomment=' ' 
c
c --- - Check if vertical coordinate required        
        CALL get_vertcoord(table,ovnm,zcoord)
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
        IF (LEN_TRIM(poimon).eq.0) CALL get_filename(year1,1,fnm)
        IF (.NOT.var_in_file(fnm,ivnm).AND..NOT.TRIM(ivnm).EQ.'transifs'
     .    .OR.TRIM(ivnm).EQ.'transifs'.AND..NOT.lsecindex) CYCLE 
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
            IF (LEN_TRIM(poimon).eq.0) CALL get_filename(year,month,fnm)
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
            DO rec=1,get_nrec(fnm)
c
c --- --- --- Read data 
              CALL read_tslice(rec)
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
      END PROGRAM main 

