; ******** oktalyzer_init ********
; Initialize Oktalyzer module
; INPUT: a0 = module
; OUTPUT: none
oktalyzer_init:
	bra lb_0014

; ******** oktalyzer_play ********
; Plays Oktalyzer module, to be called once per frame
; INPUT: none
; OUTPUT: none
oktalyzer_play:
	bra lb_0122

; ******** oktalyzer_release ********
; Release Oktalyzer module
; INPUT: none
; OUTPUT: none
oktalyzer_release:
	bra lb_0126

;==================== replay oktalyzer RESSOURCE =================
lb_0014	movem.l	d0-a6,-(a7)
	move.w	d0,-(a7)
	bsr.w	lb_0126
	addq.w	#8,a0
	move.l	a0,lb_011e
	move.l	#$434d4f44,d0
	bsr.w	lb_00f8
	lea	lb_014e(pc),a1
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	#$53414d50,d0
	bsr.w	lb_00f8
	lea	lb_0fc8,a1
	move.w	#$047f,d0
lb_004c	move.b	(a0)+,(a1)+
	dbf	d0,lb_004c
	move.l	#$53504545,d0
	bsr.w	lb_00f8
	move.w	(a0)+,lb_0156
	move.l	#$534c454e,d0
	bsr.w	lb_00f8
	move.w	(a0)+,lb_00f2
	move.l	#$504c454e,d0
	bsr.w	lb_00f8
	move.w	(a0)+,lb_0158
	move.l	#$50415454,d0
	bsr.w	lb_00f8
	lea	lb_1448,a1
	moveq	#$7f,d0
lb_0094	move.b	(a0)+,(a1)+
	dbf	d0,lb_0094
	lea	lb_14c8,a1
	moveq	#$00,d7
lb_00a2	move.l	#$50424f44,d0
	bsr.w	lb_00f8
	move.l	a0,(a1)+
	addq.w	#1,d7
	cmp.w	lb_00f2(pc),d7
	bne.b	lb_00a2
	lea	lb_0fdc,a5
	lea	lb_15c8,a1
	moveq	#$00,d7
lb_00c4	tst.l	(a5)
	beq.b	lb_00d8
	move.l	#$53424f44,d0
	bsr.w	lb_00f8
	move.l	a0,(a1)
	move.l	d0,$0004(a1)
lb_00d8	addq.w	#8,a1
	lea	$0020(a5),a5
	addq.w	#1,d7
	cmpi.w	#$0024,d7
	bne.b	lb_00c4
	move.w	(a7)+,d0
	bsr.w	lb_015c
	movem.l	(a7)+,d0-a6
	rts	
lb_00f2	ori.b	#$00,d0
lb_00f8	movem.l	d2/d3,-(a7)
	move.w	d0,d0
	move.l	lb_011e(pc),a0
lb_0100	movem.l	(a0)+,d2/d3
	cmp.l	d2,d0
	beq.b	lb_010c
	adda.l	d3,a0
	bra.b	lb_0100
lb_010c	adda.l	d3,a0
	move.l	a0,lb_011e
	suba.l	d3,a0
	move.l	d3,d0
	movem.l	(a7)+,d2/d3
	rts	
lb_011e	dc.l	0
lb_0122	bra.w	lb_0216
lb_0126	movem.l	d0/a6,-(a7)
	lea	$00dff000,a6
	move.w	#$000f,$0096(a6)
	moveq	#$00,d0
	move.w	d0,$00a8(a6)
	move.w	d0,$00b8(a6)
	move.w	d0,$00c8(a6)
	move.w	d0,$00d8(a6)
	movem.l	(a7)+,d0/a6
	rts	
lb_014e	dc.l	0
	dc.l	0
lb_0156	dc.w	0
lb_0158	dc.l	0
lb_015c	lea	lb_06cc(pc),a0
	tst.b	d0
	beq.b	lb_0168
	lea	lb_0710(pc),a0
lb_0168	move.l	a0,lb_06c8
	bsr.w	lb_0e84
	moveq	#$00,d1
	lea	lb_16e8,a0
	moveq	#$0f,d0
lb_017c	move.l	d1,(a0)+
	dbf	d0,lb_017c
	lea	lb_180a,a0
	lea	lb_20ca,a1
	move.w	#$022f,d0
lb_0192	move.l	d1,(a0)+
	move.l	d1,(a1)+
	dbf	d0,lb_0192
	lea	lb_014e,a0
	moveq	#$00,d1
	moveq	#$03,d0
lb_01a4	or.w	(a0)+,d1
	ror.w	#1,d1
	dbf	d0,lb_01a4
	ror.w	#5,d1
	move.w	d1,lb_0212
	lea	$00dff000,a6
	move.w	#$000f,$0096(a6)
	lea	lb_17b8,a0
	move.l	a0,$00a0(a6)
	move.l	a0,$00b0(a6)
	move.l	a0,$00c0(a6)
	move.l	a0,$00d0(a6)
	moveq	#$29,d0
	move.w	d0,$00a4(a6)
	move.w	d0,$00b4(a6)
	move.w	d0,$00c4(a6)
	move.w	d0,$00d4(a6)
	move.w	#$0358,d0
	move.w	d0,$00a6(a6)
	move.w	d0,$00b6(a6)
	move.w	d0,$00c6(a6)
	move.w	d0,$00d6(a6)
	move.w	#$00ff,$009e(a6)
	bsr.w	lb_0f36
	bsr.w	lb_0f36
	st	lb_0214
	rts	
