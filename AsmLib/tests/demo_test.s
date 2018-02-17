
EXECBASE=4			; ADRESSE DE BASE DE EXEC.LIB
FORBID=-132			; OFFSET DE LA FONCTION ETEINDRE
PERMIT=-138			; ET REMETTRE LE MULTITACHES
OPENLIB=-552			; OFFSET OUVRIR ET
CLOSELIB=-414			; FERMER LES BIBLIOTHEQUES

	section FAST, CODE
r:	
	movem.l d0-d7/a0-a6,-(a7)

; Alloc Chip for Screen
	move.l #20, d0
	bsr memory_init
	tst.l d0
	beq exit_movem
	move.l #44*300*5, d0
	move.l #ALLOC_TYPE_CHIP, d1
	bsr memory_alloc
	move.l d0, screenBuffer
	beq exit_memory_release

; Init Copper list
	move.l EXECBASE, a6
	jsr FORBID(a6)
	
	move.l EXECBASE, a6
	lea gfxname, a1
	moveq #0,d0	; revision number
	jsr OPENLIB(a6)
	move.l d0, gfxbase
	beq exit_closelib

	move.l d0, a0
	move.l $32(a0), systemCopper
	move.l #copperlist,$32(a0)
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
	
; init protracker
	lea module,a0
	bsr protracker_init
	
main:
	bsr waitVBL
	bsr protracker_play
	
	btst	#6,$bfe001
	bne.b	main
	
	bsr protracker_release
	
; restore copperlist
	move.l gfxbase,a1
	move.l systemCopper, $32(a1)
exit_closelib:
	move.l EXECBASE, a6
	jsr CLOSELIB(a6)
	
	move.l EXECBASE, a6
	jsr PERMIT(a6)
exit_memory_release:
	bsr memory_release_all
exit_movem:
	movem.l (a7)+,d0-d7/a0-a6
	rts

waitVBL:
	cmp.b	#200,$dff006
	bne	waitVBL
waitVBL2:
	cmp.b	#200,$dff006
	beq	waitVBL2
	rts
	
	include "allocmem.i"
	even
	include "protracker.i"
	even
	
gfxname:
	dc.b "graphics.library",0
	even
gfxbase:
	dc.l 0
systemCopper:
	dc.l 0
screenBuffer:
	dc.l 0
	
	section CHIP, DATA
	
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

module:
	incbin "mod.melodee"
	
