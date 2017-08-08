;-------------------------------------------
; ROUTINE DE SCROLLING © 01/11/1989 MISTER D
;-------------------------------------------
; 1ere INTRO Mr.D & SpeedMan
;-------------------------------------------
ORG $35000			; CHARGE LE PROGRAMME
LOAD $35000			; EN RAM ($35000)

>EXTERN "LOGO",LOGO
>EXTERN "AZ",AZ
>EXTERN "MRD1",MUSIC

BPL1=$60000			; ADRESSES DES
BPL2=$62C00			; BITPLANS
BPL3=$65800			;
BPL4=$68400			;
BPL5=$6B000			;

EXECBASE=4			; ADRESSE DE BASE DE EXEC.LIB
FORBID=-132			; OFFSET DE LA FONCTION ETEINDRE
PERMIT=-138			; ET REMETTRE LE MULTITACHES
OPENLIB=-552			; OFFSET OUVRIR ET
CLOSELIB=-414			; FERMER LES BIBLIOTHEQUES

R:				; ROUTINE A APPELER
movem.l	d0-d7/a0-a6,-(a7)
MOVE.L EXECBASE,A6		; ADR. DE BASE EXEC.LIB -> A6
JSR FORBID(A6)			; ETEINDS LE MULTITACHES

LEA GFXNAME,A1			; POINTE SUR LE NOM DE LA LIB
JSR OPENLIB(A6)			; OUVRE GRAPHICS.LIB
MOVE.L D0,GFXBASE		; SAUVE ADR/ DE BASE GFX.LIB

MOVE.L #BPL1,A3			; ADRESSE DU 1ER BITPLAN 
MOVE.L #44/4*256*5,D0		; TAILLE TOTALE ECRAN (BYTES*LIGNES)  
EFFACE:				; ROUTINE DE CLS
CLR.L (A3)+			; EFFACE ENDROIT ACTUEL
DBRA D0,EFFACE			; ENDROIT SUIVANT

MOVE.L GFXBASE,A0		; ADRESSE DE BASE GFX.LIB -> A0
MOVE.L $32(A0),OLDCOPPER	; SAUVE ANCIENNE COPPER-LIST
MOVE.L #NEWCOPPER,$32(A0)	; MET LA MIENNE

;----------------------------
; COPIE DU LOGO MR.D + SPEEDY
;----------------------------
MOVE.L #LOGO,D0			; ADRESSE DU LOGO
MOVE.L #$601BD,D1		; ADRESSE ECRAN CENTRE LIGNE 10
MOVE.L #5-1,D2			; BITPLANS-1
COPY:
BSR.L ATTENTE			; ATTENTE BLITTER
MOVE.L #$FFFFFFFF,$DFF044	; MASK A
MOVE.W #$00,$DFF064		; MODULO A
MOVE.W #44-30,$DFF066		; MODULO D
MOVE.W #$09F0,$DFF040		; USE A&D
MOVE.W #$00,$DFF042		; COPIE NORMALE
MOVE.L D0,$DFF050		; SOURCE A
MOVE.L D1,$DFF054		; DESTINATION D
MOVE.W #160,D3			; HAUTEUR LOGO
LSL.L #6,D3
ORI.W #240/16,D3		; LARGEUR LOGO
MOVE.W D3,$DFF058		; BLTSIZE > GO !
ADD.L #30*160,D0		; ADDITIONNE TAILLE LOGO
ADD.L #44*256,D1		; ADDITIONNE TAILLE ECRAN (+4 MODULO)
DBRA D2,COPY			; SUR 5 BITPLANS (32 COULEURS)

;-------------------
; ROUTINE PRINCIPALE
;-------------------

Deb:
bsr	mt_init

MAIN:
	cmp.w	#0,vit
	bgt.s	non
	move.w	#6,vit
non:	sub.w	#1,vit
BSR.L FONT			; CHERCHE ET IMPRIME CARACTERE
MOVE.W  ESPACEMENT,D7		; SCROLL DE 'ESPACEMENT'
ESPACE:
BSR.L SCROLL			; SCROLL LE TEXTE
SAUT2:
BTST#10,$DFF016			; MOUSE DROIT -> QUITTE
BEQ.S FIN
BSR.L MONTE			; MONTE COPPER ET VAGUES SUR LOGO
BSR.L WAIT			; ATTENDS ENTRE CHAQUE SCROLL
BSR.L REFLETS			; VAGUES SUR REFLETS
bsr	mt_music
BTST #6,$BFE001			; BOUTON GAUCHE APPUYE ?
BNE SAUT			; NON
BSR.L WAIT			; OUI,ALORS ATTENDS UN PEU
BRA SAUT2			; ET SAUTE ROUTINE DE SCROLL
SAUT:
DBRA D7,ESPACE			; SCROLL
BRA MAIN			; REPETE MAIN ROUTINE

;---------------------------------
; ROUTINE POUR TOUT REFERMER (FIN)
;---------------------------------

FIN:
MOVE.L GFXBASE,A0		; ADRESSE DE BASE GFX.LIB  ->A0
MOVE.L OLDCOPPER,$32(A0)	; RESTITUE L'ANCIENNE COPPER-LIST
MOVE.L EXECBASE,A6		; ADRESSE DE BASE EXEC.LIB -> A6
MOVE.L GFXBASE,A1		; ADRESSE DE BASE GFX.LIB  -> A1
JSR CLOSELIB(A6)		; FERME GFX.LIB
JSR PERMIT(A6)			; REMET LE MULTITACHES
bsr	mt_end
movem.l	(a7)+,d0-d7/a0-a6
RTS				; BYE BYE (MISTER D)

;----------------------------------------------------------------
;                          ROUTINES
;----------------------------------------------------------------
MONTE:
MOVE.L PCOULEURS,A0	; POINTEUR COULEURS        -> A0
MOVE.L PVAGUES,A3	; POINTEUR VAGUES          -> A3
LEA COPPER+6,A1		; 1ERE COULEUR COPPER-LIST -> A1
LEA COPPER+10,A4	; POINTE SUR $102
LEA COPPER+6+12,A2	; 2NDE COULEUR COPPER-LIST -> A2
LEA COPPER+10+12,A5	; POINTE SUR $102 LIGNE DESSOUS
MOVE.L #160-1,D0	; SUR 160 LIGNES COPPER    -> D0
ZORGLUB:
MOVE.W (A2),(A1)	; MONTE COULEUR
MOVE.W (A5),(A4)	; 'MONTE' VAGUE
ADD.L #2,A0		; POINTE SUR COULEUR TABLE+1
ADD.L #2,A3		; VAGUE SUIVANTE
ADD.L #12,A1		; POINTE SUR COULEUR LIGNE+1
ADD.L #12,A2		; POINTE SUR LIGNE2 +1
ADD.L #12,A4		; POINTE SUR VAGUE SUIVANTE
ADD.L #12,A5		; IDEM,1 LIGNE EN DESSOUS

CMPA.L #FINCOULEURS,A0	; FIN DE TABLE DES COULEURS ?
BLO KIKI		; NON -> KIKI
LEA COULEURS,A0		; OUI : ON REPOINTE AU DEBUT
MOVE.L A0,PCOULEURS	;
KIKI:

CMPA.L #FINVAGUES,A3	; FIN DE TABLE DES VAGUES ?
BLO KAKA		; NON -> KAKA
LEA VAGUES,A3		; OUI : ON REPOINTE AU DEBUT
MOVE.L A3,PVAGUES	;
KAKA:

DBRA D0,ZORGLUB		; SUR 160 LIGNES
MOVE.W (A0),FINCOPPER-6	; COULEUR -> DERNIERE LIGNE
MOVE.W (A3),FINCOPPER-2	; VAGUE   -> DERNIERE LIGNE
ADD.L #2,PCOULEURS	; COULEURS SUIVANTES
ADD.L #2,PVAGUES	; VAGUES SUIVANTES
RTS			; FIN DE ROUTINE

REFLETS:		; FAIT DES VAGUES SUR LE REFLET
LEA VR+6,A0		; POINTE SUR LIGNE 1 DU REFLET
LEA VR+6+32,A1		; POINTE SUR LIGNE 2 DU REFLET
LEA VR+6,A2		; POUR SAUVER APRES LA VAGUE DU HAUT
MOVE.L #16-1,D0		; 16 LIGNES DE VAGUES
GPZ:
MOVE.W (A1),(A0)	; 'MONTE' LES REFLETS
ADD.L #32,A0		; VALEUR LIGNE HAUT SUIVANTE
ADD.L #32,A1		; VALEUR LIGNE BAS  SUIVANTE
DBRA D0,GPZ		; MONTE SUR 16 LIGNES
MOVE.W (A2),FVR-2	; RESTITUE LA VAGUE DU HAUT -> BAS
RTS			; FIN DE LA ROUTINE

FONT:				; CHERCHE ET IMPRIME CARACTERE
CLR.L D0
MOVE.L POINTEURTEXTE,A1		; ADRESSE POINTEUR DU SCROLL   -> A1
MOVE.B (A1),D0			; 1ER CARACTERE DU SCROLL      -> D1
SUB.B #65,D0			; MOINS ASCII (1ER CHAR FONTE)
MULU #400,D0			; * TAILLE 1 CARACTERE

BLTGO:
ADDQ.L #1,POINTEURTEXTE		; LETTRE SCROLL SUIVANTE 
CMPA.L #FINTEXTE,A1		; DERNIERE LETTRE DU SCROLL ? 
BLO.S CESTPASFINI		; NON -> CESTPASFINI
MOVE.L #TEXTE,POINTEURTEXTE	; OUI -> REPOINTE SUR 1ERE LETTRE
JMP FONT			; ET REIMPRIME LETTRE
CESTPASFINI:			; (PAS DERNIERE LETTRE)
ADD.L #AZ,D0			; ADRESSE DEBUT CHARS EN MEMOIRE
MOVE.L #$62180,A1		; ADRESSE DESTINATION LIGNE 194

MOVE.L #3-1,D1			; COPIE LETTRE SUR 3 BITPLANS

