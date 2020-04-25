; O codigo não pode manipular a pilha senao interfere na pílha do programa que esta sendo simulado
jmp main

; Usei nop porque por algum motivo do alem var #0 nao estava sendo criado
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
	; Inicializa PrgC com o incio do codigo
	loadn r7, #main ; Salva o inicio do codigo no r7
	store PrgC, r7
	load r6, PrgC

	; Inicializa Stack com o valor que esta em sp
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

	jmp loop