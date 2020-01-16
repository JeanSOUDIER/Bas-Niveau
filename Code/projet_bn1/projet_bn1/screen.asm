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
	ldi		reg_cpt3,250
	rcall	tempo_US
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

.macro placePosPerso[]				;converti la position xy du personnage pour faire un test à l'affichage sur l'ecran
	lds		reg_screen,pos_x
	mov		reg_calcul1,reg_screen	;test Y
	andi	reg_screen,7
	ldi		XL,LOW(Table)			;table de convertion 2^(8-X) = Y
	ldi		XH,HIGH(Table)
	add		XL,reg_screen			;test X
	ld		reg_screen,X
	sts		conv,reg_screen

	ldi		reg_screen,255			;convertion des positions par 8 pixels
	cpi		reg_calcul1,8
	brlo	END_PERSO
	cpi		reg_calcul1,16
	ldi		reg_screen,191
	brlo	END_PERSO
	ldi		reg_screen,127
END_PERSO:
	lds		reg_calcul1,pos_y
	sub		reg_screen,reg_calcul1	;affectation de la SRAM
	sts		convB,reg_screen
	lds		reg_calcul1,pos_x
	ldi		reg_screen,7
	cpi		reg_calcul1,8
	brlo	END_PERSO2
	cpi		reg_calcul1,16
	ldi		reg_screen,6
	brlo	END_PERSO2
	ldi		reg_screen,5
END_PERSO2:
	sts		conv2,reg_screen
.endmacro

.macro SetPosPerso[]				;affiche le point à l'endroit calculé
	lds		reg_calcul1,pos_X
	cpi		reg_calcul1,255
	breq	END_SetPerso
	lds		reg_screen,conv2
	cp		reg_cpt2,reg_screen
	brne	END_SetPerso
	lds		reg_screen,convB
	andi	reg_screen,0x3F
	cp		reg_cpt1,reg_screen
	brne	END_SetPerso
	lds		reg_screen,conv
	or		reg_spi,reg_screen
END_SetPerso:
.endmacro

.macro ClearPosPerso[]				;efface le point à l'endroit calculé
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
END_ClearPerso:
.endmacro

SCREEN_Init:
	sbi		PORTB,3					;set E and clear RS
	cbi		PORTB,2
	ldi		reg_screen,63			;instruction de début de l'écran pour activer l'affichage
	out		PORTC,reg_screen
	Enable[]						;validation
	RS_set[]						;mode données
	rjmp	SCREEN_INC

tempo_US:							;boucle de temporisation
	dec		reg_cpt3
	nop
	brne	tempo_US
	ret

;full reg_addrL/H
writeFullSreen:						;fonction d'affichage de la mémoire SPI vers l'écran
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
	rcall	Read_Mem				;lecture de la mémoire spi
	mov		reg_screen,reg_spi
	ScreenWrite[]					;écriture sur l'écran
	inc		reg_addrL				;incrément de l'adresse LOW
	cpi		reg_addrL,0
	brne	addr_carry1				;test du carry
	inc		reg_addrH
addr_carry1:

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
	rcall	Read_Mem				;lecture de la mémoire spi
	cpi		reg_cptT0,8
	brsh	PRINT
	ClearPosPerso[]
PRINT:
	cpi		reg_cptT0,8
	brlo	PRINT1
	SetPosPerso[]
PRINT1:
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


clearFullSreen:						;fonction pour effacer l'écran (ressemble beaucoup à "writeFullSreen")
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
	ScreenWrite[]					;écriture sur l'écran

	inc		reg_cpt1				;incrément du compteur 1
	sbrs	reg_cpt1,6				;test de fin de boucle = 64
	rjmp	loop6

	inc		reg_cpt2				;incrément du copteur 2
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
	ScreenWrite[]					;écriture sur l'écran

	inc		reg_cpt1				;incrément du compteur 1
	sbrs	reg_cpt1,6				;test de fin de boucle = 64
	rjmp	loop8

	inc		reg_cpt2				;incrément du copteur 2
	sbrs	reg_cpt2,3				;test de fin de boucle = 8
	rjmp	loop7
	ret

writeChar:							;affiche un caractère de la SRAM sur l'écran
	screenL[]
	ldi		reg_screen,10
	add		reg_screen,reg_addrL	;placement sur l'écran
	SetPosY[]
	ldi		reg_screen,4
	SetPosX[]
	ldi		XL,LOW(C_Wait)			;placement dans la SRAM
	ldi		XH,HIGH(C_Wait)
	ld		reg_screen,X+			;affichage du caractère en 5*8
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