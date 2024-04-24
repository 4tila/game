.data
init:		.word	0x10040000
.text
main:
	lw	t0, init 	# Heap adress
	li	t1, 0x00ff0000	# Red point to t1
	sw	t1, 0(t0)	# Paint the first dot with red
	addi	t0, t0, 4	# Jump 4 bytes
	
	li	t2, 0xff	
	sb	t2, 2(t0)	# Paint the second dot with red
