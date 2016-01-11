# XXX
PULLADDR=https://github.com/radare/radare2-regressions.git

do:
	-git pull ${PULLADDR}
	@sh run_tests.sh

all: commands formats tools io asm anal esil tools archos

archos:
	@$(MAKE) -C t.archos
dbg.linux:
	@sh run_tests.sh t.archos/Linux

commands:
	@sh run_tests.sh

tools:
	@sh run_tests.sh t.tools

io:
	@sh run_tests.sh t.io

asm: asm.8051 asm.arc asm.arm asm.avr asm.cr16 asm.dalvik asm.ebc asm.gb asm.h8300 asm.labels asm.lh5801 asm.java asm.mips asm.msp430	asm.tms320 asm.ws asm.x86 asm.z80
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
asm.labels:
	@sh run_tests.sh t.asm/labels
asm.lh5801:
	@sh run_tests.sh t.asm/lh5801
asm.mips:
	@sh run_tests.sh t.asm/mips
asm.msp430:
	@sh run_tests.sh t.asm/msp430
asm.tms320:
	@sh run_tests.sh t.asm/tms320
asm.v810:
	@sh run_tests.sh t.asm/v810
asm.ws:
	@sh run_tests.sh t.asm/ws
asm.x86:
	@sh run_tests.sh t.asm/x86
asm.z80:
	@sh run_tests.sh t.asm/z80

anal: anal.arm anal.avr anal.java anal.mips anal.x86 anal.others
anal.arm:
	@sh run_tests.sh t.anal/arm
anal.avr:
	@sh run_tests.sh t.anal/avr
anal.java:
	@sh run_tests.sh t.anal/java
anal.mips:
	@sh run_tests.sh t.anal/mips
anal.x86:
	@sh run_tests.sh t.anal/x86
anal.others:
	@sh run_tests.sh t.anal/others_anal

esil:
	@sh run_tests.sh t.esil

formats: format.dex format.elf format.firmware format.java format.mach0 format.mangling format.msil format.mz format.omf format.others format.pdb format.pe format.xbe format.zimg
format.dex:
	@sh run_tests.sh t.formats/dex
format.elf:
	@sh run_tests.sh t.formats/elf
format.firmware:
	@sh run_tests.sh t.formats/firmware
format.java:
	@sh run_tests.sh t.formats/java
format.mach0:
	@sh run_tests.sh t.formats/mach0
format.mangling:
	@sh run_tests.sh t.formats/mangling
format.msil:
	@sh run_tests.sh t.formats/msil
format.mz:
	@sh run_tests.sh t.formats/mz
format.omf:
	@sh run_tests.sh t.formats/omf
format.others:
	@sh run_tests.sh t.formats/others
format.pdb:
	@sh run_tests.sh t.formats/pdb
format.pe:
	@sh run_tests.sh t.formats/pe
format.xbe:
	@sh run_tests.sh t.formats/xbe
format.zimg:
	@sh run_tests.sh t.formats/zimg

tools: rabin2 radiff2 ragg2 ragg2-cc rahash2 rasm2 rax2
rabin2:
	@sh run_tests.sh t.tools/rabin2
radiff2:
	@sh run_tests.sh t.tools/radiff2
ragg2:
	@sh run_tests.sh t.tools/ragg2
ragg2-cc:
	@sh run_tests.sh t.tools/ragg2-cc
rahash2:
	@sh run_tests.sh t.tools/rahash2
rasm2:
	@sh run_tests.sh t.tools/rasm2
rax2:
	@sh run_tests.sh t.tools/rax2

broken:
	grep BROKEN=1 t -r -l

clean:
	rm -rf tmp

install:
	ln -fs `pwd`/r2-v /usr/bin/r2-v

unit_tests:
	@make -C ./unit all
	@sh ./run_unit.sh

tested:
	@grep -re FILE= t*  | cut -d : -f 2- | sed -e 's/^.*bins\///g' |sort -u | grep -v FILE

untested:
	@${MAKE} -s tested > .a
	@${MAKE} -s allbins > .b
	@diff -ru .a .b | grep ^+ | grep -v +++ | cut -c 2-
	@rm -f .a .b

allbins:
	find bins -type f

.PHONY: all clean
