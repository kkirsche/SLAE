#!/bin/bash

echo '[+] Assembling with Nasm ... '
nasm -f elf32 -o dual_stack_bind_shell.o dual_stack_bind_shell.nasm

echo '[+] Linking ...'
ld -o dual_stack_bind_shell dual_stack_bind_shell.o -fno-stack-protector -shared -z execstack

echo '[+] Dumping shellcode ...'
objdump -d ./dual_stack_bind_shell|grep '[0-9a-f]:'|grep -v 'file'|cut -f2 -d:|cut -f1-6 -d' '|tr -s ' '|tr '\t' ' '|sed 's/ $//g'|sed 's/ /\\x/g'|paste -d '' -s |sed 's/^/"/'|sed 's/$/"/g'

echo '[+] Done!'
