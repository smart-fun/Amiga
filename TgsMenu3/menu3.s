; LAST MENU AD$35000
; CODED BY RITCHY
; CHERCHER 'CHANGER' POUR VOIR LES MODIFICATIONS
; (lchanger)

ORG$35000
LOAD$35000

>EXTERN "FOONTS",FONTS
>EXTERN "SP0",SPRITE0
>EXTERN "SP2",SPRITE2
>EXTERN "SP4",SPRITE4
>EXTERN "MENU",PAGE
>extern "fc13.shaolin-1",module

FORBID   = -132
PERMIT   = -138
OPENLIB  = -408
CLOSELIB = -414

BPL1 = $60000
TAILLEBPL = 44*256

R:	movem.l	d0-d7/a0-a6,-(a7)
	move.l	4.w,a6
	jsr	forbid(a6)
	lea	gfxname(pc),a1
	jsr	openlib(a6)
	move.l	d0,gfxbase

	lea	bpl1,a0
	move.w	#taillebpl/4*5-1,d0
efface:	clr.l	(a0)+
	dbf	d0,efface

	move.l	gfxbase(pc),a0
	move.l	$32(a0),savecl
	move.l	#ncl,$32(a0)

	bsr.l	repointe
	bsr.l	affpage
	bsr.l	init_music
	bsr.l	affops
main2:	bsr.l	font
	moveq.l	#4-1,d7
	addq.l	#1,ptexte
	cmp.l	#fintexte,ptexte
	blo.s	main
	move.l	#texte,ptexte

main:	cmp.b	#125,$dff006
	blo.s	main
	bsr.l	movestars
	bsr.l	wait
	move.l	d7,saved7
	bsr.l	play
	move.l	saved7,d7
	bsr.l	mouse
	bsr.l	scroll
	cmp.b	#$77,$bfec01
	beq	fin
	move.b	#0,$bfec01
dbf	d7,main
bra main2


wait:	move.l	#5000,d0
wi:	dbf	d0,wi
rts

fin:
	move.l	gfxbase(pc),a0
	move.l	savecl(pc),$32(a0)
	move.l	4.w,a6
	move.l	gfxbase(pc),a1
	jsr	closelib(a6)
	jsr	permit(a6)
	bsr.l	end_music
exec:
	move.l	option(pc),d0
	subq.l	#1,d0
	lea	options(pc),a0
cherche_la_good:
	cmp.b	#0,(a0)+
	bne.s	cherche_la_good
dbra d0,cherche_la_good
	move.b (a0),d4
	move.l	a0,option
	movem.l	(a7)+,d0-d7/a0-a6
rts	;CHANGER: virer le rts avant d'assembler!
	; et virer le movem.l ci-dessus !!!!!!!!!
	move.l	4.w,a6
	lea	dosname,a1
	jsr	openlib(a6)
	move.l	d0,dosbase
	
	move.l	d0,a6
	move.l	option(pc),d1
	moveq.l	#$00000000,d2
	moveq.l	#$00000000,d3
	jsr	-222(a6)
	
	move.l	4.w,a6
	move.l	dosbase(pc),a1
	jsr	closelib(a6)
	movem.l	(a7)+,d0-d7/a0-a6
rts

mouse:
	cmpi.b	#$63,$bfec01
	beq	droite
	cmpi.b	#$61,$bfec01
	beq	gauche
	cmpi.b	#$65,$bfec01
	beq	descends
	cmpi.b	#$67,$bfec01
	beq	monte
rts

descends:
	lea	finselop-12,a0
	cmp.w	#$f800,(a0)
	blo	okd
rts
okd:
	moveq.l	#20-1,d0
movedown:
	add.w	#$900,(a0)
	sub.l	#12,a0
dbf d0,movedown
	addq.l	#1,option
rts

monte:
	lea	selop,a0
	cmp.w	#$8d00,(a0)
	bhi	okm
rts	
okm:
	moveq.l	#20-1,d0
moveup:
	sub.w	#$900,(a0)
	add.l	#12,a0
dbf d0,moveup
	subq.l	#1,option
rts

gauche:
	lea	selop+1,a0
	lea	selop+13,a1
	moveq.l	#10-1,d0
	cmp.b	#$0f,(a0)
	bne	ag
rts
ag:
	sub.l	#13,option
allezg:
	move.b	#$0f,(a0)
	move.b	#$8d,(a1)
	add.l	#24,a0
	add.l	#24,a1
dbf d0,allezg
rts

droite:
	lea	selop+1,a0
	lea	selop+13,a1
	moveq.l	#10-1,d0
	cmp.b	#$8d,(a0)
	bne	ad
rts
ad:
	add.l	#13,option
allezd:
	move.b	#$8d,(a0)
	move.b	#$fd,(a1)
	add.l	#24,a0
	add.l	#24,a1
dbf d0,allezd
rts

font:	lea	$62a9c,a0
	lea	table(pc),a2
	move.l	ptexte(pc),a1
	moveq.l	#0,d1
	moveq.l	#0,d2
	move.b	(a1),d1
gaguesagogo:
	move.w	(a2),d2
	cmp.b	d1,d2
	beq	ok
	addq.l	#4,a2
bra gaguesagogo

scroll:	lea	$62a74,a0
	lea	$dff000,a5
vazy:	btst	#14,2(a5)
	bne.s	vazy
	move.l	#$ffffffff,$44(a5)
	move.l	#$e9f00000,$40(a5)
	move.l	#0,$64(a5)
	move.l	a0,$50(a5)
	subq.l	#2,a0
	move.l	a0,$54(a5)
	move.w	#$216,$58(a5)
rts

ok:	move.w	2(a2),a3
	add.l	#fonts,a3
	moveq.l	#8-1,d1
