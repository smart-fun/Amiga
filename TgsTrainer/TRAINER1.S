;------------------------------------
; MENU TRAINER BY RITCHY FROM TGS
; CHANGE TEXTE1 -> TEXTE4 FOR OPTIONS
; AND TRAINER1: -> TRAINER4: FOR
; TRAINER ROUTINES !
; HOPE YOU LIKE IT !!!!
;------------------------------------
ORG$35000			; PROGRAMME EN
LOAD$35000			; RAM = $35000

>EXTERN "FONTS",FONTS
>EXTERN "ZIQUE",MODULE

EXECBASE = 4			; ADR. DE BASE DE EXEC.LIBRARY
FORBID   = -132			; OFFSET STOP MULTITACHES
PERMIT   = -138			;        REMET MULTITACHES
OPENLIB  = -408			;        OUVRIR LIBRARY
CLOSELIB = -414			;        FERME LIBRARY

BPL1 = $60000			; ADRESSES
TAILLEBPL = 52*300		; TAILLE D'UN BITPLAN

;=========================
; INITIALISATIONS DIVERSES
;=========================

R:

MOVEM.L D0-D7/A0-A6,-(A7)	; SAUVE LES REGISTRES
LEA OPTION5,A0
MOVE.L #$0,(A0)			; ON QUITTE PAS TOUT DE SUITE !!!
MOVE.L EXECBASE,A6
JSR FORBID(A6)			; ENLEVE LE MULTITACHES
LEA GFXNAME,A1
JSR OPENLIB(A6)			; OUVRE LA GRAPHICS.LIBRARY
MOVE.L D0,GFXBASE

LEA BPL1,A0			; ROUTINE 'CLS'
MOVE.L #TAILLEBPL/4*2-1,D0	; EFFACEMENT
EFFACE:				; ECRAN 320+44
CLR.L (A0)+			; x 256
DBRA D0,EFFACE			; x 5 BITPLANS

MOVE.L GFXBASE,A0
MOVE.L $32(A0),SAVECL		; SAUVE L'ANCIEN COPPER 
MOVE.L #NCL,$32(A0)		; MET LE MIEN

BSR.L PRINT1
BSR.L PRINT2
BSR.L PRINT3
BSR.L PRINT4
BSR.L PRINT5
BSR.L PRINT6
BSR.L PRINT7
BSR.L PRINT8

BSR.L INIT_MUSIC
MAIN:
BSR.L FONT
BSR.L WHICH
MOVE.L #3,ESPACEMENT
MOVE.L ESPACEMENT,D7
MAIN2:
CMP.B #$80,$DFF006
BLO.S MAIN2
BSR.L SCROLL
BSR.L COPPER
MOVE.L D7,ESPACEMENT
BSR.L PLAY
MOVE.L ESPACEMENT,D7
BSR.L WAIT
LEA OPTION5,A0
CMP.L #$FFFF,(A0)
BEQ FIN
DBRA D7,MAIN2
BRA MAIN

TRAINER1:
; PLACE POUR L'OPTION 1 DU TRAINER SI ON
RTS

TRAINER2:
RTS

TRAINER3:
RTS

TRAINER4:
RTS

WAIT:
MOVE.L #10000,D0
WI:
DBRA D0,WI
RTS

JOYTEST:
MOVE.W $DFF00C,D0
BTST #1,D0
BNE DROITE
BTST #9,D0
BNE GAUCHE
MOVE.W D0,D1
LSR.W #1,D1
EOR.W D0,D1
BTST #0,D1
BNE ARRIERE
BTST #8,D1
BNE AVANT
LEA LIGNE,A0
CMP.B #5,LIGNE
BLO BIENTOT
; OUI ! CA Y EST,ON QUITTE !!!
BSR.L FIRE
BIENTOT:
RTS

;---------------------------------
; GERE A DROITE:
;---------------------------------

DROITE:
LEA LIGNE,A0
MOVE.B (A0),D0
CMP.B #1,D0				; EST-CE EN LIGNE 1 ?
BEQ DROITE11
CMP.B #2,D0				; OU EN LIGNE 2 ?
BEQ DROITE22
CMP.B #3,D0				; OU ENCORE EN LIGNE 3 ?
BEQ DROITE33
CMP.B #4,D0				; OU OPTION 4
BEQ DROITE44
RTS

DROITE11:
LEA OPTION1+1,A0
MOVE.B #1,(A0)				; MARQUE 'ON' EN MEM.
LEA OPTION1+2,A0
BRA ADROITETOUTE
RTS

