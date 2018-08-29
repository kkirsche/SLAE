#!/bin/sh

msfvenom -p linux/x86/adduser --platform linux -a x86 -e generic/none | sctest -vvv -Ss 10000 -G adduser.dot && dot adduser.dot -T png > adduser.png