papajetaitrouve:
	move.b	(a3),d3
	move.b	d3,(a0)
	move.b	#0,1(a0)
	add.l	#44,a0
	add.l	#40,a3
dbf d1,papajetaitrouve
rts

affpage:
	lea	page(pc),a0
	lea	$60000,a1
	moveq.l	#2-1,d0
	lea	$dff000,a5
affit:
	btst	#14,2(a5)
	bne.s	affit
	move.l	#$ffffffff,$44(a5)
	move.l	#$09f00000,$40(a5)
	move.l	#$00000004,$64(a5)
	move.l	a0,$50(a5)
	move.l	a1,$54(a5)
	move.w	#$1654,$58(a5)
	add.l	#40*89,a0
	add.l	#$2c00,a1
dbf	d0,affit
rts

affops:
	lea	txtops(pc),a0
	move.l	nlignes(pc),d0
affthem:
	move.l	(a0)+,a1
	bsr.l	printops
dbf d0,affthem
rts

printops:
	lea	table(pc),a2
	moveq.l	#0,d1
	move.b	(a0),d1
bouboucle:
	moveq.l	#0,d2
	move.w	(a2)+,d2
	cmp.w	d1,d2
	beq	etcestparti
	addq.l	#2,a2
	bra	bouboucle
etcestparti:
	lea	fonts(pc),a3
	add.w	(a2),a3
	moveq.l	#8-1,d1
chaos:
	move.b	(a3),(a1)
	add.l	#44,a1
	add.l	#40,a3
dbf d1,chaos
	cmp.b	#0,(a0)
	beq lignefinie
	sub.l	#[44*8]-1,a1
	add.l	#1,a0
	bra printops
lignefinie:
	add.l	#1,a0
rts


repointe:
	lea	sprt+2(pc),a1
	lea	sprite0(pc),a0
	bsr.l	swapem
	lea	sprite2(pc),a0
	bsr.l	swapem
	lea	sprite4(pc),a0
	bsr.l	swapem
rts

swapem:	move.l	a0,d0
	move.w	d0,4(a1)
	swap	d0
	move.w	d0,(a1)
	addq.l	#8,a1
rts

movestars:
	lea	sprite0(pc),a0
	lea	sprite2(pc),a2
	lea	sprite4(pc),a4
	move.l	#320-1,d0
moove:	moveq.l	#0,d1
	move.w	(a0),d1
	addq.b	#1,d1
	move.w	d1,(a0)
	moveq.l	#0,d1
	move.w	(a2),d1
	adda.b	#1,d1
	move.w	d1,(a2)
	moveq.l	#0,d1
	move.w	(a4),d1
	addq.b	#2,d1
	move.w	d1,(a4)
	addq.l	#8,a0
	addq.l	#8,a2
	addq.l	#8,a4
dbf d0,moove
rts
END_MUSIC:
clr.w onoff
clr.l $dff0a6
clr.l $dff0b6
clr.l $dff0c6
clr.l $dff0d6
move.w #$000f,$dff096
bclr #1,$bfe001
rts

INIT_MUSIC:
move.w #1,onoff
bset #1,$bfe001
lea MODULE,a0
lea 100(a0),a1
move.l a1,SEQpoint
move.l a0,a1
add.l 8(a0),a1
move.l a1,PATpoint
move.l a0,a1
add.l 16(a0),a1
move.l a1,FRQpoint
move.l a0,a1
add.l 24(a0),a1
move.l a1,VOLpoint
move.l 4(a0),d0
divu #13,d0

lea 40(a0),a1
lea SOUNDINFO+4(pc),a2
moveq #10-1,d1
initloop:
move.w (a1)+,(a2)+
move.l (a1)+,(a2)+
addq.w #4,a2
dbf d1,initloop
moveq #0,d2
move.l a0,d1
add.l 32(a0),d1
sub.l #WAVEFORMS,d1
lea SOUNDINFO(pc),a0
move.l d1,(a0)+
moveq #9-1,d3
initloop1:
move.w (a0),d2
add.l d2,d1
add.l d2,d1
addq.w #6,a0
move.l d1,(a0)+
dbf d3,initloop1

move.l SEQpoint(pc),a0
moveq #0,d2
move.b 12(a0),d2		;Get replay speed
bne.s speedok
move.b #3,d2			;Set default speed
speedok:
move.w d2,respcnt		;Init repspeed counter
move.w d2,repspd
INIT2:
clr.w audtemp
move.w #$000f,$dff096		;Disable audio DMA
move.w #$0780,$dff09a		;Disable audio IRQ
moveq #0,d7
mulu #13,d0
moveq #4-1,d6			;Number of soundchannels-1
lea V1data(pc),a0		;Point to 1st voice data area
lea silent(pc),a1
lea o4a0c8(pc),a2
initloop2:
move.l a1,10(a0)
move.l a1,18(a0)
clr.l 14(a0)
clr.b 45(a0)
clr.b 47(a0)
clr.w 8(a0)
clr.l 48(a0)
move.b #$01,23(a0)
move.b #$01,24(a0)
clr.b 25(a0)
clr.l 26(a0)
clr.w 30(a0)
moveq #$00,d3
move.w (a2)+,d1
move.w (a2)+,d3
divu #$0003,d3
move.b d3,32(a0)
mulu #$0003,d3
andi.l #$00ff,d3
andi.l #$00ff,d1
addi.l #$dff0a0,d1
move.l d1,a6
move.l #$0000,(a6)
move.w #$0100,4(a6)
move.w #$0000,6(a6)
move.w #$0000,8(a6)
move.l d1,60(a0)
clr.w 64(a0)
move.l SEQpoint(pc),(a0)
move.l SEQpoint(pc),52(a0)
add.l d0,52(a0)
add.l d3,52(a0)
add.l d7,(a0)
add.l d3,(a0)
move.w #$000d,6(a0)
move.l (a0),a3
move.b (a3),d1
andi.l #$00ff,d1
lsl.w #6,d1
move.l PATpoint(pc),a4
adda.w d1,a4
move.l a4,34(a0)
clr.l 38(a0)
move.b #$01,33(a0)
move.b #$02,42(a0)
move.b 1(a3),44(a0)
move.b 2(a3),22(a0)
clr.b 43(a0)
clr.b 45(a0)
clr.w 56(a0)
adda.w #$004a,a0	;Point to next voice's data area
dbf d6,initloop2
rts


