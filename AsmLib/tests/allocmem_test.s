r:
	move.l #20, d0
	bsr memory_init
	move.l d0, init1
	
	move.l #$1234, d0
	move.l ALLOC_TYPE_CHIP, d1
	bsr memory_alloc
	move.l d0, malloc1

	move.l #$5678, d0
	move.l ALLOC_TYPE_FAST, d1
	bsr memory_alloc
	move.l d0, malloc2
	
	rts

init1: dc.l 0	
malloc1: dc.l 0
malloc2: dc.l 0

	include "allocmem.i"
