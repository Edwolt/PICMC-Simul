;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; Cuidado ao manipular a pilha, senão interfere na do programa que está sendo simulado ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
shiftr0 r0, #0
; O programa simulado tem uma memória de tamanho menor, pois o código do simulador ocupa uma parte da memória do simulador

; Inicializa Stack com o valor que está em sp
mov r0, sp ; Pega o valor de sp, pois nela iniciará a stack do programa a ser simulado
loadn r7, #code ; em r7 fica salvo o valor #code
loadn r2, #9
mov r1, r7
add r1, r1, r2 ; O programa do simulador pode guardar uma chamada de função
sub r0, r0, r1 ; Transforma o valor real do Stack Pointer para o valor virtual
store Stack, r0

; r7: #code (Constante durante todo código)

jmp loop

; Variaveis para o programa simulado
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

; Variaveis para o programa simulador
StrHalt: string "#HALT#"
Inteiros: string "0123456789"

loop:
	call busca_memoria

	; r0: A instrução

	; Pega opcode da operação 
	call get_opcode

	; r0: A instrução
	; r1: O opcode

	; Switch das Instruções (depois do jeq o r1 pode ser sobrescrito)
	; Instruções de manipualação de dado
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

	; Instruções Aritméticas
	loadn r2, #32
	cmp r1, r2
	jeq _add

	loadn r2, #33
	cmp r1, r2
	jeq _sub

	loadn r2, #34
	cmp r1, r2
	jeq _mult

	loadn r2, #35
	cmp r1, r2
	jeq _div

	loadn r2, #36
	cmp r1, r2
	jeq _incdec

	loadn r2, #37
	cmp r1, r2
	jeq _mod

	loadn r2, #18
	cmp r1, r2
	jeq _and

	loadn r2, #19
	cmp r1, r2
	jeq _or

	loadn r2, #20
	cmp r1, r2
	jeq _xor

	loadn r2, #21
	cmp r1, r2
	jeq _not

	loadn r2, #16
	cmp r1, r2
	jeq _shift

	loadn r2, #22
	cmp r1, r2
	jeq _cmp

	; Instruções de entrada e saída
	loadn r2, #53
	cmp r1, r2
	jeq _inchar

	loadn r2, #50
	cmp r1, r2
	jeq _outchar


	; Instruções de Controle
	loadn r2, #15
	cmp r1, r2
	jeq _halt
switch_fim:

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

get_RZ:
	mov r5, r0
	rotl r5, #12
	shiftr0 r5, #13
	loadn r6, #Regs
	add  r5, r5, r6

	loadi r6, r5
	rts

; Funções (não podem chamar outras funções para não acessar a pilha do código simulado)
busca_memoria:
	push r1
	push r2

	; Pega o valor que PC aponta
	load r1, PrgC ; Valor virtual do PC
	add r2, r1, r7 ; Transforma o valor virtual do PC para o valor real
	cmp r2, r7 ; Testa se posicao da meória é valida
	jle erro_mem

	loadi r0, r2 ; Carrega valor apontado pelo PC (valor real)

	; Incrementa valor virtual do PC e o salva na memória
	inc r1
	store PrgC, r1

	pop r2
	pop r1
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; Instruções (r0 contém o código da instrução) ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Instruções de manipualação de dado

_store:
	call get_RX

	; r0: A instrução
	; r1: Onde está salvo RX
	; r2: O conteúdo de RX

	call busca_memoria ; r0: O endereço virtual
	add r0, r0, r7 ; Tranformando r0 em endereço real

	; r0: O endereço real
	; r1: Onde está salvo RX
	; r2: O conteúdo de RX

	cmp r0, r7 ; Testa se posicao da meória é valida
	jle erro_mem
	storei r0, r2 ; guarda no endereço (em r0) o conteúdo de RX (em r2)

	jmp switch_fim


_load:
	call get_RX

	; r0: A instrução
	; r1: Onde está salvo RX
	; r2: O conteúdo de RX

	call busca_memoria ; r0 contém endereço virtual
	add r0, r0, r7 ; Tranformando r0 em endereço real

	; r0: O endereço real
	; r1: Onde está salvo RX
	; r2: O conteúdo de RX
	
	cmp r0, r7 ; Testa se posiço da meória é valida
	jle erro_mem
	loadi r2, r0 ; Atualiza valor de RX
	storei r1, r2 ; Salva o valor atualizado de RX na memória

	jmp switch_fim