DROITE22:
LEA OPTION2+1,A0
MOVE.B #1,(A0)				; MARQUE 'ON' EN MEMEOIRE
LEA OPTION2+2,A0
BRA ADROITETOUTE
RTS

DROITE33:
LEA OPTION3+1,A0
MOVE.B #1,(A0)				; MARQUE 'ON' EN MEMEOIRE
LEA OPTION3+2,A0
BRA ADROITETOUTE
RTS

DROITE44:
LEA OPTION4+1,A0
MOVE.B #1,(A0)				; MARQUE 'ON' EN MEMEOIRE
LEA OPTION4+2,A0
BRA ADROITETOUTE
RTS

FIRE:
BTST #7,$BFE001				; START GAME !!!!
BNE NONDUTOUT
LEA OPTION5,A0
MOVE.L #$FFFF,(A0)
NONDUTOUT:
RTS

ADROITETOUTE:
MOVE.L (A0)+,A1
ADD.L #$60000,A1
MOVE.L #3,D0
DROITE1:
BSR.L PRINT
ADD.L #2,A1
ADD.L #1,A0
DBRA D0,DROITE1
RTS

;---------------------------------
; GERE A GAUCHE :
;---------------------------------

GAUCHE:
LEA LIGNE,A0
MOVE.B (A0),D0
CMP.B #1,D0
BEQ GAUCHE11
CMP.B #2,D0
BEQ GAUCHE22
CMP.B #3,D0
BEQ GAUCHE33
CMP.B #4,D0
BEQ GAUCHE44
RTS

GAUCHE11:
LEA OPTION1+1,A0
MOVE.B #0,(A0)				; EN TRAINER : OP1=OFF
LEA OPTION1+2,A0
BRA AGAUCHETOUTE
RTS

GAUCHE22:
LEA OPTION2+1,A0
MOVE.B #0,(A0)				; TRAINER : MEM=OFF
LEA OPTION2+2,A0
BRA AGAUCHETOUTE
RTS

GAUCHE33:
LEA OPTION3+1,A0
MOVE.B #0,(A0)				; TRAINER : MEM=OFF
LEA OPTION3+2,A0
BRA AGAUCHETOUTE
RTS

GAUCHE44:
LEA OPTION4+1,A0
MOVE.B #0,(A0)				; TRAINER : MEM=OFF
LEA OPTION4+2,A0
BRA AGAUCHETOUTE
RTS

AGAUCHETOUTE:
MOVE.L (A0)+,A1
ADD.L #3,A0
ADD.L #$60000,A1
MOVE.L #3,D0
GAUCHE1:
BSR.L PRINT
ADD.L #2,A1
ADD.L #1,A0
DBRA D0,GAUCHE1
RTS

;---------------------------------
; GERE EN AVANT:
;---------------------------------

AVANT:
SUB.B #1,LIGNE			; LIGNE PLUS BAS
CMP.B #1,LIGNE			; = LIGNE 1 ??
BEQ L2				; OUI -> EFFACE LIGNE 2
CMP.B #2,LIGNE			; IDEM
BEQ L3
CMP.B #3,LIGNE
BEQ L4
CMP.B #4,LIGNE
BEQ L5
LEA LIGNE,A0			; EN LIGNE 6 (?!?) MARQUER 5
MOVE.B #1,(A0)
RTS

;---------------------------------
; GERE EN ARRIERE:
;---------------------------------

ARRIERE:
ADD.B #1,LIGNE			; LIGNE PLUS BAS
CMP.B #2,LIGNE			; = LIGNE 2 ??
BEQ L1				; OUI -> EFFACE LIGNE 1
CMP.B #3,LIGNE			; IDEM
BEQ L2
CMP.B #4,LIGNE
BEQ L3
CMP.B #5,LIGNE
BEQ L4
LEA LIGNE,A0			; EN LIGNE 6 (?!?) MARQUER 5
MOVE.B #5,(A0)
RTS

L1:
LEA CO1+6,A0
MOVE.W #$888,(A0)
RTS
L2:
LEA CO2+6,A0
MOVE.W #$888,(A0)
RTS
L3:
LEA CO3+6,A0
MOVE.W #$888,(A0)
RTS
L4:
LEA CO4+6,A0
MOVE.W #$888,(A0)
RTS
L5:
LEA CO5+6,A0
MOVE.W #$888,(A0)
RTS

WHICH:
BSR.L JOYTEST
LEA LIGNE,A0
MOVE.B (A0),D0
CMP.B #1,D0
BEQ LIGNE1
CMP.B #2,D0
BEQ LIGNE2
CMP.B #3,D0
BEQ LIGNE3
CMP.B #4,D0
BEQ LIGNE4
CMP.B #5,D0
BEQ LIGNE5
RTS

