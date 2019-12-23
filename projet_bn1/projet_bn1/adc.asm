;use r20

ADC_Init:
	ldi		Init,(1<<ADLAR)|(1<<REFS0)														;ext ref / left adjust / mux toADC0
	out		ADMUX,Init
	ldi		r20,(1<<ADEN)|(1<<ADSC)|(1<<ADPS2)|(1<<ADPS1)						;adc enable / adc start / no auto trig / no interrupt / div 64
	out		ADCSRA,Init
	rjmp	ADC_INC