PLAY:
lea pervol(pc),a6
tst.w onoff
bne.s music_on
rts
music_on:
subq.w #1,respcnt		;Decrease replayspeed counter
bne.s nonewnote
move.w repspd(pc),respcnt	;Restore replayspeed counter
lea V1data(pc),a0		;Point to voice1 data area
bsr.L new_note
lea V2data(pc),a0		;Point to voice2 data area
bsr.L new_note
lea V3data(pc),a0		;Point to voice3 data area
bsr.L new_note
lea V4data(pc),a0		;Point to voice4 data area
bsr.L new_note
nonewnote:
clr.w audtemp
lea V1data(pc),a0
bsr.L effects
move.w d0,(a6)+
move.w d1,(a6)+
lea V2data(pc),a0
bsr.L effects
move.w d0,(a6)+
move.w d1,(a6)+
lea V3data(pc),a0
bsr.L effects
move.w d0,(a6)+
move.w d1,(a6)+
lea V4data(pc),a0
bsr.L effects
move.w d0,(a6)+
move.w d1,(a6)+
lea pervol(pc),a6
move.w audtemp(pc),d0
ori.w #$8000,d0			;Set/clr bit = 1
move.w d0,-(a7)
moveq #0,d1
move.l start1(pc),d2		;Get samplepointers
move.w offset1(pc),d1		;Get offset
add.l d1,d2			;Add offset
move.l start2(pc),d3
move.w offset2(pc),d1
add.l d1,d3
move.l start3(pc),d4
move.w offset3(pc),d1
add.l d1,d4
move.l start4(pc),d5
move.w offset4(pc),d1
add.l d1,d5
move.w ssize1(pc),d0		;Get sound lengths
move.w ssize2(pc),d1
move.w ssize3(pc),d6
move.w ssize4(pc),d7
move.w (a7)+,$dff096		;Enable audio DMA
chan1:
lea V1data(pc),a0
tst.w 72(a0)
beq.l chan2
subq.w #1,72(a0)
cmpi.w #1,72(a0)
bne.s chan2
clr.w 72(a0)
move.l d2,$dff0a0		;Set soundstart
move.w d0,$dff0a4		;Set soundlength
chan2:
lea V2data(pc),a0
tst.w 72(a0)
beq.s chan3
subq.w #1,72(a0)
cmpi.w #1,72(a0)
bne.s chan3
clr.w 72(a0)
move.l d3,$dff0b0
move.w d1,$dff0b4
chan3:
lea V3data(pc),a0
tst.w 72(a0)
beq.s chan4
subq.w #1,72(a0)
cmpi.w #1,72(a0)
bne.s chan4
clr.w 72(a0)
move.l d4,$dff0c0
move.w d6,$dff0c4
chan4:
lea V4data(pc),a0
tst.w 72(a0)
beq.s setpervol
subq.w #1,72(a0)
cmpi.w #1,72(a0)
bne.s setpervol
clr.w 72(a0)
move.l d5,$dff0d0
move.w d7,$dff0d4
setpervol:
lea $dff0a6,a5
move.w (a6)+,(a5)	;Set period
move.w (a6)+,2(a5)	;Set volume
move.w (a6)+,16(a5)
move.w (a6)+,18(a5)
move.w (a6)+,32(a5)
move.w (a6)+,34(a5)
move.w (a6)+,48(a5)
move.w (a6)+,50(a5)
rts

NEW_NOTE:
moveq #0,d5
move.l 34(a0),a1
adda.w 40(a0),a1
cmp.w #64,40(a0)
bne.L samepat
move.l (a0),a2
adda.w 6(a0),a2		;Point to next sequence row
cmpa.l 52(a0),a2	;Is it the end?
bne.s notend
move.w d5,6(a0)		;yes!
move.l (a0),a2		;Point to first sequence
notend:
moveq #0,d1
addq.b #1,spdtemp
cmpi.b #4,spdtemp
bne.s nonewspd
move.b d5,spdtemp
move.b -1(a1),d1	;Get new replay speed
beq.s nonewspd
move.w d1,respcnt	;store in counter
move.w d1,repspd
nonewspd:
move.b (a2),d1		;Pattern to play
move.b 1(a2),44(a0)	;Transpose value
move.b 2(a2),22(a0)	;Soundtranspose value

move.w d5,40(a0)
lsl.w #6,d1
add.l PATpoint(pc),d1	;Get pattern pointer
move.l d1,34(a0)
addi.w #$000d,6(a0)
move.l d1,a1
samepat:
move.b 1(a1),d1		;Get info byte
move.b (a1)+,d0		;Get note
bne.s ww1
andi.w #%11000000,d1
beq.s noport
bra.s ww11
ww1:
move.w d5,56(a0)
ww11:
move.b d5,47(a0)
move.b (a1),31(a0)

		;31(a0) = PORTAMENTO/INSTR. info
			;Bit 7 = portamento on
			;Bit 6 = portamento off
			;Bit 5-0 = instrument number
		;47(a0) = portamento value
			;Bit 7-5 = always zero
			;Bit 4 = up/down
			;Bit 3-0 = value