LIGNE1:
CMP.B #1,SENS			; SENS DECREMENTE ??
BEQ SENS1			; OUI
LEA CO1+6,A0			; INCREMENTE :
CMP.W #$FFF,(A0)		; = COUL MAX ?
BLO OKCO1			; NON !
MOVE.B #1,SENS			; OUI -> 'INVERSE' SENS
MOVE.W #$FFF,(A0)		; ET MET COULEUR A FOND !!!
RTS
OKCO1:				; NON !
ADD.W #$111,(A0)		; INCREMENTE DE 1
RTS				; RETOUR
SENS1:				; SENS INCREMENTE:
LEA CO1+6,A0
CMP.W #$000,(A0)		; = ZERO ?
BHI OKCO11			; NON
MOVE.B #0,SENS			; OUI -> INVERSE SENS
MOVE.W #$000,(A0)		; ET MET COULEUR AU MIN
RTS
OKCO11:				; NON
SUB.W #$111,(A0)		; DECREMENTE DE 1
RTS				; RETOUR

LIGNE2:
CMP.B #1,SENS			; SENS DECREMENTE ??
BEQ SENS2			; OUI
LEA CO2+6,A0			; INCREMENTE :
CMP.W #$FFF,(A0)		; = COUL MAX ?
BLO OKCO2			; NON !
MOVE.B #1,SENS			; OUI -> 'INVERSE' SENS
MOVE.W #$FFF,(A0)		; ET MET COULEUR A FOND !!!
RTS
OKCO2:				; NON !
ADD.W #$111,(A0)		; INCREMENTE DE 1
RTS				; RETOUR
SENS2:				; SENS INCREMENTE:
LEA CO2+6,A0
CMP.W #$000,(A0)		; = ZERO ?
BHI OKCO22			; NON
MOVE.B #0,SENS			; OUI -> INVERSE SENS
MOVE.W #$000,(A0)		; ET MET COULEUR AU MIN
RTS
OKCO22:				; NON
SUB.W #$111,(A0)		; DECREMENTE DE 1
RTS				; RETOUR

LIGNE3:
CMP.B #1,SENS			; SENS DECREMENTE ??
BEQ SENS3			; OUI
LEA CO3+6,A0			; INCREMENTE :
CMP.W #$FFF,(A0)		; = COUL MAX ?
BLO OKCO3			; NON !
MOVE.B #1,SENS			; OUI -> 'INVERSE' SENS
MOVE.W #$FFF,(A0)		; ET MET COULEUR A FOND !!!
RTS
OKCO3:				; NON !
ADD.W #$111,(A0)		; INCREMENTE DE 1
RTS				; RETOUR
SENS3:				; SENS INCREMENTE:
LEA CO3+6,A0
CMP.W #$000,(A0)		; = ZERO ?
BHI OKCO33			; NON
MOVE.B #0,SENS			; OUI -> INVERSE SENS
MOVE.W #$000,(A0)		; ET MET COULEUR AU MIN
RTS
OKCO33:				; NON
SUB.W #$111,(A0)		; DECREMENTE DE 1
RTS				; RETOUR

LIGNE4:
CMP.B #1,SENS			; SENS DECREMENTE ??
BEQ SENS4			; OUI
LEA CO4+6,A0			; INCREMENTE :
CMP.W #$FFF,(A0)		; = COUL MAX ?
BLO OKCO4			; NON !
MOVE.B #1,SENS			; OUI -> 'INVERSE' SENS
MOVE.W #$FFF,(A0)		; ET MET COULEUR A FOND !!!
RTS
OKCO4:				; NON !
ADD.W #$111,(A0)		; INCREMENTE DE 1
RTS				; RETOUR
SENS4:				; SENS INCREMENTE:
LEA CO4+6,A0
CMP.W #$000,(A0)		; = ZERO ?
BHI OKCO44			; NON
MOVE.B #0,SENS			; OUI -> INVERSE SENS
MOVE.W #$000,(A0)		; ET MET COULEUR AU MIN
RTS
OKCO44:				; NON
SUB.W #$111,(A0)		; DECREMENTE DE 1
RTS				; RETOUR


