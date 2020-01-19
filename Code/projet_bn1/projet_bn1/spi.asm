;********************************
; Programme du jeu entre 2 Gameboy connect�es en bluetooth (�lectif bas niveau) [fichier de gestion de la m�moire EEPROM en SPI]
;
; Fichier : spi.asm
;
; Microcontr�leur Atmega16A
;
; Version atmel studio : 7.0.2397
; Created: 25/10/2019 13:42:48
;
; Author : jsoudier01 & atessier01
; INSA Strasbourg
;********************************

.equ WREN = 0x06									;define des valeurs pour lire et �crire dans la m�moir SPI
.equ WRDI = 0x04
.equ READ = 0x03
.equ WRITE = 0x02

;--------------------------------
; Nom de la macro : WR_DI[]
;
; Description : on passe la m�moire SPI en mode lecture
;
; Entr�e : - r24 (reg_spi) registre d'envoi et de r�ception en SPI
;
; Sorties : appel la fonction "SPI_Transmit" [spi.asm]
;--------------------------------
.macro WR_DI[]										;macro pour mettre la m�moire SPI en lecture
	cbi		PORTB,4									;clear CS
	ldi		reg_spi,WRDI							;send ordre de lecture
	rcall	SPI_Transmit							;envoi
	sbi		PORTB,4									;set CS
.endmacro

;--------------------------------
; Nom de la fonction : SPI_Init
;
; Description : initialisation du SPI
;
; Entr�e : - r24 (reg_spi) registre d'envoi et de r�ception en SPI
;
; Sorties : appel la macro "WR_DI[]" [spi.asm]
;--------------------------------
SPI_Init:
	ldi		reg_spi,(1<<SPE)|(1<<MSTR)|(1<<SPR0)	; ON / MASTER / fosc/16
	out		SPCR,reg_spi
	sbi		PORTB,4									;set SS
	WR_DI[]
	rjmp	SPI_INC

;--------------------------------
; Nom de la fonction : SPI_Transmit
;
; Description : envoi une donn� en SPI et r�ception celle du p�riph�rique esclave
;
; Entr�e : - r24 (reg_spi) registre d'envoi et de r�ception en SPI
;
; Sorties : - r24 (reg_spi) r�ponse du p�riph�rique
;--------------------------------
SPI_Transmit:										;attente transmission
	out		SPDR,reg_spi							;envoi msg
Wait_SPI:
	sbis	SPSR,SPIF								;test si fini
	rjmp	Wait_SPI
	in		reg_spi,SPDR							;lecture de la r�ponse
	ret

;--------------------------------
; Nom de la fonction : Read_Mem
;
; Description : lit une donn� dans la m�moire SPI
;
; Entr�e : - r24 (reg_spi) registre d'envoi et de r�ception en SPI
;		   - r19 (reg_addrL) variable de positionnement dans la m�moire SPI (LOW)
;		   - r20 (reg_addrH) variable de positionnement dans la m�moire SPI (HIGH)
;
; Sorties : - r24 (reg_spi) r�ponse de la m�moire
;--------------------------------
Read_Mem:
	cbi		PORTB,4									;clear SS
	ldi		reg_spi,READ							;instruction de lecture m�moire
	rcall	SPI_Transmit
	mov		reg_spi,reg_addrH						;s�lection de l'adresse H
	rcall	SPI_Transmit
	mov		reg_spi,reg_addrL						;s�lection de l'adresse L
	rcall	SPI_Transmit
	ldi		reg_spi,0x00							;lecture de la r�ponse
	rcall	SPI_Transmit
	sbi		PORTB,4									;set SS
	ret
