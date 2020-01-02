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
	ldi		reg_vol,(1<<WGM11)|(1<<COM1A1)
	ldi		reg_son,(1<<WGM13)|(1<<WGM12)|(1<<CS11)
	out		TCCR1A,reg_vol
	out		TCCR1B,reg_son				;démarrage du timer à 16KHz => soit à 8k
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
	ldi		reg_vol,0
	out		ICR1L,reg_vol

	ldi		reg_son,0
	rjmp	TIMER_INC


TI_Interrupt:
	in		tri,SREG					; save content of flag reg.

	;gestion du volume
	in		reg_vol,ADCH				;on lit la valeur de l'adc convertie

	/*cbi		PORTB,4									;clear SS
	ldi		reg_spi,0x03							;instruction de lecture mémoire
	rcall	SPI_Transmit
	ldi		reg_spi,0						;sélection de l'adresse H
	rcall	SPI_Transmit
	mov		reg_spi,reg_son						;sélection de l'adresse L
	rcall	SPI_Transmit
	ldi		reg_spi,0x00							;lecture de la réponse
	rcall	SPI_Transmit
	sbi		PORTB,4									;set SS
	out		TCNT1H,reg_spi*/
	inc		reg_son
	out		ICR1H,reg_son



	mov		reg_spi,reg_son
	lsr		reg_vol
	sbrc	reg_spi,6
	lsr		reg_vol
	sbrc	reg_spi,5
	lsr		reg_vol
	sbrc	reg_spi,4
	lsr		reg_vol
	sbrc	reg_spi,3
	lsr		reg_vol
	sbrc	reg_spi,2
	lsr		reg_vol
	sbrc	reg_spi,1
	lsr		reg_vol

	out		OCR1AL,reg_vol
	in		reg_vol,ADCSRA
	ori		reg_vol,(1<<ADSC)			;relance d'une conversion
	out		ADCSRA,reg_vol
	ldi		reg_vol,0
	out		TCNT1H,reg_vol
	out		TCNT1L,reg_vol







	

	;sbic	PIND,6
	;cbi		PORTD,5
	;sbis	PIND,6
	;sbi		PORTD,5

	;gestion de la led
	sbic	PIND,6						;blink led
	cbi		PORTD,6
	sbis	PIND,6
	sbi		PORTD,6

	

	out		SREG,tri					; restore flag register
	reti 								; Return from interrupt