LIGNE5:
CMP.B #1,SENS			; SENS DECREMENTE ??
BEQ SENS5			; OUI
LEA CO5+6,A0			; INCREMENTE :
CMP.W #$FFF,(A0)		; = COUL MAX ?
BLO OKCO5			; NON !
MOVE.B #1,SENS			; OUI -> 'INVERSE' SENS
MOVE.W #$FFF,(A0)		; ET MET COULEUR A FOND !!!
RTS
OKCO5:				; NON !
ADD.W #$111,(A0)		; INCREMENTE DE 1
RTS				; RETOUR
SENS5:				; SENS INCREMENTE:
LEA CO5+6,A0
CMP.W #$000,(A0)		; = ZERO ?
BHI OKCO55			; NON
MOVE.B #0,SENS			; OUI -> INVERSE SENS
MOVE.W #$000,(A0)		; ET MET COULEUR AU MIN
RTS
OKCO55:				; NON
SUB.W #$111,(A0)		; DECREMENTE DE 1
RTS				; RETOUR

FIN:
MOVE.L GFXBASE,A0
MOVE.L SAVECL,$32(A0)		; REMET ANCIEN COPPER
MOVE.L EXECBASE,A6
MOVE.L GFXBASE,A1
JSR CLOSELIB(A6)		; REFERME LA GRAPHICS.LIBRARY
JSR PERMIT(A6)			; REACTIVE LE MULTITACHES
BSR.L TRAINERS
BSR.L END_MUSIC
MOVEM.L (A7)+,D0-D7/A0-A6
RTS				; FIN

TRAINERS:
LEA OPTION1+1,A0
CMP.B #1,(A0)
BEQ TRAINER1
LEA OPTION2+1,A0
CMP.B #1,(A0)
BEQ TRAINER2
LEA OPTION3+1,A0
CMP.B #1,(A0)
BEQ TRAINER3
LEA OPTION4+1,A0
CMP.B #1,(A0)
BEQ TRAINER4
RTS

COPPER:
LEA FINREDEF-2,A0
MOVE.L PCOLORS,A1
CMP.L #FINCOLORS,A1
BLO ONYVADONC
MOVE.L #COLORS,PCOLORS
ONYVADONC:
MOVE.W (A1),(A0)
LEA REDEF+6,A0
LEA REDEF+6+8,A1
MOVE.L #15-1,D0
BAVAZY:
MOVE.W (A1),(A0)
ADD.L #8,A0
ADD.L #8,A1
DBRA D0,BAVAZY
ADD.L #2,PCOLORS
RTS

PRINT1:
LEA TEXTE1,A0			; POINTE SUR ADRESSE TEXTE
MOVE.L (A0)+,A1			; ADRESSE -> A1 ET A0 SUR CHAR1
ADD.L #$60000,A1
MOVE.L #FINTEXTE1-TEXTE1-5,D0	; TAILLE DU TEXTE
YOUPI1:
BSR.L PRINT			; VA PRINTER CHAR
ADD.L #2,A1			; ADRESSE SUIVANTE
ADD.L #1,A0			; LETTRE SUIVANTE
DBRA D0,YOUPI1			; N FOIS
RTS				; RETOUR

PRINT2:
LEA TEXTE2,A0			; POINTE SUR ADRESSE TEXTE
MOVE.L (A0)+,A1			; ADRESSE -> A1 ET A0 SUR CHAR1
ADD.L #$60000,A1
MOVE.L #FINTEXTE2-TEXTE2-5,D0	; TAILLE DU TEXTE
YOUPI2:
BSR.L PRINT			; VA PRINTER CHAR
ADD.L #2,A1			; ADRESSE SUIVANTE
ADD.L #1,A0			; LETTRE SUIVANTE
DBRA D0,YOUPI2			; N FOIS
RTS				; RETOUR

PRINT3:
LEA TEXTE3,A0			; POINTE SUR ADRESSE TEXTE
MOVE.L (A0)+,A1			; ADRESSE -> A1 ET A0 SUR CHAR1
ADD.L #$60000,A1
MOVE.L #FINTEXTE3-TEXTE3-5,D0	; TAILLE DU TEXTE
YOUPI3:
BSR.L PRINT			; VA PRINTER CHAR
ADD.L #2,A1			; ADRESSE SUIVANTE
ADD.L #1,A0			; LETTRE SUIVANTE
DBRA D0,YOUPI3			; N FOIS
RTS				; RETOUR

PRINT4:
LEA TEXTE4,A0			; POINTE SUR ADRESSE TEXTE
MOVE.L (A0)+,A1			; ADRESSE -> A1 ET A0 SUR CHAR1
ADD.L #$60000,A1
MOVE.L #FINTEXTE4-TEXTE4-5,D0	; TAILLE DU TEXTE
YOUPI4:
BSR.L PRINT			; VA PRINTER CHAR
ADD.L #2,A1			; ADRESSE SUIVANTE
ADD.L #1,A0			; LETTRE SUIVANTE
DBRA D0,YOUPI4			; N FOIS
RTS				; RETOUR

