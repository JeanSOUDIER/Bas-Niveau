;use r25 and r26 and r27

.equ WREN = 0x06
.equ WRDI = 0x04
.equ READ = 0x03
.equ WRITE = 0x02

.macro WR_DI[]
	cbi		PORTB,4
	ldi		reg_spi,WRDI
	rcall	SPI_Transmit
	sbi		PORTB,4
	ldi		reg_cpt3,255
	rcall	tempo
.endmacro

.macro WR_EN[]
	cbi		PORTB,4									;clear SS
	ldi		reg_spi,WREN							;instruction de mémoire en ecriture
	rcall	SPI_Transmit
	sbi		PORTB,4
	ldi		reg_cpt3,255
	rcall	tempo
.endmacro

SPI_Init:
	ldi		reg_spi,(1<<SPE)|(1<<MSTR)|(1<<SPR0)	; ON / MASTER / fosc/16
	out		SPCR,reg_spi
	sbi		PORTB,4									;set SS
	cbi		PORTB,4
	ldi		reg_spi,WRDI							;sélection du mode lecture de la mémoire
	rcall	SPI_Transmit
	sbi		PORTB,4
	rjmp	SPI_INC

SPI_Transmit:										;attente transmission
	out		SPDR,reg_spi							;envoi msg
Wait_SPI:
	sbis	SPSR,SPIF								;test si fini
	rjmp	Wait_SPI
	in		reg_spi,SPDR							;lecture de la réponse
	ret

Read_Mem:
	cbi		PORTB,4									;clear SS
	ldi		reg_spi,READ							;instruction de lecture mémoire
	rcall	SPI_Transmit
	mov		reg_spi,reg_addrH						;sélection de l'adresse H
	rcall	SPI_Transmit
	mov		reg_spi,reg_addrL						;sélection de l'adresse L
	rcall	SPI_Transmit
	ldi		reg_spi,0x00							;lecture de la réponse
	rcall	SPI_Transmit
	sbi		PORTB,4									;set SS
	ret

Write_Mem_SetB:
	cbi		PORTB,4
	ldi		reg_spi,WRITE
	rcall	SPI_Transmit
	mov		reg_spi,reg_addrH						;sélection de l'adresse H
	rcall	SPI_Transmit
	mov		reg_spi,reg_addrL						;sélection de l'adresse L
	rcall	SPI_Transmit
	ret

Write_Mem_SetE:
	sbi		PORTB,4
	ret