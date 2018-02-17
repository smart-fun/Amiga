; ******** WAIT_VBL ********
; Wait for the screen spot to reach a given line number
; example of usage: WaitVBL 100
WAIT_VBL	MACRO
.waitVBL1\@
	cmp.b	#\1,$dff006
	bne		.waitVBL1\@
.waitVBL2\@
	cmp.b	#\1,$dff006
	beq		.waitVBL2\@
	ENDM
	
; ******** WAIT_BLITTER ********
; Wait for the Blitter to finish his current task if any
; example of usage: WaitBlitter
WAIT_BLITTER	MACRO
	move.l a5,-(a7)
	lea $dff002,a5
	tst (a5)			;for compatibility
.waitBlitter:
	btst #6,(a5)
	bne.s .waitBlitter
	move.l (a7)+,a5
	ENDM

; ******** CREATE_OUTPUT_TEXT ********
; Creates a texts for Logs (with CR and final 0) and returns a pointer in an Address Register
; example of usage: CREATE_LOG_TEXT "hello world",a0
CREATE_OUTPUT_TEXT MACRO
	lea .text\@, \2
	bra .textEnd\@
.text\@
	dc.b \1
	dc.b 10,13,0
	even
.textEnd\@
	ENDM
