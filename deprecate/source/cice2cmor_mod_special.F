      MODULE cice2cmor_mod_special
c
      USE netcdf
      USE cice2cmor_mod_namelists
      USE cice2cmor_mod_utils
      USE cice2cmor_mod_main
c
      IMPLICIT NONE
c
      CHARACTER(LEN=slenmax), SAVE :: str1,str2



c --- -----------------------------------------------------------------
      CONTAINS
c --- -----------------------------------------------------------------



      SUBROUTINE special_pre
c
      IMPLICIT NONE
c
      str2=special 
      DO 
        IF (INDEX(str2,';').GT.0) THEN 
          str1=str2(1:INDEX(str2,';')-1)  
          str2=str2(INDEX(str2,';')+1:)
        ELSE 
          str1=str2
        ENDIF  
        SELECT CASE (str1)
c
c --- - Fix unitless units 
        CASE ('unitless')
          vunits='1'
c
c --- - Set correct units for percentage
        CASE ('percent')
          vunits='%'
c
c --- - Set correct units for percentage
        CASE ('fraction')
          vunits='1'
c
c --- - Unit transformation: kg m-2  
        CASE ('kg m-2')
          vunits='kg m-2'
c 
c --- - Unit transformation: cm/day -> kg m-2 s-1 
        CASE ('cmFW day-1 -> kg m-2 s-1','cmICE day-1 -> kg m-2 s-1',
     .    'cmSNOW day-1 -> kg m-2 s-1')
          vunits='kg m-2 s-1'
c 
c --- - Unit transformation: kg/m^2/day -> kg m-2 s-1 
        CASE ('kg m-2 day-1 -> kg m-2 s-1')
          vunits='kg m-2 s-1'
c 
c --- - Fix micrometers units 
        CASE ('micrometer')
          vunits='micrometers'
c
c --- - Fix m-2 units 
        CASE ('m-2')
          vunits='m-2'
c        
c --- - Convert units from radians2 to m2    
        CASE ('rad2m')
          vunits='m2'
c
c --- - Fix hcice units 
        CASE ('J m-2')
          vunits='J m-2'
c
c --- - Set positive attribute  
        CASE ('positiveup')
          vpositive='up'
        CASE ('positivedo')
          vpositive='down'
c
c --- - Write comment for hur and hurs
        CASE ('tsicecomment')
          vcomment='This field differs from the CMOR-definition '
     .           //'because at every time-step, the field has been '
     .           //'put to 271.314 K in grid-cells without sea ice. '
     .           //'The time-mean has been calculated from these '
     .           //'values without taking care of when a grid-cell is ' 
     .           //'free of sea ice.'
c
c --- - Write comment for streng and divice
        CASE ('tavecomment')
          vcomment='During the time-averaging there was no weighting '
     .           //'with respect to the ice concentration in this '
     .           //'field. A value of zero was used over open water.' 
c 
        END SELECT
        IF (str1.EQ.str2) exit 
      END DO
c
      END SUBROUTINE special_pre



      SUBROUTINE special_post
c
      IMPLICIT NONE
c
      str2=special 
      DO 
        IF (INDEX(str2,';').GT.0) THEN
          str1=str2(1:INDEX(str2,';')-1)
          str2=str2(INDEX(str2,';')+1:)
        ELSE 
          str1=str2
        ENDIF
        SELECT CASE (str1)
c
c --- - Convert units from radians2 to m2    
        CASE ('rad2m')
          fld=fld*6.37122e6**2
c
c --- - Unit transformation: cm day-1 -> kg m-2 s-1 
        CASE ('cmFW day-1 -> kg m-2 s-1')
          fld=fld/100./(24.*3600.)*1000. 
        CASE ('cmICE day-1 -> kg m-2 s-1')
          fld=fld/100./(24.*3600.)*917. 
        CASE ('cmSNOW day-1 -> kg m-2 s-1')
          fld=fld/100./(24.*3600.)*330.
c 
c --- - Unit transformation: kg/m^2/day -> kg m-2 s-1 
        CASE ('kg m-2 day-1 -> kg m-2 s-1')
          fld=fld/(24.*3600.) 
c
c --- - Flip sign
        CASE ('flipsign')
          WHERE (fld.LT.1e20) fld=-fld
c
c --- - Set ice free points to missing value
        CASE ('zero2missing')
          WHERE (abs(fld).LT.1e-6)
            fld=1e20
          END WHERE
c
c --- - Divide by cell area 
        CASE ('Xcellarea-1')
          WHERE (abs(fld).LT.1e20)
            fld=fld/tarea
          END WHERE
c
        END SELECT
        IF (str1.EQ.str2) exit 
      END DO
c
      END SUBROUTINE special_post


      END MODULE cice2cmor_mod_special
