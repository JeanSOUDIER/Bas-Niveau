;use r23

ADC_Init:
	;ldi		r23,0x00
	;out		SFIOR,r23
	ldi		r23,(1<<ADLAR)|(1<<REFS0)														;ext ref / left adjust / mux toADC0
	out		ADMUX,r23
	ldi		r23,(1<<ADEN)|(1<<ADSC)|(1<<ADPS2)|(1<<ADPS1)						;adc enable / adc start / no auto trig / no interrupt / div 64
	out		ADCSRA,r23
	rjmp	ADC_INC