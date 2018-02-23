r:	
	lea myIrqCode, a0
	bsr irq_start

main:
	btst	#6,$bfe001
	bne.b	main

	bsr irq_stop

	rts
	
	include "irq.i"
	
myIrqCode:
	move.w #$4F4, $dff180
	rts
