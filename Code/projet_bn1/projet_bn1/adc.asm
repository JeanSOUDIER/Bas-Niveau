ADC_Init:
	ldi		reg_init,(1<<ADLAR)|(1<<REFS0)							;ext ref / left adjust / mux to ADC0
	out		ADMUX,reg_init
	ldi		reg_init,(1<<ADEN)|(1<<ADSC)|(1<<ADPS2)|(1<<ADPS1)		;adc enable / adc start / no auto trig / no interrupt / div 64
	out		ADCSRA,reg_init
	rjmp	ADC_INC

/*rand:
	cli																;désactivation des interruptions
	sbic	ADCSRA,ADSC												;test de fin de conversion
	rjmp	rand
	in		reg_vol,ADCH											;lecture de la valeur converti
	sts		pos_rand,reg_vol										;stockage de la position du personnage
	sei																;réactivation des interruptions
	ret*/
