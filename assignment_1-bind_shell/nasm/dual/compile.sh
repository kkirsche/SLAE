#!/bin/bash

echo '[+] Assembling with Nasm ... '
nasm -f elf32 -o dual_stack_bind_shell.o dual_stack_bind_shell.nasm

echo '[+] Linking ...'
ld -o dual_stack_bind_shell dual_stack_bind_shell.o -fno-stack-protector -shared -z execstack

echo '[+] Done!'
