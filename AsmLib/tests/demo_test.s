
	include "const.i"
	include "macros.i"

	section FAST, CODE

r:	
	movem.l d0-d7/a0-a6,-(a7)
	
	CREATE_OUTPUT_TEXT "Hello AMIGA",a0
	bsr writeCLI

; Alloc Chip memory for Screen
	move.l #20, d0
	bsr memory_init
	tst.l d0
	beq exit_movem
	move.l #44*300*5, d0
	move.l #EXEC_ALLOC_TYPE_CHIP, d1
	bsr memory_alloc
	move.l d0, screenBuffer
	beq exit_memory_release
	
	CREATE_OUTPUT_TEXT "Memory Allocated for Frame Buffer",a0
	bsr writeCLI
	
	; get File Size
	lea modname,a0
	bsr file_size
	move.l d0, modsize
	bne .modsize_ok
	
	CREATE_OUTPUT_TEXT "Cannot open mod.demo",a0
	bsr writeCLI
	bra skip_mod_file
	
.modsize_ok:
	; Alloc for File
	move.l modsize, d0
	move.l #EXEC_ALLOC_TYPE_CHIP, d1
	bsr memory_alloc
	move.l d0, modBuffer
	bne .mod_alloc_ok

	CREATE_OUTPUT_TEXT "Cannot allocate Chip Memory for module",a0
	bsr writeCLI
	bra skip_mod_file
	
.mod_alloc_ok
	; Read File
	move.l modsize, d0
	lea modname,a0
	move.l modBuffer, a1
	bsr read_file
	
skip_mod_file:
	
; set bitplan addresses
	move.l screenBuffer, d0
	lea copperbitplans, a1
	moveq #5-1, d1
setBitplans:
	swap d0
	move.w d0,2(a1)
	swap d0
	move.w d0, 6(a1)
	add.l #8, a1
	add.l #44, d0
	dbf d1, setBitplans

; check if copperlist is loaded in chip ram
	move.l #copperlist, d0
	move.l d0, copperListAddress
	cmp.l #$20000, d0
	bhs .copper_in_fast
	
	CREATE_OUTPUT_TEXT "Copperlist in Chip Memory, OK",a0
	bra .copperInChip

.copper_in_fast:
	CREATE_OUTPUT_TEXT "Copperlist in Fast Memory, allocate Chip...",a0
	bsr writeCLI
; alloc Chip memory for copperlist, and copy copperlist in it
	move.l #endcopperlist-copperlist, d0
	move.l #EXEC_ALLOC_TYPE_CHIP, d1
	bsr memory_alloc
	move.l d0, copperListAddress
	bne .copper_allocation_ok
	
	CREATE_OUTPUT_TEXT "Cannot allocate Chip Memory for copperlist",a0
	bsr writeCLI
	bra exit_memory_release
	
.copper_allocation_ok
	move.l #endcopperlist-copperlist, d0
	lsr.l #2, d0	; /4 because copy longs
	lea copperlist, a0
	move.l copperListAddress, a1
.copyCopper:
	move.l (a0)+,(a1)+
	dbf d0,.copyCopper
	
.copperInChip
; Init Copper list
	move.l EXEC_BASE, a6
	jsr EXEC_Forbid(a6)
	
	move.l EXEC_BASE, a6
	lea gfxname, a1
	moveq #0,d0	; revision number
	jsr EXEC_OpenLib(a6)
	move.l d0, gfxbase
	beq exit_permit
	
	move.l gfxbase, a0
	move.l $32(a0), systemCopper
	move.l copperListAddress,$32(a0)
	
	bsr loadTurrican

; init protracker
	move.l modBuffer, a0
	tst.l (a0)
	beq .noMusicInit
	bsr protracker_init
.noMusicInit:

main:
	WAIT_VBL 80
	
	move.w #$482, $dff180

	tst.l modBuffer
	beq .noMusicPlay
	bsr protracker_play
.noMusicPlay:
	btst	#6,$bfe001
	bne.b	main
	
	tst.l modBuffer
	beq .noMusicRelease
	bsr protracker_release
.noMusicRelease:

; restore copperlist
	move.l gfxbase,a1
	move.l systemCopper, $32(a1)
	move.l EXEC_BASE, a6
	jsr EXEC_CloseLib(a6)
exit_permit:	
	move.l EXEC_BASE, a6
	jsr EXEC_Permit(a6)
exit_memory_release:
	bsr memory_release_all
exit_movem:
	movem.l (a7)+,d0-d7/a0-a6
	rts

loadTurrican:
	lea turricanName, a0
	bsr file_size
	move.l d0, turricanIFFSize
	beq .endTurrican
	
	move.l turricanIFFSize,d0
	move.l #EXEC_ALLOC_TYPE_ANY, d1
	bsr memory_alloc
	move.l d0, turricanIFFBuffer
	beq .endTurrican

	lea turricanName,a0
	move.l turricanIFFBuffer,a1
	move.l turricanIFFSize,d0
	bsr read_file
	
	move.l turricanIFFBuffer,a0
	bsr IFF_GetSize
	move.w d0, turricanWidth
	beq .noTurricanIFF
	move.w d1, turricanHeight
	move.w d2, turricanBpls
	lsr.l #3, d0
	mulu d1, d0
	mulu d2, d0	; size of bitmap
	
	; TODO allocate for uncompressed bitmap
	
.noTurricanIFF
	move.l turricanIFFBuffer, a0
	bsr memory_free
.endTurrican:
	rts

	