t_porton:
btst #7,d1
beq.s noport
move.b 2(a1),47(a0)	
noport:
andi.w #$007f,d0
beq.L nextnote
move.b d0,8(a0)
move.b (a1),9(a0)
move.b 32(a0),d2
moveq #0,d3
bset d2,d3
or.w d3,audtemp
move.w d3,$dff096
move.b (a1),d1
andi.w #$003f,d1	;Max 64 instruments
add.b 22(a0),d1
move.l VOLpoint(pc),a2
lsl.w #6,d1
adda.w d1,a2
move.w d5,16(a0)
move.b (a2),23(a0)
move.b (a2)+,24(a0)
move.b (a2)+,d1
andi.w #$00ff,d1
move.b (a2)+,27(a0)
move.b #$40,46(a0)
move.b (a2)+,d0
move.b d0,28(a0)
move.b d0,29(a0)
move.b (a2)+,30(a0)
move.l a2,10(a0)
move.l FRQpoint(pc),a2
lsl.w #6,d1
adda.w d1,a2
move.l a2,18(a0)
move.w d5,50(a0)
move.b d5,26(a0)
move.b d5,25(a0)
nextnote:
addq.w #2,40(a0)
rts

EFFECTS:
moveq #0,d7
testsustain:
tst.b 26(a0)		;Is sustain counter = 0
beq.s sustzero
subq.b #1,26(a0)	;if no, decrease counter
bra.L VOLUfx
sustzero:		;Next part of effect sequence
move.l 18(a0),a1	;can be executed now.
adda.w 50(a0),a1
testeffects:
cmpi.b #$e1,(a1)	;E1 = end of FREQseq sequence
beq.L VOLUfx
cmpi.b #$e0,(a1)	;E0 = loop to other part of sequence
bne.s testnewsound
move.b 1(a1),d0		;loop to start of sequence + 1(a1)
andi.w #$003f,d0
move.w d0,50(a0)
move.l 18(a0),a1
adda.w d0,a1
testnewsound:
cmpi.b #$e2,(a1)	;E2 = set waveform
bne.s o49c64
moveq #0,d0
moveq #0,d1
move.b 32(a0),d1
bset d1,d0
or.w d0,audtemp
move.w d0,$dff096
move.b 1(a1),d0
andi.w #$00ff,d0
lea SOUNDINFO(pc),a4
add.w d0,d0
move.w d0,d1
add.w d1,d1
add.w d1,d1
add.w d1,d0
adda.w d0,a4
move.l 60(a0),a3
move.l (a4),d1
add.l #WAVEFORMS,d1
move.l d1,(a3)
move.l d1,68(a0)
move.w 4(a4),4(a3)
move.l 6(a4),64(a0)
swap d1
move.w #$0003,72(a0)
tst.w d1
bne.s o49c52
move.w #$0002,72(a0)
o49c52:
clr.w 16(a0)
move.b #$01,23(a0)
addq.w #2,50(a0)
bra.L o49d02
o49c64:
cmpi.b #$e4,(a1)
bne.s testpatjmp
move.b 1(a1),d0
andi.w #$00ff,d0
lea SOUNDINFO(pc),a4
add.w d0,d0
move.w d0,d1
add.w d1,d1
add.w d1,d1
add.w d1,d0
adda.w d0,a4
move.l 60(a0),a3
move.l (a4),d1
add.l #WAVEFORMS,d1
move.l d1,(a3)
move.l d1,68(a0)
move.w 4(a4),4(a3)
move.l 6(a4),64(a0)

swap d1
move.w #$0003,72(a0)
tst.w d1
bne.s o49cae
move.w #$0002,72(a0)
o49cae:
addq.w #2,50(a0)
bra.s o49d02
testpatjmp:
cmpi.b #$e7,(a1)
bne.s testnewsustain
move.b 1(a1),d0
andi.w #$00ff,d0
lsl.w #6,d0
move.l FRQpoint(pc),a1
adda.w d0,a1
move.l a1,18(a0)
move.w d7,50(a0)
bra.L testeffects
testnewsustain:
cmpi.b #$e8,(a1)	;E8 = set sustain time
bne.s o49cea
move.b 1(a1),26(a0)
addq.w #2,50(a0)
bra.L testsustain
o49cea:
cmpi.b #$e3,(a1)
bne.s o49d02
addq.w #3,50(a0)
move.b 1(a1),27(a0)
move.b 2(a1),28(a0)
o49d02:
move.l 18(a0),a1
adda.w 50(a0),a1
move.b (a1),43(a0)
addq.w #1,50(a0)
VOLUfx:
tst.b 25(a0)
beq.s o49d1e
subq.b #1,25(a0)
bra.s o49d70
o49d1e:
subq.b #1,23(a0)
bne.s o49d70
move.b 24(a0),23(a0)
o49d2a:
move.l 10(a0),a1
adda.w 16(a0),a1
move.b (a1),d0
cmpi.b #$e8,d0
bne.s o49d4a
addq.w #2,16(a0)
move.b 1(a1),25(a0)
bra.s VOLUfx
o49d4a:
cmpi.b #$e1,d0
beq.s o49d70
cmpi.b #$e0,d0
bne.s o49d68
move.b 1(a1),d0
andi.l #$003f,d0
subq.b #5,d0
move.w d0,16(a0)
bra.s o49d2a
o49d68:
move.b (a1),45(a0)
addq.w #1,16(a0)
o49d70:
move.b 43(a0),d0
bmi.s o49d7e
add.b 8(a0),d0
add.b 44(a0),d0
o49d7e:
andi.w #$007f,d0
lea PERIODS(pc),a1
add.w d0,d0
move.w d0,d1
adda.w d0,a1
move.w (a1),d0
move.b 46(a0),d7
tst.b 30(a0)
beq.s o49d9e
subq.b #1,30(a0)

