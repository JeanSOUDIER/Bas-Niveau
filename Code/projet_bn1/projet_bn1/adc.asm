;********************************
; Programme du jeu entre 2 Gameboy connectées en bluetooth (électif bas niveau) [fichier de gestion de l'ADC]
;
; Fichier : adc.asm
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
; Nom de la fonction : ADC_Init
;
; Description : intialise l'ADC
;
; Entrée : - r29 (reg_init) variable temporaire
;
; Sorties : démarre une convertion
;--------------------------------
ADC_Init:
	ldi		reg_init,(1<<ADLAR)|(1<<REFS0)							;ext ref / left adjust / mux to ADC0
	out		ADMUX,reg_init
	ldi		reg_init,(1<<ADEN)|(1<<ADSC)|(1<<ADPS2)|(1<<ADPS1)		;adc enable / adc start / no auto trig / no interrupt / div 64
	out		ADCSRA,reg_init
	rjmp	ADC_INC