_storei:
	call get_RX
	call get_RY

	; r0: A instrução
	; r1: Onde está salvo RX
	; r2: O conteúdo de RX
	; r3: Onde está salvo RY
	; r4: O conteúdo de RY

	add r2, r2, r7 ; tranforma o endereço virtual em r2 em um endereço real
	cmp r2, r7 ; Testa se posiço da meória é valida
	jle erro_mem
	storei r2, r4

	jmp switch_fim


_loadi:
	call get_RX
	call get_RY

	; r0: A instrução
	; r1: Onde está salvo RX
	; r2: O conteúdo de RX
	; r3: Onde está salvo RY
	; r4: O conteúdo de RY

	add r4, r4, r7 ; tranforma o endereço virtual em r4 em um endereço real
	cmp r4, r7 ; Testa se posiço da meória é valida
	jle erro_mem
	loadi r1, r4

	jmp switch_fim


_loadn:
	call get_RX

	; r0: A instrução
	; r1: Onde está salvo RX
	; r2: O conteúdo de RX

	call busca_memoria

	; r0: O número
	; r1: Onde está salvo RX
	; r2: O conteúdo de RX
	storei r1, r0

	jmp switch_fim


_mov:
	call get_RX

	; r0: A instrução
	; r1: Onde está salvo RX
	; r2: O conteúdo de RX

	mov r3, r0
	rotl r3, #14
	shiftr0 r3, #14 ; r3 contém o tipo de mov

	; Switch do tipo de mov (está em r3)
	loadn r4, #1
	cmp r3, r4
	jeq _mov_fromSP

	loadn r4, #3
	cmp r3, r4
	jeq _mov_toSP

	jmp _mov_regreg ; default

_mov_switch_fim:

	jmp switch_fim

_mov_regreg:
	call get_RY
	
	; r0: A instrução
	; r1: Onde está salvo RX
	; r2: O conteúdo de RX
	; r3: Onde está salvo RY
	; r4: O conteúdo de RY

	storei r1, r4 ; Salva o conteúdo de RY em RX

	jmp _mov_switch_fim

_mov_fromSP:
	; r0: A instrução
	; r1: Onde está salvo RX
	; r2: O conteúdo de RX

	loadn r3, #Stack
	loadi r4, r3

	; r0: A instrução
	; r1: Onde está salvo RX
	; r2: O conteúdo de RX
	; r3: Onde está salvo SP
	; r4: O conteúdo de SP

	storei r1, r4 ; Salva o conteúdo de SP em RX
	

	jmp _mov_switch_fim

_mov_toSP:
	; r0: A instrução
	; r1: Onde está salvo RX
	; r2: O conteúdo de RX

	loadn r3, #Stack
	loadi r4, r3

	; r0: A instrução
	; r1: Onde está salvo RX
	; r2: O conteúdo de RX
	; r3: Onde está salvo SP
	; r4: O conteúdo de SP

	storei r3, r2 ; Salva o conteúdo de RX em SP

	jmp _mov_switch_fim


; Instruçoẽs Aritméticas

; TODO adcionar uso do FlagR
_add:
	call get_RX
	call get_RY
	call get_RZ

	; r0: A instrução
	; r1: Onde está salvo RX
	; r2: O conteúdo de RX
	; r3: Onde está salvo RY
	; r4: O conteúdo de RY
	; r5: Onde está salvo RZ
	; r6: O conteúdo de RZ

	add r2, r4, r6

	; r0: A instrução
	; r1: Onde está salvo RX
	; r2: Novo conteúdo de RX

	storei r1, r2

	jmp switch_fim

_sub:
	call get_RX
	call get_RY
	call get_RZ

	; r0: A instrução
	; r1: Onde está salvo RX
	; r2: O conteúdo de RX
	; r3: Onde está salvo RY
	; r4: O conteúdo de RY
	; r5: Onde está salvo RZ
	; r6: O conteúdo de RZ

	sub r2, r4, r6

	; r0: A instrução
	; r1: Onde está salvo RX
	; r2: Novo conteúdo de RX

	storei r1, r2

	jmp switch_fim

_mult:
	call get_RX
	call get_RY
	call get_RZ

	; r0: A instrução
	; r1: Onde está salvo RX
	; r2: O conteúdo de RX
	; r3: Onde está salvo RY
	; r4: O conteúdo de RY
	; r5: Onde está salvo RZ
	; r6: O conteúdo de RZ

	mul r2, r4, r6

	; r0: A instrução
	; r1: Onde está salvo RX
	; r2: Novo conteúdo de RX

	storei r1, r2

	jmp switch_fim