lb_0212	dc.w	0
lb_0214	dc.w	0
lb_0216	move.b	lb_0214(pc),d0
	beq.b	lb_022a
	move.w	#$800f,$00dff096
	sf	lb_0214
lb_022a	bsr.w	lb_0578
	bsr.w	lb_0754
	lea	lb_1748,a0
	lea	lb_06c0(pc),a2
	move.l	(a2)+,a1
	move.l	(a2),-(a2)
	move.l	a1,$0004(a2)
	moveq	#$00,d0
lb_0246	tst.w	(a0)
	beq.b	lb_0256
	movem.l	d0/a0-a2,-(a7)
	bsr.w	lb_026a
	movem.l	(a7)+,d0/a0-a2
lb_0256	lea	$001c(a0),a0
	lea	$0230(a1),a1
	addq.w	#1,d0
	cmpi.w	#$0004,d0
	bne.b	lb_0246
	bra.w	lb_05cc
lb_026a	tst.l	$0002(a0)
	beq.b	lb_029e
	tst.l	$0010(a0)
	beq.b	lb_02a2
	bsr.w	lb_02aa
	move.w	d1,d2
	lea	$000e(a0),a0
	bsr.w	lb_02aa
	cmp.w	d1,d2
	blt.b	lb_0292
	move.l	a1,a2
	lea	-$000e(a0),a1
	bra.w	lb_02c4
lb_0292	move.l	a1,a2
	lea	-$000e(a0),a1
	exg	a0,a1
	bra.w	lb_02c4
lb_029e	lea	$000e(a0),a0
lb_02a2	bsr.w	lb_02aa
	bra.w	lb_04ee
lb_02aa	move.w	$000a(a0),d1
	bpl.b	lb_02b6
	clr.w	$000a(a0)
	rts	
lb_02b6	cmpi.w	#$0021,d1
	ble.b	lb_02c2
	move.w	#$0021,$000a(a0)
lb_02c2	rts	
lb_02c4	lea	lb_16e8,a3
	lsl.w	#4,d0
	adda.w	d0,a3
	move.w	$000a(a1),d0
	add.w	d0,d0
	lea	lb_0f56,a4
	move.w	$00(a4,d0.w),d2
	move.w	d2,$0004(a3)
	move.w	$000a(a0),d3
	add.w	d3,d3
	move.w	$00(a4,d3.w),d3
	move.l	lb_06c8(pc),a4
	move.w	$00(a4,d0.w),d1
	add.w	$0008(a3),d1
	move.w	d1,$0006(a3)
	swap	d2
	clr.w	d2
	divu.w	d3,d2
	move.l	$0006(a0),d0
	lsr.l	#1,d0
	move.l	a2,(a3)
	movem.l	d0/a0/a1,-(a7)
	move.l	$0002(a0),a0
	move.l	a2,a1
	bsr.w	lb_03f8
	move.l	a0,a4
	movem.l	(a7)+,d1/a0/a1
	sub.w	d0,d1
	bcc.b	lb_0334
	clr.l	$0002(a0)
	clr.l	$0006(a0)
	clr.w	$000a(a0)
	clr.w	$000c(a0)
	bra.b	lb_033e
lb_0334	move.l	a4,$0002(a0)
	add.l	d1,d1
	move.l	d1,$0006(a0)
lb_033e	move.l	$0006(a1),d0
	lsr.l	#1,d0
	move.w	$0006(a3),d1
	movem.l	d0/d1/a1,-(a7)
	move.l	$0002(a1),a0
	move.l	a2,a1
	bsr.w	lb_037e
	move.l	a0,a4
	movem.l	(a7)+,d0/d1/a1
	sub.w	d1,d0
	bcc.b	lb_0372
	clr.l	$0002(a1)
	clr.l	$0006(a1)
	clr.w	$000a(a1)
	clr.w	$000c(a1)
	rts	
lb_0372	move.l	a4,$0002(a1)
	add.l	d0,d0
	move.l	d0,$0006(a1)
	rts	
lb_037e	cmp.w	d0,d1
	bhi.b	lb_0384
	move.w	d1,d0
lb_0384	bra.w	lb_0388
lb_0388	cmpi.w	#$0020,d0
	bcs.b	lb_03d4
	move.l	(a0)+,d1
	add.l	d1,(a1)+
	move.l	(a0)+,d1
	add.l	d1,(a1)+
	move.l	(a0)+,d1
	add.l	d1,(a1)+
	move.l	(a0)+,d1
	add.l	d1,(a1)+
	move.l	(a0)+,d1
	add.l	d1,(a1)+
	move.l	(a0)+,d1
	add.l	d1,(a1)+
	move.l	(a0)+,d1
	add.l	d1,(a1)+
	move.l	(a0)+,d1
	add.l	d1,(a1)+
	move.l	(a0)+,d1
	add.l	d1,(a1)+
	move.l	(a0)+,d1
	add.l	d1,(a1)+
	move.l	(a0)+,d1
	add.l	d1,(a1)+
	move.l	(a0)+,d1
	add.l	d1,(a1)+
	move.l	(a0)+,d1
	add.l	d1,(a1)+
	move.l	(a0)+,d1
	add.l	d1,(a1)+
	move.l	(a0)+,d1
	add.l	d1,(a1)+
	move.l	(a0)+,d1
	add.l	d1,(a1)+
	sub.w	#$0020,d0
	bra.b	lb_0388
