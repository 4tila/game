.data
HEAP_ADDR:		.word 0x10040000
.include "map2.s"
.text
#################################################
#	a0 = pixel do print			#
#	a1 = x					#
#	a2 = y	(profundidade)			#
#	a3 = frame (0 ou 1)			#
#################################################
#	t0 = endereco do bitmap display		#
#	t1 = endereco da imagem			#
#	t2 = QTDE de pixels na caixa (NxN)	#
#	t3 = auxiliar				#
#	t4 = auxiliar				#
#	t5 = auxiliar				#
#	t6 = auxiliar				#
#################################################

MAIN:	li      t2, 1
        slli    t2, t2, 16
        li      a2, 39
PRINT:	lw      t0, HEAP_ADDR
        add     t0, t0, a0

        la      t3, MAP2
        add     t3,t3,a0
        slli    t4, a2, 8
        add     t3, t3, t4
        lw      t1, (t3)

        sw      t1, 0(t0)
        addi    a0, a0, 4
        srli    t3, a0, 2
        blt     t3, t2, PRINT
CLEAR:	mv	a0, zero
	mv	t3, zero
	mv	t4, zero
	mv	t5, zero