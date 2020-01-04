;use r28 and r29 and r30

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
	ldi		reg_cpt3,250
	rcall	tempo_US
	sbi		PORTB,3
.endmacro

.macro SetPosX[]					;pos de 0 � 7 (� changer � chaque fois)
	RS_clear[]
	ori		reg_screen,0xB8
	out		PORTC,reg_screen
	Enable[]
	RS_set[]
.endmacro

.macro SetPosY[]					;pos de 0 � 64 (auto)
	RS_clear[]
	ori		reg_screen,0x40
	out		PORTC,reg_screen
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

.macro placePosPerso[]
	cpi		reg_work,0xFF
	breq	END_PERSO1

	mov		reg_work,reg_posY
	andi	reg_work,7
	ldi		XL,LOW(Table)
	ldi		XH,HIGH(Table)
	add		XL,reg_work
	ld		reg_work,X
	sts		conv,reg_work

	ldi		reg_work,255
	cpi		reg_posY,8
	brlo	END_PERSO
	cpi		reg_posY,16
	ldi		reg_work,191
	brlo	END_PERSO
	ldi		reg_work,127
END_PERSO:
	sub		reg_work,reg_posX
	sts		convB,reg_work
	ldi		reg_work,7
	cpi		reg_posY,8
	brlo	END_PERSO2
	cpi		reg_posY,16
	ldi		reg_work,6
	brlo	END_PERSO2
	ldi		reg_work,5
END_PERSO2:
	sts		conv2,reg_work
END_PERSO1:
.endmacro

.macro SetPosPerso[]
	lds		reg_screen,conv2
	cp		reg_cpt2,reg_screen
	brne	END_SetPerso
	lds		reg_screen,convB
	andi	reg_screen,0x3F
	cp		reg_cpt1,reg_screen
	brne	END_SetPerso
	lds		reg_screen,conv
	or		reg_spi,reg_screen
	sbi		PORTD,6
END_SetPerso:
.endmacro

.macro ClearPosPerso[]
	lds		reg_screen,conv2
	cp		reg_cpt2,reg_screen
	brne	END_ClearPerso
	lds		reg_screen,convB
	andi	reg_screen,0x3F
	cp		reg_cpt1,reg_screen
	brne	END_ClearPerso
	lds		reg_screen,conv
	com		reg_screen
	and		reg_spi,reg_screen
	cbi		PORTD,6
END_ClearPerso:
.endmacro

SCREEN_Init:
	sbi		PORTB,3					;set E and clear RS
	cbi		PORTB,2
	ldi		reg_screen,63			;instruction de d�but de l'�cran
	out		PORTC,reg_screen
	Enable[]						;validation
	RS_set[]						;mode donn�es
	rjmp	SCREEN_INC

tempo_US:
	dec		reg_cpt3
	nop
	brne	tempo_US
	ret

;full reg_addrL/H
writeFullSreen:
	placePosPerso[]
	screenR[]						;set side screen
	ldi		reg_cpt2,0				;reset var
loop1:
	ldi		reg_cpt1,0
	ldi		reg_screen,0			;set pos Y = 0
	SetPosY[]
	mov		reg_screen,reg_cpt2		;set pos X = reg_cpt2
	SetPosX[]
loop2:
	rcall	Read_Mem					;lecture de la m�moire spi
	mov		reg_screen,reg_spi
	ScreenWrite[]					;�criture sur l'�cran
	inc		reg_addrL				;incr�ment de l'adresse LOW
	cpi		reg_addrL,0
	brne	addr_carry1				;test du carry
	inc		reg_addrH
addr_carry1:

	inc		reg_cpt1				;incr�ment du compteur 1
	sbrs	reg_cpt1,6				;test de fin de boucle = 64
	rjmp	loop2

	inc		reg_cpt2				;incr�ment du copteur 2
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
	rcall	Read_Mem					;lecture de la m�moire spi
	cpi		reg_cptT0,8
	brsh	PRINT
	ClearPosPerso[]
PRINT:
	cpi		reg_cptT0,8
	brlo	PRINT1
	SetPosPerso[]
PRINT1:
	mov		reg_screen,reg_spi
	ScreenWrite[]					;�criture sur l'�cran
	inc		reg_addrL				;incr�ment de l'adresse LOW
	cpi		reg_addrL,0
	brne	addr_carry2				;test du carry
	inc		reg_addrH
addr_carry2:

	inc		reg_cpt1				;incr�ment du compteur 1
	sbrs	reg_cpt1,6				;test de fin de boucle = 64
	rjmp	loop4

	inc		reg_cpt2				;incr�ment du copteur 2
	sbrs	reg_cpt2,3				;test de fin de boucle = 8
	rjmp	loop3
	ret


clearFullSreen:
	screenR[]						;set side screen
	ldi		reg_cpt2,0				;reset var
loop5:
	ldi		reg_cpt1,0
	ldi		reg_screen,0			;set pos Y = 0
	SetPosY[]
	mov		reg_screen,reg_cpt2		;set pos X = reg_cpt2
	SetPosX[]
loop6:
	ldi		reg_screen,0
	ScreenWrite[]					;�criture sur l'�cran

	inc		reg_cpt1				;incr�ment du compteur 1
	sbrs	reg_cpt1,6				;test de fin de boucle = 64
	rjmp	loop6

	inc		reg_cpt2				;incr�ment du copteur 2
	sbrs	reg_cpt2,3				;test de fin de boucle = 8
	rjmp	loop5

	screenL[]						;set side screen
	ldi		reg_cpt2,0				;reset var
loop7:
	ldi		reg_cpt1,0
	ldi		reg_screen,0			;set pos Y = 0
	SetPosY[]
	mov		reg_screen,reg_cpt2		;set pos X = reg_cpt2
	SetPosX[]
loop8:
	ldi		reg_screen,0
	ScreenWrite[]					;�criture sur l'�cran

	inc		reg_cpt1				;incr�ment du compteur 1
	sbrs	reg_cpt1,6				;test de fin de boucle = 64
	rjmp	loop8

	inc		reg_cpt2				;incr�ment du copteur 2
	sbrs	reg_cpt2,3				;test de fin de boucle = 8
	rjmp	loop7
	ret

writeChar:
	screenL[]
	ldi		reg_screen,10
	add		reg_screen,reg_addrL
	SetPosY[]
	ldi		reg_screen,4
	SetPosX[]
	ldi		XL,LOW(C_Wait)
	ldi		XH,HIGH(C_Wait)
	ld		reg_screen,X+
	ScreenWrite[]
	ld		reg_screen,X+
	ScreenWrite[]
	ld		reg_screen,X+
	ScreenWrite[]
	ld		reg_screen,X+
	ScreenWrite[]
	ld		reg_screen,X+
	ScreenWrite[]
	ret