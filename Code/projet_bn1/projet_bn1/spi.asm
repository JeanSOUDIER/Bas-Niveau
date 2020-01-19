;********************************
; Programme du jeu entre 2 Gameboy connectées en bluetooth (électif bas niveau) [fichier de gestion de la mémoire EEPROM en SPI]
;
; Fichier : spi.asm
;
; Microcontrôleur Atmega16A
;
; Version atmel studio : 7.0.2397
; Created: 25/10/2019 13:42:48
;
; Author : jsoudier01 & atessier01
; INSA Strasbourg
;********************************

.equ WREN = 0x06									;define des valeurs pour lire et écrire dans la mémoir SPI
.equ WRDI = 0x04
.equ READ = 0x03
.equ WRITE = 0x02

;--------------------------------
; Nom de la macro : WR_DI[]
;
; Description : on passe la mémoire SPI en mode lecture
;
; Entrée : - r24 (reg_spi) registre d'envoi et de réception en SPI
;
; Sorties : appel la fonction "SPI_Transmit" [spi.asm]
;--------------------------------
.macro WR_DI[]										;macro pour mettre la mémoire SPI en lecture
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
; Entrée : - r24 (reg_spi) registre d'envoi et de réception en SPI
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
; Description : envoi une donné en SPI et réception celle du périphérique esclave
;
; Entrée : - r24 (reg_spi) registre d'envoi et de réception en SPI
;
; Sorties : - r24 (reg_spi) réponse du périphérique
;--------------------------------
SPI_Transmit:										;attente transmission
	out		SPDR,reg_spi							;envoi msg
Wait_SPI:
	sbis	SPSR,SPIF								;test si fini
	rjmp	Wait_SPI
	in		reg_spi,SPDR							;lecture de la réponse
	ret

;--------------------------------
; Nom de la fonction : Read_Mem
;
; Description : lit une donné dans la mémoire SPI
;
; Entrée : - r24 (reg_spi) registre d'envoi et de réception en SPI
;		   - r19 (reg_addrL) variable de positionnement dans la mémoire SPI (LOW)
;		   - r20 (reg_addrH) variable de positionnement dans la mémoire SPI (HIGH)
;
; Sorties : - r24 (reg_spi) réponse de la mémoire
;--------------------------------
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
