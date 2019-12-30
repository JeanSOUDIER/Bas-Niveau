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
	ldi		reg_vol,(1<<WGM11)|(1<<WGM10)|(1<<COM1A1)
	ldi		reg_son,(1<<WGM12)|(1<<CS11)|(1<<CS10)
	out		TCCR1A,reg_vol
	out		TCCR1B,reg_son				;démarrage du timer à 16KHz => soit à 8k
	in		reg_vol,TIFR				;clear flag
	andi	reg_vol,0xFB
	out		TIFR,reg_vol
	in		reg_vol,TIMSK				;interrupt enable
	ori		reg_vol,(1<<TOIE1)
	out		TIMSK,reg_vol
	ldi		reg_vol,255
	out		OCR1AH,reg_vol
	ldi		reg_vol,0
	out		TCNT1L,reg_vol
	rjmp	TIMER_INC

	ldi		reg_son,0

TI_Interrupt:
	in		tri,SREG					; save content of flag reg.

	/*mov		reg_test2,reg_addrL
	mov		reg_test3,reg_addrH
	mov		reg_addrL,reg_test1
	ldi		reg_addrH,0
	rcall	Read_Mem
	mov		reg_son,reg_spi
	inc		reg_test1
	mov		reg_addrL,reg_test2
	mov		reg_addrH,reg_test3


	cbi		PORTB,4									;clear SS
	ldi		reg_spi,0x03							;instruction de lecture mémoire
	rcall	SPI_Transmit
	mov		reg_spi,reg_addrH						;sélection de l'adresse H
	rcall	SPI_Transmit
	mov		reg_spi,reg_addrL						;sélection de l'adresse L
	rcall	SPI_Transmit
	ldi		reg_spi,0x00							;lecture de la réponse
	rcall	SPI_Transmit
	sbi		PORTB,4									;set SS
	*/

	;gestion du volume
	in		reg_vol,ADCH				;on lit la valeur de l'adc convertie
	cpi		reg_vol,10
	brsh	LIMIT_ADC
	ldi		reg_vol,10
LIMIT_ADC:
	out		OCR1AL,reg_vol
	in		reg_vol,ADCSRA
	ori		reg_vol,(1<<ADSC)			;relance d'une conversion
	out		ADCSRA,reg_vol

	cbi		PORTB,4									;clear SS
	ldi		reg_spi,0x03							;instruction de lecture mémoire
	rcall	SPI_Transmit
	ldi		reg_spi,0						;sélection de l'adresse H
	rcall	SPI_Transmit
	mov		reg_spi,reg_son						;sélection de l'adresse L
	rcall	SPI_Transmit
	ldi		reg_spi,0x00							;lecture de la réponse
	rcall	SPI_Transmit
	sbi		PORTB,4									;set SS
	out		TCNT1H,reg_spi
	inc		reg_son

	;gestion de la led
	sbic	PIND,6						;blink led
	cbi		PORTD,6
	sbis	PIND,6
	sbi		PORTD,6

	out		SREG,tri					; restore flag register
	reti 								; Return from interrupt
