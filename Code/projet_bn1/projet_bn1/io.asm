;********************************
; Programme du jeu entre 2 Gameboy connectées en bluetooth (électif bas niveau) [fichier de gestion des entrées/sorties]
;
; Fichier : io.asm
;
; Microcontrôleur Atmega16A
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
; Description : intialise les entrées et sorties
;
; Entrée : - r29 (reg_init) variable temporaire
;
; Sorties : X
;--------------------------------
IO_Init:
	ldi		reg_init,0x00			;porta en entrée
	out		DDRA,reg_init
	ldi		reg_init,0xBF			;portb en entrée sur miso
	out		DDRB,reg_init
	ldi		reg_init,0xFF			;portc en sortie
	out		DDRC,reg_init
	ldi		reg_init,0xE2			;portd en sortie sur TX, BUZZER et LED
	out		DDRD,reg_init
	rjmp	IO_INC
