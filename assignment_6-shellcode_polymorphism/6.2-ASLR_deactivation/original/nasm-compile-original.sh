#!/bin/bash

binary=original

echo '[+] Assembling with Nasm ... '
nasm -f elf32 -o "${binary}.o" "${binary}.nasm"

echo '[+] Linking ...'
ld -o "${binary}" "${binary}.o" -fno-stack-protector -shared -z execstack

echo '[+] Dumping shellcode ...'
objdump -d "./${binary}"|grep '[0-9a-f]:'|grep -v 'file'|cut -f2 -d:|cut -f1-6 -d' '|tr -s ' '|tr '\t' ' '|sed 's/ $//g'|sed 's/ /\\x/g'|paste -d '' -s |sed 's/^/"/'|sed 's/$/"/g'

echo '[+] Removing object file'
rm -f "${binary}.o"

echo '[+] Done!'