lb_03d4	cmpi.w	#$0008,d0
	bcs.b	lb_03f2
	move.l	(a0)+,d1
	add.l	d1,(a1)+
	move.l	(a0)+,d1
	add.l	d1,(a1)+
	move.l	(a0)+,d1
	add.l	d1,(a1)+
	move.l	(a0)+,d1
	add.l	d1,(a1)+
	subq.w	#8,d0
	bra.b	lb_03d4
lb_03ee	move.w	(a0)+,d1
	add.w	d1,(a1)+
lb_03f2	dbf	d0,lb_03ee
	rts	
lb_03f8	tst.w	d2
	bne.b	lb_0406
	move.w	d1,-(a7)
	bsr.w	lb_060a
	move.w	(a7)+,d0
	rts	
lb_0406	move.l	d3,-(a7)
	move.w	d2,d3
	mulu.w	d1,d3
	swap	d3
	cmp.w	d0,d3
	bhi.b	lb_041a
	move.w	d2,d0
	bsr.w	lb_0428
	bra.b	lb_0424
lb_041a	move.w	d0,-(a7)
	move.w	d1,d0
	bsr.w	lb_0678
	move.w	(a7)+,d0
lb_0424	move.l	(a7)+,d3
	rts	
lb_0428	movem.l	d2-d5/a2,-(a7)
	move.l	a0,a2
	move.w	d1,d2
	moveq	#$00,d3
	subq.w	#1,d1
lb_0434	subq.w	#8,d2
	bmi.w	lb_04be
	sub.w	d0,d3
	bcc.b	lb_0440
	move.b	(a0)+,d5
lb_0440	move.b	d5,(a1)+
	sub.w	d0,d3
	bcc.b	lb_0448
	move.b	(a0)+,d5
lb_0448	move.b	d5,(a1)+
	sub.w	d0,d3
	bcc.b	lb_0450
	move.b	(a0)+,d5
lb_0450	move.b	d5,(a1)+
	sub.w	d0,d3
	bcc.b	lb_0458
	move.b	(a0)+,d5
lb_0458	move.b	d5,(a1)+
	sub.w	d0,d3
	bcc.b	lb_0460
	move.b	(a0)+,d5
lb_0460	move.b	d5,(a1)+
	sub.w	d0,d3
	bcc.b	lb_0468
	move.b	(a0)+,d5
lb_0468	move.b	d5,(a1)+
	sub.w	d0,d3
	bcc.b	lb_0470
	move.b	(a0)+,d5
lb_0470	move.b	d5,(a1)+
	sub.w	d0,d3
	bcc.b	lb_0478
	move.b	(a0)+,d5
lb_0478	move.b	d5,(a1)+
	sub.w	d0,d3
	bcc.b	lb_0480
	move.b	(a0)+,d5
lb_0480	move.b	d5,(a1)+
	sub.w	d0,d3
	bcc.b	lb_0488
	move.b	(a0)+,d5
lb_0488	move.b	d5,(a1)+
	sub.w	d0,d3
	bcc.b	lb_0490
	move.b	(a0)+,d5
lb_0490	move.b	d5,(a1)+
	sub.w	d0,d3
	bcc.b	lb_0498
	move.b	(a0)+,d5
lb_0498	move.b	d5,(a1)+
	sub.w	d0,d3
	bcc.b	lb_04a0
	move.b	(a0)+,d5
lb_04a0	move.b	d5,(a1)+
	sub.w	d0,d3
	bcc.b	lb_04a8
	move.b	(a0)+,d5
lb_04a8	move.b	d5,(a1)+
	sub.w	d0,d3
	bcc.b	lb_04b0
	move.b	(a0)+,d5
lb_04b0	move.b	d5,(a1)+
	sub.w	d0,d3
	bcc.b	lb_04b8
	move.b	(a0)+,d5
lb_04b8	move.b	d5,(a1)+
	bra.w	lb_0434
lb_04be	addq.w	#8,d2
	bra.b	lb_04d2
lb_04c2	sub.w	d0,d3
	bcc.b	lb_04c8
	move.b	(a0)+,d5
lb_04c8	move.b	d5,(a1)+
	sub.w	d0,d3
	bcc.b	lb_04d0
	move.b	(a0)+,d5
lb_04d0	move.b	d5,(a1)+
lb_04d2	dbf	d2,lb_04c2
	suba.l	a0,a2
	move.w	a2,d0
	neg.w	d0
	btst	#$00,d0
	beq.b	lb_04e6
	addq.w	#1,a0
	addq.w	#1,d0
lb_04e6	lsr.w	#1,d0
	movem.l	(a7)+,d2-d5/a2
	rts	
lb_04ee	lea	lb_16e8,a2
	lsl.w	#4,d0
	adda.w	d0,a2
	tst.l	$0002(a0)
	beq.b	lb_055c
	move.w	$000a(a0),d0
	add.w	d0,d0
	lea	lb_0f56,a3
	move.w	$00(a3,d0.w),$0004(a2)
	move.l	lb_06c8(pc),a3
	move.w	$00(a3,d0.w),d1
	add.w	$0008(a2),d1
	move.w	d1,$0006(a2)
	move.l	$0006(a0),d0
	lsr.l	#1,d0
	move.l	a1,(a2)
	movem.l	d0/d1/a0,-(a7)
	move.l	$0002(a0),a0
	bsr.w	lb_060a
	move.l	a0,a1
	movem.l	(a7)+,d0/d1/a0
	sub.w	d1,d0
	bcc.b	lb_0550
	clr.l	$0002(a0)
	clr.l	$0006(a0)
	clr.w	$000a(a0)
	clr.w	$000c(a0)
	rts	