COPYFONT:
BSR ATTENTE			; WAIT AND SEE
MOVE.L #$FFFFFFFF,$DFF044	; MASQUE A GAZ (MASK SOURCE A)
MOVE.W #$09F0,$DFF040		; BLTCON 0
MOVE.W #0000,$DFF042		; BLTCON 1
MOVE.W #0040,$DFF066		; MODULO D
MOVE.W #00,$DFF064		; MODULO A
MOVE.L    D0,$DFF050		; SOURCE A
MOVE.L    A1,$DFF054		; DESTINATION D
MOVE.W  #$0802,$DFF058		; BLTSIZE (32 lignes,2 mots)

ADD.L  #128,D0			; + TAILLE DESSIN
ADDA.L #44*256,A1		; + TAILLE ECRAN
DBRA D1,COPYFONT		; LES 3 BITPLANS
RTS

;---------------------
; ROUTINE DE SCROLLING
;---------------------

SCROLL:
BTST #6,$BFE001			; MOUSE GAUCHE -> STOPSCROLL 
BEQ SCROLL
LEA $62158,A0			; ADRESSE SOURCE LIGNE 194
MOVE.L #3-1,D0			; TOUJOURS SUR 3 BITPLANS
BSR ELECTRON			; ATTENTE DU RASTER EN LIGNE 120
RS:
BSR ATTENTE			; ATTENDS QUE LE BLITTER AIT FINI
MOVE.L #$FFFFFFFF,$DFF044	; MASK A
MOVE.W #$0000,$DFF066		; MODULO D
MOVE.W #$0000,$DFF064		; MODULO A
CLR.W $DFF042			; COPIE NORMALE SVP
MOVE.W VITESSE,$DFF040		; DECALE DE VITESSE (1-15) -> DROITE
MOVE.L A0,$DFF050		; SOURCE A
SUBQ.L #2,A0			; SCROLL DE 16 PIXELS <- GAUCHE
MOVE.L A0,$DFF054		; DESTINATION
MOVE.W #$0816,$DFF058		; BLTSIZE
ADD.L #44*256,A0		; ADDITIONNE TAILLE BITPLAN
DBRA D0,RS
RTS


;-------------------
; ATTENTE DU BLITTER
;-------------------

ATTENTE:
BTST#14,$DFF002			; A-T-IL FINI ?
BNE.S ATTENTE			; NON !
RTS				; SI ! -> RETOUR

;------------------------
; RALENTI ENTRE 2 SCROLLS
;------------------------

WAIT:
MOVE.W TEMPS,D5			; TEMPS -> D5
WI:
DBRA D5,WI			; DECREMENTE ET SAUTE TANT >0
RTS				; RETOUR

;-------------------------------
; ATTENTE DU RASTER EN LIGNE 120
;-------------------------------

ELECTRON:
CMP.B #120,$DFF006		; RASTER <120 ???
BLS.S ELECTRON			; NON !
RTS				; SI ! -> RETOUR

;----------------------------------
; DONNEES,DATAS,VARIABLES,TABLES...
;----------------------------------
vit:	dc.w	2,0
vit1:	dc.w	2,0
haut0:	dc.w	0,0
haut1:	dc.w	0,0
haut2:	dc.w	0,0
haut3:	dc.w	0,0
nb1:	dc.w	0,0
nb2:	dc.l	1,0
nb3:	dc.l	0,0
pp:	dc.l	0,0
phase:	dc.l	0,0
mvt:	dc.l	4,0
first:	dc.l	0,0
EVEN

GFXNAME:
DC.B "graphics.library",0
TEXTE:
;DC.B 'abcdefgAhijklmnopqrstuvwxyz!?B:()" 0123456C789@^$*=Å&®Þ¶§Ð£÷Ç'

DC.B '         '
DC.B	'YEAH! VOICI MA PREMIERE INTRO...BEUURRKK... CODING AND '
DC	'MUSIC BY MISTER D (RITCHY) AND FONTS BY KAMIKAZE. LMB '
DC	'TO STOP SCROLL AND RMB TO EXIT...'
FINTEXTE:
EVEN

;--------------------------------------------------------
; PLAYROUTINE
;--------------------------------------------------------

mt_init:
	lea	music,a0
	add.l	#$01d8,a0
	add.l	#$01e0,a0
	move.l	#$0080,d0
	moveq	#$00,d1
mt_init1:
	move.l	d1,d2
	subq.w	#1,d0
mt_init2:
	move.b	(a0)+,d1
	cmp.b	d2,d1
	bgt.s	mt_init1
	dbf	d0,mt_init2
	addq.b	#1,d2

mt_init3:
	lea	music,a0
	lea	mt_sample1(pc),a1
	asl.l	#$08,d2
	asl.l	#$02,d2
	add.l	#$0258,d2
	moveq	#$0e,d0
	add.l	#$01e4,d2
	moveq	#$1e,d0
	add.l	a0,d2
mt_init4:
	move.l	d2,(a1)+
	moveq	#$00,d1
	move.w	42(a0),d1
	asl.l	#1,d1
	add.l	d1,d2
	add.l	#$1e,a0
	dbf	d0,mt_init4
	lea	mt_sample1(pc),a0
	moveq	#$00,d0
mt_clear:
	move.l	(a0,d0),a1
	clr.l	(a1)
	addq.l	#4,d0
	cmp.l	#$3c,d0
	blo.s	mt_clear
	cmp.l	#$7c,d0
	blo.s	mt_clear
	clr.w	$dff0a8
	clr.w	$dff0b8
	clr.w	$dff0c8
	clr.w	$dff0d8
	clr.l	mt_partnrplay
	clr.l	mt_partnote
	clr.l	mt_partpoint

	lea	music,a0
	move.b	$1d6(a0),d0
	move.b	$3b6(a0),d0
	move.b	d0,mt_maxpart+1
	rts

mt_end:
	clr.w	$dff0a8
	clr.w	$dff0b8
	clr.w	$dff0c8
	clr.w	$dff0d8
	move.w	#$000f,$dff096
	rts
mt_music:
	addq.l	#1,mt_counter
mt_cool:cmp.l	#6,mt_counter
	bne.s	mt_notsix
	clr.l	mt_counter
	bra	mt_rout2
mt_notsix:
	lea	mt_aud1temp(pc),a6
	tst.b	3(a6)
	beq.s	mt_arp1
	lea	$dff0a0,a5		
	bsr.s	mt_arprout
mt_arp1:lea	mt_aud2temp(pc),a6
	tst.b	3(a6)
	beq.s	mt_arp2
	lea	$dff0b0,a5
	bsr.s	mt_arprout
mt_arp2:lea	mt_aud3temp(pc),a6
	tst.b	3(a6)
	beq.s	mt_arp3
	lea	$dff0c0,a5
	bsr.s	mt_arprout
mt_arp3:lea	mt_aud4temp(pc),a6
	tst.b	3(a6)
	beq.s	mt_arp4
	lea	$dff0d0,a5
	bra.s	mt_arprout
mt_arp4:rts

mt_arprout:
	move.b	2(a6),d0
	and.b	#$0f,d0
	tst.b	d0
	beq.s	mt_arpegrt
	cmp.b	#1,d0
	beq.s	mt_portup
	cmp.b	#2,d0
	beq.s	mt_portdwn
	rts

mt_portup:
	moveq	#$00,d0
	move.b	3(a6),d0
	sub.w	d0,22(a6)
	cmp.w	#$71,22(a6)
	bpl.s	mt_ok1
	move.w	#$71,22(a6)
mt_ok1:	move.w	22(a6),6(a5)
	rts

mt_portdwn:
	moveq	#$00,d0
	move.b	3(a6),d0
	add.w	d0,22(a6)
	cmp.w	#$358,22(a6)
	bmi.s	mt_ok2
	move.w	#$358,22(a6)
mt_ok2:	move.w	22(a6),6(a5)
	rts

mt_arpegrt:
	cmp.l	#1,mt_counter
	beq.s	mt_loop2
	cmp.l	#2,mt_counter
	beq.s	mt_loop3
	cmp.l	#3,mt_counter
	beq.s	mt_loop4
	cmp.l	#4,mt_counter
	beq.s	mt_loop2
	cmp.l	#5,mt_counter
	beq.s	mt_loop3
	rts

mt_loop2:
	moveq	#$00,d0
	move.b	3(a6),d0
	lsr.b	#4,d0
	bra.s	mt_cont
mt_loop3:
	moveq	#$00,d0
	move.b	3(a6),d0
	and.b	#$0f,d0
	bra.s	mt_cont
mt_loop4:
	move.w	16(a6),d2
	bra.s	mt_endpart
mt_cont:
	asl.w	#1,d0
	moveq	#$00,d1
	move.w	16(a6),d1
	lea	mt_arpeggio(pc),a0
mt_loop5:
	move.w	(a0,d0),d2
	cmp.w	(a0),d1
	beq.s	mt_endpart
	addq.l	#2,a0
	bra.s	mt_loop5
mt_endpart:
	move.w	d2,6(a5)
	rts

mt_rout2:
	lea	music,a0
	move.l	a0,a3
	add.l	#$0c,a3
	move.l	a0,a2
	add.l	#$1d8,a2
	add.l	#$258,a0
	add.l	#$1e0,a2
	add.l	#$1e4,a0
	move.l	mt_partnrplay,d0
	moveq	#$00,d1
	move.b	(a2,d0),d1
	asl.l	#$08,d1
	asl.l	#$02,d1
	add.l	mt_partnote,d1
	move.l	d1,mt_partpoint
	clr.w	mt_dmacon

	lea	$dff0a0,a5
	lea	mt_aud1temp(pc),a6
	move.b	#0,voie
	bsr	mt_playit
	lea	$dff0b0,a5
	lea	mt_aud2temp(pc),a6
	move.b	#1,voie
	bsr	mt_playit
	lea	$dff0c0,a5
	lea	mt_aud3temp(pc),a6
	move.b	#2,voie
	bsr	mt_playit
	lea	$dff0d0,a5
	lea	mt_aud4temp(pc),a6
	move.b	#3,voie
	bsr	mt_playit
	move.w	#$01f4,d0
mt_rls:	dbf	d0,mt_rls

	move.w	#$8000,d0
	or.w	mt_dmacon,d0
	move.w	d0,$dff096

	lea	mt_aud4temp(pc),a6
	cmp.w	#1,14(a6)
	bne.s	mt_voice3
	move.l	10(a6),$dff0d0
	move.w	#1,$dff0d4
mt_voice3:
	lea	mt_aud3temp(pc),a6
	cmp.w	#1,14(a6)
	bne.s	mt_voice2
	move.l	10(a6),$dff0c0
	move.w	#1,$dff0c4