bra.s o49df4
o49d9e:
move.b d1,d5
move.b 28(a0),d4
add.b d4,d4
move.b 29(a0),d1
tst.b d7
bpl.s o49db4
btst #0,d7
bne.s o49dda
o49db4:
btst #5,d7
bne.s o49dc8
sub.b 27(a0),d1
bcc.s o49dd6
bset #5,d7
moveq #0,d1
bra.s o49dd6
o49dc8:
add.b 27(a0),d1
cmp.b d4,d1
bcs.s o49dd6
bclr #5,d7
move.b d4,d1
o49dd6:
move.b d1,29(a0)
o49dda:
lsr.b #1,d4
sub.b d4,d1
bcc.s o49de4
subi.w #$0100,d1
o49de4:
addi.b #$a0,d5
bcs.s o49df2
o49dea:
add.w d1,d1
addi.b #$18,d5
bcc.s o49dea
o49df2:
add.w d1,d0
o49df4:
eori.b #$01,d7
move.b d7,46(a0)

; DO THE PORTAMENTO THING
moveq #0,d1
move.b 47(a0),d1	;get portavalue
beq.s a56d0		;0=no portamento
cmpi.b #$1f,d1
bls.s portaup
portadown: 
andi.w #$1f,d1
neg.w d1
portaup:
sub.w d1,56(a0)
a56d0:
add.w 56(a0),d0
o49e3e:
cmpi.w #$0070,d0
bhi.s nn1
move.w #$0071,d0
nn1:
cmpi.w #$06b0,d0
bls.s nn2
move.w #$06b0,d0
nn2:
moveq #0,d1
move.b 45(a0),d1
rts



pervol: blk.b 16,0	;Periods & Volumes temp. store
respcnt: dc.w 0		;Replay speed counter 
repspd:  dc.w 0		;Replay speed counter temp
onoff:   dc.w 0		;Music on/off flag.
firseq:	 dc.w 0		;First sequence
lasseq:	 dc.w 0		;Last sequence
audtemp: dc.w 0
spdtemp: dc.w 0

V1data:  blk.b 64,0	;Voice 1 data area
offset1: blk.b 02,0	;Is added to start of sound
ssize1:  blk.b 02,0	;Length of sound
start1:  blk.b 06,0	;Start of sound

V2data:  blk.b 64,0	;Voice 2 data area
offset2: blk.b 02,0
ssize2:  blk.b 02,0
start2:  blk.b 06,0

V3data:  blk.b 64,0	;Voice 3 data area
offset3: blk.b 02,0
ssize3:  blk.b 02,0
start3:  blk.b 06,0

V4data:  blk.b 64,0	;Voice 4 data area
offset4: blk.b 02,0
ssize4:  blk.b 02,0
start4:  blk.b 06,0

o4a0c8: dc.l $00000000,$00100003,$00200006,$00300009
SEQpoint: dc.l 0
PATpoint: dc.l 0
FRQpoint: dc.l 0
VOLpoint: dc.l 0


even
SILENT: dc.w $0100,$0000,$0000,$00e1

PERIODS:dc.w $06b0,$0650,$05f4,$05a0,$054c,$0500,$04b8,$0474
	dc.w $0434,$03f8,$03c0,$038a,$0358,$0328,$02fa,$02d0
	dc.w $02a6,$0280,$025c,$023a,$021a,$01fc,$01e0,$01c5
	dc.w $01ac,$0194,$017d,$0168,$0153,$0140,$012e,$011d
	dc.w $010d,$00fe,$00f0,$00e2,$00d6,$00ca,$00be,$00b4
	dc.w $00aa,$00a0,$0097,$008f,$0087,$007f,$0078,$0071
	dc.w $0071,$0071,$0071,$0071,$0071,$0071,$0071,$0071
	dc.w $0071,$0071,$0071,$0071,$0d60,$0ca0,$0be8,$0b40
	dc.w $0a98,$0a00,$0970,$08e8,$0868,$07f0,$0780,$0714
	dc.w $1ac0,$1940,$17d0,$1680,$1530,$1400,$12e0,$11d0
	dc.w $10d0,$0fe0,$0f00,$0e28

SOUNDINFO:
;Offset.l , Sound-length.w , Start-offset.w , Repeat-length.w 

;Reserved for samples
	dc.w $0000,$0000 ,$0000 ,$0000 ,$0001 
	dc.w $0000,$0000 ,$0000 ,$0000 ,$0001 
	dc.w $0000,$0000 ,$0000 ,$0000 ,$0001 
	dc.w $0000,$0000 ,$0000 ,$0000 ,$0001 
	dc.w $0000,$0000 ,$0000 ,$0000 ,$0001 
	dc.w $0000,$0000 ,$0000 ,$0000 ,$0001 
	dc.w $0000,$0000 ,$0000 ,$0000 ,$0001 
	dc.w $0000,$0000 ,$0000 ,$0000 ,$0001 
	dc.w $0000,$0000 ,$0000 ,$0000 ,$0001 
	dc.w $0000,$0000 ,$0000 ,$0000 ,$0001 
