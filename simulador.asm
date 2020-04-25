;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; Cuidado ao manipular a pilha, senão interfere na do programa que está sendo simulado ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; O programa simulado tem uma memória de tamanho menor, pois o código do simulador ocupa uma parte da memória do simulador

; Inicializa Stack com o valor que está em sp
mov r0, sp ; Pega o valor da stack, pois nela iniciará a stack do programa a ser simulado
loadn r7, #code ; em r7 fica salvo o valor #code
loadn r2, #9
mov r1, r7
add r1, r1, r2 ; O programa do simulador pode guardar uma chamada de função
sub r0, r0, r1 ; Transforma o valor real do Stack Pointer para o valor virtual
store Stack, r0

; r7 tem #code

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
	call busca_memoria

	; r0 tem a instrução

	; Pega opcode da operação 
	call get_opcode

	; r0 tem a instrução
	; r1 tem o opcode

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
loop_fim:

	jmp loop


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Funções (não podem chamar outras funções para não bagunçar a pilha) ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

get_opcode:
	mov r1, r0
	shiftr0 r1, #10
	rts

get_RX:
	mov r1, r0
	rotl r1, #6
	shiftr0 r1, #13
	loadn r2, #Regs
	add r1, r1, r2 ; r1 contém onde está salvo RX

	loadi r2, r1 ; r2 contém o conteudo de RX
	rts

get_RY:
	mov r3, r0
	rotl r3, #9
	shiftr0 r3, #13
	loadn r4, #Regs
	add r3, r3, r4 ; r3 contém onde está salvo RX

	loadi r4, r3 ; r4 contém o conteudo de RX
	rts


; Funções (não podem chamar outras funções para não acessar a pilha do código simulado)
busca_memoria:
	push r1
	push r2

	; Pega o valor que Program Counter aponta
	load r1, PrgC ; Valor real do Program Counter
	add r1, r1, r7 ; Transforma o valor virtual do Program counter para o valor real
	loadi r0, r1 ; Carrega valor apontado pelo Program Counter (valor real)

	; Incrementa valor virtual do Program Counter e o salva na memória
	inc r2
	store PrgC, r2

	pop r2
	pop r1
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; Instruções (r0 contém o código da instrução) ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Instruções de manipualação de dado

_store:
	call get_RX

	; r1 contém onde está salvo RX
	; r2 contém o conteúdo de RX

	call busca_memoria

	; r0 contém o endereço virtual

	add r0, r0, r7

	; r0 contém o endereço real

	storei r0, r2

	jmp loop_fim


_load:
	call get_RX

	; r1 contém onde está salvo RX
	; r2 contém o conteúdo de RX

	call busca_memoria

	; r0 contém o endereço virtual

	add r0, r0, r7

	; r0 contém o endereço real

	loadi r2, r0 ; Atualiza valor de RX
	storei r1, r2 ; Salva o valor atualizado de RX na memória

	jmp loop_fim


_storei:
	call get_RX

	; r1 contém onde está salvo RX
	; r2 contém o conteúdo de RX

	call get_RY

	; r3 contém onde está salvo RY
	; r4 contém o conteúdo de RY


	add r2, r2, r7 ; tranforma o endereço virtual em r2 em um endereço real
	storei r2, r4

	jmp loop_fim


_loadi:
	call get_RX

	; r1 contém onde está salvo RX
	; r2 contém o conteúdo de RX

	call get_RY

	; r3 contém onde está salvo RY
	; r4 contém o conteúdo de RY

	add r4, r4, r7 ; tranforma o endereço virtual em r4 em um endereço real
	loadi r1, r4

	jmp loop_fim


_loadn:
	jmp loop_fim


_mov:
	jmp loop_fim


code: ; Código a ser simulado