mt_voice2:
	lea	mt_aud2temp(pc),a6
	cmp.w	#1,14(a6)
	bne.s	mt_voice1
	move.l	10(a6),$dff0b0
	move.w	#1,$dff0b4
mt_voice1:
	lea	mt_aud1temp(pc),a6
	cmp.w	#1,14(a6)
	bne.s	mt_voice0
	move.l	10(a6),$dff0a0
	move.w	#1,$dff0a4
mt_voice0:
	move.l	mt_partnote,d0
	add.l	#$10,d0
	move.l	d0,mt_partnote
	cmp.l	#$400,d0
	bne.s	mt_stop
mt_higher:
	clr.l	mt_partnote
	addq.l	#1,mt_partnrplay
	moveq	#$00,d0
	move.w	mt_maxpart,d0
	move.l	mt_partnrplay,d1
	cmp.l	d0,d1
	bne.s	mt_stop
	clr.l	mt_partnrplay

mt_stop:tst.w	mt_status
	beq.s	mt_stop2
	clr.w	mt_status
	bra.s	mt_higher
mt_stop2:
	rts

mt_playit:
	move.l	(a0,d1),(a6)
	addq.l	#4,d1
	moveq	#$00,d2
	move.b	(a6),d2
	and.b	#$0f,(a6)
	lsl.w	#4,d2
	move.b	2(a6),d2
	lsr.w	#4,d2
	tst.b	d2
	beq.L	mt_nosamplechange
	moveq	#$00,d3
	lea	mt_samples(pc),a1
	move.l	d2,d4
	asl.l	#2,d2
	mulu	#$1e,d4
	move.l	(a1,d2),4(a6)
	move.w	(a3,d4),8(a6)
	move.w	2(a3,d4),18(a6)

	move.l	d0,-(a7)
	move.b	2(a6),d0
	and.b	#$f,d0
	cmp.b	#$c,d0
	bne	ok3
	move.w	#0,hh
	move.b	3(a6),hh	;valeur du volume
	move.w	hh,d7
	asr	#8,d7
	asr	#2,d7
	move.w	d7,hh
	cmp.w	#32,hh
	ble	ok2
	move.w	#8,hh
	bra	ok4
ok2:	cmp.w	#0,hh
	bge	ok4
	move.w	#4,hh
	bra	ok4
ok3:	move.w	#16,hh
ok4:	move.l	(a7)+,d0

	clr.l	d3
	move.w	4(a3,d4),d3
	tst.w	d3
	beq.s	mt_displace
	move.l	4(a6),d2
	add.l	d3,d2
	move.l	d2,4(a6)
	move.l	d2,10(a6)
	move.w	6(a3,d4),8(a6)
	move.w	6(a3,d4),14(a6)
	move.w	18(a6),8(a5)
	bra.s	mt_nosamplechange

mt_displace:
	move.l	4(a6),d2
	add.l	d3,d2
	move.l	d2,10(a6)
	move.w	6(a3,d4),14(a6)
	move.w	18(a6),8(a5)


mt_nosamplechange:
	tst.w	(a6)
	beq.L	mt_retrout
	move.w	(a6),16(a6)
	move.w	20(a6),$dff096
	move.l	4(a6),(a5)
	move.w	8(a6),4(a5)
	move.w	(a6),6(a5)
	move.w	20(a6),d0
	or.w	d0,mt_dmacon
v0:	cmp.b	#0,voie
	bne.s	v1
	move.w	hh,haut0
	bra	v5
v1:	cmp.b	#1,voie
	bne.s	v2
	move.w	hh,haut1
	bra	v5
v2:	cmp.b	#2,voie
	bne.s	v3
	move.w	hh,haut2
	bra	v5
v3:	cmp.b	#3,voie
	bne.s	v5
	move.w	hh,haut3
v5:

mt_retrout:
	tst.w	(a6)
	beq.s	mt_nonewper
	move.w	(a6),22(a6)

mt_nonewper:
	move.b	2(a6),d0
	and.b	#$0f,d0
	cmp.b	#11,d0
	beq.s	mt_posjmp
	cmp.b	#12,d0
	beq.s	mt_setvol
	cmp.b	#13,d0
	beq.s	mt_break
	cmp.b	#14,d0
	beq.s	mt_setfil
	cmp.b	#15,d0
	beq.s	mt_setspeed
	rts

mt_posjmp:
	not.w	mt_status
	moveq	#$00,d0
	move.b	3(a6),d0
	subq.b	#$01,d0
	move.l	d0,mt_partnrplay
	rts

mt_setvol:
	move.b	3(a6),8(a5)
	rts

mt_break:
	not.w	mt_status
	rts

mt_setfil:
	moveq	#$00,d0
	move.b	3(a6),d0
	and.b	#$01,d0
	rol.b	#$01,d0
	and.b	#$fd,$bfe001
	or.b	d0,$bfe001
	rts

mt_setspeed:
	move.b	3(a6),d0
	and.b	#$0f,d0
	beq.s	mt_back
	clr.l	mt_counter
	move.b	d0,mt_cool+5
mt_back:rts

mt_aud1temp:
	blk.w	10,0
	dc.w	$0001
	blk.w	2,0
mt_aud2temp:
	blk.w	10,0
	dc.w	$0002
	blk.w	2,0
mt_aud3temp:
	blk.w	10,0
	dc.w	$0004
	blk.w	2,0
mt_aud4temp:
	blk.w	10,0
	dc.w	$0008
	blk.w	2,0

mt_partnote:	dc.l	0
mt_partnrplay:	dc.l	0
mt_counter:	dc.l	0
mt_partpoint:	dc.l	0
mt_samples:	dc.l	0
mt_sample1:	blk.l $1f,0
mt_maxpart:	dc.w	$0000
mt_dmacon:	dc.w	$0000
mt_status:	dc.w	$0000

mt_arpeggio:
dc.w $0358,$0328,$02fa,$02d0,$02a6,$0280,$025c
dc.w $023a,$021a,$01fc,$01e0,$01c5,$01ac,$0194,$017d
dc.w $0168,$0153,$0140,$012e,$011d,$010d,$00fe,$00f0
dc.w $00e2,$00d6,$00ca,$00be,$00b4,$00aa,$00a0,$0097
dc.w $008f,$0087,$007f,$0078,$0071,$0000,$0000,$0000

voie:		dc.b	0,0
hh:		dc.w	0,0
smvt:		dc.w	$1d05,0
;----------------------------------------------------------


;--------------------------------------------------------
ESPACEMENT:
DC.W 6
VITESSE:
DC.W $C9F0
TEMPS:
DC.B $000F
EVEN
GFXBASE:
DC.L 0
OLDCOPPER:
DC.L 0

POINTEURTEXTE:
DC.L TEXTE
;@ =la main		= :disquette		Ð=music
;^ =kamikaze signature	Å :cygle omega		£=gfx
;$ =tete de mort	& :AND			÷=greets
;* =dragon		® :INXS			Ç=68000
;¶ =cigarette		§ :WC			Þ=wildcopper
TABLE:
DC.W "a",$0000,"b",$0004,"c",$0008,"d",$000C,"e",$0010,"f",$0014
DC.W "g",$0018,"h",$001C,"i",$0020,"j",$0024,"k",$0500,"l",$0504
DC.W "m",$0508,"n",$050C,"o",$0510,"p",$0514,"q",$0518,"r",$051C
DC.W "s",$0520,"t",$0524,"u",$0A00,"v",$0A04,"w",$0A08,"x",$0A0C
DC.W "y",$0A10,"z",$0A14,"!",$0A18,"?",$0A1C,":",$0A20,"@",$0A24
DC.W "0",$0F00,"1",$0F04,"2",$0F08,"3",$0F0C,"4",$0F10,"5",$0F14
DC.W "6",$0F18,"7",$0F1C,"8",$0F20,"9",$0F24,'"',$1400,"(",$1404
DC.W ")",$1408,"^",$140C,"-",$1410,".",$1414,"$",$1418,"*",$141C
DC.W "=",$1420," ",$1424,"Å",$1900,"&",$1904,"®",$1908,"Þ",$190C
DC.W "¶",$1910,"§",$1914,"Ð",$1918,"£",$191C,"÷",$1920,"Ç",$1924

;------------------------------
; TABLE DES COULEURS DES BARRES
;------------------------------
COULEURS:
DC.W 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
DC.W 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
DC.W 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
DC.W 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
DC.W 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
DC.W 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
DC.W 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
DC.W 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
DC.W 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
DC.W 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
DC.W 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

DC.W $020,$030,$040,$050,$060,$070,$080,$090,$0A0	; TUBE VERT
DC.W $0B0,$0C0,$0D0,$0E0,$0F0,$0E0,$0D0,$0C0,$0B0
DC.W $0A0,$090,$080,$070,$060,$050,$040,$030,$020

DC.W 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

DC.W $220,$330,$440,$550,$660,$770,$880,$990,$AA0	; TUBE JAUNE
DC.W $BB0,$CC0,$DD0,$EE0,$FF0,$EE0,$DD0,$CC0,$BB0
DC.W $AA0,$990,$880,$770,$660,$550,$440,$330,$220

DC.W 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

DC.W $200,$300,$400,$500,$600,$700,$800,$900,$A00	; TUBE ROUGE
DC.W $B00,$C00,$D00,$E00,$F00,$E00,$D00,$C00,$B00
DC.W $A00,$900,$800,$700,$600,$500,$400,$300,$200

DC.W 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
DC.W 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
DC.W 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
DC.W 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
DC.W 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
DC.W 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
DC.W 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
DC.W 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
DC.W 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

