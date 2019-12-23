;use r20

IO_Init:
	ldi		Init,0x00			;porta en entrée
	out		DDRA,Init
	ldi		Init,0xBF			;portb en entrée sur miso
	out		DDRB,Init
	ldi		Init,0xFF			;portc en sortie
	out		DDRC,Init
	ldi		Init,0xE2			;portd en sortie sur TX, BUZZER et LED
	out		DDRD,Init
	rjmp	IO_INC