;Reserved for synth sounds
	dc.w $0000,$0000 ,$0010 ,$0000 ,$0010 
	dc.w $0000,$0020 ,$0010 ,$0000 ,$0010 
	dc.w $0000,$0040 ,$0010 ,$0000 ,$0010 
	dc.w $0000,$0060 ,$0010 ,$0000 ,$0010 
	dc.w $0000,$0080 ,$0010 ,$0000 ,$0010 
	dc.w $0000,$00a0 ,$0010 ,$0000 ,$0010 
	dc.w $0000,$00c0 ,$0010 ,$0000 ,$0010 
	dc.w $0000,$00e0 ,$0010 ,$0000 ,$0010 
	dc.w $0000,$0100 ,$0010 ,$0000 ,$0010 
	dc.w $0000,$0120 ,$0010 ,$0000 ,$0010 
	dc.w $0000,$0140 ,$0010 ,$0000 ,$0010 
	dc.w $0000,$0160 ,$0010 ,$0000 ,$0010 
	dc.w $0000,$0180 ,$0010 ,$0000 ,$0010 
	dc.w $0000,$01a0 ,$0010 ,$0000 ,$0010 
	dc.w $0000,$01c0 ,$0010 ,$0000 ,$0010 
	dc.w $0000,$01e0 ,$0010 ,$0000 ,$0010 
	dc.w $0000,$0200 ,$0010 ,$0000 ,$0010 
	dc.w $0000,$0220 ,$0010 ,$0000 ,$0010 
	dc.w $0000,$0240 ,$0010 ,$0000 ,$0010 
	dc.w $0000,$0260 ,$0010 ,$0000 ,$0010 
	dc.w $0000,$0280 ,$0010 ,$0000 ,$0010 
	dc.w $0000,$02a0 ,$0010 ,$0000 ,$0010 
	dc.w $0000,$02c0 ,$0010 ,$0000 ,$0010 
	dc.w $0000,$02e0 ,$0010 ,$0000 ,$0010 
	dc.w $0000,$0300 ,$0010 ,$0000 ,$0010 
	dc.w $0000,$0320 ,$0010 ,$0000 ,$0010 
	dc.w $0000,$0340 ,$0010 ,$0000 ,$0010 
	dc.w $0000,$0360 ,$0010 ,$0000 ,$0010 
	dc.w $0000,$0380 ,$0010 ,$0000 ,$0010 
	dc.w $0000,$03a0 ,$0010 ,$0000 ,$0010 
	dc.w $0000,$03c0 ,$0010 ,$0000 ,$0010 
	dc.w $0000,$03e0 ,$0010 ,$0000 ,$0010 
	dc.w $0000,$0400 ,$0008 ,$0000 ,$0008 
	dc.w $0000,$0410 ,$0008 ,$0000 ,$0008 
	dc.w $0000,$0420 ,$0008 ,$0000 ,$0008 
	dc.w $0000,$0430 ,$0008 ,$0000 ,$0008 
	dc.w $0000,$0440 ,$0008 ,$0000 ,$0008
	dc.w $0000,$0450 ,$0008 ,$0000 ,$0008
	dc.w $0000,$0460 ,$0008 ,$0000 ,$0008
	dc.w $0000,$0470 ,$0008 ,$0000 ,$0008
	dc.w $0000,$0480 ,$0010 ,$0000 ,$0010
	dc.w $0000,$04a0 ,$0008 ,$0000 ,$0008
	dc.w $0000,$04b0 ,$0010 ,$0000 ,$0010
	dc.w $0000,$04d0 ,$0010 ,$0000 ,$0010
	dc.w $0000,$04f0 ,$0008 ,$0000 ,$0008
	dc.w $0000,$0500 ,$0008 ,$0000 ,$0008
	dc.w $0000,$0510 ,$0018 ,$0000 ,$0018
 

