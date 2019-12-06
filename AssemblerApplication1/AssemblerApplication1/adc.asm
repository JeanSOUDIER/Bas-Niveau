;use r23

ADC_Init:
	;ldi r23,0x01
	;out AIO,r23   ;adc, ne marche pas ?
	ldi r23,0x20
	out ADMUX,r23
	;ldi r23,0x00
	;out SFIOR,r23 ;adc ?
	ldi r23,0xC0
	out ADCSRA,r23
	ret