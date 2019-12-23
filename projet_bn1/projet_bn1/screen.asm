;use r28 and r29 and r30


.macro screenL[]					;choix du côté de l'écran à gauche
	sbi		PORTB,0
	cbi		PORTB,1
.endmacro
.macro screenR[]					;choix du côté de l'écran à droite
	sbi		PORTB,1
	cbi		PORTB,0
.endmacro
.macro Enable[]						;validation de la commande sur l'écran
	cbi		PORTB,3
	;nop								;on attent l'écran
	ldi		reg_cpt3,250
	rcall	tempo
	sbi		PORTB,3
.endmacro
.macro SetPosX[]					;pos de 0 à 7 (à changer à chaque fois)
	RS_clear[]
	ori		reg_screen,0xB8
	out		PORTC,reg_screen
	Enable[]
	RS_set[]
.endmacro
.macro SetPosY[]					;pos de 0 à 64 (auto)
	RS_clear[]
	ori		reg_screen,0x40
	out		PORTC,reg_screen
	Enable[]
	RS_set[]
.endmacro
.macro RS_clear[]					;changement de bit instruction/données
	cbi		PORTB,2
.endmacro
.macro RS_set[]						;changement de bit instruction/données
	sbi		PORTB,2
.endmacro
.macro ScreenWrite[]				;affichage sur l'écran
	out		PORTC,reg_screen
	Enable[]
.endmacro

SCREEN_Init:
	sbi		PORTB,3					;set E and clear RS
	cbi		PORTB,2
	ldi		reg_screen,63			;instruction de début de l'écran
	out		PORTC,reg_screen
	Enable[]						;validation
	RS_set[]						;mode données
	rjmp	SCREEN_INC

; sous programme de temposirsation
tempo:
	dec		reg_cpt3
	nop
	brne	tempo
	ret

;full reg_addrL/H
writeFullSreen:
	screenL[]						;set side screen
	ldi		reg_cpt2,0				;reset var
	ldi		XL,LOW(img)
	ldi		XH,HIGH(img)
loop1:
	ldi		reg_cpt1,0
	ldi		reg_screen,0			;set pos Y = 0
	SetPosY[]
	mov		reg_screen,reg_cpt2		;set pos X = reg_cpt2
	SetPosX[]
loop2:
	;rcall Read_Mem					;lecture de la mémoire spi
	;ldi		reg_spi,5



	/*mov		reg_indice,reg_cpt1
	andi	reg_indice,0x07
	cpi		reg_indice,6
	brlt	saut
	ldi		reg_indice,11
saut:
	ldi		reg_lettre,0
	rcall	conv_lettre
	mov		reg_spi,reg_out*/
	/*ldi		reg_lettre,5
	ldi		reg_indice,0
	cpi		reg_cpt1,0
	breq	saut
	ldi		reg_indice,1
	cpi		reg_cpt1,1
	breq	saut
	ldi		reg_indice,2
	cpi		reg_cpt1,2
	breq	saut
	ldi		reg_indice,3
	cpi		reg_cpt1,3
	breq	saut
	ldi		reg_indice,4
	cpi		reg_cpt1,4
	breq	saut
	ldi		reg_out,0
	cpi		reg_cpt1,5
	brsh	saut2
saut:
	rcall	conv_lettre
	;mov		reg_out,reg_indice
saut2:
	mov		reg_spi,reg_out*/
	


	;mov		reg_screen,reg_spi
	ld		reg_screen,X
	inc		XL
	cpi		XL,0
	brne	loopAff
	inc		XH
loopAff:
	ScreenWrite[]					;écriture sur l'écran

	inc		reg_cpt1				;incrément du compteur 1
	sbrs	reg_cpt1,6				;test de fin de boucle = 64
	rjmp	loop2

	inc		reg_cpt2				;incrément du copteur 2
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
	;rcall Read_Mem					;lecture de la mémoire spi
	ldi		reg_spi,5
	mov		reg_screen,reg_spi
	ScreenWrite[]					;écriture sur l'écran
	inc		reg_addrL				;incrément de l'adresse LOW
	cpi		reg_addrL,0
	brne	addr_carry2				;test du carry
	inc		reg_addrH
addr_carry2:

	inc		reg_cpt1				;incrément du compteur 1
	sbrs	reg_cpt1,6				;test de fin de boucle = 64
	rjmp	loop4

	inc		reg_cpt2				;incrément du copteur 2
	sbrs	reg_cpt2,3				;test de fin de boucle = 8
	rjmp	loop3
	ret

createImgFull:
	ldi		reg_cpt1,4
	add		reg_cpt1,reg_addrH
	sts		addrL,reg_addrL
	sts		addrH,reg_cpt1
	ldi		reg_addrL,0
	ldi		reg_addrH,0
loopImg:
	ldi		XL,LOW(img)
	ldi		XH,HIGH(img)
	add		XL,reg_addrL
	add		XH,reg_addrH
	rcall	Read_Mem					;lecture de la mémoire spi
	st		X,reg_spi

	inc		reg_addrL				;incrément de l'adresse LOW
	cpi		reg_addrL,0
	brne	addr_carry				;test du carry
	inc		reg_addrH
addr_carry:
	cpi		reg_addrH,4
	brne	loopImg
	ret

;load reg_addrL, reg_addrH, reg_lettre
addImgChar:
	ldi		XL,LOW(img)
	ldi		XH,HIGH(img)
	ldi		reg_cpt1,0
	ldi		reg_cpt2,1
	add		XH,reg_addrH
	adc		XL,reg_addrL
testAdd:
	rcall	conv_lettre
	st		X,reg_out
	inc		reg_lettre
	inc		XL
	cpi		XL,0
	brne	testAdd1
	inc		XH
testAdd1:
	inc		reg_cpt1
	cpi		reg_cpt1,5
	brne	testAdd
	ret