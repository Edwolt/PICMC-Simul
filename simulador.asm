;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; O código não pode manipular a pilha, senão interfere na pilha do programa que está sendo simulado ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; O programa simulado tem uma memória de tamanho menor, pois o código do simulador ocupa uma parte da memória do simulador

; Inicializa Stack com o valor que está em sp
mov r0, sp ; Pega o valor da stack, pois nela iniciará a stack do programa a ser simulado
loadn r1, #code
sub r0, r0, r1 ; Transforma o valor real do Stack Pointer para o valor virtual
store Stack, r0
jmp loop

Stack: var #1 ; Guarda o Stack Pointer do programa simulado
			  ; 
			  ; A Stack terá que começar com um valor menor do que costuma
			  ; pois na memória não tem espaço para todo o programa
			  ; por causa que parte está sendo gasta com o código do simulador
FlagR: var #1 ; Guarda o Flag Register do programa simulado
PrgC: var #1  ; Guarda o Program Counter do programa simulado
Regs: var #8
	static Regs + #0, #0
	static Regs + #1, #0
	static Regs + #2, #0
	static Regs + #3, #0
	static Regs + #4, #0
	static Regs + #5, #0
	static Regs + #6, #0
	static Regs + #7, #0


loop:
	; Pega o valor que Program Counter aponta
	load r1, PrgC ; Valor real do Program Counter
	loadn r2, #code
	add r1, r1, r2 ; Transforma o valor virtual do Program counter para o valor real
	loadi r0, r1 ; Carrega valor apontado pelo Program Counter (valor real)

	; Incrementa valor virtual do Program Counter e o salva na memória
	inc r2
	store PrgC, r2

	; r0 tem a instrução

	; Pega opcode da operação 
	mov r1, r0
	shiftr0 r1, #10

	; r0 tem a instrução
	; r1 tem o opcode

	breakp
	; Switch das Instruções (depois do jeq o r1 pode ser sobrescrito)
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
	; Pegando valor de RX
	mov r1, r0
	rotl r1, #6
	shiftr0 r1, #13
	loadn r2, #Regs
	add r1, r1, r2 ; r1 contém onde está salvo RX

	loadi r1, r1

	; r1 contém o conteúdo de RX

	; Pega o valor que Program Counter aponta
	load r3, PrgC ; Valor real do Program Counter
	loadn r4, #code
	add r3, r3, r4 ; Transforma o valor virtual do Program counter para o valor real
	loadi r2, r3 ; Carrega valor apontado pelo Program Counter (valor real)

	; Incrementa valor virtual do Program Counter e o salva na memória
	inc r4
	store PrgC, r4

	; r2 contém o endereço real

	loadn r3, #code
	add r2, r2, r3

	; r2 contém o endereço real

	storei r2, r1

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