WAVEFORMS:
dc.w $c0c0,$d0d8,$e0e8,$f0f8,$00f8,$f0e8,$e0d8,$d0c8
dc.w $3f37,$2f27,$1f17,$0f07,$ff07,$0f17,$1f27,$2f37
dc.w $c0c0,$d0d8,$e0e8,$f0f8,$00f8,$f0e8,$e0d8,$d0c8
dc.w $c037,$2f27,$1f17,$0f07,$ff07,$0f17,$1f27,$2f37
dc.w $c0c0,$d0d8,$e0e8,$f0f8,$00f8,$f0e8,$e0d8,$d0c8
dc.w $c0b8,$2f27,$1f17,$0f07,$ff07,$0f17,$1f27,$2f37
dc.w $c0c0,$d0d8,$e0e8,$f0f8,$00f8,$f0e8,$e0d8,$d0c8
dc.w $c0b8,$b027,$1f17,$0f07,$ff07,$0f17,$1f27,$2f37
dc.w $c0c0,$d0d8,$e0e8,$f0f8,$00f8,$f0e8,$e0d8,$d0c8
dc.w $c0b8,$b0a8,$1f17,$0f07,$ff07,$0f17,$1f27,$2f37
dc.w $c0c0,$d0d8,$e0e8,$f0f8,$00f8,$f0e8,$e0d8,$d0c8
dc.w $c0b8,$b0a8,$a017,$0f07,$ff07,$0f17,$1f27,$2f37
dc.w $c0c0,$d0d8,$e0e8,$f0f8,$00f8,$f0e8,$e0d8,$d0c8
dc.w $c0b8,$b0a8,$a098,$0f07,$ff07,$0f17,$1f27,$2f37
dc.w $c0c0,$d0d8,$e0e8,$f0f8,$00f8,$f0e8,$e0d8,$d0c8
dc.w $c0b8,$b0a8,$a098,$9007,$ff07,$0f17,$1f27,$2f37
dc.w $c0c0,$d0d8,$e0e8,$f0f8,$00f8,$f0e8,$e0d8,$d0c8
dc.w $c0b8,$b0a8,$a098,$9088,$ff07,$0f17,$1f27,$2f37
dc.w $c0c0,$d0d8,$e0e8,$f0f8,$00f8,$f0e8,$e0d8,$d0c8
dc.w $c0b8,$b0a8,$a098,$9088,$8007,$0f17,$1f27,$2f37
dc.w $c0c0,$d0d8,$e0e8,$f0f8,$00f8,$f0e8,$e0d8,$d0c8
dc.w $c0b8,$b0a8,$a098,$9088,$8088,$0f17,$1f27,$2f37
dc.w $c0c0,$d0d8,$e0e8,$f0f8,$00f8,$f0e8,$e0d8,$d0c8
dc.w $c0b8,$b0a8,$a098,$9088,$8088,$9017,$1f27,$2f37
dc.w $c0c0,$d0d8,$e0e8,$f0f8,$00f8,$f0e8,$e0d8,$d0c8
dc.w $c0b8,$b0a8,$a098,$9088,$8088,$9098,$1f27,$2f37
dc.w $c0c0,$d0d8,$e0e8,$f0f8,$00f8,$f0e8,$e0d8,$d0c8
dc.w $c0b8,$b0a8,$a098,$9088,$8088,$9098,$a027,$2f37
dc.w $c0c0,$d0d8,$e0e8,$f0f8,$00f8,$f0e8,$e0d8,$d0c8
dc.w $c0b8,$b0a8,$a098,$9088,$8088,$9098,$a0a8,$2f37
dc.w $c0c0,$d0d8,$e0e8,$f0f8,$00f8,$f0e8,$e0d8,$d0c8
dc.w $c0b8,$b0a8,$a098,$9088,$8088,$9098,$a0a8,$b037
dc.w $8181,$8181,$8181,$8181,$8181,$8181,$8181,$8181
dc.w $7f7f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f
dc.w $8181,$8181,$8181,$8181,$8181,$8181,$8181,$8181
dc.w $817f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f
dc.w $8181,$8181,$8181,$8181,$8181,$8181,$8181,$8181
dc.w $8181,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f
dc.w $8181,$8181,$8181,$8181,$8181,$8181,$8181,$8181
dc.w $8181,$817f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f
dc.w $8181,$8181,$8181,$8181,$8181,$8181,$8181,$8181
dc.w $8181,$8181,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f
dc.w $8181,$8181,$8181,$8181,$8181,$8181,$8181,$8181
dc.w $8181,$8181,$817f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f
dc.w $8181,$8181,$8181,$8181,$8181,$8181,$8181,$8181
dc.w $8181,$8181,$8181,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f
dc.w $8181,$8181,$8181,$8181,$8181,$8181,$8181,$8181
dc.w $8181,$8181,$8181,$817f,$7f7f,$7f7f,$7f7f,$7f7f
dc.w $8181,$8181,$8181,$8181,$8181,$8181,$8181,$8181
dc.w $8181,$8181,$8181,$8181,$7f7f,$7f7f,$7f7f,$7f7f
dc.w $8181,$8181,$8181,$8181,$8181,$8181,$8181,$8181
dc.w $8181,$8181,$8181,$8181,$817f,$7f7f,$7f7f,$7f7f
dc.w $8181,$8181,$8181,$8181,$8181,$8181,$8181,$8181
dc.w $8181,$8181,$8181,$8181,$8181,$7f7f,$7f7f,$7f7f
dc.w $8181,$8181,$8181,$8181,$8181,$8181,$8181,$8181
dc.w $8181,$8181,$8181,$8181,$8181,$817f,$7f7f,$7f7f
dc.w $8181,$8181,$8181,$8181,$8181,$8181,$8181,$8181
dc.w $8181,$8181,$8181,$8181,$8181,$8181,$7f7f,$7f7f
dc.w $8181,$8181,$8181,$8181,$8181,$8181,$8181,$8181
dc.w $8181,$8181,$8181,$8181,$8181,$8181,$817f,$7f7f
dc.w $8080,$8080,$8080,$8080,$8080,$8080,$8080,$8080
dc.w $8080,$8080,$8080,$8080,$8080,$8080,$8080,$7f7f
dc.w $8080,$8080,$8080,$8080,$8080,$8080,$8080,$8080
dc.w $8080,$8080,$8080,$8080,$8080,$8080,$8080,$807f
dc.w $8080,$8080,$8080,$8080,$7f7f,$7f7f,$7f7f,$7f7f
dc.w $8080,$8080,$8080,$807f,$7f7f,$7f7f,$7f7f,$7f7f
dc.w $8080,$8080,$8080,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f
dc.w $8080,$8080,$807f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f
dc.w $8080,$8080,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f
dc.w $8080,$807f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f
dc.w $8080,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f
dc.w $8080,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f,$7f7f
dc.w $8080,$9098,$a0a8,$b0b8,$c0c8,$d0d8,$e0e8,$f0f8
dc.w $0008,$1018,$2028,$3038,$4048,$5058,$6068,$707f
dc.w $8080,$a0b0,$c0d0,$e0f0,$0010,$2030,$4050,$6070
dc.w $4545,$797d,$7a77,$7066,$6158,$534d,$2c20,$1812
dc.w $04db,$d3cd,$c6bc,$b5ae,$a8a3,$9d99,$938e,$8b8a
dc.w $4545,$797d,$7a77,$7066,$5b4b,$4337,$2c20,$1812
dc.w $04f8,$e8db,$cfc6,$beb0,$a8a4,$9e9a,$9594,$8d83
dc.w $0000,$4060,$7f60,$4020,$00e0,$c0a0,$80a0,$c0e0
dc.w $0000,$4060,$7f60,$4020,$00e0,$c0a0,$80a0,$c0e0
dc.w $8080,$9098,$a0a8,$b0b8,$c0c8,$d0d8,$e0e8,$f0f8
dc.w $0008,$1018,$2028,$3038,$4048,$5058,$6068,$707f
dc.w $8080,$a0b0,$c0d0,$e0f0,$0010,$2030,$4050,$6070


