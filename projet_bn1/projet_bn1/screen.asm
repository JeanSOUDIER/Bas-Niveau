;use r28 and r29 and r30

.def reg_cpt1 = r28
.def reg_cpt2 = r29
.def reg_screen = r30
.def reg_cpt3 = r20
.def reg_cpt4 = r23

SCREEN_Init:
	cbi		PORTB,0
	sbi		PORTB,1
	sbi		PORTB,3
	cbi		PORTB,2

	ldi		reg_cpt4,250
	rcall	tempo
	ldi		reg_cpt4,250
	rcall	tempo
	ldi		reg_cpt4,250
	rcall	tempo
	ldi		reg_cpt4,250
	rcall	tempo
	ldi		reg_cpt4,250
	rcall	tempo
	ldi		reg_cpt4,250
	rcall	tempo
	ldi		reg_cpt4,250
	rcall	tempo
	ldi		reg_cpt4,250
	rcall	tempo

	ldi		reg_screen,63
	out		PORTC,reg_screen
	rcall	enable

	sbi		PORTB,0
	cbi		PORTB,1
	ldi		reg_screen,63
	out		PORTC,reg_screen
	rcall	enable

	cbi		PORTB,0
	sbi		PORTB,1
	ldi		reg_screen,63
	out		PORTC,reg_screen
	rcall	enable

	rjmp	SCREEN_INC


; sous programme de temposirsation
tempo:
	ldi		reg_cpt3,255
boucletempo:
	dec		reg_cpt3
	nop
	brne	boucletempo
	dec		reg_cpt4
	brne	tempo
	ret

enable:
	ldi		reg_cpt4,4
	rcall	tempo
	cbi		PORTB,3
	ldi		reg_cpt4,4
	rcall	tempo
	sbi		PORTB,3
	ldi		reg_cpt4,4
	rcall	tempo
	ret