; TODO: move in dos.i
writeCLI:
	move.l a0, .writeCLItext
	lea dosname, a1
	moveq #0, d0
	move.l EXEC_BASE, a6	; exec library
	jsr EXEC_OpenLib(a6)
	move.l d0, dosbase
	beq .writeCLIexit
	move.l d0, a6	; dos library
	jsr -60(a6)	; get output
	move.l d0,outputHandle
	beq .writeCLIcloseDos
	
	move.l d0, d1	; file handler
	move.l .writeCLItext, d2	; text
	moveq.l #-1, d3	; compute size
	move.l d2, a0
.writeCLIsize:
	addq.l #1,d3
	tst.b (a0)+
	bne .writeCLIsize
	jsr -48(a6)	; write
	
.writeCLIcloseDos:
	move.l EXEC_BASE, a6	; exec library
	move.l dosbase,a1
	jsr EXEC_CloseLib(a6)
.writeCLIexit:
	rts
.writeCLItext:
	dc.l 0
	
text:
	dc.b "Hello World",10,13,0
	even
dosname:
	dc.b "dos.library",0
	even
dosbase:
	dc.l 0
outputHandle:
	dc.l 0
	
	include "allocmem.i"
	include "protracker.i"
	include "file.i"
	include "iff_ilbm.i"
	
gfxname:
	dc.b "graphics.library",0
	even
gfxbase:
	dc.l 0
systemCopper:
	dc.l 0
screenBuffer:
	dc.l 0
copperListAddress:
	dc.l 0

	section CHIP, DATA_C
	
copperlist:
	DC.W $008E,$2981		; DWISTRT (H129,V41)
	DC.W $0090,$29C1        ; DWISTOP (H449,V297)
	DC.W $0092,$0038		; DFFSTRT
	DC.W $0094,$00D0		; DFFSTOP
copperbitplans:
	DC.W $00E0,0, $00E2,0		; POINTEUR BITPLAN 1
	DC.W $00E4,0, $00E6,0		; POINTEUR BITPLAN 2
	DC.W $00E8,0, $00EA,0		; POINTEUR BITPLAN 3
	DC.W $00EC,0, $00EE,0		; POINTEUR BITPLAN 4
	DC.W $00F0,0, $00F2,0		; POINTEUR BITPLAN 5
	DC.W $0100,$5200		; BLTCON 0
	DC.W $0108,$0004
	DC.W $010A,$0004
	DC.W $0102,$0000
	DC.W $0120,0,$0122,0	; POINTEUR (SPRITE 0)
	DC.W $0124,0,$0126,0	; POINTEUR (SPRITE 1)
	DC.W $0128,0,$012A,0	; POINTEUR (SPRITE 2)
	DC.W $012C,0,$012E,0	; PS3
	DC.W $0130,0,$0132,0	; PS4
	DC.W $0134,0,$0136,0	; PS5 !!!
	DC.W $0138,0,$013A,0	; PS6 !
	DC.W $013C,0,$013E,0	; PS7 (8 SPRITES !)
	DC.W $0180,$0000		; REGISTRES COULEURS
	DC.W $0182,$0DFD
	DC.W $0184,$0BFC
	DC.W $0186,$08F8
	DC.W $0188,$03F7
	DC.W $018A,$00E0
	DC.W $018C,$00C0
	DC.W $018E,$0090
	DC.W $0190,$0F00
	DC.W $0192,$0333
	DC.W $0194,$0666
	DC.W $0196,$0555
	DC.W $0198,$0666
	DC.W $019A,$0777
	DC.W $019C,$0888
	DC.W $019E,$0999

	DC.W $01A0,$0000
	DC.W $01A2,$0FFF
	DC.W $01A4,$0F00
	DC.W $01A6,$0800
	DC.W $01A8,$0000
	DC.W $01AA,$0FFF
	DC.W $01AC,$0F00
	DC.W $01AE,$0800
	DC.W $01B0,$0000
	DC.W $01B2,$0FFF
	DC.W $01B4,$0F00
	DC.W $01B6,$0800
	DC.W $01B8,$0000
	DC.W $01BA,$0FFF
	DC.W $01BC,$0F00
	DC.W $01BE,$0800

	DC.W $1B0F,$FFFE,$180,$000
	DC.W $360F,$FFFE,$180,$055
	DC.W $370F,$FFFE,$180,$377
	DC.W $380F,$FFFE,$180,$588
	DC.W $390F,$FFFE,$180,$799
	DC.W $3A0F,$FFFE,$180,$9AA
	DC.W $3B0F,$FFFE,$180,$BBB
	DC.W $3C0F,$FFFE,$180,$420
	DC.W $3D0F,$FFFE,$180,$530
	DC.W $3E0F,$FFFE,$180,$640
	DC.W $3F0F,$FFFE,$180,$750
	DC.W $400F,$FFFE,$180,$860
	DC.W $410F,$FFFE,$180,$970
	DC.W $420F,$FFFE,$180,$A80
	DC.W $430F,$FFFE,$180,$B90
	dc.l	-2
	dc.w 0 ; just here for .L copy
endcopperlist:

modname:
	dc.b "mod.demo", 0
	even
modsize:
	dc.l 0
modBuffer:
	dc.l 0
	
turricanName:
	dc.b "Turrican2.IFF",0
	even
turricanIFFSize:
	dc.l 0
turricanIFFBuffer:
	dc.l 0
turricanWidth:
	dc.w 0
turricanHeight:
	dc.w 0
turricanBpls
	dc.w 0

