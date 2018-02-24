	include "const.i"

; ******** DOS_InitLibrary ********
; Opens the Dos Library
; INPUT: none
; OUTPUT: none
DOS_InitLibrary:
	movem.l d0-d7/a0-a6,-(a7)
	bsr openDosLibrary
	movem.l (a7)+, d0-d7/a0-a6
	rts
	
; ******** DOS_ReleaseLibrary ********
; Releases the Dos Library
; INPUT: none
; OUTPUT: none
DOS_ReleaseLibrary:
	movem.l d0-d7/a0-a6,-(a7)
	bsr closeDosLibrary
	movem.l (a7)+, d0-d7/a0-a6
	rts

; ******** DOS_GetBase ********
; Returns the Dos library Base
; INPUT: none
; OUTPUT: d0 = dos base, or 0 if error
DOS_GetBase:
	move.l dos_dosbase, d0
	rts
	
; ******** DOS_GetFileSize ********
; Returns the size of a file in Bytes
; INPUT: a0 = filename
; OUTPUT: d0 = file size, or -1 if not found
DOS_GetFileSize:
	movem.l d1-d7/a0-a6, -(a7)
	bsr file_size_get
	movem.l (a7)+,d1-d7/a0-a6
	rts
	
; ******** DOS_LoadFile ********
; Reads a file from disk to a memory buffer
; INPUT: d0 = filesize
;		 a0 = filename
;		 a1 = destination buffer
; OUTPUT: none
DOS_LoadFile:
	movem.l d0-d7/a0-a6, -(a7)
	bsr file_read
	movem.l (a7)+,d0-d7/a0-a6
	rts

; *************************************************************************************************
openDosLibrary:
	move.l EXEC_BASE, a6
	lea dos_dosname, a1
	moveq #0,d0
	jsr EXEC_OpenLib(a6)
	move.l d0, dos_dosbase
	rts

; *************************************************************************************************
closeDosLibrary:
	move.l dos_dosbase, d0
	beq .dosNotOpened
	move.l dos_dosbase, a1
	move.l EXEC_BASE, a6
	jsr EXEC_CloseLib(a6)
.dosNotOpened:
	rts

; *************************************************************************************************
file_read:
	move.l d0, dos_filesize
	move.l a0, dos_file_name
	move.l a1, dos_file_buffer
	move.l dos_dosbase, a6
	move.l dos_file_name, d1
	move.l #DOS_ACCESS_EXISTING, d2
	jsr DOS_OpenFile(a6)
	move.l d0, dos_file
	beq .file_read_exit

	move.l d0,d1				; file
	move.l dos_file_buffer, d2	; buffer
	move.l dos_filesize, d3		; size
	jsr DOS_ReadFile(a6)
	
	move.l dos_file,d1
	jsr DOS_CloseFile(a6)
	
.file_read_exit:
	rts
	
dos_file_buffer:
	dc.l 0
; *************************************************************************************************
file_size_get:
	clr.l dos_filesize
	move.l a0, dos_file_name
	move.l dos_dosbase, a6
	move.l dos_file_name, d1
	move.l #DOS_ACCESS_EXISTING, d2
	jsr DOS_OpenFile(a6)
	move.l d0, dos_file
	bne .file_opened
	moveq.l #0,d0
	rts
	
.file_opened:
	move.l dos_file, d1
	move.l  #0,d2
    move.l  #DOS_SEEK_MODE_END,d3
    jsr     DOS_SeekFile(a6)

	move.l dos_file, d1
	move.l  #0,d2
    move.l  #DOS_SEEK_MODE_CURRENT,d3
    jsr     DOS_SeekFile(a6)
	
	move.l d0,dos_filesize
	
	move.l dos_file,d1
	jsr DOS_CloseFile(a6)

	move.l dos_filesize, d0
	rts

dos_file_name:
	dc.l 0
dos_dosname:
	dc.b "dos.library", 0
	even
dos_dosbase:
	dc.l 0
dos_file:
	dc.l 0
dos_filesize:
	dc.l 0
