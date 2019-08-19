      PROGRAM main 
c
      USE m_namelists, ONLY: verbose, read_namelists, print_namelists,
     .  ibasedir, casename, forcefilescan  
      USE m_modelsatm, ONLY: atm2cmor
      USE m_modelslnd, ONLY: lnd2cmor
      USE m_modelsice, ONLY: ice2cmor
      USE m_modelsocn, ONLY: ocn2cmor
c
      IMPLICIT NONE
c
      LOGICAL :: fileexists 
#ifdef MPI
      INCLUDE 'mpif.h' 
      INTEGER :: mpierror,mpirank  
c
c --- Initialise mpi 
      CALL MPI_INIT(mpierror) 
#endif 
c
c --- Read namelists 
      CALL read_namelists
      IF (verbose) CALL print_namelists
c
c --- Create file list if it does not exist
#ifdef MPI
      CALL MPI_COMM_RANK(MPI_COMM_WORLD, mpirank, mpierror)
      IF (mpirank.EQ.0) THEN 
#endif 
      INQUIRE(FILE=TRIM('filelist_'//casename),EXIST=fileexists)
      IF (.NOT.fileexists.OR.forcefilescan) THEN
        WRITE(*,*) 'get_file_info: create new file list '
     .    //TRIM('filelist_'//casename)
        CALL SYSTEM('find '//trim(ibasedir)//'/'//trim(casename)//
     .    ' -path "*/hist/*" -name "*.nc"'
     .    //' | sort > '//TRIM('filelist_'//casename))
      ELSE
        WRITE(*,*) 'get_file_info: read existing file list '   
     .    //TRIM('filelist_'//casename)
      ENDIF
#ifdef MPI
      ENDIF 
      CALL MPI_BARRIER(MPI_COMM_WORLD,mpierror)
#endif 
c
c --- Run cmor processing for individual components
      call atm2cmor 
      call lnd2cmor 
      call ice2cmor
      call ocn2cmor 
c
#ifdef MPI
c --- Finalise mpi 
      call MPI_FINALIZE(mpierror) 
c
#endif 
      WRITE(*,*)
      WRITE(*,*) '===================='   
      WRITE(*,*) '   ALL JOBS DONE'   
      WRITE(*,*) '===================='   
      WRITE(*,*)
      END PROGRAM main