DC.W $020,$030,$040,$050,$060,$070,$080,$090,$0A0	; TUBES VERT/
DC.W $BB0,$CC0,$DD0,$EE0,$FF0,$EE0,$DD0,$CC0,$BB0	; JAUNE/ROUGE
DC.W $A00,$900,$800,$700,$600,$500,$400,$300,$200
DC.W $020,$030,$040,$050,$060,$070,$080,$090,$0A0
DC.W $BB0,$CC0,$DD0,$EE0,$FF0,$EE0,$DD0,$CC0,$BB0
DC.W $A00,$900,$800,$700,$600,$500,$400,$300,$200
DC.W $020,$030,$040,$050,$060,$070,$080,$090,$0A0
DC.W $BB0,$CC0,$DD0,$EE0,$FF0,$EE0,$DD0,$CC0,$BB0
DC.W $A00,$900,$800,$700,$600,$500,$400,$300,$200
DC.W $020,$030,$040,$050,$060,$070,$080,$090,$0A0
DC.W $BB0,$CC0,$DD0,$EE0,$FF0,$EE0,$DD0,$CC0,$BB0
DC.W $A00,$900,$800,$700,$600,$500,$400,$300,$200
DC.W $020,$030,$040,$050,$060,$070,$080,$090,$0A0
DC.W $BB0,$CC0,$DD0,$EE0,$FF0,$EE0,$DD0,$CC0,$BB0
DC.W $A00,$900,$800,$700,$600,$500,$400,$300,$200
DC.W $020,$030,$040,$050,$060,$070,$080,$090,$0A0
DC.W $BB0,$CC0,$DD0,$EE0,$FF0,$EE0,$DD0,$CC0,$BB0
DC.W $A00,$900,$800,$700,$600,$500,$400,$300,$200
DC.W $020,$030,$040,$050,$060,$070,$080,$090,$0A0
DC.W $BB0,$CC0,$DD0,$EE0,$FF0,$EE0,$DD0,$CC0,$BB0
DC.W $A00,$900,$800,$700,$600,$500,$400,$300,$200
DC.W $020,$030,$040,$050,$060,$070,$080,$090,$0A0
DC.W $BB0,$CC0,$DD0,$EE0,$FF0,$EE0,$DD0,$CC0,$BB0
DC.W $A00,$900,$800,$700,$600,$500,$400,$300,$200
DC.W $020,$030,$040,$050,$060,$070,$080,$090,$0A0
DC.W $BB0,$CC0,$DD0,$EE0,$FF0,$EE0,$DD0,$CC0,$BB0
DC.W $A00,$900,$800,$700,$600,$500,$400,$300,$200
DC.W $020,$030,$040,$050,$060,$070,$080,$090,$0A0
DC.W $BB0,$CC0,$DD0,$EE0,$FF0,$EE0,$DD0,$CC0,$BB0
DC.W $A00,$900,$800,$700,$600,$500,$400,$300,$200
DC.W $020,$030,$040,$050,$060,$070,$080,$090,$0A0
DC.W $BB0,$CC0,$DD0,$EE0,$FF0,$EE0,$DD0,$CC0,$BB0
DC.W $A00,$900,$800,$700,$600,$500,$400,$300,$200
DC.W $020,$030,$040,$050,$060,$070,$080,$090,$0A0
DC.W $BB0,$CC0,$DD0,$EE0,$FF0,$EE0,$DD0,$CC0,$BB0
DC.W $A00,$900,$800,$700,$600,$500,$400,$300,$200
DC.W $020,$030,$040,$050,$060,$070,$080,$090,$0A0
DC.W $BB0,$CC0,$DD0,$EE0,$FF0,$EE0,$DD0,$CC0,$BB0
DC.W $A00,$900,$800,$700,$600,$500,$400,$300,$200
DC.W $020,$030,$040,$050,$060,$070,$080,$090,$0A0
DC.W $BB0,$CC0,$DD0,$EE0,$FF0,$EE0,$DD0,$CC0,$BB0
DC.W $A00,$900,$800,$700,$600,$500,$400,$300,$200
DC.W 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
DC.W 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
DC.W 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
DC.W 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
DC.W 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
DC.W 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
DC.W 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
DC.W 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
DC.W 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
FINCOULEURS:
DC.W $000,$000

VAGUES:
DC.W 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
DC.W 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
DC.W 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
DC.W 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
DC.W 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
DC.W 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
DC.W 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
DC.W 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
DC.W 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
DC.W 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
DC.W 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
DC.W 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
DC.W 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
DC.W 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
DC.W 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
DC.W 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
DC.W 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
DC.W 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
DC.W 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
DC.W 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
DC.W 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
DC.W 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

DC.W $00,$00,$00,$00,$00,$00,$00,$00	; VAGUES LENTES
DC.W $11,$11,$11,$11,$11,$11,$11,$11
DC.W $22,$22,$22,$22,$22,$22,$22
DC.W $33,$33,$33,$33,$33,$33,$33
DC.W $44,$44,$44,$44,$44,$44
DC.W $55,$55,$55,$55,$55,$55
DC.W $66,$66,$66,$66,$66
DC.W $77,$77,$77,$77,$77
DC.W $88,$88,$88,$88,$88
DC.W $99,$99,$99,$99,$99
DC.W $AA,$AA,$AA,$AA,$AA,$AA
DC.W $BB,$BB,$BB,$BB,$BB,$BB
DC.W $CC,$CC,$CC,$CC,$CC,$CC,$CC
DC.W $DD,$DD,$DD,$DD,$DD,$DD,$DD
DC.W $EE,$EE,$EE,$EE,$EE,$EE,$EE,$EE
DC.W $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
DC.W $EE,$EE,$EE,$EE,$EE,$EE,$EE,$EE
DC.W $DD,$DD,$DD,$DD,$DD,$DD,$DD
DC.W $CC,$CC,$CC,$CC,$CC,$CC,$CC
DC.W $BB,$BB,$BB,$BB,$BB,$BB
DC.W $AA,$AA,$AA,$AA,$AA,$AA
DC.W $99,$99,$99,$99,$99
DC.W $88,$88,$88,$88,$88
DC.W $77,$77,$77,$77,$77
DC.W $66,$66,$66,$66,$66
DC.W $55,$55,$55,$55,$55,$55
DC.W $44,$44,$44,$44,$44,$44
DC.W $33,$33,$33,$33,$33,$33,$33
DC.W $22,$22,$22,$22,$22,$22,$22
DC.W $11,$11,$11,$11,$11,$11,$11,$11
DC.W $00,$00,$00,$00,$00,$00,$00,$00
DC.W $11,$11,$11,$11,$11,$11,$11,$11
DC.W $22,$22,$22,$22,$22,$22,$22
DC.W $33,$33,$33,$33,$33,$33,$33
DC.W $44,$44,$44,$44,$44,$44
DC.W $55,$55,$55,$55,$55,$55
DC.W $66,$66,$66,$66,$66
DC.W $77,$77,$77,$77,$77
DC.W $88,$88,$88,$88,$88
DC.W $99,$99,$99,$99,$99
DC.W $AA,$AA,$AA,$AA,$AA,$AA
DC.W $BB,$BB,$BB,$BB,$BB,$BB
DC.W $CC,$CC,$CC,$CC,$CC,$CC,$CC
DC.W $DD,$DD,$DD,$DD,$DD,$DD,$DD
DC.W $EE,$EE,$EE,$EE,$EE,$EE,$EE,$EE
DC.W $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
DC.W $EE,$EE,$EE,$EE,$EE,$EE,$EE,$EE
DC.W $DD,$DD,$DD,$DD,$DD,$DD,$DD
DC.W $CC,$CC,$CC,$CC,$CC,$CC,$CC
DC.W $BB,$BB,$BB,$BB,$BB,$BB
DC.W $AA,$AA,$AA,$AA,$AA,$AA
DC.W $99,$99,$99,$99,$99
DC.W $88,$88,$88,$88,$88
DC.W $77,$77,$77,$77,$77
DC.W $66,$66,$66,$66,$66
DC.W $55,$55,$55,$55,$55,$55
DC.W $44,$44,$44,$44,$44,$44
DC.W $33,$33,$33,$33,$33,$33,$33
DC.W $22,$22,$22,$22,$22,$22,$22
DC.W $11,$11,$11,$11,$11,$11,$11,$11
DC.W $00,$00,$00,$00,$00,$00,$00,$00
DC.W $11,$11,$11,$11,$11,$11,$11,$11
DC.W $22,$22,$22,$22,$22,$22,$22
DC.W $33,$33,$33,$33,$33,$33,$33
DC.W $44,$44,$44,$44,$44,$44
DC.W $55,$55,$55,$55,$55,$55
DC.W $66,$66,$66,$66,$66
DC.W $77,$77,$77,$77,$77
DC.W $88,$88,$88,$88,$88
DC.W $99,$99,$99,$99,$99
DC.W $AA,$AA,$AA,$AA,$AA,$AA
DC.W $BB,$BB,$BB,$BB,$BB,$BB
DC.W $CC,$CC,$CC,$CC,$CC,$CC,$CC
DC.W $DD,$DD,$DD,$DD,$DD,$DD,$DD
DC.W $EE,$EE,$EE,$EE,$EE,$EE,$EE,$EE
DC.W $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
DC.W $EE,$EE,$EE,$EE,$EE,$EE,$EE,$EE
DC.W $DD,$DD,$DD,$DD,$DD,$DD,$DD
DC.W $CC,$CC,$CC,$CC,$CC,$CC,$CC
DC.W $BB,$BB,$BB,$BB,$BB,$BB
DC.W $AA,$AA,$AA,$AA,$AA,$AA
DC.W $99,$99,$99,$99,$99
DC.W $88,$88,$88,$88,$88
DC.W $77,$77,$77,$77,$77
DC.W $66,$66,$66,$66,$66
DC.W $55,$55,$55,$55,$55,$55
DC.W $44,$44,$44,$44,$44,$44
DC.W $33,$33,$33,$33,$33,$33,$33
DC.W $22,$22,$22,$22,$22,$22,$22
DC.W $11,$11,$11,$11,$11,$11,$11,$11
DC.W 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
DC.W 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
DC.W 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
DC.W 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
DC.W 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
DC.W 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

DC.W $11,$11,$11,$11,$11,$11,$11,$11	; DEBUT DEDOUBLEMENT
DC.W $22,$22,$22,$22,$22,$22,$22
DC.W $33,$33,$33,$33,$33,$33,$33
DC.W $44,$44,$44,$44,$44,$44
DC.W $55,$55,$55,$55,$55,$55
DC.W $66,$66,$66,$66,$66
DC.W $77,$77,$77,$77,$77
DC.W $88,$88,$88,$88,$88
DC.W $99,$99,$99,$99,$99
DC.W $AA,$AA,$AA,$AA,$AA,$AA
DC.W $BB,$AA,$CC,$88,$CC,$66,$DD,$44,$DD
DC.W $33,$EE,$22,$EE,$22,$FF,$11,$FF,$11

