;use r28 and r29 and r30

.def reg_cpt1 = r28
.def reg_cpt2 = r29
.def reg_screen = r30

.macro screenL[]					;choix du c�t� de l'�cran � gauche
	sbi		PORTB,0
	cbi		PORTB,1
.endmacro
.macro screenR[]					;choix du c�t� de l'�cran � droite
	sbi		PORTB,1
	cbi		PORTB,0
.endmacro
.macro Enable[]						;validation de la commande sur l'�cran
	cbi		PORTB,3
	nop								;on attent l'�cran
	nop
	sbi		PORTB,3
.endmacro
.macro SetPosX[]					;pos de 0 � 7 (� changer � chaque fois)
	ori		reg_screen,0xB8
	out		PORTC,reg_screen
	RS_clear[]
	Enable[]
	RS_set[]
.endmacro
.macro SetPosY[]					;pos de 0 � 64 (auto)
	ori		reg_screen,0x40
	out		PORTC,reg_screen
	RS_clear[]
	Enable[]
	RS_set[]
.endmacro
.macro RS_clear[]					;changement de bit instruction/donn�es
	cbi		PORTB,2
.endmacro
.macro RS_set[]						;changement de bit instruction/donn�es
	sbi		PORTB,2
.endmacro
.macro ScreenWrite[]				;affichage sur l'�cran
	out		PORTB,reg_screen
	Enable[]
.endmacro


SCREEN_Init:
	sbi		PORTB,3					;set E and clear RS
	cbi		PORTB,2
	ldi		reg_screen,63			;instruction de d�but de l'�cran
	out		PORTC,reg_screen
	Enable[]						;validation
	RS_set[]						;mode donn�es
	rjmp	SCREEN_INC


; sous programme de temposirsation
;tempo:
;	ldi		reg_tempo1,255
;boucletempo:
;	dec		reg_tempo1
;	nop
;	brne	boucletempo
;	dec		reg_tempo2
;	brne	tempo
;	ret

;full reg_addr1/2
writeFullSreen:
	screenL[]						;set side screen
	ldi		reg_cpt1,0				;reset var
	ldi		reg_cpt2,0
loop1:
	ldi		reg_screen,0			;set pos X = 0
	SetPosX[]
	mov		reg_screen,reg_cpt2		;set pos Y = 0
	SetPosY[]
loop2:
	rcall Read_Mem					;lecture de la m�moire spi
	mov		reg_screen,reg_spi
	ScreenWrite[]					;�criture sur l'�cran
	inc		reg_addr1				;incr�ment de l'adresse LOW
	brcs	addr_carry				;test du carry

	inc		reg_cpt1				;incr�ment du compteur 1
	sbrs	reg_cpt1,6				;test de fin de boucle = 64
	rjmp	loop2

	inc		reg_cpt2				;incr�ment du copteur 2
	sbrs	reg_cpt2,3				;test de fin de boucle = 8
	rjmp	loop1

	screenR[]						;idem ci-dessus avec le c�t� gauche
	ldi		reg_cpt1,0
	ldi		reg_cpt2,0
loop3:
	ldi		reg_screen,0
	SetPosX[]
	ldi		reg_screen,0
	SetPosY[]
loop4:
	rcall Read_Mem
	mov		reg_screen,reg_spi
	ScreenWrite[]
	inc		reg_addr1
	brcs	addr_carry

	inc		reg_cpt1
	sbrs	reg_cpt1,6
	rjmp	loop4

	inc		reg_cpt2
	sbrs	reg_cpt2,3
	rjmp	loop3
	ret

addr_carry:
	inc		reg_addr2				;si carry on incr�mente l'adresse HIGH
	ret
	