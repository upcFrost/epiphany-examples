#!/bin/bash

set -e

ESDK=${EPIPHANY_HOME}
ELIBS="-L ${ESDK}/tools/host/lib -L ${ESDK}/tools/e-gnu/lib"
ERPATH="-Wl,-rpath=${ESDK}/tools/host/lib -Wl,-rpath=${ESDK}/tools/e-gnu/lib"
EINCS="-I ${ESDK}/tools/host/include -I ${ESDK}/tools/e-gnu.x86_64/include"
ELDF=${ESDK}/bsps/current/internal.ldf

SCRIPT=$(readlink -f "$0")
EXEPATH=$(dirname "$SCRIPT")
cd $EXEPATH

# Create the binaries directory
mkdir -p bin/

if [ -z "${CROSS_COMPILE+xxx}" ]; then
case $(uname -m) in
	arm*)
		# Use native arm compiler (no cross prefix)
		CROSS_COMPILE=
		;;
	   *)
		# Use cross compiler
		CROSS_COMPILE="arm-linux-gnueabihf-"
		;;
esac
fi

# Build HOST side application
${CROSS_COMPILE}gcc src/main.c -o bin/main.elf ${EINCS} ${ELIBS} ${ERPATH} -le-hal -le-loader -lpthread

# Build DEVICE side program
e-gcc -g -O3  -T ${ELDF} src/e_task.c -o bin/e_task.elf -le-lib -lm -ffast-math

