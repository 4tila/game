.data
HEAP_ADDR:		.word 0x10040000
.include "map2.s"
.text
#################################################
#	a0 = endereço imagem			#
#	a1 = x					#
#	a2 = y	(profundidade)			#
#	a3 = frame (0 ou 1)			#
#################################################
#	t0 = endereco do bitmap display		#
#	t1 = endereco da imagem			#
#	t2 = auxiliar				#
# 	t3 = auxiliar				#
#	t4 = QTDE de pixels na caixa (NxN)	#
#	t5 = auxiliar				#
#	t6 = auxiliar				#
#################################################

MAIN:
    	li		t4, 1
    	slli		t4, t4, 16
    	li		a2, 50
PRINT:
    	lw		t0, HEAP_ADDR
    	add		t0, t0, a0
    
    	la		t6, MAP2
    	add		t6,t6,a0
    	slli		t5, a2, 8
    	add		t6, t6, t5
    	lw		t1, (t6)
    
    	sw		t1, 0(t0)
    	addi		a0, a0, 4
	srli		t6, a0, 2
	blt		t6, t4, PRINT