lb_0550	move.l	a1,$0002(a0)
	add.l	d0,d0
	move.l	d0,$0006(a0)
	rts	
lb_055c	move.l	a1,(a2)
	move.w	lb_0f56,$0004(a2)
	move.l	lb_06c8(pc),a0
	move.w	(a0),d0
	add.w	$0008(a2),d0
	move.w	d0,$0006(a2)
	bra.w	lb_0678
lb_0578	lea	lb_16e8,a0
	lea	$00dff01e,a2
	lea	$0088(a2),a1
	moveq	#$03,d0
lb_058a	move.w	$0004(a0),d1
	beq.b	lb_0596
	move.w	d1,(a1)
	move.w	(a2),$000a(a0)
lb_0596	lea	$0010(a0),a0
	lea	$0010(a1),a1
	dbf	d0,lb_058a
	lea	lb_16e8,a0
	moveq	#$07,d1
lb_05aa	tst.l	(a0)
	beq.b	lb_05be
	clr.w	$0008(a0)
	move.w	$000a(a0),d0
	btst	d1,d0
	beq.b	lb_05be
	addq.w	#1,$0008(a0)
lb_05be	lea	$0010(a0),a0
	addq.w	#1,d1
	cmpi.w	#$000b,d1
	bne.b	lb_05aa
	rts	
lb_05cc	move.w	lb_0212(pc),d1
lb_05d0	move.w	$00dff01e,d0
	and.w	d1,d0
	cmp.w	d1,d0
	bne.b	lb_05d0
	move.w	d1,$00dff09c
	lea	lb_16e8,a0
	lea	$00dff0a0,a1
	moveq	#$03,d0
lb_05f0	move.l	(a0),d1
	beq.b	lb_05fc
	move.l	d1,(a1)
	move.w	$0006(a0),$0004(a1)
lb_05fc	lea	$0010(a0),a0
	lea	$0010(a1),a1
	dbf	d0,lb_05f0
	rts	
lb_060a	movem.l	d2/a2,-(a7)
	move.w	d1,d2
	cmp.w	d0,d2
	bhi.b	lb_061c
	move.w	d2,d0
	bsr.w	lb_0632
	bra.b	lb_062c
lb_061c	sub.w	d0,d2
	bsr.w	lb_0632
	move.l	a0,a2
	move.w	d2,d0
	bsr.w	lb_0678
	move.l	a2,a0
lb_062c	movem.l	(a7)+,d2/a2
	rts	
lb_0632	cmpi.w	#$0020,d0
	bcs.b	lb_065e
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	sub.w	#$0020,d0
	bra.b	lb_0632
lb_065e	cmpi.w	#$0008,d0
	bcs.b	lb_0672
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	subq.w	#8,d0
	bra.b	lb_065e
lb_0670	move.w	(a0)+,(a1)+
lb_0672	dbf	d0,lb_0670
	rts	
lb_0678	moveq	#$00,d1
lb_067a	cmpi.w	#$0020,d0
	bcs.b	lb_06a6
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	sub.w	#$0020,d0
	bra.b	lb_067a
lb_06a6	cmpi.w	#$0008,d0
	bcs.b	lb_06ba
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	subq.w	#8,d0
	bra.b	lb_06a6
lb_06b8	move.w	d1,(a1)+
lb_06ba	dbf	d0,lb_06b8
	rts	
lb_06c0	dc.l	lb_180a,lb_20ca
lb_06c8	dc.l	0
lb_06cc	dc.w	$0029,$002b,$002e,$0031,$0034,$0037,$003a,$003e
	dc.w	$0042,$0045,$004a,$004e,$0053,$0057,$005d,$0062
	dc.w	$0068,$006f,$0075,$007c,$0084,$008b,$0094,$009d
	dc.w	$00a6,$00af,$00ba,$00c5,$00d0,$00de,$00eb,$00f8
	dc.w	$0107,$0117
	
lb_0710	dc.w	$0022,$0025,$0027,$0029,$002c,$002e,$0031,$0034
	dc.w	$0037,$003a,$003e,$0042,$0045,$004a,$004e,$0053
	dc.w	$0058,$005d,$0063,$0068,$006f,$0075,$007c,$0084
	dc.w	$008b,$0094,$009d,$00a6,$00af,$00ba,$00c6,$00d1
	dc.w	$00dd,$00eb

lb_0754	bsr.w	lb_0960
	addq.w	#1,lb_0fa0
	move.w	lb_0faa(pc),d0
	cmp.w	lb_0fa0(pc),d0
	bgt.b	lb_0770
	bsr.w	lb_0818
	bsr.w	lb_08ec
lb_0770	lea	lb_172a,a2
	lea	lb_1748,a5
	moveq	#$07,d7
lb_077e	tst.b	(a5)
	bne.b	lb_0790
	addq.w	#4,a2
	lea	$001c(a5),a5
	subq.w	#1,d7
	dbf	d7,lb_077e
	rts	
lb_0790	moveq	#$00,d0
	move.b	(a2),d0
	add.w	d0,d0
	move.w	lb_07d0(pc,d0.w),d0
	beq.b	lb_07a6
	moveq	#$00,d1
	move.b	$0001(a2),d1
	jsr	lb_07d0(pc,d0.w)
lb_07a6	addq.w	#4,a2
	lea	$000e(a5),a5
	subq.w	#1,d7
	moveq	#$00,d0
	move.b	(a2),d0
	add.w	d0,d0
	move.w	lb_07d0(pc,d0.w),d0
	beq.b	lb_07c4
	moveq	#$00,d1
	move.b	$0001(a2),d1
	jsr	lb_07d0(pc,d0.w)