_div:
	call get_RX
	call get_RY
	call get_RZ

	; r0: A instrução
	; r1: Onde está salvo RX
	; r2: O conteúdo de RX
	; r3: Onde está salvo RY
	; r4: O conteúdo de RY
	; r5: Onde está salvo RZ
	; r6: O conteúdo de RZ

	div r2, r4, r6

	; r0: A instrução
	; r1: Onde está salvo RX
	; r2: Novo conteúdo de RX

	storei r1, r2

	jmp switch_fim

_incdec:
	call get_RX

	; r0: A instrução
	; r1: Onde está salvo RX
	; r2: O conteúdo de RX

	mov r3, r0
	rotl r3, #6
	shiftr0 r3, #15

	loadn r4, #0

	cmp r3, r4
	jeq _inc
	dec r2
	jmp _incdec_end
_inc:
	inc r2
_incdec_end:
	storei r1, r2
	jmp switch_fim

_mod:
	call get_RX
	call get_RY
	call get_RZ

	; r0: A instrução
	; r1: Onde está salvo RX
	; r2: O conteúdo de RX
	; r3: Onde está salvo RY
	; r4: O conteúdo de RY
	; r5: Onde está salvo RZ
	; r6: O conteúdo de RZ

	mod r2, r4, r6

	; r0: A instrução
	; r1: Onde está salvo RX
	; r2: Novo conteúdo de RX

	storei r1, r2

	jmp switch_fim

_and:
	call get_RX
	call get_RY
	call get_RZ

	; r0: A instrução
	; r1: Onde está salvo RX
	; r2: O conteúdo de RX
	; r3: Onde está salvo RY
	; r4: O conteúdo de RY
	; r5: Onde está salvo RZ
	; r6: O conteúdo de RZ

	and r2, r4, r6

	; r0: A instrução
	; r1: Onde está salvo RX
	; r2: Novo conteúdo de RX

	storei r1, r2

	jmp switch_fim

_or:
	call get_RX
	call get_RY
	call get_RZ

	; r0: A instrução
	; r1: Onde está salvo RX
	; r2: O conteúdo de RX
	; r3: Onde está salvo RY
	; r4: O conteúdo de RY
	; r5: Onde está salvo RZ
	; r6: O conteúdo de RZ

	or r2, r4, r6

	; r0: A instrução
	; r1: Onde está salvo RX
	; r2: Novo conteúdo de RX

	storei r1, r2

	jmp switch_fim

_xor:
	call get_RX
	call get_RY
	call get_RZ

	; r0: A instrução
	; r1: Onde está salvo RX
	; r2: O conteúdo de RX
	; r3: Onde está salvo RY
	; r4: O conteúdo de RY
	; r5: Onde está salvo RZ
	; r6: O conteúdo de RZ

	xor r2, r4, r6

	; r0: A instrução
	; r1: Onde está salvo RX
	; r2: Novo conteúdo de RX

	storei r1, r2

	jmp switch_fim

_not:
	call get_RX
	call get_RY

	; r0: A instrução
	; r1: Onde está salvo RX
	; r2: O conteúdo de RX
	; r3: Onde está salvo RY
	; r4: O conteúdo de RY

	not r2, r4

	; r0: A instrução
	; r1: Onde está salvo RX
	; r2: Novo conteúdo de RX

	storei r1, r2

	jmp switch_fim

_shift:
	call get_RX

	; r0: A instrução
	; r1: Onde está salvo RX
	; r2: O Conteúdo de RX


	mov r3, r0
	rotl r3, #12
	shiftr0 r3, #12 ; Tem o número do shift

	loadn r4, #0
	loadn r5, #2
	
	cmp r3, r4
	jeq switch_fim

	; r0: A instrução
	; r1: Onde está salvo RX
	; r2: O Conteúdo de RX
	; r3: Número do shift
	; r4: #0
	; r5: #2

	mov r6, r0
	rotl r6, #9
	shiftr0 r6, #13 ; r4 tem o tipo de shift

	; Switch Tipo de shift (em r6)
	loadn r7, #0
	cmp r6, r7
	jeq _shiftl0

	loadn r7, #1
	cmp r6, r7
	jeq _shiftl1

	loadn r7, #2
	cmp r6, r7
	jeq _shiftr0

	loadn r7, #3
	cmp r6, r7
	jeq _shiftr1

	shiftr0 r6, #1

	loadn r7, #2
	cmp r6, r7
	jeq _rotl

	loadn r7, #3
	cmp r6, r7
	jeq _rotr

