
	include "const.i"

; ******** System_InitLibrary ********
; Prepare Memory Allocations and Opens Dos Library
; INPUT: d0 = max number of allocation buffers
; OUTPUT: d0 = 0 for no error, 1 for memory error, 2 for dos.library error
System_InitLibrary:
	movem.l d1-d7/a0-a6,-(a7)
	bsr memory_prepare
	tst.l d0
	bne .initLibError
	bsr openDosLibrary
.initLibError:
	movem.l (a7)+,d1-d7/a0-a6
	rts
	
; ******** System_ReleaseLibrary ********
; close dos.library and free all allocated memory
System_ReleaseLibrary:
	movem.l d0-d7/a0-a6,-(a7)
	bsr closeDosLibrary
	bsr memory_releaseall
	movem.l (a7)+,d0-d7/a0-a6
	rts

; ******** Memory_Alloc ********
; Allocate memory
; INPUT: d0 = size of the block to alloc
;        d1 = type of memory to allocate. See EXEC_ALLOC_TYPE_* in "const.i"
; OUTPUT d0 = address of the buffer allocated (or 0 if failed)
Memory_Alloc:
	movem.l d1-d7/a0-a6,-(a7)
	bsr memory_alloc_impl
	movem.l (a7)+,d1-d7/a0-a6
	rts

; ******** Memory_Free ********
; free a block of memory
; INPUT: a0 = address of the allocated memory
; OUTPUT: none
Memory_Free:
	movem.l d0-d7/a0-a6,-(a7)
	bsr memory_free_impl
	movem.l (a7)+,d0-d7/a0-a6
	rts

; ******** File_GetSize ********
; Returns the size of a file in Bytes
; INPUT: a0 = filename
; OUTPUT: d0 = file size, or -1 if not found
File_GetSize:
	movem.l d1-d7/a0-a6, -(a7)
	bsr file_size_get
	movem.l (a7)+,d1-d7/a0-a6
	rts
	
; ******** File_Load ********
; Reads a file from disk to a memory buffer
; INPUT: d0 = filesize
;		 a0 = filename
;		 a1 = destination buffer
; OUTPUT: none
File_Load:
	movem.l d0-d7/a0-a6, -(a7)
	bsr file_read
	movem.l (a7)+,d0-d7/a0-a6
	rts

; ******** CLI_WriteText ********
; Writes some text to CLI (if launched from CLI)
; INPUT: a0 = text to print
; OUTPUT: none
CLI_WriteText:
	movem.l d0-d7/a0-a6, -(a7)
	bsr writeCLI
	movem.l (a7)+,d0-d7/a0-a6
	rts
	
; ******** Text_AddressToText ********
; Creates a text representing a hexadecimal address, ie "$00020124"
; INPUT: d0 = an address
; OUTPUT: a0 = pointer to the created text
Text_AddressToText:
	movem.l d0-d7/a1-a6, -(a7)
	bsr address_to_text
	movem.l (a7)+, d0-d7/a1-a6
	rts
	
; *************************************************************************************************
memory_prepare:
	and.l #$3FF, d0		; just in case a huge value is given -> 1023 allocs max
	move.l d0, max_allocs
	lsl.l #3, d0		; 8 bytes per address (address.l and size.l)
	move.l	#EXEC_ALLOC_TYPE_ANY,d1
	move.l	EXEC_BASE,a6
	jsr	EXEC_AllocMem(a6)
	tst.l d0
	bne .memory_prepare_buffers
	moveq #1, d0	; memory error
	rts
.memory_prepare_buffers:
	move.l d0, alloc_buffers
	move.l d0, a0
	move.l max_allocs, d0
	subq #1, d0
.memory_prepare_clear:
	clr.l (a0)+
	clr.l (a0)+
	dbf d0, .memory_prepare_clear
	moveq.l #0, d0	; no error
	rts
	
max_allocs:
	dc.l 0
alloc_buffers:
	dc.l 0

; *************************************************************************************************
memory_alloc_impl:
	move.l d0, malloc_temp_size
	move.l	EXEC_BASE,a6
	jsr	EXEC_AllocMem(a6)
	tst.l d0
	bne .malloc_success
	moveq.l #0, d0
	rts
.malloc_success:
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
memory_free_impl:
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
	move.l (a2), a1		; address
	move.l 4(a2), d0	; size
	clr.l (a2)+
	clr.l (a2)+
	move.l	EXEC_BASE,a6
	jsr	EXEC_FreeMem(a6)
	rts
	
; *************************************************************************************************
memory_releaseall:
	move.l alloc_buffers, d0
	bne .release_allocs
	rts
.release_allocs:
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
	movem.l (a7)+, d5/a5
.releaseall_empty:
	clr.l -8(a5)
	clr.l -4(a5)
	dbf d5, .releaseall_loop

	; release alloc_buffers
	move.l alloc_buffers, a1
	move.l max_allocs, d0
	lsl.l #3, d0	; 8 bytes per address (address.l and size.l)
	move.l	EXEC_BASE,a6
	jsr	EXEC_FreeMem(a6)
	rts

; *************************************************************************************************
openDosLibrary:
	move.l EXEC_BASE, a6
	lea dos_dosname, a1
	moveq #0,d0
	jsr EXEC_OpenLib(a6)
	move.l d0, dos_dosbase
	bne .dosOpened
	moveq #2, d0	; cannot open dos.library. TODO, consts ?
	rts
.dosOpened:
	moveq.l #0,d0	; no error
	rts
	
; *************************************************************************************************
closeDosLibrary:
	move.l dos_dosbase, d0
	beq .dosNotOpened
	move.l d0, a1
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

; *************************************************************************************************
writeCLI:
	move.l a0, _writeCLItext
	move.l dos_dosbase, a6
	jsr -60(a6)	; get output
	move.l d0, d1				; file handler
	bne .writeCLIhandler
	rts
.writeCLIhandler:
	move.l _writeCLItext, d2	; text
	moveq.l #-1, d3				; compute size
	move.l d2, a0
.writeCLIsize:
	addq.l #1,d3
	tst.b (a0)+
	bne .writeCLIsize
	jsr -48(a6)	; write
	rts

_writeCLItext:
	dc.l 0

; *************************************************************************************************
address_to_text:
	lea textAddress, a0
	moveq.l #8-1, d1
	moveq.l #0, d2
textloop:
	rol.l #4, d0
	move.b d0, d2
	and #$0F, d2
	cmp #9, d2
	bls .number
	add #'A'-10,d2
	bra .letter
.number:
	add #'0',d2
.letter
	move.b d2,(a0)+
	dbf d1, textloop
	lea returnedText,a0
	rts
	
returnedText:
	dc.b "$"
textAddress:
	dc.b "12345678",10,13,0
	even	
	
; *************************************************************************************************
dos_dosname:
	dc.b "dos.library", 0
	even
dos_dosbase:
	dc.l 0
dos_file_name:
	dc.l 0
dos_file:
	dc.l 0
dos_filesize:
	dc.l 0
