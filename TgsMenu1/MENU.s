;---------------------------------------------------------------
; MENU POUR COMPILATIONS DE WHAT YOU WANT    CODE : RITCHY (TGS)
; TEXTE        :  -> TEXTE DU SCROLLING (LAISSER MES 'HELLOS'
; OP1 - OP10   :  -> NOM DES OPTIONS A AFFICHER A L'ECRAN
; PRG1 - PRG10 :  -> NOM DES PROGRAMMES A EXECUTER
; TEXTE1       :  -> TEXTE EN BLEU (AU DESSUS OPTIONS)
; OP11         :  -> TEXTE EN BLEU (AU DESSOUS OPTIONS)
;---------------------------------------------------------------
; VIRER LE RTS A LA FIN DE LA ROUTINE 'FIN:'
ORG$35000
LOAD$35000

>EXTERN "LOGO",LOGO
>EXTERN "FONTS",FONTS
>EXTERN "ZIQUE",MODULE

EXECBASE = 4			; ADR. DE BASE DE EXEC.LIBRARY
FORBID   = -132			; OFFSET STOP MULTITACHES
PERMIT   = -138			;        REMET MULTITACHES
OPENLIB  = -408			;        OUVRIR LIBRARY
CLOSELIB = -414			;        FERME LIBRARY
EXEC=-222

BPL1 = $60000			; ADRESSES
BPL2 = $62C00			; DES
BPL3 = $65800			; 5 BITPLANS
BPL4 = $68400
BPL5 = $6B000
TAILLEBPL = 44*256		; TAILLE D'UN BITPLAN

;=========================
; INITIALISATIONS DIVERSES
;=========================

R:
MOVEM.L D0-D7/A0-A6,-(A7)	; SAUVE LES REGISTRES
MOVE.L #120,D7
RI:
BSR.L WAIT
DBRA D7,RI
MOVE.B #%10000111,$BFD100	; ARRETE LES DRIVES
MOVE.L EXECBASE,A6
JSR FORBID(A6)			; ENLEVE LE MULTITACHES
LEA GFXNAME,A1
JSR OPENLIB(A6)			; OUVRE LA GRAPHICS.LIBRARY
MOVE.L D0,GFXBASE

LEA BPL1,A0			; ROUTINE 'CLS'
MOVE.L #TAILLEBPL/4*5-1,D0	; EFFACEMENT
EFFACE:				; ECRAN 320+44
CLR.L (A0)+			; x 256
DBRA D0,EFFACE			; x 5 BITPLANS

MOVE.L GFXBASE,A0
MOVE.L $32(A0),SAVECL		; SAUVE L'ANCIEN COPPER 
MOVE.L #NCL,$32(A0)		; MET LE MIEN

BSR.L AFFLOGO
BSR.L PRINT1

BSR.L OPTION1			; AFFICHE LES OPTIONS !!!
BSR.L OPTION2
BSR.L OPTION3
BSR.L OPTION4
BSR.L OPTION5
BSR.L OPTION6
BSR.L OPTION7
BSR.L OPTION8
BSR.L OPTION9
BSR.L OPTION10
BSR.L OPTION11

MOVE.W #$0F00,$DFF036			; YMOUSE=15
BSR.L INIT_MUSIC
MAIN:
CMP.B #120,$DFF006
BLO.S MAIN
BSR.L FONT
MOVE.L #5-1,D7

ADD.L #1,PTEXTE
CMP.L #FINTEXTE,PTEXTE
BLO.S MAIN2
MOVE.L #TEXTE,PTEXTE

MAIN2:
BTST #6,$BFE001
BEQ FIN
BSR.L MOUSE
BSR.L SCROLL
BSR.L WAVES
MOVE.L D7,SAUVE
BSR.L PLAY
MOVE.L SAUVE,D7
BSR.L WAIT
DBRA D7,MAIN2
BRA MAIN

FIN:
MOVE.L GFXBASE,A0
MOVE.L SAVECL,$32(A0)		; REMET ANCIEN COPPER
MOVE.L EXECBASE,A6
MOVE.L GFXBASE,A1
JSR CLOSELIB(A6)		; REFERME LA GRAPHICS.LIBRARY
JSR PERMIT(A6)			; REACTIVE LE MULTITACHES
BSR.L END_MUSIC
MOVEM.L (A7)+,D0-D7/A0-A6
MOVE.L LIGNE,D0

RTS	; A VIRER !!!!!!!!!!!!!!!!!

CHOISI:				; TRAITEMENT DES OPTIONS CHOISIES...
MOVE.L EXECBASE,A6
LEA DOSNAME,A1
JSR OPENLIB(A6)
MOVE.L D0,DOSBASE

MOVE.L D0,A6

CMP.L #1,LIGNE
BHI F2
MOVE.L #PRG1,D1
BRA FINF

F2:
CMP.L #2,LIGNE
BHI F3
MOVE.L #PRG2,D1
BRA FINF

F3:
CMP.L #3,LIGNE
BHI F4
MOVE.L #PRG3,D1
BRA FINF

F4:
CMP.L #4,LIGNE
BHI F5
MOVE.L #PRG4,D1
BRA FINF

F5:
CMP.L #5,LIGNE
BHI F6
MOVE.L #PRG5,D1
BRA FINF

F6:
CMP.L #6,LIGNE
BHI F7
MOVE.L #PRG6,D1
BRA FINF

F7:
CMP.L #7,LIGNE
BHI F8
MOVE.L #PRG7,D1
BRA FINF

F8:
CMP.L #8,LIGNE
BHI F9
MOVE.L #PRG8,D1
BRA FINF

F9:
CMP.L #9,LIGNE
BHI F10
MOVE.L #PRG9,D1
BRA FINF

F10:
MOVE.L #PRG10,D1
BRA FINF

FINF:
MOVE.L  #$00000000,D2
MOVE.L  #$00000000,D3
MOVE.L DOSBASE,A6
JSR -222(A6)
;----------------
MOVE.L EXECBASE,A6
MOVE.L DOSBASE,A1
JSR CLOSELIB(A6)
RTS

WAIT:
MOVE.L #9000,D0
WI:
DBRA D0,WI
RTS

MOUSE:
MOVE.W  $DFF00A,D0	; POS DE LA SOURIS DANS D0
ASR.W   #8,D0		; SEUL LA POS Y M'INTERRESSE
CMP.B  	#19,D0		; A T'ON AUGMENTE? (DONC VERS LE H)
BHI     DESCENDS	; ALORS SCROLL VERS LE BAS
CMP.B 	#11,D0		; A T'ON DIMINUE? ( DONC VERS LE B)
BLO     MONTE		; ALORS VERS LE H(BIZARRE NON !!!)
RTS

MONTE:
MOVE.W #$0F00,$DFF036
LEA REDEF,A0
MOVE.L #9-1,D0
CMP.W #$A000,(A0)		; REGLAGE EN HAUT ( x>$A000)
BHI MNT
RTS
MNT:
SUB.B #10,(A0)
ADD.L #16,A0
DBRA D0,MNT
SUB.L #1,LIGNE
RTS

DESCENDS:
MOVE.W #$0F00,$DFF036
LEA REDEF,A0
MOVE.L #9-1,D0
CMP.W #$F000,(A0)		; REGALAGE EN BAS ( x<$F000 )
BLO DSC
RTS
DSC:
ADD.B #10,(A0)
ADD.L #16,A0
DBRA D0,DSC
ADD.L #1,LIGNE
RTS

WAVES:
MOVE.L PVAGUES,A0
LEA FINREDEF-2,A1
MOVE.W (A0),(A1)
ADD.L #2,PVAGUES
CMP.L #FINVAGUES,PVAGUES
BLO.S BONCAVA
MOVE.L #VAGUES,PVAGUES
BONCAVA:
LEA REDEF+14,A0
LEA REDEF+14+16,A1
MOVE.L #7-1,D0
DECALETOUT:
MOVE.W (A1),(A0)
ADD.L #16,A0
ADD.L #16,A1
DBRA D0,DECALETOUT
RTS

PRINT1:
LEA TEXTE1,A1			; POINTE SUR ADRESSE
MOVE.L (A1)+,A0			; ADRESSE -> A0 ET A1 SUR DEBUT TXT
ADD.L #$60000,A0		; DESTINATION = A0+ADR ECRAN
MOVE.L #FINTEXTE1-TEXTE1-5,D0	; LONGUEUR TEXTE
BOUCLE1:
BSR.L PRINT			; VA PRINTER UN CARACTERE
SUB.L #[44*8],A0		; PROCHAINE ADRESSE LETTRE
ADD.L #1,A0			; CARACTERE SUIVANT
ADD.L #1,A1			; PROCHAIN CARACTERE
DBRA D0,BOUCLE1			; N FOIS
RTS

OPTION1:
LEA OP1,A1			; POINTE SUR ADRESSE
MOVE.L (A1)+,A0			; ADRESSE -> A0 ET A1 SUR DEBUT TXT
ADD.L #$60000,A0		; DESTINATION = A0+ADR ECRAN
MOVE.L #FINOP1-OP1-5,D0		; LONGUEUR TEXTE
B1:
BSR.L PRINT			; VA PRINTER UN CARACTERE
SUB.L #[44*8],A0		; PROCHAINE ADRESSE LETTRE
ADD.L #1,A0			; CARACTERE SUIVANT
ADD.L #1,A1			; PROCHAIN CARACTERE
DBRA D0,B1			; N FOIS
RTS

OPTION2:
LEA OP2,A1			; POINTE SUR ADRESSE
MOVE.L (A1)+,A0			; ADRESSE -> A0 ET A1 SUR DEBUT TXT
ADD.L #$60000,A0		; DESTINATION = A0+ADR ECRAN
MOVE.L #FINOP2-OP2-5,D0		; LONGUEUR TEXTE
B2:
BSR.L PRINT			; VA PRINTER UN CARACTERE
SUB.L #[44*8],A0		; PROCHAINE ADRESSE LETTRE
ADD.L #1,A0			; CARACTERE SUIVANT
ADD.L #1,A1			; PROCHAIN CARACTERE
DBRA D0,B2			; N FOIS
RTS

OPTION3:
LEA OP3,A1			; POINTE SUR ADRESSE
MOVE.L (A1)+,A0			; ADRESSE -> A0 ET A1 SUR DEBUT TXT
ADD.L #$60000,A0		; DESTINATION = A0+ADR ECRAN
MOVE.L #FINOP3-OP3-5,D0		; LONGUEUR TEXTE
B3:
BSR.L PRINT			; VA PRINTER UN CARACTERE
SUB.L #[44*8],A0		; PROCHAINE ADRESSE LETTRE
ADD.L #1,A0			; CARACTERE SUIVANT
ADD.L #1,A1			; PROCHAIN CARACTERE
DBRA D0,B3			; N FOIS
RTS

OPTION4:
LEA OP4,A1
MOVE.L (A1)+,A0
ADD.L #$60000,A0
MOVE.L #FINOP4-OP4-5,D0
B4:
BSR.L PRINT
SUB.L #[44*8],A0
ADD.L #1,A0
ADD.L #1,A1
DBRA D0,B4
RTS

OPTION5:
LEA OP5,A1
MOVE.L (A1)+,A0
ADD.L #$60000,A0
MOVE.L #FINOP5-OP5-5,D0
B5:
BSR.L PRINT
SUB.L #[44*8],A0
ADD.L #1,A0
ADD.L #1,A1
DBRA D0,B5
RTS

OPTION6:
LEA OP6,A1
MOVE.L (A1)+,A0
ADD.L #$60000,A0
MOVE.L #FINOP6-OP6-5,D0
B6:
BSR.L PRINT
SUB.L #[44*8],A0
ADD.L #1,A0
ADD.L #1,A1
DBRA D0,B6
RTS

OPTION7:
LEA OP7,A1
MOVE.L (A1)+,A0
ADD.L #$60000,A0
MOVE.L #FINOP7-OP7-5,D0
B7:
BSR.L PRINT
SUB.L #[44*8],A0
ADD.L #1,A0
ADD.L #1,A1
DBRA D0,B7
RTS

OPTION8:
LEA OP8,A1
MOVE.L (A1)+,A0
ADD.L #$60000,A0
MOVE.L #FINOP8-OP8-5,D0
B8:
BSR.L PRINT
SUB.L #[44*8],A0
ADD.L #1,A0
ADD.L #1,A1
DBRA D0,B8
RTS

OPTION9:
LEA OP9,A1
MOVE.L (A1)+,A0
ADD.L #$60000,A0
MOVE.L #FINOP9-OP9-5,D0
B9:
BSR.L PRINT
SUB.L #[44*8],A0
ADD.L #1,A0
ADD.L #1,A1
DBRA D0,B9
RTS

OPTION10:
LEA OP10,A1
MOVE.L (A1)+,A0
ADD.L #$60000,A0
MOVE.L #FINOP10-OP10-5,D0
B10:
BSR.L PRINT
SUB.L #[44*8],A0
ADD.L #1,A0
ADD.L #1,A1
DBRA D0,B10
RTS

OPTION11:
LEA OP11,A1
MOVE.L (A1)+,A0
ADD.L #$60000,A0
MOVE.L #FINOP11-OP11-5,D0
B11:
BSR.L PRINT
SUB.L #[44*8],A0
ADD.L #1,A0
ADD.L #1,A1
DBRA D0,B11
RTS

PRINT:
LEA TABLE,A2			; POINTE SUR TABLE
CLR.L D1
CLR.L D2
MOVE.B (A1),D1			; CARACTERE A AFFICHER -> D1
PAPAOUESTU:
MOVE.W (A2),D2			; CARACTERE TABLE -> D2
CMP.B D1,D2			; LETTRES EGALES ???
BEQ OK				; OUI ALORS VA AFFICHER
ADD.L #4,A2			; NON : LETTRE SUIVANTE
BRA PAPAOUESTU			; RE ESAIE

OK:
MOVE.L #0,A3
MOVE.W 2(A2),A3			; -> A3
ADD.L #FONTS,A3			; + ADRESSE FONTE
MOVE.L #8-1,D1			; 8 LIGNES DE HAUT
PAPAJETAITROUVE:
MOVE.B (A3),D3			; DATA LETTRE -> D3
MOVE.B D3,(A0)			; D3 SUR L'ECRAN
MOVE.B #0,1(A0)
ADD.L #44,A0			; ADRESSE ECRAN + 1 LIGNE
ADD.L #40,A3			; DATA FONTE + 1 LIGNE
DBRA D1,PAPAJETAITROUVE		; 8 FOIS
RTS				; RETOUR

FONT:
LEA $62A9C,A0
LEA TABLE,A2			; POINTE SUR TABLE
MOVE.L PTEXTE,A1
CLR.L D1
CLR.L D2
MOVE.B (A1),D1			; CARACTERE A AFFICHER -> D1
GAGUESAGOGO:
MOVE.W (A2),D2			; CARACTERE TABLE -> D2
CMP.B D1,D2			; LETTRES EGALES ???
BEQ OK				; OUI ALORS VA AFFICHER
ADD.L #4,A2			; NON : LETTRE SUIVANTE
BRA GAGUESAGOGO

SCROLL:
LEA $62A74,A0
VAZY:
BTST #14,$DFF002
BNE.S VAZY
MOVE.L #$FFFFFFFF,$DFF044
MOVE.W #$E9F0,$DFF040
CLR.W $DFF042
MOVE.W #$0000,$DFF064
MOVE.W #$0000,$DFF066
MOVE.L A0,$DFF050
SUB.L #2,A0
MOVE.L A0,$DFF054
MOVE.W #$0216,$DFF058
RTS

AFFLOGO:
LEA LOGO,A0
LEA $60006,A1
MOVE.L #3-1,D0
COPYLOGO:
BTST #14,$DFF002
BNE COPYLOGO
MOVE.L #$FFFFFFFF,$DFF044
MOVE.W #$09F0,$DFF040
CLR.W $DFF042
MOVE.W #$0000,$DFF064
MOVE.W #44-26,$DFF066
MOVE.L A0,$DFF050
MOVE.L A1,$DFF054
MOVE.W #$154D,$DFF058
ADD.L #26*85,A0
ADD.L #$2C00,A1
DBRA D0,COPYLOGO
RTS

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
;----------------------------------------------------------------
; DATAS   DATAS   DATAS   DATAS   DATAS   DATAS   DATAS   DATAS
;----------------------------------------------------------------
; abcdefghijklmnopqrstuvwxyz0123456789 +-.
;----------------------------------------------------------------
SAUVE:				; POUR SAUVER D7 (APPEL ZIQUE)
DC.L 0

DOSNAME:
DC.B 'dos.library',0
EVEN
DOSBASE:
DC.L 0

LIGNE:				; LIGNE ACTUELLE
DC.L 7

; 40 CARACTERES PAR LIGNE MAXIMUM !!!
;    '           = 40 CARACTERES              '
TEXTE1:
DC.L [100*44]				; ADRESSE OU AFFICHER
DC.B '  presents the greatest tools you need  '	; TEXTE A AFFICHER
FINTEXTE1:
EVEN

OP1:				; LISTE DES OPTIONS
DC.L $1340+10			; ADRESSE ECRAN (+10=ABSCICES)
DC.B 'diskmaster       1.3'	; TEXTO
FINOP1:				; FIN !
EVEN

OP2:
DC.L $1340+[440]+10
DC.B 'graphic searcher 1.0'
FINOP2:
EVEN

OP3:
DC.L $1340+[2*440]+10
DC.B 'iff converter    2.0'
FINOP3:
EVEN

OP4:
DC.L $1340+[3*440]+10
DC.B 'imploder         1.0'
FINOP4:
EVEN

OP5:
DC.L $1340+[4*440]+10
DC.B 'st.ripper        1.0'
FINOP5:
EVEN

OP6:
DC.L $1340+[5*440]+10
DC.B 'rossimon         ...'
FINOP6:
EVEN

OP7:
DC.L $1340+[6*440]+10
DC.B 'seka by kefrens  3.2'
FINOP7:
EVEN

OP8:
DC.L $1340+[7*440]+10
DC.B 'soundtracker     2.5'
FINOP8:
EVEN

OP9:
DC.L $1340+[8*440]+10
DC.B 'virusx           4.0'
FINOP9:
EVEN

OP10:
DC.L $1340+[9*440]+10
DC.B 'xcopy             ii'
FINOP10:
EVEN

OP11:
DC.L $1340+[11*440]+6			; 0=DECALAGE <->
DC.B 'vincent is the biggest lamer'
FINOP11:
EVEN

PRG1:				; NOM DU PROGRAMME A EXECUTER
DC.B 'DISKMASTER',0		; NE PAS OUBLIER ,0
EVEN

PRG2:
DC.B 'GFX',0
EVEN
PRG3:
DC.B 'IFF',0
EVEN
PRG4:
DC.B 'IMPLODER',0
EVEN
PRG5:
DC.B 'RIPPER',0
EVEN
PRG6:
DC.B 'ROSSI',0
EVEN
PRG7:
DC.B 'SEKA',0
EVEN
PRG8:
DC.B 'ST',0
EVEN
PRG9:
DC.B 'VIRUSX',0
EVEN
PRG10:
DC.B 'XCOPY',0
EVEN

TEXTE:				; TAPER EN minuscules ( a-z  0-9  -+. )
DC.B '           '
DC.B ' yoooooooooo......        ritchy from tg'
DC.B 's proudly presents a cool compiltion of '
DC.B 'tools.       coding by the incredible ri'
DC.B 'tchy     music taken from future sound  '
DC.B '     gfx and fonts by - lucyfer         '
DC.B 'here are the greetings in a-z order to..'
DC.B '.        '
DC.B '- avenger  - acu  - bs1  - brainstorm  - '
DC.B 'd mod  - digitech  - dragons  - disknet  '
DC.B '- equinox  - fraxion  - g.o.t  - iron eagle crew '
DC.B ' - impact inc.  - kefrens  - master crew'
DC.B '  - paranoimia  - rebels  - supplex  - subsoftware  - '
DC.B 'sunstar  - tarkus team  - tetragon  - unique  - '
DC.B 'vision  - vision factory and all we had forgotten...'
DC.B '          '
DC.B 'my coolest regards are flying to  - dd  '
DC.B '- chaos  - kamikaze  - ninja  - zorglub.'
DC.B '                                        '
FINTEXTE:
EVEN

PTEXTE:
DC.L TEXTE

TABLE:			; TABLE DES CARACTERES DE LA FONTE
DC.W "a",0,"b",1,"c",2,"d",3,"e",4,"f",5,"g",6,"h",7
DC.W "i",8,"j",9,"k",10,"l",11,"m",12,"n",13,"o",14,"p",15
DC.W "q",16,"r",17,"s",18,"t",19,"u",20,"v",21,"w",22,"x",23
DC.W "y",24,"z",25,"0",26,"1",27,"2",28,"3",29,"4",30,"5",31
DC.W "6",32,"7",33,"8",34,"9",35," ",36,".",37,"-",38,"+",39

PVAGUES:
DC.L VAGUES
VAGUES:
DC.W 0,0,1,1,2,3,3
DC.W 4,4,3,3,2,1,1
FINVAGUES:

GFXNAME:
DC.B "graphics.library",0
EVEN
GFXBASE:
DC.L 0
SAVECL:
DC.L 0
NCL:				; MA COPPER-LIST
DC.W $008E,$2981,$0090,$29C1	; DIWSTRT
DC.W $0092,$0038,$0094,$00D0	; DIWSTOP
DC.W $00E0,$0006,$00E2,$0000	; POINTEUR BITPLAN 1 
DC.W $00E4,$0006,$00E6,$2C00	; POINTEUR BITPLAN 2
DC.W $00E8,$0006,$00EA,$5800	; POINTEUR BITPLAN 3
DC.W $00EC,$0006,$00EE,$8400	; POINTEUR BITPLAN 4
DC.W $00F0,$0006,$00F2,$B000	; POINTEUR BITPLAN 5
DC.W $0100,$5200,$0102,$0000	; BPLCON 0 / BPLCON 1
DC.W $0104,$0000		; BPLCON 2
DC.W $0108,$0004,$010A,$0004	; BPL1 MOD / BPL2 MOD
DC.W $0120,$0000,$0122,$0000	; ENLEVE POINTEUR (SPRITE 0)
DC.W $0182,$0005,$0184,$0008
DC.W $0186,$000A,$0188,$000D
DC.W $018A,$000F

DC.W $1B0F,$FFFE,$180,$FDB		; PREMIER TUBE MARRON
DC.W $1C0F,$FFFE,$180,$ECA
DC.W $1D0F,$FFFE,$180,$DB9
DC.W $1E0F,$FFFE,$180,$CA8
DC.W $1F0F,$FFFE,$180,$B97
DC.W $200F,$FFFE,$180,$A86
DC.W $210F,$FFFE,$180,$975
DC.W $220F,$FFFE,$180,$864
DC.W $230F,$FFFE,$180,$753
DC.W $240F,$FFFE,$180,$642
DC.W $250F,$FFFE,$180,$531
DC.W $260F,$FFFE,$180,$420
DC.W $270F,$FFFE,$180,$000

DC.W $7E0F,$FFFE,$182,$888		; COULEUR TEXTE

DC.W $8D0F,$FFFE,$182,$077		; COULEURS TEXTE1
DC.W $8E0F,$FFFE,$182,$099
DC.W $8F0F,$FFFE,$182,$0BB
DC.W $900F,$FFFE,$182,$0DD
DC.W $910F,$FFFE,$182,$0FF
DC.W $920F,$FFFE,$182,$0DD
DC.W $930F,$FFFE,$182,$0BB
DC.W $940F,$FFFE,$182,$099
DC.W $950F,$FFFE,$182,$AAA

REDEF:
DC.W $D50F,$FFFE,$180,$642,$182,$CCC,$102,$0	; COULEUR TUBE
DC.W $D60F,$FFFE,$180,$864,$182,$DDD,$102,$0	; + COULEUR TEXTE
DC.W $D70F,$FFFE,$180,$A86,$182,$EEE,$102,$0	; + VAGUE
DC.W $D80F,$FFFE,$180,$CA8,$182,$FFF,$102,$0
DC.W $D90F,$FFFE,$180,$CA8,$182,$FFF,$102,$0
DC.W $DA0F,$FFFE,$180,$A86,$182,$EEE,$102,$0
DC.W $DB0F,$FFFE,$180,$864,$182,$DDD,$102,$0
DC.W $DC0F,$FFFE,$180,$642,$182,$CCC,$102,$0
FINREDEF:
DC.W $DD0F,$FFFE,$180,$000,$182,$AAA,$102,$0

OVERSCAN:
DC.W $FFFF,$FFDE

DC.W $070F,$FF00,$182,$077		; COULEUR TEXTE 2 (OP11)
DC.W $080F,$FF00,$182,$099
DC.W $090F,$FF00,$182,$0BB
DC.W $0A0F,$FF00,$182,$0DD
DC.W $0B0F,$FF00,$182,$0FF
DC.W $0C0F,$FF00,$182,$0DD
DC.W $0D0F,$FF00,$182,$0BB
DC.W $0E0F,$FF00,$182,$099

DC.W $200F,$FF00,$182,$707			; COULEURS SCROLL
DC.W $210F,$FF00,$182,$909
DC.W $220F,$FF00,$182,$B0B
DC.W $230F,$FF00,$182,$D0D
DC.W $240F,$FF00,$182,$F0F
DC.W $250F,$FF00,$182,$D0D
DC.W $260F,$FF00,$182,$B0B
DC.W $270F,$FF00,$182,$909

DC.W $280F,$FF00,$180,$000

DC.W $2D0F,$FF00,$180,$420		; DERNIER TUBE MARRON
DC.W $2E0F,$FF00,$180,$531
DC.W $2F0F,$FF00,$180,$642
DC.W $300F,$FF00,$180,$753
DC.W $310F,$FF00,$180,$864
DC.W $320F,$FF00,$180,$975
DC.W $330F,$FF00,$180,$A86
DC.W $340F,$FF00,$180,$B97
DC.W $350F,$FF00,$180,$CA8
DC.W $360F,$FF00,$180,$DB9
DC.W $370F,$FF00,$180,$ECA
DC.W $380F,$FF00,$180,$FDB
DC.W $390F,$FF00,$180,$000
DC.W $FFFF,$FF00

LOGO:
BLK.B 6630
FONTS:
BLK.B 320
MODULE:
FININTRO=MODULE+24478
