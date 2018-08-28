#!/bin/sh

msfvenom -e generic/none -a x86 --platform linux -p linux/x86/read_file PATH=/etc/passwd | sctest -vvv -Ss 10000 -G read_file.dot && dot read_file.dot -T png > read_file.png

