      MODULE micom2cmor_mod_special
c
      USE netcdf
      USE micom2cmor_mod_namelists
      USE micom2cmor_mod_utils
      USE micom2cmor_mod_main
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
      lsumz=.FALSE.
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
c --- - atm to Pa
        CASE ('atm2Pa')
          vunits='Pa'
c
c --- - uatm to Pa
        CASE ('uatm2Pa')
          vunits='Pa'
c 
c --- - Unit transformation: mol cfcXX m-3 -> mol cfcXX kg-1
        CASE ('cfcunits')
          vunits='mol kg-1'
c
c --- - CFC11 comment
        CASE ('cfc11comment')
          vcomment='In this simulation, annual means of reconstructed'//
     .' Northern Hemisphere CFC-11 are applied globally to the ocean.'//
     .' Reference: Walker S.J., Weiss R.F., Salameh P.K. (2000)'//
     .' Reconstructed histories of the annual mean atmospheric mole'//
     .' fractions for the halocarbons CFC-11, CFC-12, CFC-113 and'//
     .' carbon tetrachloride. J. Geophys. Res. 105(C6): 14285-14296.'//
     .' CFC-11 data in ppt (1910.5-2008.5):'//
     .' 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,'//
     .' 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,'//
     .' 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,'//
     .' 0.0, 0.0, 0.0, 0.0, 0.0, 0.1, 0.1, 0.1, 0.2, 0.4, 0.7, 1.0,'//
     .' 1.5, 2.2, 3.0, 4.1, 5.4, 6.8, 8.1, 9.4, 11.1, 13.3, 16.1,'//
     .' 19.6, 23.8, 28.4, 33.6, 39.5, 46.1, 53.7, 62.5, 72.0, 82.7,'//
     .' 94.9, 108.4, 121.4, 133.9, 145.9, 156.6, 168.3, 176.7, 184.3,'//
     .' 191.4, 199.4, 208.1, 218.1, 229.5, 241.7, 253.0, 259.5,'// 
     .' 266.0, 268.4, 268.3, 269.7, 269.8, 268.5, 267.3, 265.9,'// 
     .' 264.4, 262.9, 262.0, 260.3, 258.1, 256.0, 254.1, 252.0,'// 
     .' 248.9, 246.9, 245.3'
c
c --- - CFC11 comment
        CASE ('cfc12comment')
          vcomment='In this simulation, annual means of reconstructed'//
     .' Northern Hemisphere CFC-12 are applied globally to the ocean.'//
     .' Reference: Walker S.J., Weiss R.F., Salameh P.K. (2000)'//
     .' Reconstructed histories of the annual mean atmospheric mole'//
     .' fractions for the halocarbons CFC-11, CFC-12, CFC-113 and'//
     .' carbon tetrachloride. J. Geophys. Res. 105(C6): 14285-14296.'//
     .' CFC-12 data in ppt (1910.5-2008.5):'//
     .' 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,'//
     .' 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,'//
     .' 0.0, 0.0, 0.1, 0.1, 0.2, 0.3, 0.4, 0.5, 0.7, 0.9, 1.2, 1.7,'//
     .' 2.3, 3.4, 4.8, 6.1, 7.6, 9.2, 11.0, 12.8, 15.0, 17.4, 20.2,'//
     .' 23.4, 26.8, 30.5, 35.0, 40.0, 45.8, 52.5, 60.4, 69.3, 79.2,'//
     .' 90.3, 102.8, 116.7, 132.0, 148.3, 166.1, 185.7, 207.1, 228.1,'//
     .' 248.0, 266.9, 284.2, 305.9, 323.0, 339.6, 353.3, 369.0,'// 
     .' 385.7, 403.4, 424.3, 444.0, 465.4, 483.6, 497.7, 506.0,'// 
     .' 516.4, 523.2, 528.9, 533.9, 537.6, 540.5, 542.5, 544.1,'// 
     .' 546.4, 546.9, 546.8, 546.5, 547.2, 546.5, 544.5, 541.8, 540.6'
