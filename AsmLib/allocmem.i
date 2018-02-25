
	include "const.i"

; ******** memory_init ********
; Prepare allocator for a max number of possible allocations
; INPUT: d0 = max number of buffers than can be allocated
; OUTPUT: d0 = number of buffers that can really be allocated
memory_init:
	movem.l d1-d7/a0-a6,-(a7)
	bsr memory_prepare
	movem.l (a7)+,d1-d7/a0-a6
	rts

; ******** memory_alloc ********
; Allocate memory
; INPUT: d0 = size of the block to alloc
;        d1 = type of memory to allocate. See EXEC_ALLOC_TYPE_* in "const.i"
; OUTPUT d0 = address of the buffer allocated (or 0 if failed)
memory_alloc:
	movem.l d1-d7/a0-a6,-(a7)
	bsr malloc
	movem.l (a7)+,d1-d7/a0-a6
	rts

; ******** memory_free ********
; free a block of memory
; INPUT: a0 = address of the allocated memory
; OUTPUT: none
memory_free:
	movem.l d0-d7/a0-a6,-(a7)
	bsr freemem
	movem.l (a7)+,d0-d7/a0-a6
	rts
	
; ******** memory_release_all ********
; free all allocated memory and release allocator
memory_release_all:
	movem.l d0-d7/a0-a6,-(a7)
	bsr releaseall
	movem.l (a7)+,d0-d7/a0-a6
	rts
	
; *************************************************************************************************
memory_prepare:
	CREATE_OUTPUT_TEXT "memory_prepare:",a0
	bsr DOS_WriteTextToCLI
	
	move.l d0, max_allocs
	lsl.l #3, d0		; 8 bytes per address (address.l and size.l)
	move.l	#EXEC_ALLOC_TYPE_ANY,d1
	move.l	EXEC_BASE,a6
	jsr	EXEC_AllocMem(a6)
	tst.l d0
	bne .memory_prepare_buffers
	rts
.memory_prepare_buffers:

	bsr DOS_AddressToText
	bsr DOS_WriteTextToCLI
	
	move.l d0, alloc_buffers
	move.l d0, a0
	move.l max_allocs, d0
	subq #1, d0
.memory_prepare_clear:
	clr.l (a0)+
	clr.l (a0)+
	dbf d0, .memory_prepare_clear
	move.l max_allocs, d0	; returns the number of buffers that can be allocated
	rts
	
max_allocs:
	dc.l 0
alloc_buffers:
	dc.l 0

; *************************************************************************************************
malloc:
	CREATE_OUTPUT_TEXT "malloc:",a0
	bsr DOS_WriteTextToCLI

	move.l d0, malloc_temp_size
	move.l	EXEC_BASE,a6
	jsr	EXEC_AllocMem(a6)
	tst.l d0
	bne .malloc_success

	CREATE_OUTPUT_TEXT "malloc failed for size:",a0
	bsr DOS_WriteTextToCLI
	move.l malloc_temp_size, d0
	bsr DOS_AddressToText
	bsr DOS_WriteTextToCLI
	moveq.l #0, d0
	rts
.malloc_success:

	bsr DOS_AddressToText
	bsr DOS_WriteTextToCLI

	move.l alloc_buffers, a0
	move.l max_allocs, d1
	subq #1,d1
.malloc_search:
	tst.l	(a0)
	beq	.malloc_found
	addq.l	#8,a0
	dbf d1, .malloc_search
	rts	; no place in the alloc_buffers, but still returns the allocated buffer
.malloc_found:
	move.l d0,(a0)+
	move.l malloc_temp_size,(a0)+
	rts
malloc_temp_size:
	dc.l 0

; *************************************************************************************************
freemem:
	move.l a0,-(a7)
	CREATE_OUTPUT_TEXT "FreeMem:",a0
	bsr DOS_WriteTextToCLI
	move.l (a7)+, a0
	
	move.l alloc_buffers, a2
	move.l max_allocs, d0
	subq #1, d0
.freemem_search:
	cmp.l (a2), a0
	beq .freemem_found
	addq.l #8,a2
	dbf d0, .freemem_search
	rts	; alloc not found
.freemem_found:

	move.l (a2), d0
	bsr DOS_AddressToText
	bsr DOS_WriteTextToCLI

	move.l (a2), a1		; address
	move.l 4(a2), d0	; size
	clr.l (a2)+
	clr.l (a2)+
	move.l	EXEC_BASE,a6
	jsr	EXEC_FreeMem(a6)
	rts
	
; *************************************************************************************************
releaseall:
	CREATE_OUTPUT_TEXT "RelaseAll:",a0
	bsr DOS_WriteTextToCLI
	
	move.l alloc_buffers, a5
	move.l max_allocs, d5
	subq #1, d5
.releaseall_loop:
	move.l (a5)+, a1	; address
	move.l (a5)+, d0	; size
	tst.l d0
	beq .releaseall_empty
	movem.l d5/a5, -(a7)
	move.l	EXEC_BASE,a6
	jsr	EXEC_FreeMem(a6)
	
	move.l -8(a5), d0
	bsr DOS_AddressToText
	bsr DOS_WriteTextToCLI
	
	movem.l (a7)+, d5/a5
.releaseall_empty:
	clr.l -8(a5)
	clr.l -4(a5)
	dbf d5, .releaseall_loop

	move.l alloc_buffers, d0
	bsr DOS_AddressToText
	bsr DOS_WriteTextToCLI
	
	; release alloc_buffers
	move.l alloc_buffers, a1
	move.l max_allocs, d0
	lsl.l #3, d0	; 8 bytes per address (address.l and size.l)
	move.l	EXEC_BASE,a6
	jsr	EXEC_FreeMem(a6)

	rts
