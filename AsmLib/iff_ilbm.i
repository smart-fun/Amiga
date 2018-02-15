; ******** iff_uncompress ********
; Uncompress a IFF ILBM picture to a pre-allocated buffer
; INPUT: a0 = IFF ILBM source, a1 = destination buffer
; OUTPUT: d0 = error code (0 = success, 1 = invalid format)
iff_uncompress:
	movem.l d1-d2/a0-a1,-(a7)
	cmp.l #"FORM",(a0)+
	bne iff_failure
	move.l (a0)+,d0		; remaining size
	add.l a0,d0		; d0 = end of file
	cmp.l #"ILBM",(a0)+
	bne iff_failure
iff_next_chunk:
	cmp.l #"BODY",(a0)+
	beq iff_body
	add.l (a0)+,a0	; skip this chunk (BMHD, CMAP...)
	cmp.l d0, a0
	blo iff_next_chunk
	bra iff_failure	; no body chunk!
iff_body:
	move.l (a0)+,d0	; size of body chunk
	add.l a0,d0	; end of body chunk
iff_next_byte:
	moveq.l #0,d1
	move.b (a0)+,d1	; read next compressed byte
	cmp.b #128,d1
	bhs iff_repeat
iff_copy:
	move.b (a0)+,(a1)+
	dbf d1, iff_copy
	cmp.l d0,a0
	blo iff_next_byte
	bra iff_success
iff_repeat:
	neg.b d1
	move.b (a0)+,d2
iff_repeat_loop:
	move.b d2,(a1)+
	dbf d1, iff_repeat_loop
	cmp.l d0,a0
	blo iff_next_byte
iff_success:
	moveq.l #0, d0
	bra iff_exit	
iff_failure:
	moveq.l #1, d0
iff_exit:
	movem.l (a7)+,d1-d2/a0-a1
	rts
; ******** end iff_uncompress ********

; BMHD, 4 bytes chunk size, 2 words width / height, 2 words x/y, 1 byte nb bitplans
; getchunk method ?