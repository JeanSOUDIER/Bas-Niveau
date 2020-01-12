.equ WREN = 0x06									;define des valeurs pour lire et écrire dans la mémoir SPI
.equ WRDI = 0x04
.equ READ = 0x03
.equ WRITE = 0x02

.macro WR_DI[]										;macro pour mettre la mémoire SPI en lecture
	cbi		PORTB,4									;clear CS
	ldi		reg_spi,WRDI							;send ordre de lecture
	rcall	SPI_Transmit							;envoi
	sbi		PORTB,4									;set CS
.endmacro

SPI_Init:
	ldi		reg_spi,(1<<SPE)|(1<<MSTR)|(1<<SPR0)	; ON / MASTER / fosc/16
	out		SPCR,reg_spi
	sbi		PORTB,4									;set SS
	WR_DI[]
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
