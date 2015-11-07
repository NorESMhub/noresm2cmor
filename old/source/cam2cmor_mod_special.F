      MODULE cam2cmor_mod_special
c
      USE netcdf
      USE cam2cmor_mod_namelists
      USE cam2cmor_mod_utils
      USE cam2cmor_mod_main
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
c --- - CO2 units 
        CASE ('co2units')
          vunits='1e-6'
c
c --- - Set correct units for percentage
        CASE ('percent')
          vunits='%'
c 
c --- - Unit transformation: m -> kg m-2  
        CASE ('kg m-2','calcload')
          vunits='kg m-2'
c 
c --- - Unit transformation: m s-1 -> kg m-2 s-1 
        CASE ('kg m-2 s-1')
          vunits='kg m-2 s-1'
c 
c --- - Fix micrometers units 
        CASE ('micrometer')
          vunits='micrometers'
c
c --- - Fix m units 
        CASE ('m')
          vunits='m'
c
c --- - Fix m-2 units 
        CASE ('m-2')
          vunits='m-2'
c 
c --- - Set N_AER units
        CASE ('cm-3')
          vunits='cm-3'
c        
c --- - Convert units from radians2 to m2    
        CASE ('rad2m')
          vunits='m2'
c
c --- - Set positive attribute  
        CASE ('positiveup')
          vpositive='up'
          WRITE(*,*) 'set positive attribute to ',TRIM(vpositive)
        CASE ('positivedo')
          vpositive='down'
          WRITE(*,*) 'set positive attribute to ',TRIM(vpositive)
c
c --- - Write comment for hur and hurs
        CASE ('hurcomment')
          vcomment='field is weighted towards water-ice fraction'
c
c --- - Write comment for evspsbl
        CASE ('evscomment')
          vcomment='field includes dew fall and therefore may ' 
     .      //'have negative values'
c
c --- - Times dry mass 
        CASE ('timesmass')
          vunits='kg'
c
c --- - Weight with CLDFOC^-1 or FOCHANA^-1  
        CASE ('cldfoc','fochana') 
          vcomment=
     .      'Variable definition deviates from the CMIP5 table '
     .    //'definition. The variable is weighted toward ' 
     .    //'frequency of occurence of warm clouds.'
c
c --- - Weight with CLDFOC^-1 or FOCHANA^-1  
        CASE ('blayer') 
          vcomment=
     .      'Variable definition deviates from the CMIP5 table '
     .    //'definition. Values are taken from the lowest model layer.' 
     
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
c --- - CO2 units 
        CASE ('co2units')
          ofld=ofld*1e6*29./(12.+2.*16.)
c
c --- - Density weighted vertical integration  
        CASE ('calcload') 
          CALL calcload 
c
c --- - Convert units from radians2 to m2    
        CASE ('rad2m')
          ofld=ofld*6.37122e6**2
c
c --- - Unit transformation: m -> kg m-2 
        CASE ('kg m-2')
          ofld=ofld*1e3
c
c --- - Unit transformation: m s-1 -> kg m-2 s-1 
        CASE ('kg m-2 s-1')
          ofld=ofld*1e3
c
c --- - Weight with DAYFOC^-1  
        CASE ('dayfoc') 
          WHERE (ABS(ifld2).GT.1e-15) 
            ofld=ofld/ifld2
          ELSEWHERE
            ofld=1e20
          ENDWHERE 
c
c --- - Weight with CLDFOC^-1 or FOCHANA^-1  
        CASE ('cldfoc','fochana')
          WHERE (ABS(ifld2).GT.1e-15)
            ofld=ofld/ifld2
          ELSEWHERE
            ofld=0.
          ENDWHERE
c
c --- - Weight with land fraction 
        CASE ('landfrac') 
          ofld=ofld*ifld2
c
c --- - Times dry mass (computed offline from PS and Q)
        CASE ('timesmass')
          ofld=ofld*5.11253535805483d+18
c
c --- - Invert fraction field
        CASE ('invert') 
          ofld=1-ofld 
c
c --- - Divide by g 
        CASE ('xginv')
          ofld=ofld/9.80665 
c 
        END SELECT
        IF (str1.EQ.str2) exit 
      END DO 
c
      END SUBROUTINE special_post



      SUBROUTINE calcload
c
      IMPLICIT NONE 
c     
      REAL(KIND=8) :: pt,pb,ps1,fldint 
      INTEGER :: i,j,k 
c 
c --- Compute dp and dz   
      DO j=1,jdm 
        DO i=1,idm
          fldint=0. 
          DO k=1,kdm 
            ps1=ps(i,j) 
            pt=p0*hyai(k)+ps1*hybi(k)
            pb=p0*hyai(k+1)+ps1*hybi(k+1)
            fldint=fldint+ofld(i,j,k)*(pb-pt)*ginv  
          ENDDO 
          ofld(i,j,kdm)=fldint
        ENDDO
      ENDDO
c 
      END SUBROUTINE calcload

      END MODULE cam2cmor_mod_special