c
c --- - mol m-3 
        CASE ('mol m-3')
          vunits='mol m-3'
c
c --- - mol m-2 s-1
        CASE ('mol m-2 s-1')
          vunits='mol m-2 s-1'
c
c --- - mol m-3 s-1
        CASE ('mol m-3 s-1')
          vunits='mol m-3 s-1'
c
c --- - Salinity has to be in practical salinity units 
        CASE ('psu')
          vunits='psu'
c
c --- - Fix unitless units 
        CASE ('unitless')
          vunits='1'
c
c --- - Set correct units for percentage
        CASE ('percent')
          vunits='%'
c
c --- - Set correct units for fraction
        CASE ('fraction')
          vunits='1'
c
c --- - Unit transformation: kg m-2  
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
c --- - Set units to kg 
        CASE ('kg')
          vunits='kg'
c
c --- - Set units to m^3 
        CASE ('m3')
          vunits='m3'
c        
c --- - Convert units from radians2 to m2    
        CASE ('rad2m')
          vunits='m2'
c        
c --- - Set units for streamfunction    
        CASE ('strmf')
          vunits='kg s-1'
          lsumz=.TRUE.
c
c --- - Set positive attribute  
        CASE ('positiveup')
          vpositive='up'
        CASE ('positivedo')
          vpositive='down'
c
c --- - Compute vertical sum 
        CASE ('sumz') 
          lsumz=.TRUE. 
c
c --- - Compute density 
        CASE ('ts2rho0') 
          vunits='kg m-3'
c
c --- - Compute steric sea level change from density 
        CASE ('ts2zossga','t2zostoga') 
          vunits='m'
c
c --- - Compute fixed cell volume of interpolated grid
        CASE ('volcello') 
          vunits='m3'
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
      INTEGER :: i,j,k 
      REAL :: r,rd,p,ptop,pbot,sref=35.
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
c --- - Compute depth below geoid from dz or pddpo 
        CASE ('dz2zfull') 
          fldacc(:,:,1)=sealv 
          DO k=1,kdm 
            fldacc(:,:,k)=fldacc(:,:,MAX(k-1,1))+fld(:,:,k)
          ENDDO 
          fld=fldacc-0.5*fld    
c
c --- - Compute depth below geoid at interfaces from dz      
        CASE ('dz2zhalf') 
          fldacc(:,:,1)=sealv 
          DO k=1,kdm 
            fldacc(:,:,k)=fldacc(:,:,MAX(k-1,1))+fld(:,:,k)
          ENDDO 
          fld=fldacc
c
c --- - Convert units from radians2 to m2    
        CASE ('rad2m')
          fld=fld*6.37122e6**2
c
c --- - Unit transformation: cm day-1 -> kg m-2 s-1 
c       CASE ('kg m-2 s-1')
c         fld=fld/(10.*24.*3600.) 
c
c --- - Set ice free points to missing value
        CASE ('zero2missing')
          WHERE (abs(fld).LT.1e-6)
            fld=1e20
          END WHERE
c
c --- - Set ice free points to missing value
        CASE ('pmask') 
          DO k=1,SIZE(fld,3)
            WHERE (pmask.LT.0.5) fld(:,:,k)=1e20
          ENDDO
c
c --- - Compute vertical sum 
        CASE ('sumz') 
          DO k=2,kdm 
            WHERE (abs(fld(:,:,k)).LT.1e20)
              fld(:,:,1)=fld(:,:,1)+fld(:,:,k)
            END WHERE
          ENDDO 
c
c --- - Multiply with global ocean area 
        CASE ('xglbarea') 
          fld=fld*aoglb
c
c --- - Multiply gravity constant 
        CASE ('xg') 
          WHERE (fld.LT.1e20) fld=fld*9.806
c
c --- - Devide by gravity constant 
        CASE ('xginv') 
          WHERE (fld.LT.1e20) fld=fld/9.806
