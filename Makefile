#
# Requires https://github.com/autc04/Retro68
# Update TOOLCHAIN to point to your build.
#

TOOLCHAIN=/opt/Retro68-build/toolchain
ARCH=m68k-unknown-elf

CC=$(TOOLCHAIN)/bin/$(ARCH)-gcc
LINKER=$(TOOLCHAIN)/bin/$(ARCH)-g++
MAKE_APPL = $(TOOLCHAIN)/bin/MakeAPPL

CFLAGS=-O3 -Wno-multichar
#LFLAGS=-d -c 'HCC ' -t APPL -mf
LFLAGS = -Wl,-elf2flt -Wl,-q -Wl,-Map=linkmap.txt -Wl,-undefined=consolewrite

LIBRARIES=-lretrocrt

SOURCES=Retro68Test.c
OBJECTS=$(SOURCES:.c=.o)
#RFILES=Retro68Test.r
EXECUTABLE=Retro68Test.68k
DISK=Retro68Test.dsk
BIN=Retro68Test.bin

all: $(SOURCES) $(DISK)

$(EXECUTABLE): $(OBJECTS)
	$(LINKER) $(LFLAGS) $(OBJECTS) $(LIBRARIES) -o $@
	#Rez -rd $(RFILES) -o $@ -i $(RINCLUDES) -append

%.dsk %.bin: %.68k
	$(MAKE_APPL) -c $< -o $*

.c.o:
	$(CC) $(CFLAGS) -c $< -o $@
	
clean:
	rm -rf *o $(EXECUTABLE) $(DISK) $(BIN)
