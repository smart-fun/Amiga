; ******** file_size ********
; Returns the size of a file in Bytes
; INPUT: a0 = filename
; OUTPUT: d0 = file size, or -1 if not found
file_size:
	movem.l d1-d7/a0-a6, -(a7)
	bsr file_size_get
	movem.l (a7)+,d1-d7/a0-a6
	rts
	
; ******** read_file ********
; Reads a file from disk to a memory buffer
; INPUT: d0 = filesize
;		 a0 = filename
;		 a1 = destination buffer
; OUTPUT: none
read_file:
	movem.l d0-d7/a0-a6, -(a7)
	bsr file_read
	movem.l (a7)+,d0-d7/a0-a6
	rts

; *************************************************************************************************
file_read:
	move.l d0, filesize
	move.l a0, file_name
	move.l a1, file_buffer

	move.l 4.w, a6	; Execbase
	lea file_dosname, a1
	moveq #0,d0
	jsr -552(a6)	; OPENLIB
	tst.l d0
	beq .file_read_exit
	
	move.l d0, a6
	move.l file_name, d1
	move.l #1005, d2	; READ
	jsr -30(a6)	; OPEN FILE
	move.l d0, file
	beq .file_close_dos

	move.l d0,d1			; file
	move.l file_buffer, d2	; buffer
	move.l filesize, d3		; size
	jsr -42(a6)				; READ FILE
	
	move.l d0, file_buffer	; TEMP
	
	move.l file,d1
	jsr -36(a6)	; CLOSE FILE
	
.file_close_dos:	
	move.l a6, a1
	move.l 4.w, a6	; EXECBASE
	jsr -414(a6)	; CLOSELIB
.file_read_exit:
	rts
	
file_buffer:
	dc.l 0
; *************************************************************************************************
file_size_get:
	move.l a0, file_name
	clr.l filesize
	move.l 4.w, a6	; Execbase
	lea file_dosname, a1
	moveq #0,d0
	jsr -552(a6)	; OPENLIB
	tst.l d0
	beq nodos

	move.l d0, a6
	move.l file_name, d1
	move.l #1005, d2	; READ
	jsr -30(a6)	; OPEN FILE
	move.l d0, file
	beq .closedos

	move.l file, d1
	move.l  #0,d2
    move.l  #1,d3	; END OF FILE
    jsr     -66(a6)	; FILE SEEK

	move.l file, d1
	move.l  #0,d2
    move.l  #0,d3	; CURRENT
    jsr     -66(a6)	; FILE SEEK
	
	move.l d0,filesize
	
	move.l file,d1
	jsr -36(a6)	; CLOSE FILE
	
.closedos:
	move.l a6, a1
	move.l 4.w, a6	; EXECBASE
	jsr -414(a6)	; CLOSELIB
nodos:
	move.l filesize, d0
	rts

file_name:
	dc.l 0
file_dosname:
	dc.b "dos.library", 0
	even
file_dosbase:
	dc.l 0
file:
	dc.l 0
filesize:
	dc.l 0