PRINT5:
LEA TEXTE5,A0			; POINTE SUR ADRESSE TEXTE
MOVE.L (A0)+,A1			; ADRESSE -> A1 ET A0 SUR CHAR1
ADD.L #$60000,A1
MOVE.L #FINTEXTE5-TEXTE5-5,D0	; TAILLE DU TEXTE
YOUPI5:
BSR.L PRINT			; VA PRINTER CHAR
ADD.L #2,A1			; ADRESSE SUIVANTE
ADD.L #1,A0			; LETTRE SUIVANTE
DBRA D0,YOUPI5			; N FOIS
RTS				; RETOUR

PRINT6:
LEA TEXTE6,A0			; POINTE SUR ADRESSE TEXTE
MOVE.L (A0)+,A1			; ADRESSE -> A1 ET A0 SUR CHAR1
ADD.L #$60000,A1
MOVE.L #FINTEXTE6-TEXTE6-5,D0	; TAILLE DU TEXTE
YOUPI6:
BSR.L PRINT			; VA PRINTER CHAR
ADD.L #2,A1			; ADRESSE SUIVANTE
ADD.L #1,A0			; LETTRE SUIVANTE
DBRA D0,YOUPI6			; N FOIS
RTS				; RETOUR

PRINT7:
LEA TEXTE7,A0			; POINTE SUR ADRESSE TEXTE
MOVE.L (A0)+,A1			; ADRESSE -> A1 ET A0 SUR CHAR1
ADD.L #$60000,A1
MOVE.L #FINTEXTE7-TEXTE7-5,D0	; TAILLE DU TEXTE
YOUPI7:
BSR.L PRINT			; VA PRINTER CHAR
ADD.L #2,A1			; ADRESSE SUIVANTE
ADD.L #1,A0			; LETTRE SUIVANTE
DBRA D0,YOUPI7			; N FOIS
RTS				; RETOUR

PRINT8:
LEA TEXTE8,A0			; POINTE SUR ADRESSE TEXTE
MOVE.L (A0)+,A1			; ADRESSE -> A1 ET A0 SUR CHAR1
ADD.L #$60000,A1
MOVE.L #FINTEXTE8-TEXTE8-5,D0	; TAILLE DU TEXTE
YOUPI8:
BSR.L PRINT			; VA PRINTER CHAR
ADD.L #2,A1			; ADRESSE SUIVANTE
ADD.L #1,A0			; LETTRE SUIVANTE
DBRA D0,YOUPI8			; N FOIS
RTS				; RETOUR

PRINT:
LEA TABLE,A2			; TABLE CHARS -> A2
MOVE.B (A0),D1			; 1ER CHAR -> D1
MISTERD:
MOVE.W (A2),D2			; CHAR TABLE (=A) ->D2
CMP.B D2,D1			; CARACTERE=TABLE ?
BEQ.S GOGO			; OUI -> PRINT
ADDQ.L #4,A2			; NON -> LETTRE TABLE SUIVANTE
BRA MISTERD			; SAUT

GOGO:
ADD.L #2,A2			; ADRESSE FONTE
GO:
BTST #14,$DFF002
BNE.S GO
CLR.L D4
MOVE.W (A2),D4			; ADRESSE DANS FONTE
ADD.L #FONTS,D4			; +ADRESSE DEBUT FONTE -> A4 (S)
MOVE.L #$FFFFFFFF,$DFF044
MOVE.W #$09F0,$DFF040
CLR.W $DFF042
MOVE.W #40-2,$DFF064
MOVE.W #52-2,$DFF066
MOVE.L D4,$DFF050
MOVE.L A1,$DFF054
MOVE.W #$03C1,$DFF058
RTS

FONT:				; CHERCHE ET IMPRIME CARACTERE
LEA TABLE,A0			; ADRESSE DE LA TABLE ALPHABET -> A0
MOVE.L POINTEURTEXTE,A1		; ADRESSE POINTEUR DU SCROLL   -> A1
MOVE.B (A1),D1			; 1ER CARACTERE DU SCROLL      -> D1
SPEEDMAN:			; MON SPREADER (IMPORTANT ICI!)	
MOVE.W (A0),D0			; CARACTERE ALPHABET           -> D0
CMP.B D1,D0			; COMPARE D0 A D1 (2 LETTRES)
BEQ.S BLTGO			; MEMES LETTRES -> AFFICHE LETTRE
ADDQ.L #4,A0			; LETTRE ALPHABET SUIVANTE
BRA SPEEDMAN			; CHERCHE A NOUVEAU

