#!/bin/bash

echo '[+] Assembling with Nasm ... '
nasm -f elf32 -o ipv4_bind_shell.o ipv4_bind_shell.nasm
nasm -f elf32 -o ipv6_bind_shell.o ipv6_bind_shell.nasm


echo '[+] Linking ...'
ld -o ipv4_bind_shell ipv4_bind_shell.o -fno-stack-protector -shared -z execstack
ld -o ipv6_bind_shell ipv6_bind_shell.o -fno-stack-protector -shared -z execstack

echo '[+] Done!'