lb_07c4	addq.w	#4,a2
	lea	$000e(a5),a5
	dbf	d7,lb_077e
	rts	
lb_07d0
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$050c,$054e,$0584,$05e0,$0000,$0022
	dc.w	$0000,$00c6,$0000,$0000,$0000,$00d8,$0000,$0000
	dc.w	$0000,$00ea,$0000,$0000,$060c,$0000,$00ce,$0632
	dc.w	$0000,$0000,$0000,$0000

lb_0818	clr.w	lb_0fa0
	move.l	lb_0fa2(pc),a1
	adda.w	lb_0fa6(pc),a1
	move.l	a1,lb_0fa2
	addq.w	#1,lb_0fa8
	bsr.w	lb_08a6
	tst.w	lb_0fac
	bpl.b	lb_0844
	cmp.w	lb_0fa8(pc),d0
	bgt.b	lb_088c
lb_0844	clr.w	lb_0fa8
	mulu.w	lb_0fa6(pc),d0
	sub.l	d0,lb_0fa2
	tst.w	lb_0fac
	bmi.b	lb_0866
	move.w	lb_0fac(pc),lb_0fae
	bra.b	lb_086c
lb_0866	addq.w	#1,lb_0fae
lb_086c	move.w	lb_0fae(pc),d0
	cmp.w	lb_0158,d0
	bne.b	lb_0888
	clr.w	lb_0fae
	move.w	lb_0156,lb_0faa
lb_0888	bsr.w	lb_08b8
lb_088c	move.l	lb_0fa2(pc),a0
	movem.l	(a0),d0-d7
	movem.l	d0-d7,lb_1728
	move.w	#$ffff,lb_0fac
	rts	
lb_08a6	move.w	lb_0fae(pc),d0
	lea	lb_1448,a0
	move.b	$00(a0,d0.w),d0
	bra.w	lb_08da
lb_08b8	lea	lb_1448,a0
	move.w	lb_0fae(pc),d2
	moveq	#$00,d0
	move.b	$00(a0,d2.w),d0
	bsr.w	lb_08da
	move.l	a0,lb_0fa2
	clr.w	lb_0fa8
	rts	
lb_08da	lea	lb_14c8,a0
	add.w	d0,d0
	add.w	d0,d0
	move.l	$00(a0,d0.w),a0
	move.w	(a0)+,d0
	rts	
lb_08ec	lea	lb_15c8,a0
	lea	lb_0fc8,a1
	lea	lb_1728,a2
	lea	lb_1748,a3
	moveq	#$07,d7
lb_0906	tst.b	(a3)
	bne.b	lb_0918
	addq.w	#4,a2
	lea	$001c(a3),a3
	subq.w	#1,d7
	dbf	d7,lb_0906
	rts	
lb_0918	bsr.b	lb_0924
	subq.w	#1,d7
	bsr.b	lb_0924
	dbf	d7,lb_0906
	rts	
lb_0924	moveq	#$00,d3
	move.b	(a2),d3
	beq.b	lb_0958
	subq.w	#1,d3
	moveq	#$00,d0
	move.b	$0001(a2),d0
	lsl.w	#3,d0
	move.l	$00(a0,d0.w),d2
	beq.b	lb_0958
	add.w	d0,d0
	add.w	d0,d0
	cmpi.w	#$0001,$1e(a1,d0.w)
	beq.b	lb_0958
	move.l	d2,$0002(a3)
	move.l	$14(a1,d0.w),$0006(a3)
	move.w	d3,$000a(a3)
	move.w	d3,$000c(a3)
lb_0958	addq.w	#4,a2
	lea	$000e(a3),a3
	rts	
lb_0960	bsr.w	lb_0aa2
	move.w	lb_0fa0(pc),d0
	bne.b	lb_0972
	bsr.b	lb_09b4
	or.w	d4,lb_0fc2
lb_0972	bsr.w	lb_0b14
	lea	lb_0fb8(pc),a0
	move.l	(a0)+,(a0)
	lea	$00dff0a8,a1
	moveq	#$00,d0
	move.b	(a0)+,d0
	move.w	d0,(a1)
	move.b	(a0)+,d0
	move.w	d0,$0010(a1)
	move.b	(a0)+,d0
	move.w	d0,$0020(a1)
	move.b	(a0)+,d0
	move.w	d0,$0030(a1)
	move.b	lb_0fc0(pc),d0
	beq.b	lb_09aa
	bclr	#$01,$00bfe001
	rts	
lb_09aa	bset	#$01,$00bfe001
	rts	
lb_09b4	lea	lb_15c8,a0
	lea	lb_1728,a2
	lea	lb_1748,a3
	lea	$00dff0a0,a4
	lea	lb_0f56(pc),a6
	moveq	#$00,d4
	moveq	#$01,d5
	moveq	#$07,d7
lb_09d6	tst.b	(a3)
	bne.b	lb_09f0
	bsr.b	lb_0a04
	addq.w	#4,a2
	lea	$001c(a3),a3
	lea	$0010(a4),a4
	add.w	d5,d5
	subq.w	#1,d7
	dbf	d7,lb_09d6
	rts	
lb_09f0	addq.w	#8,a2
	lea	$001c(a3),a3
	lea	$0010(a4),a4
	add.w	d5,d5
	subq.w	#1,d7
	dbf	d7,lb_09d6
	rts	
