.data
.include "map.s"
.include "char.s"
.include "char2.s"
.include "char3.s"
.include "char4.s"
AUX_AI0:	.word 0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
AUX_AI1:	.word 0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
AUX_AI2:	.word 0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
TYPE:		.word 0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
POSITIONX:  	.word 0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
POSITIONY:	.word 0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
ALIVE:		.word 0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
TYPELOAD:	.word 0x0, 0x1, 0x2, 0x1, 0x1, 0x1
POSITIONXLOAD:	.word 0xc, 0x12c, 0x12c, 0x12c, 0x12c, 0x12c
POSITIONYLOAD:	.word 0x4600, 0x2d00, 0x4600, 0x5f00, 0x7800, 0x9100
ALIVELOAD:	.word 0x1, 0x1, 0x1, 0x1, 0x1, 0x1
AUX_AI0LOAD:	.word 0x0,0xc,0xc,0xc,0xc,0xc,0xc,0xc,0xc,0xc,0xc,0xc
AUX_AI1LOAD:	.word 0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
AUX_AI2LOAD:	.word 0x0,0x0,0x1,0x1,0x0,0x0,0x0,0x0,0x0,0x0,0x0,0x0
LOADRANGE:      .word 0x0, 24 # always position to load (times 4) followed by how many objects to load (times 4)
LEVEL:		.word 0x0
.text
#		a0 = depth of map
#		a1 = time for going up in a jump (if it's negative it means he didnt touch the ground)
#		a2 = color of barrier in map
#		a3 = color for success
#		a4 = number of characters in the map times size of word = 4*size of TYPE array
#		a5 = width of screen (320)
#		a6 = height times width (320*240)
#		s0 = frame
#		s1 = direction of character (1 for right and 0 for left)
#       	s2 = type of item he has (0 means no item, 1 means attack item, 2 means hidden level item)
#      		s3 = map address
#		s4 = number of lives
#		s5 = color for item that allows access to hidden areas
#		
#		Foi tentado tornar o codigo do jogo o mais programavel possivel, no sentido que eh possivel controlar o comportamento do jogo
#		alterando apenas as variaveis da memoria,com algumas excecoes. Isso vai facilitar pois nao eh necessario na maior parte dos casos
#		mexer no codigo para adicionar ao mapa. Como se fosse uma engine
#		
#		A variavel TYPE eh o tipo do character. Ela eh usada para o algoritmo decidir qual imagem carregar na sua respectiva posicao, se eh um 
#		item e qual o tipo e qual mecanismo de IA ela vai usar.
#
#		As variaveis POSITIONX e POSITIONY se tratam da posicao do character, sendo que quando nao se trata do personagem, se trata da posicao do objeto do mapa e
#		no caso do protagonista eh a posicao dele no bitmap. Isso permite com que os objetos do mapa acompanhem a movimentacao do mapa
#
#		ALIVE representa se o objeto esta vivo (1) ou morto (0) e se estiver morto nao aparece mais na tela nem causa dano
# 
#		As variaveis ***LOAD tem informacao que devera ser carregada para as outras variaveis durante o inicio da fase
#
#		A variavel LOADRANGE contem onde comecar a crregar em cada fase nas posicoes pares (comecando em 0) e a quantidade de caracteres a crregar nas posicoes impares
#		(vezes 4 para facilitar o tratmento de words)
#
#		As variaveis AUX_AI* sao variaveis auxiliares para que possa ser calculado a posicao do objeto na iteracao seguinte. O que cada uma delas representa vai depender do tipo
#		por exemplo, o objeto de TYPE 0x1 eh uma IA que fica indo da esquerda para a direita e nesse caso AUX_AI0 eh largura que ele percorre (range), AUX_AI1 a posicao relativa
#		desse range e AUX_AI2 eh se ele esta indo para a esquerda ou direita no momento
#		
#		A variavel LEVEL contem o nivel em que o personagem esta
#
#		Por simplicidade, se o personagem for atacado, ele volta ao inicio da fase atual em que ele esta, "wasd" move o persongem e "k" atira (kill)
#		
#		** WARNING **
#
#		Pela forma com que foi escrita o codigo ao se mover para a direita o caracter aparece na esquerda ao cruzar a borda e isso gera problemas nas comparacoes, como
#		por exemplo teste de colisao. Tera que ser resolvido esse problema, ou adicionado no mapa barreiras para evitar que isso ocorra.
SETUP:		li	a5, 320
		li	a6, 0x12c00
