#!/bin/bash

set -e

SCRIPT=$(readlink -f "$0")
EXEPATH=$(dirname "$SCRIPT")

cd $EXEPATH/bin; 

case $(uname -m) in
	arm*)
		# Use native arm compiler (no cross prefix)
		./main.elf 0 0 4 4 0x12345678
		;;
	   *)
		# Use cross compiler
		e-sim --host `pwd`/main.elf 0 0 4 4 0x12345678 -p parallella16
		;;
esac

#> dotproduct.log

retval=$?

if [ $retval -ne 0 ]
then
    echo "$SCRIPT FAILED"
else
    echo "$SCRIPT PASSED"
fi

exit $retval
