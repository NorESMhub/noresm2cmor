# Targets 
TARGET1=cam2cmor
TARGET2=clm2cmor
TARGET3=cice2cmor
TARGET4=micom2cmor

# Objects
OBJ1=cam2cmor_mod_namelists.o cam2cmor_mod_utils.o cam2cmor_mod_main.o cam2cmor_mod_special.o cam2cmor.o
OBJ2=clm2cmor_mod_namelists.o clm2cmor_mod_utils.o clm2cmor_mod_main.o clm2cmor_mod_special.o clm2cmor.o
OBJ3=cice2cmor_mod_namelists.o cice2cmor_mod_utils.o cice2cmor_mod_main.o cice2cmor_mod_special.o cice2cmor.o
OBJ4=micom2cmor_mod_namelists.o micom2cmor_mod_utils.o micom2cmor_mod_main.o micom2cmor_mod_special.o micom2cmor.o

# Paths 
SRCDIR=../source
BINDIR=../bin 

# Fortran compiler
FC=gfortran 

# Linker
LD=$(FC)

# Libraries
CMOR=/diverse/software/cmor-2.7.1
UUID=/diverse/software/uuid-1.5.1
NETCDF=/diverse/software/old_software/netcdf.gnu-4.2.1.1

# Directory list to search for library files
LIBS=-L$(CMOR)/lib -Wl,-rpath=$(CMOR)/lib -L$(UUID)/lib -Wl,-rpath=$(UUID)/lib -lcmor -lnetcdff -lnetcdf -lhdf5 -lhdf5_hl -luuid -l:libudunits2.so.0 -l:libexpat.so.1

# Compiler flags
#FFLAGS=-g -fbounds-check -fdefault-real-8 -I$(CMOR)/include -I$(NETCDF)/include
FFLAGS=-O3 -fdefault-real-8 -I$(CMOR)/include -I$(NETCDF)/include

# Linker flags
#LDFLAGS=$(LIBS) -g -fbounds-check
LDFLAGS=$(LIBS) 

.PHONY: all clean

all: $(TARGET1) $(TARGET2) $(TARGET3) $(TARGET4)

clean:
	rm -f *.o *.f *.h *.inc *2cmor* 

$(TARGET1): $(OBJ1) 
	$(LD) -o $(TARGET1) $(OBJ1) $(LDFLAGS)
	cp -f $(TARGET1) $(BINDIR)

$(TARGET2): $(OBJ2) 
	$(LD) -o $(TARGET2) $(OBJ2) $(LDFLAGS)
	cp -f $(TARGET2) $(BINDIR)

$(TARGET3): $(OBJ3)
	$(LD) -o $(TARGET3) $(OBJ3) $(LDFLAGS)
	cp -f $(TARGET3) $(BINDIR)

$(TARGET4): $(OBJ4)
	$(LD) -o $(TARGET4) $(OBJ4) $(LDFLAGS)
	cp -f $(TARGET4) $(BINDIR)

cam2cmor.o: $(SRCDIR)/cam2cmor.F
	$(FC) $(FFLAGS) -c $(SRCDIR)/cam2cmor.F

cam2cmor_mod_namelists.o: $(SRCDIR)/cam2cmor_mod_namelists.F
	$(FC) $(FFLAGS) -c $(SRCDIR)/cam2cmor_mod_namelists.F

cam2cmor_mod_special.o: $(SRCDIR)/cam2cmor_mod_special.F
	$(FC) $(FFLAGS) -c $(SRCDIR)/cam2cmor_mod_special.F

cam2cmor_mod_main.o: $(SRCDIR)/cam2cmor_mod_main.F
	$(FC) $(FFLAGS) -c $(SRCDIR)/cam2cmor_mod_main.F

cam2cmor_mod_utils.o: $(SRCDIR)/cam2cmor_mod_utils.F
	$(FC) $(FFLAGS) -c $(SRCDIR)/cam2cmor_mod_utils.F

clm2cmor.o: $(SRCDIR)/clm2cmor.F
	$(FC) $(FFLAGS) -c $(SRCDIR)/clm2cmor.F

clm2cmor_mod_namelists.o: $(SRCDIR)/clm2cmor_mod_namelists.F
	$(FC) $(FFLAGS) -c $(SRCDIR)/clm2cmor_mod_namelists.F

clm2cmor_mod_special.o: $(SRCDIR)/clm2cmor_mod_special.F
	$(FC) $(FFLAGS) -c $(SRCDIR)/clm2cmor_mod_special.F

clm2cmor_mod_main.o: $(SRCDIR)/clm2cmor_mod_main.F
	$(FC) $(FFLAGS) -c $(SRCDIR)/clm2cmor_mod_main.F

clm2cmor_mod_utils.o: $(SRCDIR)/clm2cmor_mod_utils.F
	$(FC) $(FFLAGS) -c $(SRCDIR)/clm2cmor_mod_utils.F

cice2cmor.o: $(SRCDIR)/cice2cmor.F
	$(FC) $(FFLAGS) -c $(SRCDIR)/cice2cmor.F

cice2cmor_mod_namelists.o: $(SRCDIR)/cice2cmor_mod_namelists.F
	$(FC) $(FFLAGS) -c $(SRCDIR)/cice2cmor_mod_namelists.F

cice2cmor_mod_special.o: $(SRCDIR)/cice2cmor_mod_special.F
	$(FC) $(FFLAGS) -c $(SRCDIR)/cice2cmor_mod_special.F

cice2cmor_mod_main.o: $(SRCDIR)/cice2cmor_mod_main.F
	$(FC) $(FFLAGS) -c $(SRCDIR)/cice2cmor_mod_main.F

cice2cmor_mod_utils.o: $(SRCDIR)/cice2cmor_mod_utils.F
	$(FC) $(FFLAGS) -c $(SRCDIR)/cice2cmor_mod_utils.F

micom2cmor.o: $(SRCDIR)/micom2cmor.F
	$(FC) $(FFLAGS) -c $(SRCDIR)/micom2cmor.F

micom2cmor_mod_namelists.o: $(SRCDIR)/micom2cmor_mod_namelists.F
	$(FC) $(FFLAGS) -c $(SRCDIR)/micom2cmor_mod_namelists.F

micom2cmor_mod_special.o: $(SRCDIR)/micom2cmor_mod_special.F
	$(FC) $(FFLAGS) -c $(SRCDIR)/micom2cmor_mod_special.F

micom2cmor_mod_main.o: $(SRCDIR)/micom2cmor_mod_main.F
	$(FC) $(FFLAGS) -c $(SRCDIR)/micom2cmor_mod_main.F

micom2cmor_mod_utils.o: $(SRCDIR)/micom2cmor_mod_utils.F
	$(FC) $(FFLAGS) -c $(SRCDIR)/micom2cmor_mod_utils.F