DC.W $FF,$11,$FF,$22,$EE,$22,$EE,$33	; DEDOUBLEMENT
DC.W $DD,$44,$DD,$66,$CC,$88,$CC,$AA,$BB
DC.W $AA,$CC,$88,$CC,$66,$DD,$44,$DD
DC.W $33,$EE,$22,$EE,$22,$FF,$11,$FF,$11

DC.W $FF,$11,$FF,$11,$EE,$22,$EE,$22,$DD
DC.W $33,$DD,$44,$CC,$66,$CC,$88,$BB,$AA
DC.W $BB,$88,$CC,$66,$CC,$44,$DD,$33
DC.W $DD,$22,$EE,$22,$EE,$11,$FF,$11,$FF
DC.W $11,$FF,$11,$EE,$22,$EE,$22,$DD
DC.W $33,$DD,$44,$CC,$66,$CC,$88,$BB,$AA
DC.W $BB,$88,$CC,$66,$CC,$44,$DD,$33
DC.W $DD,$22,$EE,$22,$EE,$11,$FF,$11,$FF
DC.W $11,$FF,$11,$EE,$22,$EE,$22,$DD
DC.W $33,$DD,$44,$CC,$66,$CC,$88,$BB,$AA
DC.W $BB,$88,$CC,$66,$CC,$44,$DD,$33
DC.W $DD,$22,$EE,$22,$EE,$11,$FF,$11,$FF
DC.W $11,$FF,$11,$EE,$22,$EE,$22,$DD
DC.W $33,$DD,$44,$CC,$66,$CC,$88,$BB,$AA
DC.W $BB,$88,$CC,$66,$CC,$44,$DD,$33
DC.W $DD,$22,$EE,$22,$EE,$11,$FF,$11,$FF
DC.W $11,$FF,$11,$EE,$22,$EE,$22,$DD
DC.W $33,$DD,$44,$CC,$66,$CC,$88,$BB,$AA
DC.W $BB,$88,$CC,$66,$CC,$44,$DD,$33
DC.W $DD,$22,$EE,$22,$EE,$11,$FF,$11,$FF
DC.W $11,$FF,$11,$EE,$22,$EE,$22,$DD
DC.W $33,$DD,$44,$CC,$66,$CC,$88,$BB,$AA
DC.W $BB,$88,$CC,$66,$CC,$44,$DD,$33
DC.W $DD,$22,$EE,$22,$EE,$11,$FF,$11,$FF
DC.W $11,$FF,$11,$EE,$22,$EE,$22,$DD
DC.W $33,$DD,$44,$CC,$66,$CC,$88,$BB,$AA
DC.W $BB,$88,$CC,$66,$CC,$44,$DD,$33
DC.W $DD,$22,$EE,$22,$EE,$11,$FF,$11,$FF
DC.W $11,$FF,$11,$EE,$22,$EE,$22,$DD
DC.W $33,$DD,$44,$CC,$66,$CC,$88,$BB,$AA
DC.W $BB,$88,$CC,$66,$CC,$44,$DD,$33
DC.W $DD,$22,$EE,$22,$EE,$11,$FF,$11,$FF

DC.W $11,$FF,$11,$EE,$22,$EE,$22,$DD	; FIN DEDOUBLE
DC.W $33,$DD,$44,$CC,$66,$CC,$88,$BB,$AA
DC.W $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
DC.W $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
DC.W $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
DC.W $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
DC.W $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
DC.W $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
DC.W $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
DC.W $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
DC.W $99,$99,$88,$88,$77,$66,$44,$33,$22
DC.W $22,$11,$11,$11,$00,$00,$00,$00,$00

DC.W $11,$11,$11,$11,$11,$11,$11,$11	; FORME BRUTE
DC.W $22,$22,$22,$22,$22,$22,$22
DC.W $33,$33,$33,$33,$33,$33,$33
DC.W $44,$44,$44,$44,$44,$44
DC.W $55,$55,$55,$55,$55,$55
DC.W $66,$66,$66,$66,$66
DC.W $77,$77,$77,$77,$77
DC.W $88,$88,$88,$88,$88
DC.W $99,$99,$99,$99,$99
DC.W $AA,$AA,$AA,$AA,$AA,$AA
DC.W $99,$99,$88,$88,$77,$66,$44,$33,$22
DC.W $22,$11,$11,$11,$00,$00,$00,$00,$00
DC.W $11,$11,$11,$11,$11,$11,$11,$11
DC.W $22,$22,$22,$22,$22,$22,$22
DC.W $33,$33,$33,$33,$33,$33,$33
DC.W $44,$44,$44,$44,$44,$44
DC.W $55,$55,$55,$55,$55,$55
DC.W $66,$66,$66,$66,$66
DC.W $77,$77,$77,$77,$77
DC.W $88,$88,$88,$88,$88
DC.W $99,$99,$99,$99,$99
DC.W $AA,$AA,$AA,$AA,$AA,$AA
DC.W $AA,$AA,$AA,$AA,$AA,$AA
DC.W $BB,$BB,$BB,$BB,$BB,$BB
DC.W $CC,$CC,$CC,$CC,$CC,$CC,$CC
DC.W $DD,$DD,$DD,$DD,$DD,$DD,$DD
DC.W $EE,$EE,$EE,$EE,$EE,$EE,$EE,$EE
DC.W $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
DC.W $EE,$EE,$DD,$CC,$BB,$BB,$AA,$AA
DC.W $99,$99,$88,$88,$77,$66,$44,$33,$22
DC.W $22,$11,$11,$11,$00,$00,$00,$00,$00
DC.W $11,$11,$11,$11,$11,$11,$11,$11
DC.W $22,$22,$22,$22,$22,$22,$22
DC.W $33,$33,$33,$33,$33,$33,$33
DC.W $44,$44,$44,$44,$44,$44
DC.W $55,$55,$55,$55,$55,$55
DC.W $66,$66,$66,$66,$66
DC.W $77,$77,$77,$77,$77
DC.W $88,$88,$88,$88,$88
DC.W $99,$99,$99,$99,$99
DC.W $AA,$AA,$AA,$AA,$AA,$AA
DC.W $BB,$BB,$BB,$BB,$BB,$BB
DC.W $CC,$CC,$CC,$CC,$CC,$CC,$CC
DC.W $DD,$DD,$DD,$DD,$DD,$DD,$DD
DC.W $EE,$EE,$EE,$EE,$EE,$EE,$EE,$EE
DC.W $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
DC.W $EE,$EE,$DD,$CC,$BB,$BB,$AA,$AA
DC.W $99,$99,$88,$88,$77,$66,$44,$33,$22
DC.W $22,$11,$11,$11,$00,$00,$00,$00,$00

DC.W $11,$22,$33,$44,$55,$66,$77,$88,$99,$AA		; TRIANGLE
DC.W $BB,$CC,$DD,$EE,$FF,$EE,$DD,$CC,$BB,$AA
DC.W $99,$88,$77,$66,$55,$44,$33,$22,$11,$00
DC.W $11,$22,$33,$44,$55,$66,$77,$88,$99,$AA		; TRIANGLE
DC.W $BB,$CC,$DD,$EE,$FF,$EE,$DD,$CC,$BB,$AA
DC.W $99,$88,$77,$66,$55,$44,$33,$22,$11,$00
DC.W $11,$22,$33,$44,$55,$66,$77,$88,$99,$AA		; TRIANGLE
DC.W $BB,$CC,$DD,$EE,$FF,$EE,$DD,$CC,$BB,$AA
DC.W $99,$88,$77,$66,$55,$44,$33,$22,$11,$00
DC.W $11,$22,$33,$44,$55,$66,$77,$88,$99,$AA		; TRIANGLE
DC.W $BB,$CC,$DD,$EE,$FF,$EE,$DD,$CC,$BB,$AA
DC.W $99,$88,$77,$66,$55,$44,$33,$22,$11,$00
DC.W $11,$22,$33,$44,$55,$66,$77,$88,$99,$AA
DC.W $BB,$CC,$DD,$EE,$FF,$EE,$DD,$CC,$BB,$AA
DC.W $99,$88,$77,$66,$55,$44,$33,$22,$11,$00
DC.W $11,$22,$33,$44,$55,$66,$77,$88,$99,$AA
DC.W $BB,$CC,$DD,$EE,$FF,$EE,$DD,$CC,$BB,$AA
DC.W $99,$88,$77,$66,$55,$44,$33,$22,$11,$00
DC.W $11,$22,$33,$44,$55,$66,$77,$88,$99,$AA
DC.W $BB,$CC,$DD,$EE,$FF,$EE,$DD,$CC,$BB,$AA
DC.W $99,$88,$77,$66,$55,$44,$33,$22,$11,$00
DC.W $11,$22,$33,$44,$55,$66,$77,$88,$99,$AA
DC.W $BB,$CC,$DD,$EE,$FF,$EE,$DD,$CC,$BB,$AA
DC.W $99,$88,$77,$66,$55,$44,$33,$22,$11,$00
DC.W $11,$22,$33,$44,$55,$66,$77,$88,$99,$AA
DC.W $BB,$CC,$DD,$EE,$FF,$EE,$DD,$CC,$BB,$AA
DC.W $99,$88,$77,$66,$55,$44,$33,$22,$11,$00
DC.W $11,$22,$33,$44,$55,$66,$77,$88,$99,$AA
DC.W $BB,$CC,$DD,$EE,$FF,$EE,$DD,$CC,$BB,$AA
DC.W $99,$88,$77,$66,$55,$44,$33,$22,$11,$00
DC.W $11,$22,$33,$44,$55,$66,$77,$88,$99,$AA
DC.W $BB,$CC,$DD,$EE,$FF,$EE,$DD,$CC,$BB,$AA
DC.W $99,$88,$77,$66,$55,$44,$33,$22,$11,$00
DC.W $11,$22,$33,$44,$55,$66,$77,$88,$99,$AA
DC.W $BB,$CC,$DD,$EE,$FF,$EE,$DD,$CC,$BB,$AA
DC.W $99,$88,$77,$66,$55,$44,$33,$22,$11,$00
DC.W $11,$22,$33,$44,$55,$66,$77,$88,$99,$AA
DC.W $BB,$CC,$DD,$EE,$FF,$EE,$DD,$CC,$BB,$AA
DC.W $99,$88,$77,$66,$55,$44,$33,$22,$11,$00
DC.W $11,$22,$33,$44,$55,$66,$77,$88,$99,$AA
DC.W $BB,$CC,$DD,$EE,$FF,$EE,$DD,$CC,$BB,$AA
DC.W $99,$88,$77,$66,$55,$44,$33,$22,$11,$00
DC.W $11,$22,$33,$44,$55,$66,$77,$88,$99,$AA
DC.W $BB,$CC,$DD,$EE,$FF,$EE,$DD,$CC,$BB,$AA
DC.W $99,$88,$77,$66,$55,$44,$33,$22,$11,$00

