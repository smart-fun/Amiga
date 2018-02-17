; ******** irq_start ********
; Starts IRQ level 3
; INPUT: a0 = address of the code to be called in the irq
; OUTPUT: none
irq_start:
	move.l a0, irq_user_code
	move.l	$6c.w, irq_system+2
	move.l	#irq_code, $6c.w
	rts

; ******** irq_stop ********
; Starts IRQ level 3
; INPUT: none
; OUTPUT: none
irq_stop:
	move.l	irq_system+2,$6c.w
	rts

	
;**********************************
; Ritchy's IRQ level 3
; Thanks to Kamikaze for his help !
;**********************************

irq_code:
	movem.l	d0-d7/a0-a6,-(a7)

	; avoids most of disk access issues
	move	$dff01e,d0
	and		$dff01c,d0
	btst	#5,d0
	beq.s	.irq_skip

	; execute user code
	lea irq_user_code, a0
	jsr (a0)
.irq_skip:
	movem.l	(a7)+,d0-d7/a0-a6
irq_system:
	jmp $0	; jump to previous irq (system)

irq_user_code:
	dc.l 0
