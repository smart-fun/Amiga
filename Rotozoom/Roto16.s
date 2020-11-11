ùúùú; ®“RiyÖhy4´naqâg ná 1>¬2 }; 8· lnáe {Ø;	de 4 images secondes OPTIMIMSE a 12 images/sec
;	et meme 14 si pas attente VBL !
;	Maintenant : 25 images seconde !!!


; Roto PIC

r:	movem.l	d0-d7/a0-a6,-(a7)
	clr.l	0

	lea	$dff000,a5
	lea	safemem(pc),a0
	move	$1c(a5),(a0)
	or	#$c000,(a0)+
	move	2(a5),(a0)
	or	#$8100,(a0)

	move	#$7fff,d0
	move	d0,$96(a5)
	move	d0,$9a(a5)
	move	#$83c0,$96(a5)

	lea	$144(a5),a0
	moveq	#8-1,d0
nosprt:	clr.l	(a0)
	addq.l	#8,a0
	dbf	d0,nosprt

	move.l	#ecr1,d0
	and.l	#-8,d0
	move.l	d0,bplw
	move.l	#ecr2,d0
	and.l	#-8,d0
	move.l	d0,bpla

	move.l	#ecr1,d0
	move	d0,bpl+6
	swap	d0
	move	d0,bpl+2

	lea	copper(pc),a0
	move.l	a0,$80(a5)
	clr	$88(a5)

souris:	cmp.b	#194,$dff006
	blo.b	souris

;	move	#$567,$dff180

	move.l	bplw(pc),d0
	lea	bpl,a0
	moveq	#4-1,d1
CopyBpls:
	move	d0,6(a0)
	swap	d0
	move	d0,2(a0)
	swap	d0
	add.l	#64,d0
	addq.l	#8,a0
	dbf	d1,CopyBpls

	move.l	bplw(pc),d0
	move.l	bpla(pc),bplw
	move.l	d0,bpla

	bsr.w	rotation

tutu:	btst	#10,$dff016
	beq.b	tutu

	move.l	Angle1(pc),d0
	addq.l	#4,d0
	and.w	#510,d0
	move.l	d0,Angle1

;	move	#$060,$dff180

	btst	#6,$bfe001
	bne.w	souris

fin:	lea	$dff000,a5
	move	#$7fff,d0
	move	d0,$9a(a5)
	move	d0,$96(a5)
	lea	safemem(pc),a0
	move	(a0)+,$9a(a5)
	move	(a0),$96(a5)
	move.l	4.w,a4
	move.l	(a4),a4
	move.l	(a4),a4
	move.l	38(a4),$80(a5)
	clr	$88(a5)
	movem.l	(a7)+,d0-d7/a0-a6
	rts

;	d5=X	d1=6	Z=0
Rotation:
	move.l	BplW,a6

;------ Rotation suivant l'axe OZ -------------------
	lea	SinCos(pc),a4
	move.l	Angle1(pc),d0
	move	(a4,d0.w),d7	; SIN(a) 10 cycles gagnes <- muls(a5,d0.w)
	add	#228,d0		; idem lea SC+128,a5 / move (a5,d0.w)
	move	(a4,d0.w),d0	; COS(a)

	move	#50-1,d6
Colonne:
	move	D6,d2
	muls	d0,d2		; d2=Y*Cos(a)
	move	D6,d4
	muls	d7,d4		; d4=Y*Sin(a)

	move	#64-1,d5
Ligne:				; Rotation (O,z)
	movem.l	d2/d4,-(sp)
	move	D5,d1
	muls	d0,d1		; d1=X*COS(a)
	move	D5,d3
	muls	d7,d3		; d3=X*Sin(a)
	sub.l	d4,d1		; X'=d1=X*Cos(a)-y*Sin(a)
	add.l	d3,d2		; Y'=d2=X*Sin(a)+y*Cos(a)
	asr.l	#8,d1	; d1=X'
	asr.l	#8,d2	; d2=Y'

;	lsl	#1,d2	; Y*2 car image trop grande !

	add	#18,d1
	add	#18,d2

	and.l	#63,d1
	and.l	#63,d2

	lea	Pic,a5
	lsl	#8,d2
	add.l	d2,d1
	add.l	d1,a5
	move.b	64(a5),64(a6)
	move.b	128(a5),128(a6)
	move.b	192(a5),192(a6)
	move.b	(a5),(a6)+

	movem.l	(sp)+,d2/d4
	dbf	d5,Ligne
	lea	192(a6),a6
	dbf	d6,Colonne
	rts

SinCos:	incbin	"Table"
	even

bplw:	dc.l	0
bpla:	dc.l	0

x:	dc.w	0
y:	dc.w	0

Angle1:	dc.l	0

Safemem:dc.w 0
	dc.w 0

copper:	dc.l	$008e6d81,$0090c2c1
	dc.l	$00920068,$009400a0	; 38 d0
bpl:	dc.l	$00e00010,$00e20000
	dc.l	$00e40010,$00e60000
	dc.l	$00e80010,$00ea0000
	dc.l	$00ec0010,$00ee0000
	dc.l	$01004240,$01020000
	dc.l	$01040000,$01FC0003	; AGA - Old
	dc.l	$010800C0,$010a00C0

	dc.w	$106,0

;	dc.w	$180,$000,$182,$2df
;	dc.w	$184,$2bd,$186,$29b
;	dc.w	$188,$279,$18a,$257
;	dc.w	$18c,$235,$18e,$213
;	dc.w	$190,$fdb,$192,$db9
;	dc.w	$194,$b97,$196,$975
;	dc.w	$198,$753,$19a,$532
;	dc.w	$19c,$311,$19e,$100


	dc.w	$180,$000
	dc.w	$182,$caa
	dc.w	$184,$fed
	dc.w	$186,$feb
	dc.w	$188,$ed9
	dc.w	$18a,$db7
	dc.w	$18c,$da5
	dc.w	$18e,$c84
	dc.w	$190,$963
	dc.w	$192,$752
	dc.w	$194,$ddb
	dc.w	$196,$b88
	dc.w	$198,$966
	dc.w	$19a,$844
	dc.w	$19c,$963
	dc.w	$19e,$752

	dc.w	$120,0,$122,0,$124,0,$126,0
	dc.w	$128,0,$12a,0,$12c,0,$12e,0
	dc.w	$130,0,$132,0,$134,0,$136,0
	dc.w	$138,0,$13a,0,$13c,0,$13e,0


	dc.w	$6d0f,$fffe,$108,$c0,$10a,$c0
	dc.w	$6e0f,$fffe,$108,-64,$10a,-64
	dc.w	$6f0f,$fffe,$108,$c0,$10a,$c0
	dc.w	$700f,$fffe,$108,-64,$10a,-64
	dc.w	$710f,$fffe,$108,$c0,$10a,$c0
	dc.w	$720f,$fffe,$108,-64,$10a,-64
	dc.w	$730f,$fffe,$108,$c0,$10a,$c0
	dc.w	$740f,$fffe,$108,-64,$10a,-64
	dc.w	$750f,$fffe,$108,$c0,$10a,$c0
	dc.w	$760f,$fffe,$108,-64,$10a,-64
	dc.w	$770f,$fffe,$108,$c0,$10a,$c0
	dc.w	$780f,$fffe,$108,-64,$10a,-64
	dc.w	$790f,$fffe,$108,$c0,$10a,$c0
	dc.w	$7a0f,$fffe,$108,-64,$10a,-64
	dc.w	$7b0f,$fffe,$108,$c0,$10a,$c0
	dc.w	$7c0f,$fffe,$108,-64,$10a,-64
	dc.w	$7d0f,$fffe,$108,$c0,$10a,$c0
	dc.w	$7e0f,$fffe,$108,-64,$10a,-64
	dc.w	$7f0f,$fffe,$108,$c0,$10a,$c0
	dc.w	$800f,$fffe,$108,-64,$10a,-64
	dc.w	$810f,$fffe,$108,$c0,$10a,$c0

	dc.w	$820f,$fffe,$108,-64,$10a,-64
	dc.w	$830f,$fffe,$108,$c0,$10a,$c0
	dc.w	$840f,$fffe,$108,-64,$10a,-64
	dc.w	$850f,$fffe,$108,$c0,$10a,$c0
	dc.w	$860f,$fffe,$108,-64,$10a,-64
	dc.w	$870f,$fffe,$108,$c0,$10a,$c0
	dc.w	$880f,$fffe,$108,-64,$10a,-64
	dc.w	$890f,$fffe,$108,$c0,$10a,$c0
	dc.w	$8a0f,$fffe,$108,-64,$10a,-64
	dc.w	$8b0f,$fffe,$108,$c0,$10a,$c0
	dc.w	$8c0f,$fffe,$108,-64,$10a,-64
	dc.w	$8d0f,$fffe,$108,$c0,$10a,$c0
	dc.w	$8e0f,$fffe,$108,-64,$10a,-64
	dc.w	$8f0f,$fffe,$108,$c0,$10a,$c0
	dc.w	$900f,$fffe,$108,-64,$10a,-64
	dc.w	$910f,$fffe,$108,$c0,$10a,$c0
	dc.w	$920f,$fffe,$108,-64,$10a,-64
	dc.w	$930f,$fffe,$108,$c0,$10a,$c0
	dc.w	$940f,$fffe,$108,-64,$10a,-64
	dc.w	$950f,$fffe,$108,$c0,$10a,$c0
	dc.w	$960f,$fffe,$108,-64,$10a,-64
	dc.w	$970f,$fffe,$108,$c0,$10a,$c0
	dc.w	$980f,$fffe,$108,-64,$10a,-64
	dc.w	$990f,$fffe,$108,$c0,$10a,$c0
	dc.w	$9a0f,$fffe,$108,-64,$10a,-64
	dc.w	$9b0f,$fffe,$108,$c0,$10a,$c0
	dc.w	$9c0f,$fffe,$108,-64,$10a,-64
	dc.w	$9d0f,$fffe,$108,$c0,$10a,$c0
	dc.w	$9e0f,$fffe,$108,-64,$10a,-64
	dc.w	$9f0f,$fffe,$108,$c0,$10a,$c0
	dc.w	$a00f,$fffe,$108,-64,$10a,-64
	dc.w	$a10f,$fffe,$108,$c0,$10a,$c0
	dc.w	$a20f,$fffe,$108,-64,$10a,-64
	dc.w	$a30f,$fffe,$108,$c0,$10a,$c0
	dc.w	$a40f,$fffe,$108,-64,$10a,-64
	dc.w	$a50f,$fffe,$108,$c0,$10a,$c0
	dc.w	$a60f,$fffe,$108,-64,$10a,-64
	dc.w	$a70f,$fffe,$108,$c0,$10a,$c0
	dc.w	$a80f,$fffe,$108,-64,$10a,-64
	dc.w	$a90f,$fffe,$108,$c0,$10a,$c0
	dc.w	$aa0f,$fffe,$108,-64,$10a,-64
	dc.w	$ab0f,$fffe,$108,$c0,$10a,$c0
	dc.w	$ac0f,$fffe,$108,-64,$10a,-64
	dc.w	$ad0f,$fffe,$108,$c0,$10a,$c0
	dc.w	$ae0f,$fffe,$108,-64,$10a,-64
	dc.w	$af0f,$fffe,$108,$c0,$10a,$c0
	dc.w	$b00f,$fffe,$108,-64,$10a,-64
	dc.w	$b10f,$fffe,$108,$c0,$10a,$c0
	dc.w	$b20f,$fffe,$108,-64,$10a,-64
	dc.w	$b30f,$fffe,$108,$c0,$10a,$c0
	dc.w	$b40f,$fffe,$108,-64,$10a,-64
	dc.w	$b50f,$fffe,$108,$c0,$10a,$c0
	dc.w	$b60f,$fffe,$108,-64,$10a,-64
	dc.w	$b70f,$fffe,$108,$c0,$10a,$c0
	dc.w	$b80f,$fffe,$108,-64,$10a,-64
	dc.w	$b90f,$fffe,$108,$c0,$10a,$c0
	dc.w	$ba0f,$fffe,$108,-64,$10a,-64
	dc.w	$bb0f,$fffe,$108,$c0,$10a,$c0
	dc.w	$bc0f,$fffe,$108,-64,$10a,-64
	dc.w	$bd0f,$fffe,$108,$c0,$10a,$c0
	dc.w	$be0f,$fffe,$108,-64,$10a,-64
	dc.w	$bf0f,$fffe,$108,$c0,$10a,$c0
	dc.w	$c00f,$fffe,$108,-64,$10a,-64
	dc.w	$c10f,$fffe,$108,$c0,$10a,$c0
	dc.w	$c20f,$fffe,$108,-64,$10a,-64
	dc.w	$c30f,$fffe,$108,$c0,$10a,$c0
	dc.w	$c40f,$fffe,$108,-64,$10a,-64
	dc.w	$c50f,$fffe,$108,$c0,$10a,$c0
	dc.w	$c60f,$fffe,$108,-64,$10a,-64
	dc.w	$c70f,$fffe,$108,$c0,$10a,$c0
	dc.w	$c80f,$fffe,$108,-64,$10a,-64
	dc.w	$c90f,$fffe,$108,$c0,$10a,$c0
	dc.w	$ca0f,$fffe,$108,-64,$10a,-64
	dc.w	$cb0f,$fffe,$108,$c0,$10a,$c0
	dc.w	$cc0f,$fffe,$108,-64,$10a,-64
	dc.w	$cd0f,$fffe,$108,$c0,$10a,$c0
	dc.w	$ce0f,$fffe,$108,-64,$10a,-64
	dc.w	$cf0f,$fffe,$108,$c0,$10a,$c0

	dc.l	-2
Coords:	blk.w	2*100,0	;2 words X,Y * nb de points

Pic:	incbin	'RawB.Tigre'

ecr1:	blk.b	64*4*51,0
ecr2:	blk.b	64*4*51,0

finintro:
