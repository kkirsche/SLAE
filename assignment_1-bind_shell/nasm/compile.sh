#!/bin/bash

echo '[+] Assembling with Nasm ... '
nasm -f elf32 -o bind_shell.o bind_shell.nasm

echo '[+] Linking ...'
ld -o bind_shell bind_shell.o -fno-stack-protector -shared -z execstack

echo '[+] Done!'



