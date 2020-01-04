;use r20 and r21 and r23 and r24

.macro bGa[]
	sbis	PINA,1
.endmacro
.macro bGan[]
	sbic	PINA,1
.endmacro
.macro bBa[]
	sbis	PINA,2
.endmacro
.macro bBan[]
	sbic	PINA,2
.endmacro
.macro bDr[]
	sbis	PINA,3
.endmacro
.macro bDrn[]
	sbic	PINA,3
.endmacro
.macro bHa[]
	sbis	PINA,4
.endmacro
.macro bHan[]
	sbic	PINA,4
.endmacro
.macro bB[]
	sbis	PINA,5
.endmacro
.macro bBn[]
	sbic	PINA,5
.endmacro
.macro bA[]
	sbis	PINA,6
.endmacro
.macro bAn[]
	sbic	PINA,6
.endmacro
.macro bSta[]
	sbis	PINA,7
.endmacro
.macro bStan[]
	sbic	PINA,7
.endmacro
.macro bSel[]
	sbis	PIND,2
.endmacro
.macro bSeln[]
	sbic	PIND,2
.endmacro
.macro bL[]
	sbis	PIND,3
.endmacro
.macro bLn[]
	sbic	PIND,3
.endmacro
.macro bR[]
	sbis	PIND,4
.endmacro
.macro bRn[]
	sbic	PIND,4
.endmacro

TIMER_Init:
	ldi		reg_vol,(1<<CS02)|(1<<CS00)
	out		TCCR0,reg_vol
	in		reg_vol,TIMSK
	ori		reg_vol,(1<<TOIE0)
	out		TIMSK,reg_vol
	ldi		reg_init,0

	ldi		reg_vol,(1<<WGM11)|(1<<COM1A1)			;timer1
	out		TCCR1A,reg_vol
	ldi		reg_vol,(1<<WGM13)|(1<<WGM12)|(1<<CS11)
	out		TCCR1B,reg_vol				;d�marrage du timer � 16KHz => soit � 8k
	in		reg_vol,TIFR				;clear flag
	andi	reg_vol,0xFB
	out		TIFR,reg_vol
	in		reg_vol,TIMSK				;interrupt enable
	ori		reg_vol,(1<<TICIE1)|(1<<TOIE1)|(1<<OCIE1A)
	out		TIMSK,reg_vol

	ldi		reg_vol,0
	out		OCR1AH,reg_vol
	ldi		reg_vol,1
	out		OCR1AL,reg_vol

	ldi		reg_vol,100
	out		ICR1H,reg_vol
	ldi		reg_vol,255
	out		ICR1L,reg_vol

	ldi		reg_vol,20
	sts		num_son,reg_vol
	ldi		reg_vol,2
	sts		num_son2,reg_vol
	

	rjmp	TIMER_INC


TI1_Interrupt:
	in		tri,SREG					; save content of flag reg.

	lds		reg_vol,num_son2				;chargement de l'addresse du caract�re
	cpi		reg_vol,2
	brsh	No_sound

conv_son:
	sbic	EECR,EEWE					;test de d'�criture dans l'eeprom
	rjmp	conv_son

	
	out		EEARH,reg_vol
	lds		reg_vol,num_son
	out		EEARL,reg_vol
	
	sbi		EECR,EERE				;test de fin de lecture
	in		reg_vol,EEDR			;lecture
	out		ICR1H,reg_vol			;set freq


	;gestion du volume
	ldi		reg_vol,0
	out		OCR1AH,reg_vol
	in		reg_vol,ADCH				;on lit la valeur de l'adc convertie
	out		OCR1AL,reg_vol

	in		reg_vol,ADCSRA
	ori		reg_vol,(1<<ADSC)			;relance d'une conversion
	out		ADCSRA,reg_vol
	ldi		reg_vol,0
	out		TCNT1H,reg_vol
	out		TCNT1L,reg_vol

	;gestion de la led
	sbic	PIND,6						;blink led
	cbi		PORTD,6
	sbis	PIND,6
	sbi		PORTD,6

	

	out		SREG,tri					; restore flag register
	reti 								; Return from interrupt

No_sound:
	ldi		reg_vol,0
	out		OCR1AL,reg_vol
	ldi		reg_vol,0
	out		TCNT1H,reg_vol
	out		TCNT1L,reg_vol
	reti

TI0_interrupt:
	in		tri,SREG					; save content of flag reg.
	inc		reg_cptT0
	cpi		reg_cptT0,16
	brne	END_T0
	ldi		reg_cptT0,0
END_T0:
	out		SREG,tri					; restore flag register
	reti