LOAD:		la	t1, LEVEL
		lw	t1, (t1)
		beq	t1, zero, LEVEL0
LEVEL0:		li	a1, -1 # cant jump at beginning
		li	a2, 1
		li	a3, 2
		li	s5, 3
		li	s1, 1
		li	s2, 2
		li	s4, 4 # Sao 3 vidas, mas eu coloco 4 por causa da comparacao para decidir se eh game_over
		li	a0, 0x2800
		la	s3, MAP
		la	s6, LOADRANGE
		mv	a4, s6
		lw	s6, (s6)
		addi	a4, a4, 4
		lw	a4, (a4)
		mv	t1, zero
L5:		la	t2, POSITIONXLOAD
		add	t2, t2, s6
		add	t2, t2, t1
		lw	t2, (t2)
		la	t3, POSITIONX
		add	t3, t3, t1
		sw	t2, (t3)
		la	t2, POSITIONYLOAD
		add	t2, t2, s6
		add	t2, t2, t1
		lw	t2, (t2)
		la	t3, POSITIONY
		add	t3, t3, t1
		sw	t2, (t3)
		la	t2, TYPELOAD
		add	t2, t2, s6
		add	t2, t2, t1
		lw	t2, (t2)
		la	t3, TYPE
		add	t3, t3, t1
		sw	t2, (t3)
		la	t2, ALIVELOAD
		add	t2, t2, s6
		add	t2, t2, t1
		lw	t2, (t2)
		la	t3, ALIVE
		add	t3, t3, t1
		sw	t2, (t3)
		la	t2, AUX_AI0LOAD
		add	t2, t2, s6
		add	t2, t2, t1
		lw	t2, (t2)
		la	t3, AUX_AI0
		add	t3, t3, t1
		sw	t2, (t3)
		la	t2, AUX_AI1LOAD
		add	t2, t2, s6
		add	t2, t2, t1
		lw	t2, (t2)
		la	t3, AUX_AI1
		add	t3, t3, t1
		sw	t2, (t3)
		la	t2, AUX_AI2LOAD
		add	t2, t2, s6
		add	t2, t2, t1
		lw	t2, (t2)
		la	t3, AUX_AI2
		add	t3, t3, t1
		sw	t2, (t3)
		addi	t1, t1, 4
		blt	t1, a4, L5
		mv	t1, zero
		mv	t2, zero
		mv	t3, zero
PRINT:  	li  	s7, 0xFF0
    		add 	s7, s7, s0
    		slli    s7, s7, 20
L0:    		add 	t0, s7, t2  
        	add	t1, s3, a0	# depth of character in map
        	add 	t1,t1,t2
        	lw  	t1, (t1)
        	sw  	t1, (t0)
        	addi    t2, t2, 4
        	blt 	t2, a6, L0
PRINT_CHAR:	mv	t0, zero # counter of characters in t0
		li  	s6, 0xFF0
    		add 	s6, s6, s0
    		slli    s6, s6, 20 # bitmap address in s6
    		li	s7, 0xf #0b1111 in s7
    		li	s8, 308 # 320-16 in s8
    		li	s9, 256
L1:		la	t1, ALIVE
		add	t1, t1, t0
		lw	t1, (t1)
		beq	t1, zero, NEXT_IMG # check if it's alive to render
		la	t2, POSITIONX
		add	t2, t2, t0
		lw	t2, (t2)
		la	t1, POSITIONY
		add	t1, t1, t0
		lw	t1, (t1)
		add	t1, t1, t2 # position of character is in t1
		la	t2, TYPE
		add	t2, t2, t0
		lw	t2, (t2)
		li	t3, 0
		beq	t2, t3, IMG0
		li	t3, 1
		beq	t2, t3, IMG1
		li	t3, 2
		beq	t2, t3, IMG2
		li	t3, 3
		beq	t2, t3, IMG3
IMG0:		la	t2, CHAR #saves image address in t2
		j	B1
IMG1:		la	t2, CHAR2
		sub	t1, t1, a0
		j	B1
IMG2:		la	t2, CHAR3
		sub	t1, t1, a0
		j	B1
IMG3:		la	t2, ITEM1_IMG
		sub	t1, t1, a0
		j	B1
B1:		bgt	zero, t1, NEXT_IMG
		mv 	t6, zero # position of pixel in image in t6
		mv	t3, zero # counter for image in t3