lb_0a04	moveq	#$00,d3
	move.b	(a2),d3
	beq.w	lb_0a86
	subq.w	#1,d3
	moveq	#$00,d0
	move.b	$0001(a2),d0
	lsl.w	#3,d0
	move.l	$00(a0,d0.w),d2
	beq.w	lb_0a86
	add.w	d0,d0
	add.w	d0,d0
	lea	lb_0fc8,a1
	adda.w	d0,a1
	tst.w	$001e(a1)
	beq.w	lb_0a86
	move.l	$0014(a1),d1
	lsr.l	#1,d1
	tst.w	d1
	beq.w	lb_0a86
	move.w	d5,$00dff096
	or.w	d5,d4
	move.l	d2,(a4)
	move.w	d3,$0008(a3)
	add.w	d3,d3
	move.w	$00(a6,d3.w),d0
	move.w	d0,$000a(a3)
	move.w	d0,$0006(a4)
	move.l	a0,-(a7)
	lea	lb_0fb8(pc),a0
	moveq	#$00,d0
	move.b	-$08(a0,d7.w),d0
	move.b	$001d(a1),$00(a0,d0.w)
	move.l	(a7)+,a0
	move.w	$001a(a1),d0
	bne.b	lb_0a88
	move.w	d1,$0004(a4)
	move.l	#lb_298c,$0002(a3)
	move.w	#$0001,$0006(a3)
lb_0a86	rts	
lb_0a88	move.w	d0,$0006(a3)
	moveq	#$00,d1
	move.w	$0018(a1),d1
	add.w	d1,d0
	move.w	d0,$0004(a4)
	add.l	d1,d1
	add.l	d2,d1
	move.l	d1,$0002(a3)
	rts	
lb_0aa2	lea	lb_0fc2(pc),a0
	move.w	(a0),d0
	beq.b	lb_0b12
	clr.w	(a0)
	or.w	#$8000,d0
	lea	$00dff006,a0
	move.w	d0,$0090(a0)
	move.b	(a0),d1
lb_0abc	cmp.b	(a0),d1
	beq.b	lb_0abc
	move.b	(a0),d1
lb_0ac2	cmp.b	(a0),d1
	beq.b	lb_0ac2
	lea	lb_174a,a1
	btst	#$00,d0
	beq.b	lb_0adc
	move.l	(a1),$009a(a0)
	move.w	$0004(a1),$009e(a0)
lb_0adc	btst	#$01,d0
	beq.b	lb_0aee
	move.l	$001c(a1),$00aa(a0)
	move.w	$0020(a1),$00ae(a0)
lb_0aee	btst	#$02,d0
	beq.b	lb_0b00
	move.l	$0038(a1),$00ba(a0)
	move.w	$003c(a1),$00be(a0)
lb_0b00	btst	#$03,d0
	beq.b	lb_0b12
	move.l	$0054(a1),$00ca(a0)
	move.w	$0058(a1),$00ce(a0)
lb_0b12	rts	
lb_0b14	lea	lb_1728,a2
	lea	lb_1748,a3
	lea	$00dff0a0,a4
	lea	lb_0f56(pc),a6
	moveq	#$01,d5
	moveq	#$07,d7
lb_0b2e	tst.b	(a3)
	bne.b	lb_0b48
	bsr.b	lb_0b5c
	addq.w	#4,a2
	lea	$001c(a3),a3
	lea	$0010(a4),a4
	add.w	d5,d5
	subq.w	#1,d7
	dbf	d7,lb_0b2e
	rts	
lb_0b48	addq.w	#8,a2
	lea	$001c(a3),a3
	lea	$0010(a4),a4
	add.w	d5,d5
	subq.w	#1,d7
	dbf	d7,lb_0b2e
	rts	
lb_0b5c	moveq	#$00,d0
	move.b	$0002(a2),d0
	add.w	d0,d0
	moveq	#$00,d1
	move.b	$0003(a2),d1
	move.w	lb_0b74(pc,d0.w),d0
	jmp	lb_0b74(pc,d0.w)
	rts	
lb_0b74
	dc.w	$fffe,$0062,$0048,$fffe,$fffe,$fffe,$fffe,$fffe
	dc.w	$fffe,$fffe,$007c,$00b8,$00e6,$013c,$fffe,$027e
	dc.w	$fffe,$0120,$fffe,$fffe,$fffe,$0134,$fffe,$fffe
	dc.w	$02f4,$0246,$fffe,$fffe,$0268,$fffe,$0128,$028e
	dc.w	$fffe,$fffe,$fffe,$fffe
lb_0bbc:
	add.w	d1,$000a(a3)
	cmpi.w	#$0358,$000a(a3)
	ble.b	lb_0bce
	move.w	#$0358,$000a(a3)
lb_0bce	move.w	$000a(a3),$0006(a4)
	rts	
	sub.w	d1,$000a(a3)
	cmpi.w	#$0071,$000a(a3)
	bge.b	lb_0be8
	move.w	#$0071,$000a(a3)
lb_0be8	move.w	$000a(a3),$0006(a4)
	rts	
	move.w	$0008(a3),d2
	move.w	lb_0fa0(pc),d0
	move.b	lb_0c1c(pc,d0.w),d0
	bne.b	lb_0c0a
	and.w	#$00f0,d1
	lsr.w	#4,d1
	sub.w	d1,d2
	bra.w	lb_0cbe
lb_0c0a	subq.b	#1,d0
	bne.b	lb_0c12
	bra.w	lb_0cbe
lb_0c12	and.w	#$000f,d1
	add.w	d1,d2
	bra.w	lb_0cbe
