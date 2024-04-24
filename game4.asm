.data
init:		.word	0x10040000
map:		.word	0x10040000, 
			0x10040000,0x10040000
.text

PRINT:
	la	t3, map
	lw	t0, 8(t3) 	# Heap adress
	li	t1, 0xff0	# Red point to t1
	slli	t1, t1, 16
	sw	t1, 0(t0)	# Paint the first dot with red
	addi	t0, t0, 4	# Jump 4 bytes
	
	li	t2, 0xff	
	sb	t2, 2(t0)	# Paint the second dot with red
