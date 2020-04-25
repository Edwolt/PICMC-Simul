; O código não pode manipular a pilha, senão interfere na pilha do programa que está sendo simulado
jmp main

Stack: var #1

FlagR: var #1

PrgC: static PrgC + #0, #code

Regs: var #8
	static Regs + #0, #0
	static Regs + #1, #0
	static Regs + #2, #0
	static Regs + #3, #0
	static Regs + #4, #0
	static Regs + #5, #0
	static Regs + #6, #0
	static Regs + #7, #0

main:
	; Inicializa Stack com o valor que está em sp
	mov r0, sp
	store Stack, r0

	breakp
loop:
	; Pega o valor que PrgC aponta
	load r1, PrgC
	loadi r0, r1

	load r6, PrgC


	; Incrementa PrgC
	inc r1
	store PrgC, r1

	; r0 tem a instrução

	; Pega opcode da operação 
	mov r1, r0
	shiftr0 r1, #10

	; r0 tem a instrução
	; r1 tem o opcode

	breakp
	; Switch das Instruções
	loadn r2, #49
	cmp r1, r2
	jeq _store

	loadn r2, #48
	cmp r1, r2
	jeq _load

	loadn r2, #61
	cmp r1, r2
	jeq _storei

	loadn r2, #60
	cmp r1, r2
	jeq _loadi

	loadn r2, #56
	cmp r1, r2
	jeq _loadn

	loadn r2, #51
	cmp r1, r2
	jeq _mov
fim:

	jmp loop

; Instruções de manipualação de dado
_store:
	mov r1, r0
	rotl r1, #6
	shiftr0 r1, #13

	jmp fim

_load:
	jmp fim

_storei:
	jmp fim

_loadi:
	jmp fim

_loadn:
	jmp fim

_mov:
	jmp fim
