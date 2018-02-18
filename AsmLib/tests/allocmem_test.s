
r:
	move.l #10, d0
	bsr memory_init
	move.l d0, init1
	
	move.l #$10, d0
	move.l EXEC_ALLOC_TYPE_CHIP, d1
	bsr memory_alloc
	move.l d0, malloc1

	move.l #$20, d0
	move.l EXEC_ALLOC_TYPE_FAST, d1
	bsr memory_alloc
	move.l d0, malloc2
	
	move.l malloc2, a0
	bsr memory_free

	move.l malloc1, a0
	bsr memory_free
	
	bsr memory_release_all
	
	rts

init1: dc.l 0	
malloc1: dc.l 0
malloc2: dc.l 0

	include "allocmem.i"
