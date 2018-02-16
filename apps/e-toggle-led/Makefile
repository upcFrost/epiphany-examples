# ESDK setup
ESDK:=${EPIPHANY_HOME}
EINCS:= $(strip -I${ESDK}/tools/host/include -I${ESDK}/tools/e-gnu/include -I${ESDK}/tools/e-gnu/epiphany-elf/include)
ELDF:=${ESDK}/bsps/current/internal.ldf
PATH:=$(PATH):${EPIPHANY_HOME}/tools/e-gnu/bin
LD_LIBRARY_PATH:=${EPIPHANY_HOME}/tools/host/lib:${LD_LIBRARY_PATH}
LD_LIBRARY_PATH:=${EPIPHANY_HOME}/tools/e-gnu/lib:${LD_LIBRARY_PATH}
LD_LIBRARY_PATH:=${EPIPHANY_HOME}/tools/e-gnu/epiphany-elf/lib:${LD_LIBRARY_PATH}

# LLVM Bin dir

# FLAGS
GCCFLAGS=-c -Wall
CLANGFLAGS=-target epiphany -O2
LLCFLAGS=-march epiphany -mcpu E16 -O2
LDFLAGS=-T ${ELDF} -le-lib -lm -L${EPIPHANY_HOME}/tools/e-gnu/lib -L${EPIPHANY_HOME}/tools/e-gnu/epiphany-elf/lib -L${EPIPHANY_HOME}/tools/host/lib

# SOURCES
SOURCES=$(shell ls src/device*.c)
ASMFILES=$(SOURCES:src/%=asm/%)
ASMFILESGCC=$(ASMFILES:.c=.gcc.s)
ASMFILESLLVM=$(ASMFILES:.c=.llvm.s)
OBJECTS=$(SOURCES:src/%=obj/%)
OBJECTSGCC=$(OBJECTS:.c=.gcc.o)
OBJECTSLLVM=$(OBJECTS:.c=.llvm.o)
EXECUTABLE=$(SOURCES:src/%.c=bin/%)

.PHONY: all

all: clean $(EXECUTABLE)_llvm $(EXECUTABLE)_gcc

list:
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$'

clean:
	find . -name *.o -exec rm -f {} +
	find . -name *.ll -exec rm -f {} +
	find . -name *.s -exec rm -f {} +
	rm -f $(EXECUTABLE)

makedirs:
	mkdir -p obj
	mkdir -p bin
	mkdir -p asm
	mkdir -p ll

$(EXECUTABLE)_llvm: $(OBJECTSLLVM) makedirs
	e-gcc -o $@  $(OBJECTSLLVM) $(LDFLAGS)

$(EXECUTABLE)_gcc: $(OBJECTSGCC) makedirs
	e-gcc -o $@ $(OBJECTSGCC) $(LDFLAGS)

asm/%.gcc.s: obj/%.gcc.o makedirs
	e-objdump -D $< > $@

obj/%.gcc.o: src/%.c makedirs
	e-gcc $(GCCFLAGS) $(EINCS) $< -o $@

obj/%.llvm.o: ll/%.ll makedirs
	$(LLVMBIN)/llc $(LLCFLAGS) -filetype obj $< -o $@

asm/%.llvm.s: ll/%.ll makedirs
	$(LLVMBIN)/llc $(LLCFLAGS) -filetype asm $< -o $@

ll/%.ll : src/%.c makedirs
	$(LLVMBIN)/clang $(CLANGFLAGS) $(EINCS) -emit-llvm -S $< -o $@
