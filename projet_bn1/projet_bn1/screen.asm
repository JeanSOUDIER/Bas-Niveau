;use r28 and r29 and r30

.def reg_cpt1 = r28
.def reg_cpt2 = r29
.def reg_screen = r30
.def reg_cpt3 = r20
.def reg_cpt4 = r23

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
	ldi		reg_cpt4,4
	rcall	tempo
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
	out		PORTC,reg_screen
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
	screenL[]						;set side screen
	ldi		reg_cpt2,0				;reset var
	ldi		reg_addr1,0
	ldi		reg_addr2,0
loop1:
	ldi		reg_cpt1,0
	ldi		reg_screen,0			;set pos Y = 0
	SetPosY[]
	mov		reg_screen,reg_cpt2		;set pos X = reg_cpt2
	SetPosX[]
loop2:
	rcall Read_Mem					;lecture de la m�moire spi
	mov		reg_screen,reg_spi
	ScreenWrite[]					;�criture sur l'�cran
	inc		reg_addr1				;incr�ment de l'adresse LOW
	cpi		reg_addr1,0
	brne	addr_carry1				;test du carry
	inc		reg_addr2
addr_carry1:

	inc		reg_cpt1				;incr�ment du compteur 1
	sbrs	reg_cpt1,6				;test de fin de boucle = 64
	rjmp	loop2

	inc		reg_cpt2				;incr�ment du copteur 2
	sbrs	reg_cpt2,3				;test de fin de boucle = 8
	rjmp	loop1

	screenR[]						;set side screen
	ldi		reg_cpt2,0				;reset var
loop3:
	ldi		reg_cpt1,0
	ldi		reg_screen,0			;set pos Y = 0
	SetPosY[]
	mov		reg_screen,reg_cpt2		;set pos X = reg_cpt2
	SetPosX[]
loop4:
	rcall Read_Mem					;lecture de la m�moire spi
	mov		reg_screen,reg_spi
	ScreenWrite[]					;�criture sur l'�cran
	inc		reg_addr1				;incr�ment de l'adresse LOW
	cpi		reg_addr1,0
	brne	addr_carry2				;test du carry
	inc		reg_addr2
addr_carry2:

	inc		reg_cpt1				;incr�ment du compteur 1
	sbrs	reg_cpt1,6				;test de fin de boucle = 64
	rjmp	loop4

	inc		reg_cpt2				;incr�ment du copteur 2
	sbrs	reg_cpt2,3				;test de fin de boucle = 8
	rjmp	loop3
	ret
	