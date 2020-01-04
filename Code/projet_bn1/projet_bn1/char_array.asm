Init_char_array:
	ldi		XL,LOW(C_Wait)			;load '#'
	ldi		XH,HIGH(C_Wait)
	ldi		reg_init,0x14
	st		X+,reg_init
	ldi		reg_init,0xFF
	st		X+,reg_init
	ldi		reg_init,0x14
	st		X+,reg_init
	ldi		reg_init,0xFF
	st		X+,reg_init
	ldi		reg_init,0x14
	st		X,reg_init
	ldi		XL,LOW(Table)			;load table
	ldi		XH,HIGH(Table)
	ldi		reg_init,0x80
	st		X+,reg_init
	ldi		reg_init,0x40
	st		X+,reg_init
	ldi		reg_init,0x20
	st		X+,reg_init
	ldi		reg_init,0x10
	st		X+,reg_init
	ldi		reg_init,0x08
	st		X+,reg_init
	ldi		reg_init,0x04
	st		X+,reg_init
	ldi		reg_init,0x02
	st		X+,reg_init
	ldi		reg_init,0x01
	st		X,reg_init
	ldi		reg_init,1
	sts		dead,reg_init
	rjmp	CHAR_INC

.macro Fenetre_Debut[]				;affichage de "JOUER / RESEAU / MENTION"
	ldi		reg_addrL,0x00
	ldi		reg_addrH,0x60
	add		reg_addrH,reg_init
	rcall	writeFullSreen

.endmacro

.macro CONNECTED[]				;affichage de "connecte"
	ldi		reg_addrL,0x00
	ldi		reg_addrH,0x6C
	rcall	writeFullSreen
.endmacro

.macro NO_CONNECTED[]				;affichage de "non connecte"
	ldi		reg_addrL,0x00
	ldi		reg_addrH,0x70
	rcall	writeFullSreen
.endmacro

.macro MENTION_MA[]			;affichage des mentions
	ldi		reg_addrL,0x00
	ldi		reg_addrH,0x74
	rcall	writeFullSreen
.endmacro

.macro CONN1[]
	rcall	clearFullSreen
	ldi		reg_addrL,0
	rcall	writeChar
.endmacro

.macro CONN2[]
	ldi		reg_addrL,6
	rcall	writeChar
.endmacro

.macro CONN3[]
	ldi		reg_addrL,12
	rcall	writeChar
.endmacro