c
c --- - Flip sign 
        CASE ('flipsign') 
          WHERE (fld.LT.1e20) fld=-fld
c
c --- - Compute global 2d average 
        CASE ('glbave2d')
          fld(1,1,1)=SUM(fld(:,:,1)*parea)/SUM(parea)
c
c --- - Compute global 3d average 
        CASE ('glbave3d') 
          r=0.
          rd=0. 
          DO k=1,kdm 
            r=r+SUM(fld(:,:,k)*dp(:,:,k)*parea)
            rd=rd+SUM(dp(:,:,k)*parea)
          ENDDO
          fld(1,1,1)=r/MAX(1e-10,rd)
c
c --- - Compute potential density 
        CASE ('ts2rho0') 
c         WRITE(*,*) 'rho_ref(0Pa,15degC,35psu)=',rho(0.,15.,35.)*1e3 
          DO k=1,SIZE(fld,DIM=3) 
            DO j=1,SIZE(fld,DIM=2)
              DO i=1,SIZE(fld,DIM=1)    
                IF (fld(i,j,k).NE.1e20) 
     .            fld(i,j,k)=1e3*rho(0.,fld(i,j,k),fld2(i,j,k)) 
              ENDDO
            ENDDO
          ENDDO
c
c --- - Compute steric sea level
        CASE ('ts2zossga') 
          IF (vtype.EQ.'layer') THEN
            r=0.
            DO j=1,jdm
              DO i=1,idm    
                pbot=0.
                DO k=1,kdm
                  ptop=pbot 
                  pbot=ptop+dp(i,j,k)
                  IF (fld(i,j,k).NE.1e20) THEN
                    r=r+1e-2*(1e-2*ginv)*parea(i,j)*
     .                p_alpha(ptop,pbot,fld(i,j,k),fld2(i,j,k))
                  ENDIF
                ENDDO
              ENDDO
            ENDDO
            fld(1,1,1)=(r-voglb)/aoglb    
            WRITE(*,*) 'zossga=',fld(1,1,1)
          ELSE 
            STOP 'input variables for zossga must be of type layer'
          ENDIF
c
c --- - Compute thermo-steric sea level
        CASE ('t2zostoga')
          IF (vtype.EQ.'layer') THEN
            r=0.
            DO j=1,jdm
              DO i=1,idm
                pbot=0.
                DO k=1,kdm
                  ptop=pbot 
                  pbot=ptop+dp(i,j,k)
                  IF (fld(i,j,k).NE.1e20)
     .              r=r+1e-2*(1e-2*ginv)*parea(i,j)*
     .                p_alpha(ptop,pbot,fld(i,j,k),sref)
                ENDDO
              ENDDO
            ENDDO
            fld(1,1,1)=(r-voglb)/aoglb
            WRITE(*,*) 'zostoga',fld(1,1,1)
          ELSE 
            STOP 'input variable for zostoga must be of type layer'
          ENDIF
c 
c --- - Set land mask of streamfunction 
        CASE ('strmf')
          WHERE (pmask.EQ.0)
            fld(:,:,1)=1e20
          END WHERE
c
c --- - Compute fixed cell volume of interpolated grid
        CASE ('volcello') 
          DO j=1,jdm
            DO i=1,idm    
              DO k=ddm,1,-1
                IF (fld(i,j,1).EQ.0.) THEN
                  fld(i,j,k)=1e20
                ELSE
                  ptop=MIN(depth_bnds(1,k),fld(i,j,1))  
                  pbot=MIN(depth_bnds(2,k),fld(i,j,1))  
                  fld(i,j,k)=pbot-ptop
                ENDIF
              ENDDO
            ENDDO
          ENDDO
