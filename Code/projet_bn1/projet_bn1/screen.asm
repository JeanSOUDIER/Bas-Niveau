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

.macro inc_reg[]
	inc		reg_screen
	inc		reg_screen
	inc		reg_screen
	inc		reg_screen
.endmacro
;in addrH/L img, posX,posY perso
.macro SetPosPerso[]
	WR_EN[]
	PosPerso[]
	mov		reg_work,reg_spi
	rcall	Read_Mem
	and		reg_work,reg_spi
	rcall	Write_Mem_SetB
	mov		reg_spi,reg_work
	rcall	SPI_Transmit
	rcall	Write_Mem_SetE
.endmacro
;in addrH/L img, posX,posY perso
.macro ClearPosPerso[]
	WR_EN[]
	PosPerso[]
	com		reg_spi
	mov		reg_work,reg_spi
	rcall	Read_Mem
	and		reg_work,reg_spi
	rcall	Write_Mem_SetB
	mov		reg_spi,reg_work
	rcall	SPI_Transmit
	rcall	Write_Mem_SetE
.endmacro
.macro PosPerso[]
	ldi		reg_work,0x04
	ldi		reg_spi,1
	add		reg_addrH,reg_work
	sub		reg_addrL,reg_posX
	mov		reg_work,reg_posY
	andi	reg_work,0x07
	cpi		reg_posY,8
	brlo	pos_perso
	cpi		reg_posY,16
	brlo	pos_perso1
	subi	reg_addrL,64
pos_perso1:
	subi	reg_addrL,64
pos_perso:
	cpi		reg_work,0
	breq	pos_perso2
	lsl		reg_spi
	dec		reg_work
	rjmp	pos_perso
pos_perso2:
.endmacro

SCREEN_Init:
	sbi		PORTB,3					;set E and clear RS
	cbi		PORTB,2
	ldi		reg_screen,63			;instruction de début de l'écran
	out		PORTC,reg_screen
	;Enable[]						;validation
	RS_set[]						;mode données
	rjmp	SCREEN_INC

tempo:
	tempo1:
	dec		reg_cpt3
	nop
	nop
	nop
	nop
	nop
	brne	tempo1
	ret

;load reg_addrL, reg_addrH, reg_lettre
addImgChar:
	WR_EN[]
	ldi		reg_cpt3,255
	rcall	tempo
	ldi		reg_cpt1,0x70
	add		reg_addrH,reg_cpt1
	mov		reg_cpt1,reg_lettre
	inc		reg_cpt1
	inc		reg_cpt1
	inc		reg_cpt1
	inc		reg_cpt1
	inc		reg_cpt1
	rcall	Write_Mem_SetB
loop_ADD1:
	rcall	conv_lettre				;convertion de la lettre
	mov		reg_spi,reg_out
	rcall	SPI_Transmit
	inc		reg_lettre
	inc		reg_addrL
	cpi		reg_addrL,0
	brne	loop_ADD
	inc		reg_addrH
loop_ADD:
	cp		reg_cpt1,reg_lettre
	brne	loop_ADD1
	rcall	Write_Mem_SetE
	ret

;full reg_addrL/H
writeFullSreen:
	WR_DI[]
	screenR[]						;set side screen
	ldi		reg_cpt2,0				;reset var
loop1:
	ldi		reg_cpt1,0
	ldi		reg_screen,0			;set pos Y = 0
	SetPosY[]
	mov		reg_screen,reg_cpt2		;set pos X = reg_cpt2
	SetPosX[]
loop2:
	rcall Read_Mem					;lecture de la mémoire spi
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
	rcall Read_Mem					;lecture de la mémoire spi
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

CLR_RAM:
	ldi		reg_addrL,0x00
	ldi		reg_addrH,0x70
	ldi		reg_cpt2,0				;reset var
loop_CLR:
	ldi		reg_cpt1,0
	WR_EN[]
	ldi		reg_cpt3,255
	rcall	tempo
	rcall	Write_Mem_SetB
	nop
loop_CLR1:
	ldi		reg_spi,0
	rcall	SPI_Transmit
	inc		reg_addrL				;incrément de l'adresse LOW
	cpi		reg_addrL,0
	brne	addr_carry3				;test du carry
	inc		reg_addrH
addr_carry3:

	inc		reg_cpt1				;incrément du compteur 1
	sbrs	reg_cpt1,6				;test de fin de boucle = 64
	rjmp	loop_CLR1

	rcall	Write_Mem_SetE

	inc		reg_cpt2				;incrément du copteur 2
	sbrs	reg_cpt2,4				;test de fin de boucle = 16
	rjmp	loop_CLR

	ret
