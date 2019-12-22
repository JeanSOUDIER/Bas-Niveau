;
; test_328p.asm
;
; Created: 22/12/2019 16:44:35
; Author : xoxox
;

.def reg_cpt1 = r28
.def reg_cpt2 = r29
.def reg_screen = r30
.def reg_cpt3 = r20
.def reg_cpt4 = r23
.def reg_spi = r25
.def reg_addr1 = r26
.def reg_addr2 = r27

.macro screenL[]					;choix du c�t� de l'�cran � gauche
	sbi		PORTB,0
	cbi		PORTB,1
.endmacro
.macro screenR[]					;choix du c�t� de l'�cran � droite
	sbi		PORTB,1
	cbi		PORTB,0
.endmacro
.macro Enable[]						;validation de la commande sur l'�cran
	ldi		reg_cpt4,1
	rcall	tempo
	cbi		PORTB,3
	nop								;on attent l'�cran
	ldi		reg_cpt4,1
	rcall	tempo
	sbi		PORTB,3
	ldi		reg_cpt4,1
	rcall	tempo
.endmacro
.macro SetPosX[]					;pos de 0 � 7 (� changer � chaque fois)
	ori		reg_screen,0xB8
	out		PORTD,reg_screen
	Enable[]
.endmacro
.macro SetPosY[]					;pos de 0 � 64 (auto)
	ori		reg_screen,0x40
	out		PORTD,reg_screen
	Enable[]
.endmacro
.macro RS_clear[]					;changement de bit instruction/donn�es
	cbi		PORTB,2
.endmacro
.macro RS_set[]						;changement de bit instruction/donn�es
	sbi		PORTB,2
.endmacro
.macro ScreenWrite[]				;affichage sur l'�cran
	out		PORTD,reg_screen
	Enable[]
.endmacro


; Replace with your application code
.org 0x00
	jmp		RESET

RESET:
	ldi		r20,0xBF			;portb en entr�e sur miso
	out		DDRB,r20
	ldi		r20,0xFF			;portc en sortie
	out		DDRD,r20

	screenR[]
	sbi		PORTB,3					;set E and clear RS
	RS_clear[]

	ldi		reg_cpt4,250
	rcall	tempo
	ldi		reg_cpt4,250
	rcall	tempo
	ldi		reg_cpt4,250
	rcall	tempo
	ldi		reg_cpt4,250
	rcall	tempo
	ldi		reg_cpt4,250
	rcall	tempo
	ldi		reg_cpt4,250
	rcall	tempo


	ldi		reg_screen,63			;instruction de d�but de l'�cran
	ScreenWrite[]					;validation
	
	screenL[]
	ScreenWrite[]

	screenR[]
	ScreenWrite[]

	RS_set[]						;mode donn�es

	rcall	writeFullSreen	

start:
    
    rjmp start



; sous programme de temposirsation
tempo:
	ldi		reg_cpt3,255
boucletempo:
	dec		reg_cpt3
	nop
	brne	boucletempo
	dec		reg_cpt4
	brne	tempo
	ret

;full reg_addr1/2
writeFullSreen:
	screenR[]						;set side screen
	ldi		reg_cpt2,0
	ldi		reg_addr1,0
	ldi		reg_addr2,0
loop1:
	RS_clear[]
	ldi		reg_cpt1,0
	mov		reg_screen,reg_cpt2		;set pos Y = 0
	SetPosX[]
	ldi		reg_screen,0			;set pos X = 0
	SetPosY[]
	RS_set[]
loop2:
	;rcall Read_Mem					;lecture de la m�moire spi
	ldi		reg_spi,0
	;mov		reg_screen,reg_spi
	com		reg_cpt1
	mov		reg_screen,reg_cpt1
	com		reg_cpt1
	ScreenWrite[]					;�criture sur l'�cran
	inc		reg_addr1				;incr�ment de l'adresse LOW
	cpi		reg_addr1,0				;test du carry
	brne	addr_carry1
	inc		reg_addr2				;si carry on incr�mente l'adresse HIGH
addr_carry1:

	inc		reg_cpt1				;incr�ment du compteur 1
	sbrs	reg_cpt1,6				;test de fin de boucle = 64
	rjmp	loop2

	inc		reg_cpt2				;incr�ment du copteur 2
	sbrs	reg_cpt2,3				;test de fin de boucle = 8
	rjmp	loop1


	/*screenR[]						;set side screen
	ldi		reg_cpt2,0
loop3:
	ldi		reg_cpt1,0
	mov		reg_screen,reg_cpt2		;set pos Y = 0
	SetPosX[]
	ldi		reg_screen,0			;set pos X = 0
	SetPosY[]
loop4:
	;rcall Read_Mem					;lecture de la m�moire spi
	ldi		reg_spi,5
	mov		reg_screen,reg_spi
	ScreenWrite[]					;�criture sur l'�cran
	inc		reg_addr1				;incr�ment de l'adresse LOW
	cpi		reg_addr1,0				;test du carry
	brne	addr_carry2
	inc		reg_addr2				;si carry on incr�mente l'adresse HIGH
addr_carry2:

	inc		reg_cpt1				;incr�ment du compteur 1
	sbrs	reg_cpt1,6				;test de fin de boucle = 64
	rjmp	loop4

	inc		reg_cpt2				;incr�ment du copteur 2
	sbrs	reg_cpt2,3				;test de fin de boucle = 8
	rjmp	loop3*/

	ret