L2:		mv	t4, s6
		add	t4, t4, t1
		add	t4, t4, t6
		mv	t5, t2
		add	t5, t5, t3
		lw	t5, (t5)
		sw	t5, (t4)
		addi	t3, t3, 4
		and	t4, t3, s7
		beq	t4, zero, LINE_JUMP
		addi	t6, t6, 4
		blt	t3, s9, L2
		j	NEXT_IMG
LINE_JUMP:	add	t6, t6, s8
		blt	t3, s9, L2
NEXT_IMG:	addi	t0, t0, 4
		blt	t0, a4, L1
KEY:		la	t0, MAP
		add	t0, t0, a0
		la	t3, POSITIONX
		lw	t1, (t3)
		la	t4, POSITIONY
		lw	t2, (t4)
		add	t0, t0, t1
		add	t0, t0, t2
		li 	t5,0xFF200000		
		lw 	t6,(t5)			
		andi 	t6,t6,0x0001		
   		beq 	t6,zero,JUMP   	   	
  		lw 	t6,4(t5)  			
		li 	t5,'w'
		beq 	t5,t6,CHAR_CIMA		
		li 	t5,'a'
		beq 	t5,t6,CHAR_ESQ		
		li 	t5,'s'
		beq 	t5,t6,CHAR_BAIXO		
		li 	t5,'d'
		beq 	t5,t6,CHAR_DIR
		li	t5, 'k'
		beq	t5, t6, ATTACK
ATTACK: 	li	t0, 4 # counter of characters
		li	s6, 24
		beq	zero, s2, NOITEM1 # branch if doesnt have item
		addi	s6, s6, 16	# Having Item 1 increases the range of shot
NOITEM1:	la	s7, POSITIONX
		la	s8, POSITIONY
		la	s9, ALIVE
		lw	t4, (s7)
		lw	t5, (s8)
		add	t5, t5, a0 # Y-a0-t5=Y-(a0+t5)
		li	t6, 0x1400 # 320*16
L4:		add	t1, s7, t0
		add	t2, s8, t0
		lw	t1, (t1)
		lw	t2, (t2)
		sub	t1, t1, t4
		sub	t2, t2, t5 # position of enemy minus character
		blt	zero, t2, CONTINUE
		sub	t2, zero, t2
CONTINUE:	bge	t2, t6, B3
		bne	s1, zero, ATTRGT
		sub	t1, zero, t1
ATTRGT:		blt	t1, zero, B3
		blt	t3, t1, B3
		add	t1, t0, s9
		sw	zero, (t1) # set character as dead
B3:		addi	t0, t0, 4
		blt	t0, a4, L4
		j	JUMP
CHAR_CIMA:	bne	a1, zero, JUMP
		li	a1, 10
		j	JUMP
CHAR_BAIXO:	slli	t5, a5, 4
		add	t0, t0, t5
		lb	t0, (t0)
		beq	t0, a2, JUMP
		beq	t0, a3, NEXT_LEVEL
		srli	t5, s2, 1
		mul	t5, t5, s5
		beq	t0, t5, HIDDEN_LEVEL
		slli	t5, a5, 2
		add	a0, a0, t5
		j	JUMP
CHAR_DIR:	li	s1, 1
		addi	t0, t0, 16
		lb	t0, (t0)
		beq	t0, a2, JUMP
		beq	t0, a3, NEXT_LEVEL
		srli	t5, s2, 1
		mul	t5, t5, s5
		beq	t0, t5, HIDDEN_LEVEL
		addi	t1, t1, 4
		blt	t1, a5, LT0_R
		sub	t1, t1, a5
LT0_R:		bge	t1, zero, SAVE_R
		add	t1, t1, a5
SAVE_R:		sw	t1, (t3)
		j	JUMP
CHAR_ESQ:	li	s1, 0
		addi	t0, t0, -1
		lb	t0, (t0)
		beq	t0, a2, JUMP
		beq	t0, a3, NEXT_LEVEL
		srli	t5, s2, 1
		mul	t5, t5, s5
		beq	t0, t5, HIDDEN_LEVEL
		addi	t1, t1, -4
		blt	t1, a5, LT0_L
		sub	t1, t1, a5
LT0_L:		bge	t1, zero, SAVE_L
		add	t1, t1, a5
SAVE_L:		sw	t1, (t3)
		j	JUMP