lb_0c1c	ori.b	#$00,d1
	btst	d0,d2
	ori.b	#$00,d1
	btst	d0,d2
	ori.b	#$00,d1
	move.w	$0008(a3),d2
	move.w	lb_0fa0(pc),d0
	and.w	#$0003,d0
	bne.b	lb_0c3e
	bra.w	lb_0cbe
lb_0c3e	subq.b	#1,d0
	bne.b	lb_0c4a
	and.w	#$000f,d1
	add.w	d1,d2
	bra.b	lb_0cbe
lb_0c4a	subq.b	#1,d0
	beq.b	lb_0cbe
	and.w	#$00f0,d1
	lsr.w	#4,d1
	sub.w	d1,d2
	bra.w	lb_0cbe
	move.w	$0008(a3),d2
	move.w	lb_0fa0(pc),d0
	move.b	lb_0c84(pc,d0.w),d0
	bne.b	lb_0c6a
	rts	
lb_0c6a	subq.b	#1,d0
	bne.b	lb_0c78
	and.w	#$00f0,d1
	lsr.w	#4,d1
	add.w	d1,d2
	bra.b	lb_0cbe
lb_0c78	subq.b	#1,d0
	bne.b	lb_0c82
	and.w	#$000f,d1
	add.w	d1,d2
lb_0c82	bra.b	lb_0cbe
lb_0c84	ori.b	#$03,d1
	btst	d0,d2
	btst	d1,d1
	andi.b	#$02,d3
	btst	d1,d1
	andi.b	#$3a,d3
	movep.w	$6702(a2),d1
	rts	
	move.w	$0008(a3),d2
	add.w	d1,d2
	move.w	d2,$0008(a3)
	bra.b	lb_0cbe
	move.w	lb_0fa0(pc),d0
	beq.b	lb_0cb0
	rts	
lb_0cb0	move.w	$0008(a3),d2
	sub.w	d1,d2
	move.w	d2,$0008(a3)
	bra.w	lb_0cbe
lb_0cbe	tst.w	d2
	bpl.b	lb_0cc4
	moveq	#$00,d2
lb_0cc4	cmpi.w	#$0023,d2
	ble.b	lb_0ccc
	moveq	#$23,d2
lb_0ccc	add.w	d2,d2
	move.w	$00(a6,d2.w),d0
	move.w	d0,$0006(a4)
	move.w	d0,$000a(a3)
	rts	
	move.w	$000c(a5),d2
	move.w	lb_0fa0(pc),d0
	move.b	lb_0d0e(pc,d0.w),d0
	bne.b	lb_0cf8
	and.w	#$00f0,d1
	lsr.w	#4,d1
	sub.w	d1,d2
	move.w	d2,$000a(a5)
	rts	
lb_0cf8	subq.b	#1,d0
	bne.b	lb_0d02
	move.w	d2,$000a(a5)
	rts	
lb_0d02	and.w	#$000f,d1
	add.w	d1,d2
	move.w	d2,$000a(a5)
	rts	
lb_0d0e	ori.b	#$00,d1
	btst	d0,d2
	ori.b	#$00,d1
	btst	d0,d2
	ori.b	#$00,d1
	move.w	$000c(a5),d2
	move.w	lb_0fa0(pc),d0
	and.w	#$0003,d0
	bne.b	lb_0d32
lb_0d2c	move.w	d2,$000a(a5)
	rts	
lb_0d32	subq.b	#1,d0
	bne.b	lb_0d42
	and.w	#$000f,d1
	add.w	d1,d2
	move.w	d2,$000a(a5)
	rts	
lb_0d42	subq.b	#1,d0
	beq.b	lb_0d2c
	and.w	#$00f0,d1
	lsr.w	#4,d1
	sub.w	d1,d2
	move.w	d2,$000a(a5)
	rts	
	move.w	$000c(a5),d2
	move.w	lb_0fa0(pc),d0
	move.b	lb_0d86(pc,d0.w),d0
	bne.b	lb_0d64
	rts	
lb_0d64	subq.b	#1,d0
	bne.b	lb_0d76
	and.w	#$00f0,d1
	lsr.w	#4,d1
	add.w	d1,d2
	move.w	d2,$000a(a5)
	rts	
lb_0d76	subq.b	#1,d0
	bne.b	lb_0d80
	and.w	#$000f,d1
	add.w	d1,d2
lb_0d80	move.w	d2,$000a(a5)
	rts	
lb_0d86	ori.b	#$03,d1
	btst	d0,d2
	btst	d1,d1
	andi.b	#$02,d3
	btst	d1,d1
	andi.b	#$3a,d3
	dc	$0208
	beq.b	lb_0d9e
	rts	
lb_0d9e	add.w	d1,$000c(a5)
	add.w	d1,$000a(a5)
	rts	
	move.w	lb_0fa0(pc),d0
	beq.b	lb_0db0
	rts	
lb_0db0	sub.w	d1,$000c(a5)
	sub.w	d1,$000a(a5)
	rts	
	move.w	lb_0fa0(pc),d0
	bne.b	lb_0dda
	move.w	d1,d0
	and.w	#$000f,d0
	lsr.w	#4,d1
	mulu.w	#$000a,d1
	add.w	d1,d0
	cmp.w	lb_0158(pc),d0
	bcc.b	lb_0dda
	move.w	d0,lb_0fac
lb_0dda	rts	
	move.w	lb_0fa0(pc),d0
	bne.b	lb_0df0
	and.w	#$000f,d1
	tst.b	d1
	beq.b	lb_0df0
	move.w	d1,lb_0faa
