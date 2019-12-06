;use r28 and r29 and r30

.def reg_tempo1 = r28
.def reg_tempo2 = r29
.def reg_screenX = r30

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
	ldi		reg_tempo2,1
	rcall	tempo
	sbi		PORTB,3
.endmacro
.macro SetPosX[]					;pos de 0 à 7 (à changer à chaque fois)
	ori		reg_screenX,0xB8
	out		PORTC,reg_screenX
	RS_clear[]
	Enable[]
	RS_set[]
.endmacro
.macro SetPosY[]					;pos de 0 à 64 (auto)
	ori		reg_screenX,0x40
	out		PORTC,reg_screenX
	RS_clear[]
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
	out		PORTB,reg_screenX
.endmacro


SCREEN_Init:
	sbi		PORTB,3					;set E and clear RS
	cbi		PORTB,2
	ldi		reg_screenX,63			;instruction de début de l'écran
	out		PORTC,reg_screenX
	Enable[]						;validation
	RS_set[]						;mode données
	rjmp	SCREEN_INC


; sous programme de temposirsation
tempo:
	ldi		reg_tempo1,255
boucletempo:
	dec		reg_tempo1
	nop
	brne	boucletempo
	dec		reg_tempo2
	brne	tempo
	ret
