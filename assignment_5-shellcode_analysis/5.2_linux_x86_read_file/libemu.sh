#!/bin/sh

msfvenom -e generic/none -a x86 --platform linux -p linux/x86/read_file PATH=/etc/passwd | sctest -vvv -Ss 10000
