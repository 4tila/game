.data
HEAP_ADDR:		.word 0x10040000
TYPES:			.word 0x0, 0x1, 0x1, 0x1, 0x1, 0x1 # type of character and the enemies
POSITIONX:		.word 0x37, 0x37, 0x37, 0x37, 0x37, 0x37
POSITIONY:		.word 0x13,0x27,0x3b,0x4f,0x63,0x77
.include "map4.s"
.include "char3.s"
.include "char4.s"
.text

#
#   	a0 = endereco do bitmap         
#   	a1 = counter for characters              
#   	a2 = profundidaden do mapa - endereco da word 
#	a3 = address of character loading
#	a4 = size of array of characters*4
#	a5 = auxiliar
#	a6 = auxiliar
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
#
#	t7 = w a s d 


MAIN:		li	a1, 0
    		li	a2, 44
        	slli	a2, a2, 10	# multiplica por 256*4
KEY:		li	t3, 0xFFFF0004		# carrega o endereco de controle do KDMMIO
		lw	t3, (t3)
	        beq 	t3,zero,PRINT        # Se nao ha tecla pressionada entao vai para FIM
		
        	li t4,'w'
            	beq t3,t4,CHAR_CIMA     # se tecla pressionada for 'w', chama CHAR_CIMA 
            	li t4,'a'
            	beq t3,t4,CHAR_ESQ      # se tecla pressionada for 'a', chama CHAR_CIMA
            	li t4,'s'
            	beq t3,t4,CHAR_BAIXO        # se tecla pressionada for 's', chama CHAR_CIMA 
            	li t4,'d'
            	beq t3,t4,CHAR_DIR      # se tecla pressionada for 'd', chama CHAR_CIMA
CHAR_CIMA:	la	a5, POSITIONY
		lw	a6, (a5)
		addi	a6, a6, -1
		sw	a6, (a5)
		j PRINT
CHAR_BAIXO:	la	a5, POSITIONY
		lw	a6, (a5)
		addi	a6, a6, 1
		sw	a6, (a5)
		j PRINT
CHAR_ESQ:	la	a5, POSITIONX
		lw	a6, (a5)
		addi	a6, a6, -1
		sw	a6, (a5)
		j PRINT
CHAR_DIR:	la	a5, POSITIONY
		lw	a6, (a5)
		addi	a6, a6, 1
		sw	a6, (a5)
		j PRINT		
PRINT:		li      t2, 1
        	slli    t2, t2, 18 	# 256 * 256 * 4
        	mv	t4, a3		# salva em t4 a profundidade atual do mapa
LOOP0:		lw      t0, HEAP_ADDR
        	add     t0, t0, a0

        	la      t3, MAP
        	add     t3, t3,t4
        	lw      t1, (t3)

        	sw      t1, 0(t0)
        	addi    a0, a0, 4
        	addi	t4, t4, 4
        	blt     a0, t2, LOOP0
PRINT_CHAR:	li	a4, 24
            	li	t2, 1024		# 4*16*16 comparador
            	li	t6, 64
            
            	la	a6, TYPES
            	add	a6, a6, a1
            	lw	a6, (a6)
            
TYPE1:		li	a5, 0x0
            	bne	a6, a5, TYPE2
            	la	a3, CHAR
            	j	XYZ
TYPE2:		li	a5, 0x1
		la	a3, VILLAIN0
		j	XYZ	# those to must be equal, could do a jump
		
XYZ:		la	a6, POSITIONX
                add	a6, a6, a1
            	lw	a6, (a6)
            	la	a5, POSITIONY
            	add	a5, a5, a1
            	lw	a5, (a5)
            	slli	a5, a5, 8
            	add	a0, a5, a6
            	slli	a0, a0, 2
            
            	mv	t3, zero 	# counter do char
            	mv	t5, zero	# counter para pular linha
LOOP1:		lw	t0, HEAP_ADDR
            	add	t0, t0, a0 
            	mv	t4, a3
            	add	t4, t4, t3
            	lw	t1, (t4)
            	sw	t1, (t0)
            
            	addi	t3, t3, 4
            	addi	t5, t5, 4
            	bne	t5, t6,	DONT_JUMP
            	mv	t5, zero
            	addi    a0, a0, 960	# adds (256-8)*4
DONT_JUMP:	addi	a0, a0, 4
            	blt	t3, t2, LOOP1
            
            	addi	a1, a1, 4
            	blt	a1, a4, PRINT_CHAR