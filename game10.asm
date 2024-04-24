.data
HEAP_ADDR:		.word 0x10040000
TYPES:			.word 0x0, 0x1, 0x1, 0x1, 0x1, 0x1 # type of character and the enemies
POSITIONX:		.word 0x37, 0x37, 0x37, 0x37, 0x37, 0x37
POSITIONY:		.word 0x13, 0x1d, 0x27, 0x31, 0x3b, 0x45
.include "map4.s"
.include "char.s"
.include "char2.s"
.text

#
#   	a0 = endereco do bitmap         
#   	a1 = counter for characters              
#   	a2 = auxiliar
#   	a3 = profundidaden do mapa - endereco da word 
#	a4 = address of character loading
#	a5 = auxiliar
#	a6 = size of array of characters*4
#
#   	t0 = endereco do bitmap display     
#   	t1 = endereco da imagem         
#   	t2 = QTDE de pixels da imagem vezes 4 (4xNxN)
#                       
#    	multiplica por 4 para reduzir as operacoes para comparacao pq
#    	o endereco das words aumenta de 4 em 4 (registradora a0)
#                       
#   	t3 = auxiliar              
#   	t4 = auxiliar               
#   	t5 = auxiliar               
#   	t6 = auxiliar               
#
#	variaveis auxiliares para usar caso necessario - nao correspondem
#	nada. Por favor tentar usar somente essas registradoras como variavel
#	auxiliar  


MAIN:		li	a1, 0
		li	a3, 44
        	slli	a3, a3, 10	# multiplica por 256*4
        	mv	t4, a3		# salva em t4 a profundidade atual do mapa
PRINT:		li      t2, 1
        	slli    t2, t2, 18 	# 256 * 256 * 4
LOOP0:		lw      t0, HEAP_ADDR
        	add     t0, t0, a0

        	la      t3, MAP
        	add     t3, t3, t4
        	lw      t1, (t3)

        	sw      t1, 0(t0)
        	addi    a0, a0, 4
        	addi	t4, t4, 4
        	blt     a0, t2, LOOP0
PRINT_CHAR:	li	a6, 24
		li	t2, 256		# 4*8*8 comparador
		li	t6, 32
		
		la	a5, TYPES
		add	a5, a5, a1
		lw	a5, (a5)
		
TYPE1:		li	a2, 0x0
		bne	a5, a2, TYPE2
		la	a4, CHAR
		beq	a5, a2, XYZ
TYPE2:		li	a2, 0x1
		la	a4, VILL0
		beq	a5, a2, XYZ	# those to must be equal, could do a jump
		
XYZ:		la	a5, POSITIONX
		add	a5, a5, a1
		lw	a5, (a5)
		la	a2, POSITIONY
		add	a2, a2, a1
		lw	a2, (a2)
		slli	a2, a2, 8
		add	a0, a2, a5
		slli	a0, a0, 2
		
		mv	t3, zero 	# counter do char
		mv	t5, zero	# counter para pular linha
LOOP1:		lw	t0, HEAP_ADDR
		add	t0, t0, a0 
		mv	t4, a4
		add	t4, t4, t3
		lw	t1, (t4)
		sw	t1, (t0)
		
		addi	t3, t3, 4
		addi	t5, t5, 4
		bne	t5, t6,	DONT_JUMP
		mv	t5, zero
		addi    a0, a0, 992	# adds (256-8)*4
DONT_JUMP:	addi	a0, a0, 4
		blt	t3, t2, LOOP1
		
		addi	a1, a1, 4
		blt	a1, a6, PRINT_CHAR
CLEAR:		mv	a0, zero
		mv	t3, zero
		mv	t4, zero
		mv	t5, zero
