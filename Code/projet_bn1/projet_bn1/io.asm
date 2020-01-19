;********************************
; Programme du jeu entre 2 Gameboy connect�es en bluetooth (�lectif bas niveau) [fichier de gestion des entr�es/sorties]
;
; Fichier : io.asm
;
; Microcontr�leur Atmega16A
;
; Version atmel studio : 7.0.2397
; Created: 25/10/2019 13:42:48
;
; Author : jsoudier01 & atessier01
; INSA Strasbourg
;********************************

;--------------------------------
; Nom de la fonction : IO_Init
;
; Description : intialise les entr�es et sorties
;
; Entr�e : - r29 (reg_init) variable temporaire
;
; Sorties : X
;--------------------------------
IO_Init:
	ldi		reg_init,0x00			;porta en entr�e
	out		DDRA,reg_init
	ldi		reg_init,0xBF			;portb en entr�e sur miso
	out		DDRB,reg_init
	ldi		reg_init,0xFF			;portc en sortie
	out		DDRC,reg_init
	ldi		reg_init,0xE2			;portd en sortie sur TX, BUZZER et LED
	out		DDRD,reg_init
	rjmp	IO_INC
