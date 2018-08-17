#!/bin/bash

echo '[+] Assembling with Nasm ... '
nasm -f elf32 -o ipv6_bind_shell.o ipv6_bind_shell.nasm


echo '[+] Linking ...'
ld -o ipv6_bind_shell ipv6_bind_shell.o -fno-stack-protector -shared -z execstack

echo '[+] Cleaning up ...'
rm -f ipv6_bind_shell.o

echo '[+] Done!'



