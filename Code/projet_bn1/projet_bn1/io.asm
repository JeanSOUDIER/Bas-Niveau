;use r20

IO_Init:
	ldi		reg_init,0x00			;porta en entrée
	out		DDRA,reg_init
	ldi		reg_init,0xBF			;portb en entrée sur miso
	out		DDRB,reg_init
	ldi		reg_init,0xFF			;portc en sortie
	out		DDRC,reg_init
	ldi		reg_init,0xE2			;portd en sortie sur TX, BUZZER et LED
	out		DDRD,reg_init
	rjmp	IO_INC
