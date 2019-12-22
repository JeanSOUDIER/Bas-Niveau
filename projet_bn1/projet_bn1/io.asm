;use r20

IO_Init:
	ldi		r20,0x00			;porta en entrée
	out		DDRA,r20
	ldi		r20,0xBF			;portb en entrée sur miso
	out		DDRB,r20
	ldi		r20,0xFF			;portc en sortie
	out		DDRC,r20
	ldi		r20,0xE2			;portd en sortie sur TX, BUZZER et LED
	out		DDRD,r20
	rjmp	IO_INC