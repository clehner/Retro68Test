#
# Requires https://github.com/autc04/Retro68
# Update TOOLCHAIN to point to your build.
#

TOOLCHAIN=/opt/Retro68-build/toolchain
ARCH=m68k-unknown-elf

CC=$(TOOLCHAIN)/bin/$(ARCH)-gcc
LINKER=$(TOOLCHAIN)/bin/$(ARCH)-g++
MAKE_APPL=$(TOOLCHAIN)/bin/MakeAPPL
FROM_HEX=xxd -r

MINI_VMAC_DIR=~/Mac/Emulation/Mini\ vMac
MINI_VMAC=$(MINI_VMAC_DIR)/Mini\ vMac
MINI_VMAC_LAUNCHER_DISK=$(MINI_VMAC_DIR)/launcher-sys.dsk

CFLAGS=-O3 -Wno-multichar
#LFLAGS=-d -c 'HCC ' -t APPL -mf
LFLAGS = -Wl,-elf2flt -Wl,-q -Wl,-Map=linkmap.txt -Wl,-undefined=consolewrite

LIBRARIES=-lretrocrt

SOURCES=Retro68Test.c
OBJECTS=$(SOURCES:.c=.o)
EXECUTABLE=Retro68Test.68k
DISK=Retro68Test.dsk
BIN=Retro68Test.bin

RSRC_HEX=$(wildcard rsrc/*/*.hex)
RSRC_DAT=$(RSRC_HEX:.hex=.dat)

all: $(DISK)

$(EXECUTABLE): $(OBJECTS)
	$(LINKER) $(LFLAGS) $(OBJECTS) $(LIBRARIES) -o $@

%.dsk %.bin: %.68k rsrc-args
	$(MAKE_APPL) -c $< -o $* $(shell cat rsrc-args)

.c.o:
	$(CC) $(CFLAGS) -c $< -o $@

rsrc: $(RSRC_DAT) rsrc-args

rsrc/%.dat: rsrc/%.hex
	$(FROM_HEX) $< > $@

rsrc-args: $(RSRC_DAT)
	@cd rsrc && for code in *; do \
		echo -n "-t $$code "; \
		cd "$$code" && for file in *.dat; do \
			echo -n "-r $${file%.dat} rsrc/$$code/$$file "; \
		done; \
		cd ..; \
	done > ../$@

clean:
	rm -rf *.o $(EXECUTABLE) $(DISK) $(BIN) $(RSRC_DAT) rsrc-args

run: all
	$(MINI_VMAC) $(MINI_VMAC_LAUNCHER_DISK) $(DISK)
