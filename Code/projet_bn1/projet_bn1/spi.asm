;use r25 and r26 and r27

SPI_Init:
	;ldi r25,(1<<DD_MOSI)|(1<<DD_CLK)
	;out DDR_SPI,r25   ;ne mache pas mais peut �tre est d�finit dans I/O
	ldi		reg_spi,(1<<SPE)|(1<<MSTR)|(1<<SPR0)	; ON / MASTER / fosc/16
	out		SPCR,reg_spi
	sbi		PORTB,4									;set SS
	cbi		PORTB,4
	ldi		reg_spi,0x04							;s�lection du mode lecture de la m�moire
	rcall	SPI_Transmit
	sbi		PORTB,4
	rjmp	SPI_INC

SPI_Transmit:										;attente transmission
	out		SPDR,reg_spi							;envoi msg
Wait_SPI:
	sbis	SPSR,SPIF								;test si fini
	rjmp	Wait_SPI
	in		reg_spi,SPDR							;lecture de la r�ponse
	ret

Read_Mem:
	cbi		PORTB,4									;clear SS
	ldi		reg_spi,0x03							;instruction de lecture m�moire
	rcall	SPI_Transmit
	mov		reg_spi,reg_addrH						;s�lection de l'adresse H
	rcall	SPI_Transmit
	mov		reg_spi,reg_addrL						;s�lection de l'adresse L
	rcall	SPI_Transmit
	ldi		reg_spi,0x00							;lecture de la r�ponse
	rcall	SPI_Transmit
	sbi		PORTB,4									;set SS
	ret
