;********************************
; Programme du jeu entre 2 Gameboy connectées en bluetooth (électif bas niveau) [fichier de gestion des timers (son et position du personnage]
;
; Fichier : timer.asm
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
; Nom de la macro : bGa[]
;
; Description : test si le bouton Gauche est appuié
;--------------------------------
.macro bGa[]				;macro de bouton
	sbis	PINA,1
.endmacro

;--------------------------------
; Nom de la macro : bGan[]
;
; Description : test si le bouton Gauche n'est pas appuié
;--------------------------------
.macro bGan[]
	sbic	PINA,1
.endmacro

;--------------------------------
; Nom de la macro : bBa[]
;
; Description : test si le bouton bas est appuié
;--------------------------------
.macro bBa[]
	sbis	PINA,2
.endmacro

;--------------------------------
; Nom de la macro : bBan[]
;
; Description : test si le bouton Bas n'est pas appuié
;--------------------------------
.macro bBan[]
	sbic	PINA,2
.endmacro

;--------------------------------
; Nom de la macro : bDr[]
;
; Description : test si le bouton Droit est appuié
;--------------------------------
.macro bDr[]
	sbis	PINA,3
.endmacro

;--------------------------------
; Nom de la macro : bDrn[]
;
; Description : test si le bouton Droit n'est pas appuié
;--------------------------------
.macro bDrn[]
	sbic	PINA,3
.endmacro

;--------------------------------
; Nom de la macro : bHa[]
;
; Description : test si le bouton Haut est appuié
;--------------------------------
.macro bHa[]
	sbis	PINA,4
.endmacro

;--------------------------------
; Nom de la macro : bHan[]
;
; Description : test si le bouton Haut n'est pas appuié
;--------------------------------
.macro bHan[]
	sbic	PINA,4
.endmacro

;--------------------------------
; Nom de la macro : bB[]
;
; Description : test si le bouton B est appuié
;--------------------------------
.macro bB[]
	sbis	PINA,5
.endmacro

;--------------------------------
; Nom de la macro : bBn[]
;
; Description : test si le bouton B n'est pas appuié
;--------------------------------
.macro bBn[]
	sbic	PINA,5
.endmacro

;--------------------------------
; Nom de la macro : bA[]
;
; Description : test si le bouton A est appuié
;--------------------------------
.macro bA[]
	sbis	PINA,6
.endmacro

;--------------------------------
; Nom de la macro : bAn[]
;
; Description : test si le bouton A n'est pas appuié
;--------------------------------
.macro bAn[]
	sbic	PINA,6
.endmacro

;--------------------------------
; Nom de la macro : bSel[]
;
; Description : test si le bouton Select est appuié
;--------------------------------
.macro bSel[]
	sbis	PINA,7
.endmacro

;--------------------------------
; Nom de la macro : bSeln[]
;
; Description : test si le bouton Select n'est pas appuié
;--------------------------------
.macro bSeln[]
	sbic	PINA,7
.endmacro

;--------------------------------
; Nom de la macro : bSta[]
;
; Description : test si le bouton Start est appuié
;--------------------------------
.macro bSta[]
	sbis	PIND,2
.endmacro

;--------------------------------
; Nom de la macro : bStan[]
;
; Description : test si le bouton Start n'est pas appuié
;--------------------------------
.macro bStan[]
	sbic	PIND,2
.endmacro

;--------------------------------
; Nom de la macro : bL[]
;
; Description : test si le bouton Gauche (gachette) est appuié
;--------------------------------
.macro bL[]
	sbis	PIND,3
.endmacro

;--------------------------------
; Nom de la macro : bLn[]
;
; Description : test si le bouton Gauche (gachette) n'est pas appuié
;--------------------------------
.macro bLn[]
	sbic	PIND,3
.endmacro

;--------------------------------
; Nom de la macro : bR[]
;
; Description : test si le bouton Droit (gachette) est appuié
;--------------------------------
.macro bR[]
	sbis	PIND,4
.endmacro

;--------------------------------
; Nom de la macro : bRn[]
;
; Description : test si le bouton Droit (gachette) n'est pas appuié
;--------------------------------
.macro bRn[]
	sbic	PIND,4
.endmacro

;--------------------------------
; Nom de la fonction : TIMER_Init
;
; Description : initialisation le timer 0 et le timer 1
;
; Entrée : - r25 (reg_vol) registre de gestion du volume et de la fréquence du buzzer
;		   - r23 (reg_cptT0) registre de comptage pour ralentir le timer 0
;
; Sorties : - num_son (SRAM) adresse mémoire EEPROM atmega du son à lire (LOW)
;			- num_son2 (SRAM) adresse mémoire EEPROM atmega du son à lire (HIGH) [0 première piste, 1 deuxième piste, 2 à 255 pas de son]
;--------------------------------
TIMER_Init:
	ldi		reg_vol,(1<<CS02)|(1<<CS00)				;timer0 pour le clignotement de la position du personage (normal mode)
	out		TCCR0,reg_vol							;prescaler max de 1024
	in		reg_vol,TIMSK
	ori		reg_vol,(1<<TOIE0)						;en interruption
	out		TIMSK,reg_vol
	ldi		reg_cptT0,0

	ldi		reg_vol,(1<<WGM11)|(1<<COM1A1)			;timer1 pour le son et le réglage du volume (fast PWM mode)
	out		TCCR1A,reg_vol
	ldi		reg_vol,(1<<WGM13)|(1<<WGM12)|(1<<CS11)	;prescaler par 8 soit 8MHz/(8*2*ICR1)
	out		TCCR1B,reg_vol
	in		reg_vol,TIFR							;clear flag
	andi	reg_vol,0xFB
	out		TIFR,reg_vol
	in		reg_vol,TIMSK							;interrupt enable
	ori		reg_vol,(1<<TICIE1)|(1<<TOIE1)|(1<<OCIE1A)
	out		TIMSK,reg_vol

	ldi		reg_vol,0								;réglage du volume au départ
	out		OCR1AH,reg_vol
	ldi		reg_vol,1
	out		OCR1AL,reg_vol

	ldi		reg_vol,100								;réglage de la fréquence de départ
	out		ICR1H,reg_vol
	ldi		reg_vol,255
	out		ICR1L,reg_vol

	ldi		reg_vol,0								;réglage du pointage dans l'eeprom de l'atmega qui contient le son
	sts		num_son,reg_vol
	ldi		reg_vol,2
	sts		num_son2,reg_vol
	

	rjmp	TIMER_INC

;--------------------------------
; Nom de la fonction : TI1_Interrupt
;
; Description : fonction d'interruption du timer 1 pour la gestion du son en fréquence et rapport cyclique (volume)
;
; Entrée : - r25 (reg_vol) registre de gestion du volume et de la fréquence du buzzer
;		   - r2 (tri) registre de sauvegarde du contexte
;
; Sorties : appel la fonction "No_sound" [timer.asm]
;--------------------------------
TI1_Interrupt:
	in		tri,SREG								;save content of flag reg.

	lds		reg_vol,num_son2						;chargement de l'addresse du son à jouer
	cpi		reg_vol,2
	brsh	No_sound

conv_son:
	sbic	EECR,EEWE								;test de d'écriture dans l'eeprom
	rjmp	conv_son

	out		EEARH,reg_vol							;recherche de l'adresse à lire depuis la SRAM
	lds		reg_vol,num_son
	out		EEARL,reg_vol
	subi	reg_vol,-0x01							;note suivante
	sts		num_son,reg_vol
	
	sbi		EECR,EERE								;test de fin de lecture
	in		reg_vol,EEDR							;lecture
	out		ICR1H,reg_vol							;set freq
	cpi		reg_vol,255
	brne	pas_fin_son
	ldi		reg_vol,2
	sts		num_son2,reg_vol
pas_fin_son:

	;gestion du volume
	ldi		reg_vol,0
	out		OCR1AH,reg_vol
	in		reg_vol,ADCH							;on lit la valeur de l'adc convertie
	out		OCR1AL,reg_vol

	in		reg_vol,ADCSRA
	ori		reg_vol,(1<<ADSC)						;relance d'une conversion
	out		ADCSRA,reg_vol
	ldi		reg_vol,0
	out		TCNT1H,reg_vol							;affectation du volume
	out		TCNT1L,reg_vol

	;gestion de la led
	sbic	PIND,6									;blink led
	cbi		PORTD,6
	sbis	PIND,6
	sbi		PORTD,6

	out		SREG,tri								;restore flag register
	reti 											;return from interrupt

;--------------------------------
; Nom de la fonction : No_sound
;
; Description : fonction pour iniber le son
;
; Entrée : - r25 (reg_vol) registre de gestion du volume et de la fréquence du buzzer
;		   - r2 (tri) registre de sauvegarde du contexte
;
; Sorties : X
;--------------------------------
No_sound:
	ldi		reg_vol,0								;pas de son à jouer
	out		OCR1AL,reg_vol
	ldi		reg_vol,0
	out		TCNT1H,reg_vol
	out		TCNT1L,reg_vol
	out		SREG,tri								;restore flag register
	reti

;--------------------------------
; Nom de la fonction : TI0_interrupt
;
; Description : fonction pour la fréquence de clignotement de la position du personnage
;
; Entrée : - r23 (reg_cptT0) registre de comptage pour ralentir le timer 0
;		   - r2 (tri) registre de sauvegarde du contexte
;
; Sorties : X
;--------------------------------
TI0_interrupt:
	in		tri,SREG								;save content of flag reg.
	inc		reg_cptT0								;variable de comptage pour diviseur la fréquence
	cpi		reg_cptT0,16
	brne	END_T0
	ldi		reg_cptT0,0
END_T0:
	out		SREG,tri								;restore flag register
	reti

;--------------------------------
; Nom de la fonction : rand
;
; Description : fonction pour avoir un nombre aléatoire pour placer le personnage sur la carte à partir du timer 0
;
; Entrée : - r12 variable temporaire
;
; Sorties : - pos_rand (SRAM) position du personnage aléatoire
;--------------------------------
rand:
	in		r12,TCNT0								;lecture de la valeur du timer
	lsr		r12										;ajustement de la valeur
	sts		pos_rand,r12							;stockage de la position du personnage aléatoire
	ret