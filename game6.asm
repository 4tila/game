.data
HEAP_ADDR:		.word 0x10040000
.include "map.s"
.text
#################################################
#	a0 = endereço imagem			#
#	a1 = x					#
#	a2 = y					#
#	a3 = frame (0 ou 1)			#
#################################################
#	t0 = endereco do bitmap display		#
#	t1 = endereco da imagem			#
#	t2 = contador de linha			#
# 	t3 = contador de coluna			#
#	t4 = largura				#
#	t5 = altura				#
#	t6 = auxiliar				#
#################################################

MAIN:
    li		t4, 1
    slli	t4, t4, 16
PRINT:
    lw		t0, HEAP_ADDR
    add		t0, t0, a0
    
    la		t6, MAP
    add		t6,t6,t3
    lw		t1, (t6)
    
    sw		t1, 0(t0)
    addi	t3, t3, 4
    addi	a0, a0, 4
    srli	t6, t3, 2
    blt		t6, t4, PRINT