BLTGO:
CLR.L D0			; EFFACE D0
ADDQ.L #1,POINTEURTEXTE		; LETTRE SCROLL SUIVANTE 
CMPA.L #FINTEXTE,A1		; DERNIERE LETTRE DU SCROLL ? 
BLO.S CESTPASFINI		; NON -> CESTPASFINI
MOVE.L #TEXTE,POINTEURTEXTE	; OUI -> REPOINTE SUR 1ERE LETTRE
BRA FONT			; ET REIMPRIME LETTRE
CESTPASFINI:			; (PAS DERNIERE LETTRE)
ADD.L #$2,A0
MOVE.W (A0),D0			; ADRESSE CARACTERE DANS L'IMAGE FONTE
ADD.L #FONTS,D0			; + ADRESSE DE LA FONTE
MOVE.L #$6315A,A1		; ADRESSE ECRAN DE LA DESTINATION

COPYFONT:
BTST #14,$DFF002
BNE.S COPYFONT
MOVE.L #$FFFFFFFF,$DFF044	; MASQUE A GAZ (MASK SOURCE A)
MOVE.W #$09F0,$DFF040		; BLTCON 0
MOVE.W #0000,$DFF042		; BLTCON 1
MOVE.W #52-2,$DFF066		; MODULO D
MOVE.W #0038,$DFF064		; MODULO A
MOVE.L    D0,$DFF050		; SOURCE A
MOVE.L    A1,$DFF054		; DESTINATION D
MOVE.W  #$03C1,$DFF058		; 3C1
RTS

;---------------------
; ROUTINE DE SCROLLING
;---------------------

SCROLL:
LEA $63128,A0			; ADRESSE SOURCE DE L'ECRAN
RS:
BTST #14,$DFF002
BNE.S RS
MOVE.L #$FFFFFFFF,$DFF044	; MASK A
MOVE.W #$0000,$DFF066		; MODULO D
MOVE.W #$0000,$DFF064		; MODULO A
CLR.W $DFF042			; COPIE NORMALE SVP
MOVE.W VITESSE,$DFF040		; DECALE DE VITESSE (1-15) -> DROITE
MOVE.L A0,$DFF050		; SOURCE A
SUBQ.L #2,A0			; SCROLL DE 16 PIXELS <- GAUCHE
MOVE.L A0,$DFF054		; DESTINATION
MOVE.W #$041A,$DFF058		; BLTSIZE
RTS

;--------------------------
; MUSIQUE !!!!!!!!!
;--------------------------
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

;--------------------------------------------------------------
; DATAS  DATAS  DATAS  DATAS  DATAS  DATAS  DATAS  DATAS  DATAS  
;--------------------------------------------------------------


VITESSE:
DC.W $C9F0
ESPACEMENT:
DC.L 3
SENS:
DC.B 0
EVEN

PCOLORS:
DC.L COLORS
COLORS:
DC.W $F03,$F02,$F01,$F00,$F11,$F22,$F33,$F44,$F55,$F66,$F77,$F88
DC.W $F99,$FAA,$FBB,$FCC,$FDD,$FEE,$FFF,$FEF,$FDF,$FCF,$FBF,$FAF
DC.W $F9F,$F8F,$F7F,$F6F,$F5F,$F4F,$F3F,$F2F,$F1F,$F0F,$F0E,$F0D
DC.W $F0C,$F0B,$F0A,$F09,$F08,$F07,$F06,$F05,$F04,$F03,$F02,$F01
DC.W $F00,$F01,$F02
FINCOLORS:
DC.W $F03

TABLE:
DC.W "a",$0000,"b",$0002,"c",$0004,"d",$0006,"e",$0008,"f",$000a
DC.W "g",$000c,"h",$000e,"i",$0010,"j",$0012,"k",$0014,"l",$0016
DC.W "m",$0018,"n",$001a,"o",$001c,"p",$001e,"q",$0020,"r",$0022
DC.W "s",$0024,"t",$0026

DC.W "u",$0280,"v",$0282,"w",$0284,"x",$0286
DC.W "y",$0288,"z",$028A,"0",$028C,"1",$028E,"2",$0290,"3",$0292
DC.W "4",$0294,"5",$0296,"6",$0298,"7",$029A,"8",$029C,"9",$029E
DC.W "+",$02A0," ",$02A2,"!",$02A4,".",$02A6