JUMP:		la	t0, MAP
		add	t0, t0, a0
		la	t3, POSITIONX
		lw	t1, (t3)
		la	t4, POSITIONY
		lw	t2, (t4)
		add	t0, t0, t1
		add	t0, t0, t2
		ble	a1, zero, GRAVITY
		mv	t5, a5
		sub	t0, t0, t5
		lb	t0, (t0)
		beq	t0, a2, COLLISION
		beq	t0, a3, NEXT_LEVEL
		srli	t5, s2, 1
		mul	t5, t5, s5
		beq	t0, t5, HIDDEN_LEVEL
		slli	t5, a5, 2
		sub	a0, a0, t5
		addi	a1, a1, -1
		j	COLLISION
GRAVITY:	slli	t5, a5, 4
		add	t0, t0, t5
		lb	t0, (t0)
		beq	t0, a2, GROUND
		beq	t0, a3, NEXT_LEVEL
		srli	t5, s2, 1
		mul	t5, t5, s5
		beq	t0, t5, HIDDEN_LEVEL
		slli	t5, a5, 2
		add	a0, a0, t5
		j	COLLISION
GROUND:		mv	a1, zero # allows character to jump once he touched the ground at least once
COLLISION:	li	t0, 4 # counter of characters
		li	s6, 16 # 16 in s6
		li	s7, 0x1400 # 320 * 16 in s7
		la	t1, POSITIONX
		la	t2, POSITIONY
		la	t5, ALIVE
		lw	s8, (t1)
		lw	s9, (t2)
		add	s9, s9, a0 # Y-a0-s9=Y-(a0+s9)
		la	s10, TYPE
L3:		add	t6, t5, t0
		lw	t6, (t6)
		beq	t6, zero, B2 # is enemy dead?
		add	t3, t1, t0
		lw	t3, (t3)
		add	t4, t2, t0
		lw	t4, (t4)
		sub	t3, t3, s8
		sub	t4, t4, s9
		blt	zero, t3, CTNX
		sub	t3, zero, t3
CTNX:		blt	zero, t4, CTNY
		sub	t4, zero, t4
CTNY:		bge	t3, s6, B2
		bge	t4, s7, B2
		add	t3, s10, t0
		lw	t3, (t3)
		li	t4, 3
		beq	t3, t4, ITEM1
		addi	s4, s4, -1
		bgt	s4, zero, LOAD 	
		j	GAME_OVER
ITEM1:		li	s2, 1		# has taken first item
		add	t6, t5, t0
		sw	zero, (t6)	# deletes first item
B2:		addi	t0, t0, 4
		blt	t0, a4, L3
AI:		li	t0, 4 #counter
		la	s6, TYPE
		la	s7, AUX_AI0 
		la	s8, AUX_AI1 
		la	s9, AUX_AI2 
		la	s10, POSITIONX
		la	s11, POSITIONY
L6:		add	t1, t0, s6		
		lw	t1, (t1)
		li	t2, 1
		beq	t1, t2, UPDATE_AI1
		j	NEXT_AI
UPDATE_AI1:	add	t1, t0, s9 # going to right or left
		lw	t2, (t1)
		add	t3, t0, s8 # relative position
		lw	t4, (t3)
		add	t5, t0, s7 # range
		lw	t5, (t5)
		add	t6, t0, s10
		lw	s11, (t6)
		bge	t4, zero, B4
		sub	t5, zero, t5
B4:		bne	t4, t5, B5
		xori	t2, t2, 1
		sw	t2, (t1)
B5:		beq	t2, zero, LEFT_AI1
		addi	t4, t4, 4
		addi	s11, s11, 4
		j	UPD_POS
LEFT_AI1:	addi	t4, t4, -4
		addi	s11, s11, -4
UPD_POS:	sw	t4, (t3)
		sw	s11, (t6)
NEXT_AI:	addi	t0, t0, 4
		blt	t0, a4, L6
FRAME:		li 	t0,0xFF200604		# carrega em t0 o endereco de troca de frame
		sw 	s0,0(t0)
		xori	s0, s0, 1
		mv	t0, zero
		mv	t1, zero
		mv	t2, zero
		mv	t3, zero
		mv	t4, zero
		mv	t5, zero
		mv	t6, zero
  		j	PRINT
HIDDEN_LEVEL:	mv	zero, zero
NEXT_LEVEL:	mv	zero, zero
GAME_OVER:	mv	zero, zero