c 
c --- - Compute basin index
        CASE ('basin')
          OPEN(10,FILE=ocnmertfile)
          READ(10,'(2i6)') i,j
          IF (i.NE.idm.OR.j.NE.jdm)
     .      STOP 'mertraocean: incorrect indexes in mertraoceans.dat!'
          str1=' '
          WRITE(str1,*) '(',jdm,'i1)'
          READ(10,str1) ((basin(i,j),j=1,jdm),i=1,idm)
          CLOSE(10) 
          fld=0 
          DO j=1,jdm
            DO i=1,idm    
c --- --- --- Southern Ocean 
              IF (plat(i,j).LT.0.AND.basin(i,j).EQ.1) fld(i,j,1)=1
c --- --- --- Pacific Ocean 
              IF (basin(i,j).EQ.3) fld(i,j,1)=3
c --- --- --- Arctic Ocean
              IF (plat(i,j).GT.60.AND.basin(i,j).EQ.1) fld(i,j,1)=4
c --- --- --- Indian Ocean 
              IF (basin(i,j).EQ.4) fld(i,j,1)=5
c --- --- --- Mediterranean Sea
              IF (basin(i,j).EQ.2.AND.plat(i,j).GT.30.5.AND.
     .          plat(i,j).LT.40.5.AND.(plon(i,j).GT.354.5.OR.
     .          plon(i,j).LT.37)) fld(i,j,1)=6
              IF (basin(i,j).EQ.2.AND.plat(i,j).GT.40.5.AND.
     .          plat(i,j).LT.46.AND.(plon(i,j).GT.359.OR.
     .          plon(i,j).LT.27.5)) fld(i,j,1)=6
c --- --- --- Black Sea  
              IF (basin(i,j).EQ.1.AND.plat(i,j).GT.40.5.AND.
     .          plat(i,j).LT.48.AND.plon(i,j).GT.27.5.AND.
     .          plon(i,j).LT.45) fld(i,j,1)=7
c --- --- --- Hudson Bay   
              IF (basin(i,j).EQ.2.AND.plat(i,j).GT.50.AND.
     .          plat(i,j).LT.70.AND.plon(i,j).GT.265.AND.
     .          plon(i,j).LT.295) fld(i,j,1)=8
c --- --- --- Baltic Sea  
              IF (basin(i,j).EQ.2.AND.plat(i,j).GT.53.AND.
     .          plat(i,j).LT.62.AND.plon(i,j).GT.10.AND.
     .          plon(i,j).LT.30) fld(i,j,1)=9
              IF (basin(i,j).EQ.2.AND.plat(i,j).GT.62.AND.
     .          plat(i,j).LT.66.5.AND.plon(i,j).GT.17.AND.
     .          plon(i,j).LT.30) fld(i,j,1)=9
c --- --- --- Red Sea  
              IF (basin(i,j).EQ.4.AND.plat(i,j).GT.13.AND.
     .          plat(i,j).LT.30.AND.plon(i,j).GT.31.AND.
     .          plon(i,j).LT.44) fld(i,j,1)=10
c --- --- --- Atlantic ocean        
              IF (basin(i,j).EQ.2.AND.fld(i,j,1).EQ.0) fld(i,j,1)=2
            ENDDO
          ENDDO
c 
c --- - Compute basin index
        CASE ('Xfield2')
          WHERE (fld.NE.1e20)
            fld=fld*fld2
          END WHERE
c
c --- - Unit transformation: mol cfcXX m-3 -> mol cfcXX kg-1
        CASE ('cfcunits')
          WHERE (fld.NE.1e20)
            fld=fld/1027.
          END WHERE
c
c --- - atm to Pa
        CASE ('atm2Pa')
          WHERE (fld.NE.1e20)
            fld=fld*101325
          END WHERE
c
c --- - uatm to Pa 
        CASE ('uatm2Pa')
          WHERE (fld.NE.1e20)
            fld=fld*0.101325
          END WHERE
c
        END SELECT
        IF (str1.EQ.str2) exit 
      END DO
c
      END SUBROUTINE special_post


      END MODULE micom2cmor_mod_special