TEXTE:
;DC.B 'abcdefghijklmnopqrst uvwxyz0123456789+!.      '
DC.B '  hi! there is the menutrainer from ritchy for the cracker '
DC.B 'of this great family named tgs.    move your joystick up and '
DC.B 'down to choose the option and left and right to put off or '
DC.B 'on these options.      have fun and dont forget     '
DC.B 'just crack   we will do the rest         !ritchy!     '
DC.B '              '
FINTEXTE:
EVEN

POINTEURTEXTE:
DC.L TEXTE
TEXTE1:
DC.L 6					; ADRESSE ECRAN (x52 + n)
DC.B "the great swappers"		; TEXTE
FINTEXTE1:
EVEN
TEXTE2:
DC.L 52*20+8
DC.B "proudly presents"
FINTEXTE2:
EVEN
TEXTE3:
DC.L 52*60+16
DC.B "p47 +++"
FINTEXTE3:
EVEN
TEXTE4:
DC.L 52*100+2
DC.B "infinites lives    off"
FINTEXTE4:
EVEN
TEXTE5:
DC.L 52*120+2
DC.B "collisions         off"
FINTEXTE5:
EVEN
TEXTE6:
DC.L 52*140+2
DC.B "option 3           off"
FINTEXTE6:
EVEN
TEXTE7:
DC.L 52*160+2
DC.B "option 4           off"
FINTEXTE7:
EVEN
TEXTE8:
DC.L 52*200+14
DC.B "start game"
FINTEXTE8:
EVEN

LIGNE:
DC.B 1					; LIGNE EN COURS D'EDITION
EVEN

OPTION1:
DC.B 1,0				; 1=ON OFF TYPE  0=OFF
DC.L 52*100+40				; ADRESSE ECRAN OPTION 1
DC.B " onoff"				; TEXTES ! 
FINOPTION1:

OPTION2:
DC.B 1,0
DC.L 52*120+40
DC.B " onoff" 
FINOPTION2:

OPTION3:
DC.B 1,0
DC.L 52*140+40
DC.B " onoff" 
FINOPTION3:

OPTION4:
DC.B 1,0
DC.L 52*160+40
DC.B " onoff" 
FINOPTION4:

OPTION5:
DC.L $0

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

GFXNAME:
DC.B "graphics.library",0
EVEN
GFXBASE:
DC.L 0
SAVECL:
DC.L 0
NCL:				; MA COPPER-LIST
DC.W $008E,$2971		; DWISTRT (H129,V41)
DC.W $0090,$29D1                ; DWISTOP (H449,V297)
DC.W $0092,$0028		; DFFSTRT
DC.W $0094,$00D8		; DFFSTOP
DC.W $00E0,$0006
DC.W $00E2,$0000
DC.W $00E4,$0006
DC.W $00E6,$3CF0
DC.W $0100,$2200		; BLTCON 0 (5400)
DC.W $0108,$0006
DC.W $010A,$0000
DC.W $0102,$0000
DC.W $0120,$0000
DC.W $0122,$0000

DC.W $0182,$888

DC.W $1B0F,$FFFE,$180,$00F		; TUBE BLEU HAUT
DC.W $1C0F,$FFFE,$180,$00E
DC.W $1D0F,$FFFE,$180,$00D
DC.W $1E0F,$FFFE,$180,$00C
DC.W $1F0F,$FFFE,$180,$00B
DC.W $200F,$FFFE,$180,$00A
DC.W $210F,$FFFE,$180,$009
DC.W $220F,$FFFE,$180,$008
DC.W $230F,$FFFE,$180,$007
DC.W $240F,$FFFE,$180,$006
DC.W $250F,$FFFE,$180,$005
DC.W $260F,$FFFE,$180,$004
DC.W $270F,$FFFE,$180,$003
DC.W $280F,$FFFE,$180,$002
DC.W $290F,$FFFE,$180,$001,$182,$077
DC.W $2A0F,$FFFE,$180,$000,$182,$088

DC.W $2B0F,$FFFE,$182,$099
DC.W $2C0F,$FFFE,$182,$0AA
DC.W $2D0F,$FFFE,$182,$0BB
DC.W $2E0F,$FFFE,$182,$0CC
DC.W $2F0F,$FFFE,$182,$0DD
DC.W $300F,$FFFE,$182,$0EE
DC.W $310F,$FFFE,$182,$0DD
DC.W $320F,$FFFE,$182,$0CC
DC.W $330F,$FFFE,$182,$0BB
DC.W $340F,$FFFE,$182,$0AA
DC.W $350F,$FFFE,$182,$099
DC.W $360F,$FFFE,$182,$088
DC.W $370F,$FFFE,$182,$077
DC.W $380F,$FFFE,$182,$066

