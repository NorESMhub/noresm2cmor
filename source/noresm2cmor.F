      PROGRAM main 
c
      USE m_namelists
      USE m_modelsatm
      USE m_modelslnd
      USE m_modelsice
      USE m_modelsocn
c
      IMPLICIT NONE
c
c --- Read namelists 
      CALL read_namelists
      IF (verbose) CALL print_namelists
c
c --- Run cmor processing for individual components
      call atm2cmor 
      call lnd2cmor 
      call ice2cmor
      call ocn2cmor 
c
      END PROGRAM main
