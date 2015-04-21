# XXX
PULLADDR=https://github.com/radare/radare2-regressions.git

do:
	-git pull ${PULLADDR}
	@sh run_tests.sh

all:
	@sh run_tests.sh
	@sh run_tests.sh t.asm
	@sh run_tests.sh t.anal
	@$(MAKE) -C t.archos
	@sh run_tests.sh t.io
	@sh run_tests.sh t.esil
	@sh run_tests.sh t.formats/pe
	@sh run_tests.sh t.formats/elf
	@sh run_tests.sh t.formats/dex
	@sh run_tests.sh t.formats/java
	@sh run_tests.sh t.formats/mach0
	@sh run_tests.sh t.formats/xbe
	@sh run_tests.sh t.formats/firmware
	@sh run_tests.sh t.formats/pdb
	@sh run_tests.sh t.formats/mangling
	@sh run_tests.sh t.formats/msil
	@sh run_tests.sh t.formats/zimg	
	@sh run_tests.sh t.pe
	@sh run_tests.sh t.tools

commands:
	@sh run_tests.sh

asm:
	@sh run_tests.sh t.asm/8051
	@sh run_tests.sh t.asm/arc
	@sh run_tests.sh t.asm/arm
	@sh run_tests.sh t.asm/avr
	@sh run_tests.sh t.asm/cr16
	@sh run_tests.sh t.asm/dalvik
	@sh run_tests.sh t.asm/ebc
	@sh run_tests.sh t.asm/gb
	@sh run_tests.sh t.asm/h8300
	@sh run_tests.sh t.asm/java
	@sh run_tests.sh t.asm/mips
	@sh run_tests.sh t.asm/tms320
	@sh run_tests.sh t.asm/x86
	@sh run_tests.sh t.asm/z80

tools:
	@sh run_tests.sh t.tools
io:
	@sh run_tests.sh t.io
asm.8051:
	@sh run_tests.sh t.asm/8051
asm.arc:
	@sh run_tests.sh t.asm/arc
asm.arm:
	@sh run_tests.sh t.asm/arm
asm.avr:
	@sh run_tests.sh t.asm/avr
asm.cr16:
	@sh run_tests.sh t.asm/cr16
asm.dalvik:
	@sh run_tests.sh t.asm/dalvik
asm.ebc:
	@sh run_tests.sh t.asm/ebc
asm.gb:
	@sh run_tests.sh t.asm/gb
asm.h8300:
	@sh run_tests.sh t.asm/h8300
asm.java:
	@sh run_tests.sh t.asm/java
asm.mips:
	@sh run_tests.sh t.asm/mips
asm.tms320:
	@sh run_tests.sh t.asm/tms320
asm.x86:
	@sh run_tests.sh t.asm/x86
asm.z80:
	@sh run_tests.sh t.asm/z80

anal:
	@sh run_tests.sh t.anal/arm
	@sh run_tests.sh t.anal/java
	@sh run_tests.sh t.anal/mips
	@sh run_tests.sh t.anal/x86
	@sh run_tests.sh t.anal/others_anal
anal.arm:
	@sh run_tests.sh t.anal/arm
anal.java:
	@sh run_tests.sh t.anal/java
anal.mips:
	@sh run_tests.sh t.anal/mips
anal.x86:
	@sh run_tests.sh t.anal/x86
anal.others:
	@sh run_tests.sh t.anal/others_anal
dbg.linux:
	@sh run_tests.sh t.archos/Linux

esil:
	@sh run_tests.sh t.esil

formats:
	@sh run_tests.sh t.formats/pe
	@sh run_tests.sh t.formats/elf
	@sh run_tests.sh t.formats/java
	@sh run_tests.sh t.formats/mach0
	@sh run_tests.sh t.formats/xbe
	@sh run_tests.sh t.formats/firmware
	@sh run_tests.sh t.formats/pdb
	@sh run_tests.sh t.formats/mangling
	@sh run_tests.sh t.formats/msil
	@sh run_tests.sh t.formats/zimg

format.pe:
	@sh run_tests.sh t.formats/pe

format.mangling:
	@sh run_tests.sh t.formats/mangling

format.msil:
	@sh run_tests.sh t.formats/msil

format.pdb:
	@sh run_tests.sh t.formats/pdb

format.elf:
	@sh run_tests.sh t.formats/elf

format.java:
	@sh run_tests.sh t.formats/java

format.dex:
	@sh run_tests.sh t.formats/dex

format.mach0:
	@sh run_tests.sh t.formats/mach0

format.xbe:
	@sh run_tests.sh t.formats/xbe

format.firmware:
	@sh run_tests.sh t.formats/firmware

format.zimg:
	@sh run_tests.sh t.formats/zimg

format.others:
	@sh run_tests.sh t.formats/others

udis86:
	@sh run_tests.sh t.asm/udis86

capstone:
	@sh run_tests.sh t.asm/capstone
	@sh run_tests.sh t.anal/capstone

utils:
	@sh run_tests.sh t/rasm2
	@sh run_tests.sh t/rabin2

broken:
	@cd t ; grep BROKEN=1 * | cut -d : -f1 |sort -u

clean:
	rm -rf tmp

install:
	ln -fs `pwd`/r2-v /usr/bin/r2-v


tested:
	@grep -re FILE= t*  | cut -d : -f 2- | sed -e 's/^.*bins\///g' |sort -u | grep -v FILE

untested:
	@${MAKE} -s tested > .a
	@${MAKE} -s allbins > .b
	@diff -ru .a .b | grep ^+ | grep -v +++ | cut -c 2-
	@rm -f .a .b

allbins:
	@cd bins ; find * -type f |sort -u

.PHONY: all clean
