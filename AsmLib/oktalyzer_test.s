r:	lea module,a0
	bsr oktalyzer_init

main:
	cmp.b	#255,$dff006
	bne	main
main2:
	cmp.b #255,$dff006
	beq main2
	
	move	#$f00,$dff180
	bsr.w	oktalyzer_play
	move	#$000,$dff180

	btst	#6,$bfe001
	bne.b	main

	bsr.w	oktalyzer_release

	rts
	
	include "oktalyzer.i"
	
module:
	incbin	'OKT.Contrast'