DC.W $00,$00,$00,$00,$00,$00,$00,$00		; CARRE
DC.W $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
DC.W $00,$00,$00,$00,$00,$00,$00,$00
DC.W $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
DC.W $00,$00,$00,$00,$00,$00,$00,$00
DC.W $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
DC.W $00,$00,$00,$00,$00,$00,$00,$00
DC.W $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
DC.W $00,$00,$00,$00,$00,$00,$00,$00
DC.W $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
DC.W $00,$00,$00,$00,$00,$00,$00,$00
DC.W $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
DC.W $11,$11,$11,$11,$11,$11,$11,$11
DC.W $EE,$EE,$EE,$EE,$EE,$EE,$EE,$EE
DC.W $22,$22,$22,$22,$22,$22,$22,$22
DC.W $DD,$DD,$DD,$DD,$DD,$DD,$DD,$DD
DC.W $33,$33,$33,$33,$33,$33,$33,$33
DC.W $CC,$CC,$CC,$CC,$CC,$CC,$CC,$CC
DC.W $44,$44,$44,$44,$44,$44,$44,$44
DC.W $BB,$BB,$BB,$BB,$BB,$BB,$BB,$BB
DC.W $55,$55,$55,$55,$55,$55,$55,$55
DC.W $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
DC.W $66,$66,$66,$66,$66,$66,$66,$66
DC.W $99,$99,$99,$99,$99,$99,$99,$99
DC.W $77,$77,$77,$77,$77,$77,$77,$77
DC.W $88,$88,$88,$88,$88,$88,$88,$88
DC.W $88,$88,$88,$88,$88,$88,$88,$88
DC.W $88,$88,$88,$88,$88,$88,$88,$88
DC.W $88,$88,$88,$88,$88,$88,$88,$88
DC.W $88,$88,$88,$88,$88,$88,$88,$88
DC.W $88,$88,$88,$88,$88,$88,$88,$88
DC.W $88,$88,$88,$88,$88,$88,$88,$88
DC.W $88,$88,$88,$88,$88,$88,$88,$88
DC.W $88,$88,$88,$88,$88
DC.W $77,$77,$77,$77,$77			; REVIENS
DC.W $66,$66,$66,$66,$66
DC.W $55,$55,$55,$55,$55,$55
DC.W $44,$44,$44,$44,$44,$44
DC.W $33,$33,$33,$33,$33,$33,$33
DC.W $22,$22,$22,$22,$22,$22,$22
DC.W $11,$11,$11,$11,$11,$11,$11,$11

DC.W $11,$22,$33,$44,$55,$66,$77,$88,$99,$AA	; SEMI TRIANGLE 1
DC.W $BB,$CC,$DD,$EE,$FF,$00
DC.W $11,$22,$33,$44,$55,$66,$77,$88,$99,$AA
DC.W $BB,$CC,$DD,$EE,$FF,$00
DC.W $11,$22,$33,$44,$55,$66,$77,$88,$99,$AA
DC.W $BB,$CC,$DD,$EE,$FF,$00
DC.W $11,$22,$33,$44,$55,$66,$77,$88,$99,$AA
DC.W $BB,$CC,$DD,$EE,$FF,$00
DC.W $11,$22,$33,$44,$55,$66,$77,$88,$99,$AA
DC.W $BB,$CC,$DD,$EE,$FF,$00
DC.W $11,$22,$33,$44,$55,$66,$77,$88,$99,$AA
DC.W $BB,$CC,$DD,$EE,$FF,$00
DC.W $11,$22,$33,$44,$55,$66,$77,$88,$99,$AA
DC.W $BB,$CC,$DD,$EE,$FF,$00
DC.W $11,$22,$33,$44,$55,$66,$77,$88,$99,$AA
DC.W $BB,$CC,$DD,$EE,$FF,$00
DC.W $11,$22,$33,$44,$55,$66,$77,$88,$99,$AA
DC.W $BB,$CC,$DD,$EE,$FF,$00
DC.W $11,$22,$33,$44,$55,$66,$77,$88,$99,$AA
DC.W $BB,$CC,$DD,$EE,$FF,$00
DC.W $11,$22,$33,$44,$55,$66,$77,$88,$99,$AA
DC.W $BB,$CC,$DD,$EE,$FF,$00
DC.W $11,$22,$33,$44,$55,$66,$77,$88,$99,$AA
DC.W $BB,$CC,$DD,$EE,$FF,$00
DC.W $11,$22,$33,$44,$55,$66,$77,$88,$99,$AA
DC.W $BB,$CC,$DD,$EE,$FF,$00
DC.W $11,$22,$33,$44,$55,$66,$77,$88,$99,$AA
DC.W $BB,$CC,$DD,$EE,$FF

DC.W $FF,$EE,$DD,$CC,$BB,$AA,$99,$88	; SEMI TRIANGLE2
DC.W $77,$66,$55,$44,$33,$22,$11,$00
DC.W $FF,$EE,$DD,$CC,$BB,$AA,$99,$88
DC.W $77,$66,$55,$44,$33,$22,$11,$00
DC.W $FF,$EE,$DD,$CC,$BB,$AA,$99,$88
DC.W $77,$66,$55,$44,$33,$22,$11,$00
DC.W $FF,$EE,$DD,$CC,$BB,$AA,$99,$88
DC.W $77,$66,$55,$44,$33,$22,$11,$00
DC.W $FF,$EE,$DD,$CC,$BB,$AA,$99,$88
DC.W $77,$66,$55,$44,$33,$22,$11,$00
DC.W $FF,$EE,$DD,$CC,$BB,$AA,$99,$88
DC.W $77,$66,$55,$44,$33,$22,$11,$00
DC.W $FF,$EE,$DD,$CC,$BB,$AA,$99,$88
DC.W $77,$66,$55,$44,$33,$22,$11,$00
DC.W $FF,$EE,$DD,$CC,$BB,$AA,$99,$88
DC.W $77,$66,$55,$44,$33,$22,$11,$00
DC.W $FF,$EE,$DD,$CC,$BB,$AA,$99,$88
DC.W $77,$66,$55,$44,$33,$22,$11,$00
DC.W $FF,$EE,$DD,$CC,$BB,$AA,$99,$88
DC.W $77,$66,$55,$44,$33,$22,$11,$00
DC.W $FF,$EE,$DD,$CC,$BB,$AA,$99,$88
DC.W $77,$66,$55,$44,$33,$22,$11,$00
DC.W $FF,$EE,$DD,$CC,$BB,$AA,$99,$88
DC.W $77,$66,$55,$44,$33,$22,$11,$00
DC.W $FF,$EE,$DD,$CC,$BB,$AA,$99,$88
DC.W $77,$66,$55,$44,$33,$22,$11,$00
DC.W $FF,$EE,$DD,$CC,$BB,$AA,$99,$88
DC.W $77,$66,$55,$44,$33,$22,$11,$00


DC.W 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
DC.W 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
DC.W 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
DC.W 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

DC.W $00,$11,$22,$33,$00,$11,$22,$33	; FLOU 1
DC.W $00,$11,$22,$33,$00,$11,$22,$33
DC.W $00,$11,$22,$33,$00,$11,$22,$33
DC.W $00,$11,$22,$33,$00,$11,$22,$33
DC.W $00,$11,$22,$33,$00,$11,$22,$33
DC.W $00,$11,$22,$33,$00,$11,$22,$33
DC.W $00,$11,$22,$33,$00,$11,$22,$33
DC.W $00,$11,$22,$33,$00,$11,$22,$33
DC.W $00,$11,$22,$33,$00,$11,$22,$33
DC.W $00,$11,$22,$33,$00,$11,$22,$33
DC.W $00,$11,$22,$33,$00,$11,$22,$33
DC.W $00,$11,$22,$33,$00,$11,$22,$33
DC.W $00,$11,$22,$33,$00,$11,$22,$33
DC.W $00,$11,$22,$33,$00,$11,$22,$33
DC.W $00,$11,$22,$33,$00,$11,$22,$33
DC.W $00,$11,$22,$33,$00,$11,$22,$33
DC.W $00,$11,$22,$33,$00,$11,$22,$33
DC.W $00,$11,$22,$33,$00,$11,$22,$33
DC.W $00,$11,$22,$33,$00,$11,$22,$33
DC.W $00,$11,$22,$33,$00,$11,$22,$33

DC.W $33,$22,$11,$00,$33,$22,$11,$00	; FLOU 2
DC.W $33,$22,$11,$00,$33,$22,$11,$00
DC.W $33,$22,$11,$00,$33,$22,$11,$00
DC.W $33,$22,$11,$00,$33,$22,$11,$00
DC.W $33,$22,$11,$00,$33,$22,$11,$00
DC.W $33,$22,$11,$00,$33,$22,$11,$00
DC.W $33,$22,$11,$00,$33,$22,$11,$00
DC.W $33,$22,$11,$00,$33,$22,$11,$00
DC.W $33,$22,$11,$00,$33,$22,$11,$00
DC.W $33,$22,$11,$00,$33,$22,$11,$00
DC.W $33,$22,$11,$00,$33,$22,$11,$00
DC.W $33,$22,$11,$00,$33,$22,$11,$00
DC.W $33,$22,$11,$00,$33,$22,$11,$00
DC.W $33,$22,$11,$00,$33,$22,$11,$00
DC.W $33,$22,$11,$00,$33,$22,$11,$00
DC.W $33,$22,$11,$00,$33,$22,$11,$00
DC.W $33,$22,$11,$00,$33,$22,$11,$00

DC.W 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
DC.W 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
DC.W 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
DC.W 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

FINVAGUES:

