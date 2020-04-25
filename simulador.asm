; O código não pode manipular a pilha, senão interfere na pilha do programa que está sendo simulado
jmp main
store 0, r0
load r0, 0
storei r0, r0
loadi r0, r0
loadn r0, #0
mov sp, r0

; Usei nop porque por algum motivo do além var #0 não estava sendo criado
Stack: nop
FlagR: nop
PrgC: nop

Reg0: nop
Reg1: nop
Reg2: nop
Reg3: nop
Reg4: nop
Reg5: nop
Reg6: nop
Reg7: nop

main:
	; Inicializa PrgC com o íncio do código
	loadn r7, #main ; Salva o ínicio do código no r7
	store PrgC, r7
	load r6, PrgC

	; Inicializa Stack com o valor que está em sp
	mov r0, sp
	store Stack, r0

	breakp
loop:
	; Pega o valor que PrgC aponta
	load r1, PrgC
	loadi r0, r1

	; Incrementa PrgC
	inc r1
	store PrgC, r1

	; r0 tem a instrução

	; Pega opcode da operação 
	mov r1, r0
	shiftr0 r1, #10

	; r0 tem a instrução
	; r1 tem o opcode

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

	; Está diferente do PDF
	loadn r2, #51
	cmp r1, r2
	jeq _mov
fim:

	jmp loop

; Instruções de manipualação de dado
_store:
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

code: