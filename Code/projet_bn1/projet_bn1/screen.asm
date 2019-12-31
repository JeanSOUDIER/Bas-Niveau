;use r28 and r29 and r30

.equ POS_MAP = 700

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
.macro CLR_RAM[]
	ldi		reg_cpt1,0
	ldi		reg_cpt2,0
	ldi		reg_spi,0
	ldi		XL,LOW(img)
	ldi		XH,HIGH(img)
loopCLR:
	st		X,reg_spi
	inc		XL
	cpi		XL,0
	brne	carry_clr
	inc		XH
carry_clr:

	inc		reg_cpt1
	cpi		reg_cpt1,0
	brne	loopCLR

	inc		reg_cpt2
	cpi		reg_cpt2,4
	brne	loopCLR
.endmacro
.macro createImgFull[]
	ldi		reg_cpt1,0
	ldi		reg_cpt2,0
	ldi		XL,LOW(img)
	ldi		XH,HIGH(img)
loopImg:
	rcall	Read_Mem					;lecture de la mémoire spi
	st		X,reg_spi

	inc		XL
	cpi		XL,0
	brne	addr_carry1
	inc		XH
addr_carry1:

	inc		reg_addrL				;incrément de l'adresse LOW
	cpi		reg_addrL,0
	brne	addr_carry				;test du carry
	inc		reg_addrH
addr_carry:

	;cpi		reg_cpt2,4
	ldi		reg_cpt1,HIGH(img)
	ldi		reg_cpt2,4
	add		reg_cpt1,reg_cpt2
	cp		XH,reg_cpt1
	brne	loopImg
	ldi		reg_cpt1,LOW(img)
	cp		XL,reg_cpt1
	brne	loopImg
.endmacro
.macro SetPosPerso
	cpi		reg_posY,8
	brsh	pos_perso1
	ldi		XL,LOW(img)+POS_MAP
	add		XL,reg_posX
	
pos_perso1:
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
	screenR[]						;set side screen
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
	ld		reg_screen,X			;affichage de l'image dans la SRAM
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

	screenL[]						;set side screen
	ldi		reg_cpt2,0				;reset var
loop3:
	ldi		reg_cpt1,0
	ldi		reg_screen,0			;set pos Y = 0
	SetPosY[]
	mov		reg_screen,reg_cpt2		;set pos X = reg_cpt2
	SetPosX[]
loop4:
	ld		reg_screen,X
	inc		XL
	cpi		XL,0
	brne	loopAff1
	inc		XH
loopAff1:


	;mov		reg_screen,reg_spi
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

;load reg_addrL, reg_addrH, reg_lettre
addImgChar:
	ldi		XL,LOW(img)				;initialisation de la l'addresse img
	ldi		XH,HIGH(img)
	ldi		reg_cpt1,0
	add		XH,reg_addrH			;positionnement dans l'image
	add		XL,reg_addrL
	cp		XL,reg_addrL			;test de carry
	brsh	testAdd
	inc		XH
testAdd:
	rcall	conv_lettre				;convertion de la lettre
	st		X,reg_out				;stockage de lettre dans la mémoire SRAM
	inc		reg_lettre
	inc		XL
	cpi		XL,0
	brne	testAdd1
	inc		XH
testAdd1:
	inc		reg_cpt1
	cpi		reg_cpt1,5				;un caractère fait 5 colonnes
	brne	testAdd

	ldi		reg_out,0
	st		X,reg_out


	ret
