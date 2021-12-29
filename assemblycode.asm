%include "asm_io.inc"
segment .bss
segment .data
	a  dd 0
	n  dd 10
	tmp  dd 0
segment .text
	global asm_main
asm_main:
	enter 0,0
	pusha
	call func_f
	mov [tmp], eax
	mov eax, [a]
	call print_int
	call print_nl
	popa
	mov eax,0
	leave
	ret
func_f:
	enter 0,0
if_29:
	cmp dword [n],0
	jnz endif_29
	mov eax,0
	leave
	ret
endif_29:
	mov eax,[a]
	add eax,[n]
	mov [a], eax
	mov eax,[n]
	sub eax,1
	mov [n], eax
	call func_f
	mov [tmp], eax
	mov eax,0
	leave
	ret
	leave
	ret
