rjmp		LETTRE_INC

conv_lettre:
	sbic	EECR,EEWE
	rjmp	conv_lettre

	ldi		reg_out,0
	out		EEARH,reg_out
	out		EEARL,reg_lettre
	
	sbi		EECR,EERE
	in		reg_out,EEDR
	ret
