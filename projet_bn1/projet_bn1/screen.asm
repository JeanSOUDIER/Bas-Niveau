;use r28 and r29 and r30

.def reg_tempo1 = r28
.def reg_tempo2 = r29
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
	ldi		reg_tempo2,1
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
	out		PORTB,reg_screen
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
	ldi		reg_tempo1,255
boucletempo:
	dec		reg_tempo1
	nop
	brne	boucletempo
	dec		reg_tempo2
	brne	tempo
	ret