lb_0df0	rts	
	move.w	lb_0fa0(pc),d0
	bne.b	lb_0e00
	tst.b	d1
	sne	lb_0fc0
lb_0e00	rts	
	move.l	a0,-(a7)
	moveq	#$00,d0
	lea	lb_0fb8(pc),a0
	move.b	-$08(a0,d7.w),d0
	adda.w	d0,a0
	cmpi.w	#$0040,d1
	bgt.b	lb_0e1c
	move.b	d1,(a0)
lb_0e18	move.l	(a7)+,a0
	rts	
lb_0e1c	sub.b	#$40,d1
	cmpi.b	#$10,d1
	blt.b	lb_0e4c
	sub.b	#$10,d1
	cmpi.b	#$10,d1
	blt.b	lb_0e5a
	sub.b	#$10,d1
	cmpi.b	#$10,d1
	blt.b	lb_0e46
	sub.b	#$10,d1
	cmpi.b	#$10,d1
	blt.b	lb_0e54
	bra.b	lb_0e18
lb_0e46	move.w	lb_0fa0(pc),d0
	bne.b	lb_0e18
lb_0e4c	sub.b	d1,(a0)
	bpl.b	lb_0e18
	sf	(a0)
	bra.b	lb_0e18
lb_0e54	move.w	lb_0fa0(pc),d0
	bne.b	lb_0e18
lb_0e5a	add.b	d1,(a0)
	cmpi.b	#$40,(a0)
	bls.b	lb_0e18
	move.b	#$40,(a0)
	bra.b	lb_0e18
	move.l	a0,-(a7)
	moveq	#$00,d0
	lea	lb_0fb8(pc),a0
	move.b	-$08(a0,d7.w),d0
	adda.w	d0,a0
	move.b	$0004(a0),(a0)
	cmpi.b	#$40,d1
	bhi.b	lb_0e1c
	move.l	(a7)+,a0
	rts	
lb_0e84	clr.w	lb_0fc4
	clr.w	lb_0fae
	lea	lb_1748,a0
	move.w	#$006f,d0
lb_0e9a	sf	(a0)+
	dbf	d0,lb_0e9a
	lea	lb_014e,a0
	lea	lb_1748,a1
	moveq	#$03,d0
	moveq	#$00,d1
lb_0eb0	tst.w	(a0)
	sne	(a1)
	sne	$000e(a1)
	add.w	(a0)+,d1
	lea	$001c(a1),a1
	dbf	d0,lb_0eb0
	addq.w	#4,d1
	add.w	d1,d1
	add.w	d1,d1
	move.w	d1,lb_0fa6
	lea	lb_1728,a0
	moveq	#$00,d1
	moveq	#$07,d0
lb_0ed8	move.l	d1,(a0)+
	dbf	d0,lb_0ed8
	lea	lb_0fb0(pc),a0
	move.l	#$03030202,(a0)+
	move.l	#$01010000,(a0)+
	move.l	#$40404040,d0
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	bsr.w	lb_08b8
	subq.w	#1,lb_0fa8
	move.w	#$ffff,lb_0fac
	move.l	lb_0fa2(pc),a0
	suba.w	lb_0fa6(pc),a0
	move.l	a0,lb_0fa2
	move.w	lb_0156,lb_0faa
	clr.w	lb_0fa0
	clr.w	lb_0fc0
	clr.w	lb_0fc2
	rts	
lb_0f36	movem.l	d0/d1,-(a7)
	moveq	#$04,d1
lb_0f3c	move.b	$00dff006,d0
lb_0f42	cmp.b	$00dff006,d0
	beq.b	lb_0f42
	dbf	d1,lb_0f3c
	movem.l	(a7)+,d0/d1
	rts	

lb_0f54
	dc.w	$0000
lb_0f56
	dc.w	$0358,$0328,$02fa,$02d0,$02a6,$0280,$025c,$023a
	dc.w	$021a,$01fc,$01e0,$01c5,$01ac,$0194,$017d,$0168
	dc.w	$0153,$0140,$012e,$011d,$010d,$00fe,$00f0,$00e2
	dc.w	$00d6,$00ca,$00be,$00b4,$00aa,$00a0,$0097,$008f
	dc.w	$0087,$007f,$0078,$0071,$0000

lb_0fa0	dc.w	$0000
lb_0fa2	dc.l	$0000
lb_0fa6	dc.w	$0000
lb_0fa8	dc.w	$0000
lb_0faa	dc.w	$0000
lb_0fac	dc.w	$0000
lb_0fae	dc.w	$0000
lb_0fb0	blk.w	($fb8-$fb0)/2
lb_0fb8	blk.w	($fc0-$fb8)/2
lb_0fc0	dc.w	$0000
lb_0fc2	dc.w	$0000
lb_0fc4	dc.l	$0000
lb_0fc8 blk.w	($fdc-$fc8)/2
lb_0fdc	blk.w	($1448-$fdc)/2
lb_1448 blk.w	($14c8-$1448)/2
lb_14c8 blk.w	($15c8-$14c8)/2
lb_15c8 blk.w	($16e8-$15c8)/2
lb_16e8 blk.w	($1728-$16e8)/2
lb_1728	dc.w	$0000
lb_172a	blk.w	($1748-$172a)/2
lb_1748	dc.w	$0000
lb_174a	blk.w	($17b8-$174a)/2
lb_17b8	blk.w	($180a-$17b8)/2
lb_180a	blk.w	($20ca-$180a)/2
lb_20ca	blk.w	($298c-$20ca)/2
lb_298c	dc.l	0

