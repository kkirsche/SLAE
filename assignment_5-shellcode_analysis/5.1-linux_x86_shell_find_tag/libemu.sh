#!/bin/sh

msfvenom -p linux/x86/shell_find_tag --platform linux -a x86 -e generic/none | sctest -vvv -Ss 10000