DC.W $3D0F,$FFFE,$182,$066
DC.W $3E0F,$FFFE,$182,$077
DC.W $3F0F,$FFFE,$182,$088
DC.W $400F,$FFFE,$182,$099
DC.W $410F,$FFFE,$182,$0AA
DC.W $420F,$FFFE,$182,$0BB
DC.W $430F,$FFFE,$182,$0CC
DC.W $440F,$FFFE,$182,$0DD
DC.W $450F,$FFFE,$182,$0EE
DC.W $460F,$FFFE,$182,$0FF
DC.W $470F,$FFFE,$182,$0EE
DC.W $480F,$FFFE,$182,$0DD
DC.W $490F,$FFFE,$182,$0CC
DC.W $4A0F,$FFFE,$182,$0BB
DC.W $4B0F,$FFFE,$182,$0AA
DC.W $4C0F,$FFFE,$182,$099

DC.W $650F,$FFFE,$182,$018
DC.W $660F,$FFFE,$182,$039
DC.W $670F,$FFFE,$182,$05A
DC.W $680F,$FFFE,$182,$07B
DC.W $690F,$FFFE,$182,$09C
DC.W $6A0F,$FFFE,$182,$0BD
DC.W $6B0F,$FFFE,$182,$0DE
DC.W $6C0F,$FFFE,$182,$0FF
DC.W $6D0F,$FFFE,$182,$0DE
DC.W $6E0F,$FFFE,$182,$0BD
DC.W $6F0F,$FFFE,$182,$09C
DC.W $700F,$FFFE,$182,$07B
DC.W $710F,$FFFE,$182,$05A
DC.W $720F,$FFFE,$182,$039
DC.W $730F,$FFFE,$182,$018
DC.W $740F,$FFFE,$182,$007

CO1:
DC.W $8C0F,$FFFE,$182,$888		; COULEUR OPTION1
DC.W $9C0F,$FFFE,$182,$888
CO2:					; OPTION 2
DC.W $A00F,$FFFE,$182,$888
DC.W $B00F,$FFFE,$182,$888
CO3:					; OPTION 3
DC.W $B40F,$FFFE,$182,$888
DC.W $C40F,$FFFE,$182,$888
CO4:					; OPTION 4
DC.W $C80F,$FFFE,$182,$888
DC.W $D80F,$FFFE,$182,$888
CO5:
DC.W $F00F,$FFFE,$182,$888		; START GAME
DC.W $FFFF,$FFDE,$182,$888

;DC.W $FFFF,$FFDE
REDEF:
DC.W $1B0F,$FF00			; DEGRADES FONTES
DC.W $0182,$0F0F
DC.W $1C0F,$FF00
DC.W $0182,$0F0E
DC.W $1D0F,$FF00
DC.W $0182,$0F0D
DC.W $1E0F,$FF00
DC.W $0182,$0F0C
DC.W $1F0F,$FF00
DC.W $0182,$0F0B
DC.W $200F,$FF00
DC.W $0182,$0F0A
DC.W $210F,$FF00
DC.W $0182,$0F09
DC.W $220F,$FF00
DC.W $0182,$0F08
DC.W $230F,$FF00
DC.W $0182,$0F07
DC.W $240F,$FF00
DC.W $0182,$0F06
DC.W $250F,$FF00
DC.W $0182,$0F05
DC.W $260F,$FF00
DC.W $0182,$0F04
DC.W $270F,$FF00
DC.W $0182,$0F03
DC.W $280F,$FF00
DC.W $0182,$0F02
DC.W $290F,$FF00
DC.W $0182,$0F01
FINREDEF:


DC.W $260F,$FF00,$180,$001
DC.W $270F,$FF00,$180,$002
DC.W $280F,$FF00,$180,$003
DC.W $290F,$FF00,$180,$004
DC.W $2A0F,$FF00,$180,$005
DC.W $2B0F,$FF00,$180,$006
DC.W $2C0F,$FF00,$180,$007
DC.W $2D0F,$FF00,$180,$008
DC.W $2E0F,$FF00,$180,$009
DC.W $2F0F,$FF00,$180,$00A
DC.W $300F,$FF00,$180,$00B
DC.W $310F,$FF00,$180,$00C
DC.W $320F,$FF00,$180,$00D
DC.W $330F,$FF00,$180,$00E
DC.W $340F,$FF00,$180,$00F
DC.W $350F,$FF00,$180,$000
DC.W $FFFF,$FF00

FONTS:
BLK.B 1280
MODULE:
FININTRO=MODULE+22980