;=================================================================
;>                          COPPERLIST                           <
;=================================================================
NEWCOPPER:
DC.W $008E,$2981		; DWISTRT (H129,V41)
DC.W $0090,$29C1                ; DWISTOP (H449,V297)
DC.W $0092,$0038		; DFFSTRT
DC.W $0094,$00D0		; DFFSTOP
DC.W $00E0,$0006		; POINTEUR BITPLAN 1
DC.W $00E2,$0000
DC.W $00E4,$0006		; POINTEUR BITPLAN 2
DC.W $00E6,$2C00
DC.W $00E8,$0006		; POINTEUR BITPLAN 3
DC.W $00EA,$5800
DC.W $00EC,$0006		; POINTEUR BITPLAN 4
DC.W $00EE,$8400
DC.W $00F0,$0006		; POINTEUR BITPLAN 5
DC.W $00F2,$B000
DC.W $0100,$5200		; BLTCON 0
DC.W $0108,$0004
DC.W $010A,$0004
DC.W $0102,$0000
DC.W $0120,$0000
DC.W $0122,$0000

DC.W $000F,$FFFE		; WAIT COULEURS LOGO
DC.W $0180,$0000
DC.W $0182,$0FFF		; 01   R/G/B
DC.W $0184,$0E00		; 02
DC.W $018A,$0FF0
DC.W $01A8,$0B00		; COULEURS LOGO
DC.W $01AA,$0B01		; DEGRADE ROUGE-ROSE
DC.W $01AC,$0B13
DC.W $01AE,$0B14
DC.W $01B0,$0B26
DC.W $01B2,$0C27
DC.W $01B4,$0C38
DC.W $01B6,$0C3A
DC.W $01B8,$0D4B
DC.W $01BA,$0D5B
DC.W $01BC,$0E5D
DC.W $01BD,$0E6E
DC.W $01BE,$0E6E

COPPER:
DC.W $330F,$FFFE,$180,$000,$102,$000
DC.W $340F,$FFFE,$180,$000,$102,$000
DC.W $350F,$FFFE,$180,$000,$102,$000
DC.W $360F,$FFFE,$180,$000,$102,$000
DC.W $370F,$FFFE,$180,$000,$102,$000
DC.W $380F,$FFFE,$180,$000,$102,$000
DC.W $390F,$FFFE,$180,$000,$102,$000
DC.W $3A0F,$FFFE,$180,$000,$102,$000
DC.W $3B0F,$FFFE,$180,$000,$102,$000
DC.W $3C0F,$FFFE,$180,$000,$102,$000
DC.W $3D0F,$FFFE,$180,$000,$102,$000
DC.W $3E0F,$FFFE,$180,$000,$102,$000
DC.W $3F0F,$FFFE,$180,$000,$102,$000
DC.W $400F,$FFFE,$180,$000,$102,$000
DC.W $410F,$FFFE,$180,$000,$102,$000
DC.W $420F,$FFFE,$180,$000,$102,$000
DC.W $430F,$FFFE,$180,$000,$102,$000
DC.W $440F,$FFFE,$180,$000,$102,$000
DC.W $450F,$FFFE,$180,$000,$102,$000
DC.W $460F,$FFFE,$180,$000,$102,$000
DC.W $470F,$FFFE,$180,$000,$102,$000
DC.W $480F,$FFFE,$180,$000,$102,$000
DC.W $490F,$FFFE,$180,$000,$102,$000
DC.W $4A0F,$FFFE,$180,$000,$102,$000
DC.W $4B0F,$FFFE,$180,$000,$102,$000
DC.W $4C0F,$FFFE,$180,$000,$102,$000
DC.W $4D0F,$FFFE,$180,$000,$102,$000
DC.W $4E0F,$FFFE,$180,$000,$102,$000
DC.W $4F0F,$FFFE,$180,$000,$102,$000
DC.W $500F,$FFFE,$180,$000,$102,$000
DC.W $510F,$FFFE,$180,$000,$102,$000
DC.W $520F,$FFFE,$180,$000,$102,$000
DC.W $530F,$FFFE,$180,$000,$102,$000
DC.W $540F,$FFFE,$180,$000,$102,$000
DC.W $550F,$FFFE,$180,$000,$102,$000
DC.W $560F,$FFFE,$180,$000,$102,$000
DC.W $570F,$FFFE,$180,$000,$102,$000
DC.W $580F,$FFFE,$180,$000,$102,$000
DC.W $590F,$FFFE,$180,$000,$102,$000
DC.W $5A0F,$FFFE,$180,$000,$102,$000
DC.W $5B0F,$FFFE,$180,$000,$102,$000
DC.W $5C0F,$FFFE,$180,$000,$102,$000
DC.W $5D0F,$FFFE,$180,$000,$102,$000
DC.W $5E0F,$FFFE,$180,$000,$102,$000
DC.W $5F0F,$FFFE,$180,$000,$102,$000
DC.W $600F,$FFFE,$180,$000,$102,$000
DC.W $610F,$FFFE,$180,$000,$102,$000
DC.W $620F,$FFFE,$180,$000,$102,$000
DC.W $630F,$FFFE,$180,$000,$102,$000
DC.W $640F,$FFFE,$180,$000,$102,$000
DC.W $650F,$FFFE,$180,$000,$102,$000
DC.W $660F,$FFFE,$180,$000,$102,$000
DC.W $670F,$FFFE,$180,$000,$102,$000
DC.W $680F,$FFFE,$180,$000,$102,$000
DC.W $690F,$FFFE,$180,$000,$102,$000
DC.W $6A0F,$FFFE,$180,$000,$102,$000
DC.W $6B0F,$FFFE,$180,$000,$102,$000
DC.W $6C0F,$FFFE,$180,$000,$102,$000
DC.W $6D0F,$FFFE,$180,$000,$102,$000
DC.W $6E0F,$FFFE,$180,$000,$102,$000
DC.W $6F0F,$FFFE,$180,$000,$102,$000
DC.W $700F,$FFFE,$180,$000,$102,$000
DC.W $710F,$FFFE,$180,$000,$102,$000
DC.W $720F,$FFFE,$180,$000,$102,$000
DC.W $730F,$FFFE,$180,$000,$102,$000
DC.W $740F,$FFFE,$180,$000,$102,$000
DC.W $750F,$FFFE,$180,$000,$102,$000
DC.W $760F,$FFFE,$180,$000,$102,$000
DC.W $770F,$FFFE,$180,$000,$102,$000
DC.W $780F,$FFFE,$180,$000,$102,$000
DC.W $790F,$FFFE,$180,$000,$102,$000
DC.W $7A0F,$FFFE,$180,$000,$102,$000
DC.W $7B0F,$FFFE,$180,$000,$102,$000
DC.W $7C0F,$FFFE,$180,$000,$102,$000
DC.W $7D0F,$FFFE,$180,$000,$102,$000
DC.W $7E0F,$FFFE,$180,$000,$102,$000
DC.W $7F0F,$FFFE,$180,$000,$102,$000
DC.W $800F,$FFFE,$180,$000,$102,$000
DC.W $810F,$FFFE,$180,$000,$102,$000
DC.W $820F,$FFFE,$180,$000,$102,$000
DC.W $830F,$FFFE,$180,$000,$102,$000
DC.W $840F,$FFFE,$180,$000,$102,$000
DC.W $850F,$FFFE,$180,$000,$102,$000
DC.W $860F,$FFFE,$180,$000,$102,$000
DC.W $870F,$FFFE,$180,$000,$102,$000
DC.W $880F,$FFFE,$180,$000,$102,$000
DC.W $890F,$FFFE,$180,$000,$102,$000
DC.W $8A0F,$FFFE,$180,$000,$102,$000
DC.W $8B0F,$FFFE,$180,$000,$102,$000
DC.W $8C0F,$FFFE,$180,$000,$102,$000
DC.W $8D0F,$FFFE,$180,$000,$102,$000
DC.W $8E0F,$FFFE,$180,$000,$102,$000
DC.W $8F0F,$FFFE,$180,$000,$102,$000
DC.W $900F,$FFFE,$180,$000,$102,$000
DC.W $910F,$FFFE,$180,$000,$102,$000
DC.W $920F,$FFFE,$180,$000,$102,$000
DC.W $930F,$FFFE,$180,$000,$102,$000
DC.W $940F,$FFFE,$180,$000,$102,$000
DC.W $950F,$FFFE,$180,$000,$102,$000
DC.W $960F,$FFFE,$180,$000,$102,$000
DC.W $970F,$FFFE,$180,$000,$102,$000
DC.W $980F,$FFFE,$180,$000,$102,$000
DC.W $990F,$FFFE,$180,$000,$102,$000
DC.W $9A0F,$FFFE,$180,$000,$102,$000
DC.W $9B0F,$FFFE,$180,$000,$102,$000
DC.W $9C0F,$FFFE,$180,$000,$102,$000
DC.W $9D0F,$FFFE,$180,$000,$102,$000
DC.W $9E0F,$FFFE,$180,$000,$102,$000
DC.W $9F0F,$FFFE,$180,$000,$102,$000
DC.W $A00F,$FFFE,$180,$000,$102,$000
DC.W $A10F,$FFFE,$180,$000,$102,$000
DC.W $A20F,$FFFE,$180,$000,$102,$000
DC.W $A30F,$FFFE,$180,$000,$102,$000
DC.W $A40F,$FFFE,$180,$000,$102,$000
DC.W $A50F,$FFFE,$180,$000,$102,$000
DC.W $A60F,$FFFE,$180,$000,$102,$000
DC.W $A70F,$FFFE,$180,$000,$102,$000
DC.W $A80F,$FFFE,$180,$000,$102,$000
DC.W $A90F,$FFFE,$180,$000,$102,$000
DC.W $AA0F,$FFFE,$180,$000,$102,$000
DC.W $AB0F,$FFFE,$180,$000,$102,$000
DC.W $AC0F,$FFFE,$180,$000,$102,$000
DC.W $AD0F,$FFFE,$180,$000,$102,$000
DC.W $AE0F,$FFFE,$180,$000,$102,$000
DC.W $AF0F,$FFFE,$180,$000,$102,$000
DC.W $B00F,$FFFE,$180,$000,$102,$000
DC.W $B10F,$FFFE,$180,$000,$102,$000
DC.W $B20F,$FFFE,$180,$000,$102,$000
DC.W $B30F,$FFFE,$180,$000,$102,$000
DC.W $B40F,$FFFE,$180,$000,$102,$000
DC.W $B50F,$FFFE,$180,$000,$102,$000
DC.W $B60F,$FFFE,$180,$000,$102,$000
DC.W $B70F,$FFFE,$180,$000,$102,$000
DC.W $B80F,$FFFE,$180,$000,$102,$000
DC.W $B90F,$FFFE,$180,$000,$102,$000
DC.W $BA0F,$FFFE,$180,$000,$102,$000
DC.W $BB0F,$FFFE,$180,$000,$102,$000
DC.W $BC0F,$FFFE,$180,$000,$102,$000
DC.W $BD0F,$FFFE,$180,$000,$102,$000
DC.W $BE0F,$FFFE,$180,$000,$102,$000
DC.W $BF0F,$FFFE,$180,$000,$102,$000
DC.W $C00F,$FFFE,$180,$000,$102,$000
DC.W $C10F,$FFFE,$180,$000,$102,$000
DC.W $C20F,$FFFE,$180,$000,$102,$000
DC.W $C30F,$FFFE,$180,$000,$102,$000
DC.W $C40F,$FFFE,$180,$000,$102,$000
DC.W $C50F,$FFFE,$180,$000,$102,$000
DC.W $C60F,$FFFE,$180,$000,$102,$000
DC.W $C70F,$FFFE,$180,$000,$102,$000
DC.W $C80F,$FFFE,$180,$000,$102,$000
DC.W $C90F,$FFFE,$180,$000,$102,$000
DC.W $CA0F,$FFFE,$180,$000,$102,$000
DC.W $CB0F,$FFFE,$180,$000,$102,$000
DC.W $CC0F,$FFFE,$180,$000,$102,$000
DC.W $CD0F,$FFFE,$180,$000,$102,$000
DC.W $CE0F,$FFFE,$180,$000,$102,$000
DC.W $CF0F,$FFFE,$180,$000,$102,$000
DC.W $D00F,$FFFE,$180,$000,$102,$000
DC.W $D10F,$FFFE,$180,$000,$102,$000
DC.W $D20F,$FFFE,$180,$000,$102,$000
FINCOPPER:
DC.W $D30F,$FFFE,$180,$000,$102,$000