s:		; s-r=longueur code

option:
dc.l	1
nlignes:
dc.l	11-1
;;;;;'option1------------  option2------------+',0
txtops:
dc.l $610ac
dc.b 'diskmaster      1.3  masterseka     1.53 ',0
dc.l $610ac+[44*9*1]
dc.b 'deluxe paint    iii  iff converter   1.0 ',0
dc.l $610ac+[44*9*2]
dc.b 'rossimon        3.0  soundtracker    2.5 ',0
dc.l $610ac+[44*9*3]
dc.b 'gfx searcher    1.4  romcrack        0.7 ',0
dc.l $610ac+[44*9*4]
dc.b 'virusx          4.0  tetra cruncher  2.1 ',0
dc.l $610ac+[44*9*5]
dc.b 'microemacs      1.3  fileboot            ',0
dc.l $610ac+[44*9*6]
dc.b 'coder copy      4.0  xcopy           2.2 ',0
dc.l $610ac+[44*9*7]
dc.b 'gfa basic       3.5  imploder        1.0 ',0
dc.l $610ac+[44*9*8]
dc.b 'ripper-st       2.3  ripper f.comp.  2.0 ',0
dc.l $610ac+[44*9*10]
dc.b 'type menu under cli to reload this menu. ',0
dc.l $610ac+[44*9*11]
dc.b '            done by - ritchy             ',0

even

options:
dc	0
		;CHANGER:mettre les noms des 'programmes',0
		;nbre options = 26! (+even a la fin)
option1:
dc.b	'dir',0
option2:
dc	'222',0
option3:
dc	'333',0
option4:
dc	'444',0


even
gfxname:
dc	"graphics.library",0
even
dosname:
dc	"dos.library",0
even
gfxbase:
dc.l	0
saved7:
dc.l	0
dosbase:
dc.l	0
savecl:
dc.l 0
table:
dc.w "a",0,"b",1,"c",2,"d",3,"e",4,"f",5,"g",6,"h",7
dc.w "i",8,"j",9,"k",10,"l",11,"m",12,"n",13,"o",14,"p",15
dc.w "q",16,"r",17,"s",18,"t",19,"u",20,"v",21,"w",22,"x",23
dc.w "y",24,"z",25,"0",26,"1",27,"2",28,"3",29,"4",30,"5",31
dc.w "6",32,"7",33,"8",34,"9",35," ",36,".",37,"-",38,"+",39
ptexte:
dc.l	texte
texte:
dc.b 'hello billy joe... ici ritchy cunningham le tueur....'
dc.b 'tgs the great shit presents... lamer menu.           '
fintexte:
even


ncl:
dc.w $008e,$2981,$0090,$29c1
dc.w $0092,$0038,$0094,$00d0
dc.w $00e0,$0006,$00e2,$0000
dc.w $00e4,$0006,$00e6,$2c00
dc.w $00e8,$0006,$00ea,$5800
dc.w $00ec,$0006,$00ee,$8400
dc.w $00f0,$0006,$00f2,$b000
dc.w $0100,$5200,$0102,$0000
dc.w $0104,$0000
dc.w $0108,$0004,$010a,$0004
dc.w $01a2,$0666
dc.w $01aa,$0aaa
dc.w $01b2,$0fff
sprt:
dc.w $0120,$0000,$0122,$0000
dc.w $0128,$0000,$012a,$0000
dc.w $0130,$0000,$0132,$0000
dc.w $0182,$0808,$0184,$0d0d
dc.w $0186,$0505
dc.w $1b0f,$fffe,$180,$000

dc.w $500f,$fffe			; ou ffff,ffde (over)
selop:
dc.w $890f,$fffe,$180,$000,$182,$505
dc.w $898d,$fffe,$180,$0,$182,$808
dc.w $8a0f,$fffe,$180,$444,$182,$909
dc.w $8a8d,$fffe,$180,$0,$182,$808
dc.w $8b0f,$fffe,$180,$555,$182,$b0b
dc.w $8b8d,$fffe,$180,$0,$182,$808
dc.w $8c0f,$fffe,$180,$666,$182,$d0d
dc.w $8c8d,$fffe,$180,$0,$182,$808
dc.w $8d0f,$fffe,$180,$777,$182,$f0f
dc.w $8d8d,$fffe,$180,$0,$182,$808
dc.w $8e0f,$fffe,$180,$777,$182,$f0f
dc.w $8e8d,$fffe,$180,$0,$182,$808
dc.w $8f0f,$fffe,$180,$666,$182,$d0d
dc.w $8f8d,$fffe,$180,$0,$182,$808
dc.w $900f,$fffe,$180,$555,$182,$b0b
dc.w $908d,$fffe,$180,$0,$182,$808
dc.w $910f,$fffe,$180,$444,$182,$909
dc.w $918d,$fffe,$180,$0,$182,$808
dc.w $920f,$fffe,$180,$000,$182,$505
dc.w $928d,$fffe,$180,$0,$182,$808
finselop:
dc.w $ffff,$ffde			; ou 1f0f,fffe (over)
finover:
dc.w $200f,$fffe,$182,$066
dc.w $210f,$fffe,$182,$088
dc.w $220f,$fffe,$182,$0aa
dc.w $230f,$fffe,$182,$0cc
dc.w $240f,$fffe,$182,$642
dc.w $250f,$fffe,$182,$864
dc.w $260f,$fffe,$182,$a86
dc.w $270f,$fffe,$182,$ca8
dc.w $280f,$fffe,$182,$eca
dc.w $290f,$fffe,$182,$000

fonts:
page=fonts+320
sprite0=page+17120
sprite2=sprite0+1256
sprite4=sprite2+1248
fsprtes=sprite4+1256
module=$40000
finintro:
