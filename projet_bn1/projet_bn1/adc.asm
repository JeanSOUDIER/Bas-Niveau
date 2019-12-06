;use r23

ADC_Init:
	;ldi r23,0x01
	;out AIO,r23   ;adc, ne marche pas ?
	;ldi		r23,(0<<PRADC)														;disable low power on ADC
	;out		PRR,16
	ldi		r23,(1<<ADLAR)														;ext ref / left adjust / mux toADC0
	out		ADMUX,r23
	ldi		r23,(1<<ADEN)|(1<<ADSC)|(1<<ADPS2)|(1<<ADPS1)|(1<<ADPS0)			;adc enable / adc start / no auto trig / no interrupt / div 128
	out		ADCSRA,r23
	rjmp	ADC_INC