DC.W $E00F,$FFFE		; WAIT COULEURS FONTES
DC.W $0180,$0000
DC.W $0182,$0F00
DC.W $0184,$0240
DC.W $0186,$0250
DC.W $0188,$0364
DC.W $018A,$0371
DC.W $018C,$0482
DC.W $018E,$04A3

DC.W $E10F,$FFFE,$180,$333
DC.W $E20F,$FFFE,$180,$666
DC.W $E30F,$FFFE,$180,$999
DC.W $E40F,$FFFE,$180,$CCC
DC.W $E50F,$FFFE,$180,$FFF
DC.W $E60F,$FFFE,$180,$CCC
DC.W $E70F,$FFFE,$180,$999
DC.W $E80F,$FFFE,$180,$666
DC.W $E90F,$FFFE,$180,$333
DC.W $EA0F,$FFFE,$180,$000

DC.W $FFFF,$FFDE
DC.W $000F,$FF00,$180,$000
DC.W $0D0F,$FF00,$180,$005

; REDEFINIT COULEURS REFLET
DC.W $0182,$0D02
DC.W $0184,$0022
DC.W $0186,$0032
DC.W $0188,$0146
DC.W $018A,$0153
DC.W $018C,$0264
DC.W $018E,$0285


VR:
DC.W $0E0F,$FF00
DC.W $102,$00
DC.W $00E0,$0006		; POINTEUR BITPLAN 1
DC.W $00E2,$0000+9900
DC.W $00E4,$0006		; POINTEUR BITPLAN 2
DC.W $00E6,$2C00+9900
DC.W $00E8,$0006		; POINTEUR BITPLAN 3
DC.W $00EA,$5800+9900
DC.W $0F0F,$FF00
DC.W $102,$11
DC.W $00E0,$0006		; POINTEUR BITPLAN 1
DC.W $00E2,$0000+9768
DC.W $00E4,$0006		; POINTEUR BITPLAN 2
DC.W $00E6,$2C00+9768
DC.W $00E8,$0006		; POINTEUR BITPLAN 3
DC.W $00EA,$5800+9768
DC.W $100F,$FF00
DC.W $102,$22
DC.W $00E0,$0006		; POINTEUR BITPLAN 1
DC.W $00E2,$0000+9680
DC.W $00E4,$0006		; POINTEUR BITPLAN 2
DC.W $00E6,$2C00+9680
DC.W $00E8,$0006		; POINTEUR BITPLAN 3
DC.W $00EA,$5800+9680
DC.W $110F,$FF00
DC.W $102,$33
DC.W $00E0,$0006		; POINTEUR BITPLAN 1
DC.W $00E2,$0000+9592
DC.W $00E4,$0006		; POINTEUR BITPLAN 2
DC.W $00E6,$2C00+9592
DC.W $00E8,$0006		; POINTEUR BITPLAN 3
DC.W $00EA,$5800+9592
DC.W $120F,$FF00
DC.W $102,$00
DC.W $00E0,$0006		; POINTEUR BITPLAN 1
DC.W $00E2,$0000+9504
DC.W $00E4,$0006		; POINTEUR BITPLAN 2
DC.W $00E6,$2C00+9504
DC.W $00E8,$0006		; POINTEUR BITPLAN 3
DC.W $00EA,$5800+9504
DC.W $130F,$FF00
DC.W $102,$11
DC.W $00E0,$0006		; POINTEUR BITPLAN 1
DC.W $00E2,$0000+9416
DC.W $00E4,$0006		; POINTEUR BITPLAN 2
DC.W $00E6,$2C00+9416
DC.W $00E8,$0006		; POINTEUR BITPLAN 3
DC.W $00EA,$5800+9416
DC.W $140F,$FF00
DC.W $102,$22
DC.W $00E0,$0006		; POINTEUR BITPLAN 1
DC.W $00E2,$0000+9328
DC.W $00E4,$0006		; POINTEUR BITPLAN 2
DC.W $00E6,$2C00+9328
DC.W $00E8,$0006		; POINTEUR BITPLAN 3
DC.W $00EA,$5800+9328
DC.W $150F,$FF00
DC.W $102,$33
DC.W $00E0,$0006		; POINTEUR BITPLAN 1
DC.W $00E2,$0000+9240
DC.W $00E4,$0006		; POINTEUR BITPLAN 2
DC.W $00E6,$2C00+9240
DC.W $00E8,$0006		; POINTEUR BITPLAN 3
DC.W $00EA,$5800+9240
DC.W $160F,$FF00
DC.W $102,$00
DC.W $00E0,$0006		; POINTEUR BITPLAN 1
DC.W $00E2,$0000+9152
DC.W $00E4,$0006		; POINTEUR BITPLAN 2
DC.W $00E6,$2C00+9152
DC.W $00E8,$0006		; POINTEUR BITPLAN 3
DC.W $00EA,$5800+9152
DC.W $170F,$FF00
DC.W $102,$11
DC.W $00E0,$0006		; POINTEUR BITPLAN 1
DC.W $00E2,$0000+9064
DC.W $00E4,$0006		; POINTEUR BITPLAN 2
DC.W $00E6,$2C00+9064
DC.W $00E8,$0006		; POINTEUR BITPLAN 3
DC.W $00EA,$5800+9064
DC.W $180F,$FF00
DC.W $102,$22
DC.W $00E0,$0006		; POINTEUR BITPLAN 1
DC.W $00E2,$0000+8976
DC.W $00E4,$0006		; POINTEUR BITPLAN 2
DC.W $00E6,$2C00+8976
DC.W $00E8,$0006		; POINTEUR BITPLAN 3
DC.W $00EA,$5800+8976
DC.W $190F,$FF00
DC.W $102,$33
DC.W $00E0,$0006		; POINTEUR BITPLAN 1
DC.W $00E2,$0000+8888
DC.W $00E4,$0006		; POINTEUR BITPLAN 2
DC.W $00E6,$2C00+8888
DC.W $00E8,$0006		; POINTEUR BITPLAN 3
DC.W $00EA,$5800+8888
DC.W $1A0F,$FF00
DC.W $102,$00
DC.W $00E0,$0006		; POINTEUR BITPLAN 1
DC.W $00E2,$0000+8800
DC.W $00E4,$0006		; POINTEUR BITPLAN 2
DC.W $00E6,$2C00+8800
DC.W $00E8,$0006		; POINTEUR BITPLAN 3
DC.W $00EA,$5800+8800
DC.W $1B0F,$FF00
DC.W $102,$11
DC.W $00E0,$0006		; POINTEUR BITPLAN 1
DC.W $00E2,$0000+8712
DC.W $00E4,$0006		; POINTEUR BITPLAN 2
DC.W $00E6,$2C00+8712
DC.W $00E8,$0006		; POINTEUR BITPLAN 3
DC.W $00EA,$5800+8712
DC.W $1C0F,$FF00
DC.W $102,$22
DC.W $00E0,$0006		; POINTEUR BITPLAN 1
DC.W $00E2,$0000+8624
DC.W $00E4,$0006		; POINTEUR BITPLAN 2
DC.W $00E6,$2C00+8624
DC.W $00E8,$0006		; POINTEUR BITPLAN 3
DC.W $00EA,$5800+8624
DC.W $1D0F,$FF00
DC.W $102,$33
FVR:
DC.W $00E0,$0006		; POINTEUR BITPLAN 1
DC.W $00E2,$0000+8536
DC.W $00E4,$0006		; POINTEUR BITPLAN 2
DC.W $00E6,$2C00+8536
DC.W $00E8,$0006		; POINTEUR BITPLAN 3
DC.W $00EA,$5800+8536
DC.W $1E0F,$FF00
DC.W $00E0,$0006		; POINTEUR BITPLAN 1
DC.W $00E2,$0000+10912
DC.W $00E4,$0006		; POINTEUR BITPLAN 2
DC.W $00E6,$2C00+10912
DC.W $00E8,$0006		; POINTEUR BITPLAN 3
DC.W $00EA,$5800+10912


COPPERLISTFIN:

PCOULEURS:
DC.L COULEURS
PVAGUES:
DC.L VAGUES
LOGO:
BLK.B 24064,$ff
EVEN
AZ:				; 320/4 x 196 x 3 PLANS
BLK.B 10400,$ff
music:		blk.b	63796,0
FININTRO:
