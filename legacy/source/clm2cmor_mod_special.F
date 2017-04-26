      MODULE clm2cmor_mod_special
c
      USE netcdf
      USE clm2cmor_mod_namelists
      USE clm2cmor_mod_utils
      USE clm2cmor_mod_main
c
      IMPLICIT NONE
c
      CHARACTER(LEN=slenmax), SAVE :: special,str1,str2



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
c --- - Unit transformation: g m-2 -> kg m-2  
        CASE ('kg m-2')
          vunits='kg m-2'
c 
c --- - Unit transformation: mm s-1 -> kg m-2 s-1 
        CASE ('kg m-2 s-1')
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
c --- - Set positive attribute  
        CASE ('positiveup')
          vpositive='up'
        CASE ('positivedo')
          vpositive='down'
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
c --- - Fraction to percent 
        CASE ('percent')
          fld=fld*1e2
 
c --- - Convert units from radians2 to m2    
        CASE ('rad2m')
          fld=fld*6.37122e6**2
c 
c --- - Unit transformation: g m-2 -> kg m-2 
        CASE ('kg m-2')
          fld=fld*1e-3
c
c --- - Unit transformation: g m-2 s-1 -> kg m-2 s-1 
        CASE ('kg m-2 s-1')
          fld=fld*1e-3
c
c --- - Limit solid soil moisture (mask ice sheets)
        CASE ('limitmoist')
          WHERE (fld.GT.5000.AND.fld.LT.1e20) fld=5000
c
c --- - Set ocean points to missing value
        CASE ('missingval')
          WHERE (ABS(fld).GT.1e20) fld=1e20
c
c --- - Set ocean points to zero
        CASE ('miss2zero')
          WHERE (ABS(fld).GT.1e20) fld=0.
c
c --- - Compute vertical sum 
        CASE ('vertsum') 
          fld(:,:,1)=sum(fld,3) 
c 
        END SELECT
        IF (str1.EQ.str2) exit 
      END DO
c
      END SUBROUTINE special_post


      END MODULE clm2cmor_mod_special