_shift_switch_fim:
	storei r1, r2
	loadn r7, #code
	jmp switch_fim

_shiftl0:
	dec r3

	mul r2, r2, r5

	cmp r3, r4
	jeq _shift_switch_fim
	jmp _shiftl0

_shiftl1:
	loadn r6, #1
_shiftl1_loop:
	dec r3

	mul r2, r2, r5
	or r2, r2, r6

	cmp r3, r4
	jeq _shift_switch_fim
	jmp _shiftl1_loop

_shiftr0:
	dec r3
	
	div r2, r2, r5

	cmp r3, r4
	jeq _shift_switch_fim
	jmp _shiftr0
	
_shiftr1:
	loadn r6, #32768 ; 100000000000000
_shiftr1_loop:
	dec r3
	
	div r2, r2, r5
	or r2, r2, r6

	cmp r3, r4
	jeq _shift_switch_fim
	jmp _shiftr1_loop

_rotl:
	dec r3
	
	rotl r2, #1

	cmp r3, r4
	jeq _shift_switch_fim
	jmp _rotl

_rotr:
	dec r3
	
	rotr r2, #1

	cmp r3, r4
	jeq _shift_switch_fim
	jmp _rotr

_cmp:
	jmp switch_fim

; Instruções de Entrada e saída

_inchar:
	call get_RX

	; r0: A instrução
	; r1: Onde está salvo RX
	; r2: O Conteúdo de RX

	inchar r3

	storei r1, r3

	jmp switch_fim

_outchar:
	call get_RX
	call get_RY

	; r0: A instrução
	; r1: Onde está salvo RX
	; r2: O Conteúdo de RX
	; r3: Onde está salvo RY
	; r4: O Conteúdo de RY

	outchar r2, r4

	jmp switch_fim

; Instruções de Controle

erro_mem:
_halt:
	breakp
	loadn r0, #0 ; Posição na tela
	loadn r2, #'\0' ; Criterio de Parada
	loadn r1, #StrHalt
	loadn r6, #2304 ; Vermelho
imprime_str_loop:
	loadi r7, r1 ; Carrega catacter
	
	; Compara criterio de parada
	cmp r7, r2
	jeq imprime_str_fim

	or r7, r7, r6 ; Colore caracter

	outchar r7, r0
	inc r0
	inc r1

	jmp imprime_str_loop

imprime_str_fim:
	

	loadn r0, #0 ; Número do Registrador
	loadn r1, #3 ; Linha da tela
regs_loop:
	loadn r7, #8
	cmp r0, r7
	jeq regs_fim

	
	loadn r7, #40 ; Tamanho da linha
	mul r2, r1, r7 ; Posição na tela
	
	; r0: Número do registrador
	; r1: Linha da tela
	; r2: Posição da tela

	; Imprime O nome do registrador
	loadn r4, #'R'
	outchar r4, r2
	inc r2

	loadn r5, #Inteiros
	add r5, r0, r5
	loadi r5, r5
	outchar r5, r2
	inc r2

	loadn r4, #':'
	outchar r4, r2
	inc r2

	loadn r4, #' '
	outchar r4, r2
	inc r2

	; r0: Número do registrador
	; r1: Linha da tela
	; r2: Posição da tela

	;imprime_int_loop(){
	;	Inteiros = "0123456789" // r3
	;	casa_decimal = 10000 // r4
	;	num := número a ser impresso // r5
    ;
	;	while(r4 != 0){
	;		digito = num / casa_decimal // r6
	;		print(Inteiros[digito])
	;		num %= casa_decimal
	;		casa_decimal /= 10
	;	}
	;}

	loadn r3, #Inteiros
	loadn r4, #10000
	loadn r7, #Regs
	add r7, r7, r0
	loadi r5, r7
imprime_int_loop:

	; r0: Número do registrador
	; r1: Linha da tela
	; r2: Posição da tela
	; r3: A base do vetor de Inteiros
	; r4: A casa decimal a ser pega
	; r5: A valor do registrador

	loadn r7, #0
	cmp r4, r7
	jeq imprime_int_fim

	div r6, r5, r4 ; Número a ser impresso
	add r7, r3, r6 ; Posição onde está o número
	loadi r7, r7
	outchar r7, r2
	inc r2

	mod r5, r5, r4
	loadn r7, #10
	div r4, r4, r7

	jmp imprime_int_loop

imprime_int_fim:

	inc r0
	inc r1

	jmp regs_loop


regs_fim:

	halt
	jmp switch_fim

code: ; Código a ser simulado
