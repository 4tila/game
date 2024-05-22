.data
.include "map.s"
.include "char2.s"
.include "char.s"
.include "char3.s"
TYPE:		.word 0x0, 0x1, 0x1, 0x1, 0x1, 0x2
POSITIONX:	.word 0xc, 0x12c, 0x12c, 0x12c, 0x12c, 0x12c
POSITIONY:	.word 0x4600, 0x2d00, 0x4600, 0x5f00, 0x7800, 0x9100
.text
#		a0 = depth of map
#		a1 = time for going up in a jump (if it's negative it means he didnt touched the ground)
#		a2 = color of barrier in map
#		a3 = color for success
#		a4 = number of characters in the map times size of word = 4*size of TYPE array
#		a5 = width of screen (320)
#		a6 = height times width (320*240)
#		s0 = frame
SETUP:		li	a0, 320
		slli	a0, a0, 5 # 320*32
		li	a1, -1 # cant jump at beginning
		li	a2, 1
		li	a3, 2
		li	a4, 24
		li	a5, 320
		li	a6, 0x12c00
PRINT:  	li  	s2, 0xFF0
    		add 	s2, s2, s0
    		slli    s2, s2, 20
L0:    		add 	t0, s2, t2  
        	la  	t1, MAP
        	add	t1, t1, a0	# depth of character in map
        	add 	t1,t1,t2
        	lw  	t1, (t1)
        	sw  	t1, (t0)
        	addi    t2, t2, 4
        	blt 	t2, a6, L0
PRINT_CHAR:	mv	t0, zero # counter of characters in t0
		li  	s1, 0xFF0
    		add 	s1, s1, s0
    		slli    s1, s1, 20 # bitmap address in s1
    		li	s2, 0xf #0b11111111 in s2
    		li	s3, 308 # 320-16 in s3
    		li	s4, 256
L1:		la	t2, POSITIONX
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
IMG0:		la	t2, CHAR #saves image address in t2
		j	B1
IMG1:		la	t2, CHAR2
		sub	t1, t1, a0
		j	B1
IMG2:		la	t2, NULL
		sub	t1, t1, a0
		j	B1
B1:		bgt	zero, t1, NEXT_IMG
		mv 	t6, zero # position of pixel in image in t6
		mv	t3, zero # counter for image in t3
L2:		mv	t4, s1
		add	t4, t4, t1
		add	t4, t4, t6
		mv	t5, t2
		add	t5, t5, t3
		lw	t5, (t5)
		sw	t5, (t4)
		addi	t3, t3, 4
		and	t4, t3, s2
		beq	t4, zero, LINE_JUMP
		addi	t6, t6, 4
		blt	t3, s4, L2
		j	NEXT_IMG
LINE_JUMP:	add	t6, t6, s3
		blt	t3, s4, L2
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
		li 	t5,0xFF200000		# carrega o endereco de controle do KDMMIO
		lw 	t6,(t5)			# Le bit de Controle Teclado
		andi 	t6,t6,0x0001		# mascara o bit menos significativo
   		beq 	t6,zero,JUMP   	   	# Se nao ha tecla pressionada entao vai para FIM
  		lw 	t6,4(t5)  			# le o valor da tecla tecla	
		li 	t5,'w'
		beq 	t5,t6,CHAR_CIMA		# se tecla pressionada for 'w', chama CHAR_CIMA	
		li 	t5,'a'
		beq 	t5,t6,CHAR_ESQ		# se tecla pressionada for 'a', chama CHAR_CIMA
		li 	t5,'s'
		beq 	t5,t6,CHAR_BAIXO		# se tecla pressionada for 's', chama CHAR_CIMA
		li 	t5,'d'
		beq 	t5,t6,CHAR_DIR		# se tecla pressionada for 'd', chama CHAR_CIMA
CHAR_CIMA:	bne	a1, zero, JUMP
		li	a1, 10
		j	JUMP
CHAR_BAIXO:	slli	t5, a5, 4
		add	t0, t0, t5
		lb	t0, (t0)
		beq	t0, a2, JUMP
		beq	t0, a3, NEXT_LEVEL
		slli	t5, a5, 2
		add	a0, a0, t5
		j	JUMP
CHAR_DIR:	addi	t0, t0, 16
		lb	t0, (t0)
		beq	t0, a2, JUMP
		beq	t0, a3, NEXT_LEVEL
		addi	t1, t1, 4
		sw	t1, (t3)
		j	JUMP
CHAR_ESQ:	addi	t0, t0, -1
		lb	t0, (t0)
		beq	t0, a2, JUMP
		beq	t0, a3, NEXT_LEVEL
		addi	t1, t1, -4
		sw	t1, (t3)
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
		slli	t5, a5, 2
		sub	a0, a0, t5
		addi	a1, a1, -1
		j	COLLISION
GRAVITY:	slli	t5, a5, 4
		add	t0, t0, t5
		lb	t0, (t0)
		beq	t0, a2, GROUND
		beq	t0, a3, NEXT_LEVEL
		slli	t5, a5, 2
		add	a0, a0, t5
		j	COLLISION
GROUND:		mv	a1, zero # allows character to jump once he touched the ground at least once
COLLISION:	li	t0, 4 # counter of characters
		li	s1, 16 # 16 in s1
		sub	s2, zero, s1 # -16 in s2
		li	s3, 320
		slli	s3, s3, 4 # 320 * 16 in s3
		sub	s4, zero, s3 # -320*16 in s4
		la	t1, POSITIONX
		la	t2, POSITIONY
		lw	s5, (t1)
		lw	s6, (t2)
L3:		add	t3, t1, t0
		lw	t3, (t3)
		add	t4, t2, t0
		lw	t4, (t4)
		sub	t4, t4, a0
		sub	t3, t3, s5
		sub	t4, t4, s6
		bge	t3, s1, B2
		bge	s2, t3, B2
		bge	t4, s3, B2
		bge	s4, t4, B2
		j	GAME_OVER
B2:		addi	t0, t0, 4
		blt	t0, a4, L3
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
NEXT_LEVEL:	mv	zero, zero
GAME_OVER:	mv	zero, zero
