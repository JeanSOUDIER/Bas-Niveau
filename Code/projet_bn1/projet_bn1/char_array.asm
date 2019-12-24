.macro Fenetre_Debut[]				;affichage de "JOUER / RESEAU / MENTION"
	CLR_RAM[]

	ldi		reg_addrL,CHAR_SIZE*16+4
	ldi		reg_addrH,3
	ldi		reg_lettre,C_J
	rcall	addImgChar

	ldi		reg_addrL,CHAR_SIZE*15+4
	ldi		reg_addrH,3
	ldi		reg_lettre,C_O
	rcall	addImgChar
	
	ldi		reg_addrL,CHAR_SIZE*14+4
	ldi		reg_addrH,3
	ldi		reg_lettre,C_U
	rcall	addImgChar
	
	ldi		reg_addrL,CHAR_SIZE*13+4
	ldi		reg_addrH,3
	ldi		reg_lettre,C_E
	rcall	addImgChar
	
	ldi		reg_addrL,CHAR_SIZE*12+4
	ldi		reg_addrH,3
	ldi		reg_lettre,C_R
	rcall	addImgChar
	
	ldi		reg_addrL,CHAR_SIZE*6
	ldi		reg_addrH,3
	ldi		reg_lettre,C_R
	rcall	addImgChar
	
	ldi		reg_addrL,CHAR_SIZE*5
	ldi		reg_addrH,3
	ldi		reg_lettre,C_E
	rcall	addImgChar

	ldi		reg_addrL,CHAR_SIZE*4
	ldi		reg_addrH,3
	ldi		reg_lettre,C_S
	rcall	addImgChar

	ldi		reg_addrL,CHAR_SIZE*3
	ldi		reg_addrH,3
	ldi		reg_lettre,C_E
	rcall	addImgChar

	ldi		reg_addrL,CHAR_SIZE*2
	ldi		reg_addrH,3
	ldi		reg_lettre,C_A
	rcall	addImgChar

	ldi		reg_addrL,CHAR_SIZE
	ldi		reg_addrH,3
	ldi		reg_lettre,C_U
	rcall	addImgChar

	ldi		reg_addrL,CHAR_SIZE*38
	ldi		reg_addrH,2
	ldi		reg_lettre,C_M
	rcall	addImgChar

	ldi		reg_addrL,CHAR_SIZE*37
	ldi		reg_addrH,2
	ldi		reg_lettre,C_E
	rcall	addImgChar

	ldi		reg_addrL,CHAR_SIZE*36
	ldi		reg_addrH,2
	ldi		reg_lettre,C_N
	rcall	addImgChar

	ldi		reg_addrL,CHAR_SIZE*35
	ldi		reg_addrH,2
	ldi		reg_lettre,C_T
	rcall	addImgChar

	ldi		reg_addrL,CHAR_SIZE*34
	ldi		reg_addrH,2
	ldi		reg_lettre,C_I
	rcall	addImgChar

	ldi		reg_addrL,CHAR_SIZE*33
	ldi		reg_addrH,2
	ldi		reg_lettre,C_O
	rcall	addImgChar

	ldi		reg_addrL,CHAR_SIZE*32
	ldi		reg_addrH,2
	ldi		reg_lettre,C_N
	rcall	addImgChar

.endmacro

.macro CONNECTED[]				;affichage de "connecte"
	CLR_RAM[]

	ldi		reg_addrL,CHAR_SIZE*6
	ldi		reg_addrH,3
	ldi		reg_lettre,C_C
	rcall	addImgChar

	ldi		reg_addrL,CHAR_SIZE*5
	ldi		reg_addrH,3
	ldi		reg_lettre,C_O
	rcall	addImgChar

	ldi		reg_addrL,CHAR_SIZE*4
	ldi		reg_addrH,3
	ldi		reg_lettre,C_N
	rcall	addImgChar

	ldi		reg_addrL,CHAR_SIZE*3
	ldi		reg_addrH,3
	ldi		reg_lettre,C_N
	rcall	addImgChar

	ldi		reg_addrL,CHAR_SIZE*2
	ldi		reg_addrH,3
	ldi		reg_lettre,C_E
	rcall	addImgChar

	ldi		reg_addrL,CHAR_SIZE
	ldi		reg_addrH,3
	ldi		reg_lettre,C_C
	rcall	addImgChar

	ldi		reg_addrL,0
	ldi		reg_addrH,3
	ldi		reg_lettre,C_T
	rcall	addImgChar

	ldi		reg_addrL,CHAR_SIZE*10-2
	ldi		reg_addrH,1
	ldi		reg_lettre,C_E
	rcall	addImgChar
.endmacro

.macro NO_CONNECTED[]				;affichage de "non connecte"
	ldi		reg_addrL,CHAR_SIZE*6
	ldi		reg_addrH,3
	ldi		reg_lettre,C_N
	rcall	addImgChar

	ldi		reg_addrL,CHAR_SIZE*5
	ldi		reg_addrH,3
	ldi		reg_lettre,C_O
	rcall	addImgChar

	ldi		reg_addrL,CHAR_SIZE*4
	ldi		reg_addrH,3
	ldi		reg_lettre,C_N
	rcall	addImgChar

	ldi		reg_addrL,CHAR_SIZE*3
	ldi		reg_addrH,3
	ldi		reg_lettre,C_PT
	rcall	addImgChar

	ldi		reg_addrL,CHAR_SIZE*2
	ldi		reg_addrH,3
	ldi		reg_lettre,C_C
	rcall	addImgChar

	ldi		reg_addrL,CHAR_SIZE
	ldi		reg_addrH,3
	ldi		reg_lettre,C_O
	rcall	addImgChar

	ldi		reg_addrL,0
	ldi		reg_addrH,3
	ldi		reg_lettre,C_N
	rcall	addImgChar

	ldi		reg_addrL,CHAR_SIZE*10-2
	ldi		reg_addrH,1
	ldi		reg_lettre,C_N
	rcall	addImgChar

	ldi		reg_addrL,CHAR_SIZE*9-2
	ldi		reg_addrH,1
	ldi		reg_lettre,C_E
	rcall	addImgChar

	ldi		reg_addrL,CHAR_SIZE*8-2
	ldi		reg_addrH,1
	ldi		reg_lettre,C_C
	rcall	addImgChar

	ldi		reg_addrL,CHAR_SIZE*7-2
	ldi		reg_addrH,1
	ldi		reg_lettre,C_T
	rcall	addImgChar

	ldi		reg_addrL,CHAR_SIZE*6-2
	ldi		reg_addrH,1
	ldi		reg_lettre,C_E
	rcall	addImgChar
.endmacro

.macro MENTION_MA[]			;affichage des mentions
	CLR_RAM[]

	ldi		reg_addrL,CHAR_SIZE*16+4
	ldi		reg_addrH,3
	ldi		reg_lettre,C_J
	rcall	addImgChar

	ldi		reg_addrL,CHAR_SIZE*15+4
	ldi		reg_addrH,3
	ldi		reg_lettre,C_E
	rcall	addImgChar

	ldi		reg_addrL,CHAR_SIZE*14+4
	ldi		reg_addrH,3
	ldi		reg_lettre,C_A
	rcall	addImgChar

	ldi		reg_addrL,CHAR_SIZE*13+4
	ldi		reg_addrH,3
	ldi		reg_lettre,C_N
	rcall	addImgChar

	ldi		reg_addrL,CHAR_SIZE*12+4
	ldi		reg_addrH,3
	ldi		reg_lettre,C_PT
	rcall	addImgChar

	ldi		reg_addrL,CHAR_SIZE*11+4
	ldi		reg_addrH,3
	ldi		reg_lettre,C_S
	rcall	addImgChar

	ldi		reg_addrL,CHAR_SIZE*6
	ldi		reg_addrH,3
	ldi		reg_lettre,C_A
	rcall	addImgChar

	ldi		reg_addrL,CHAR_SIZE*5
	ldi		reg_addrH,3
	ldi		reg_lettre,C_L
	rcall	addImgChar

	ldi		reg_addrL,CHAR_SIZE*4
	ldi		reg_addrH,3
	ldi		reg_lettre,C_E
	rcall	addImgChar

	ldi		reg_addrL,CHAR_SIZE*3
	ldi		reg_addrH,3
	ldi		reg_lettre,C_X
	rcall	addImgChar

	ldi		reg_addrL,CHAR_SIZE*2
	ldi		reg_addrH,3
	ldi		reg_lettre,C_A
	rcall	addImgChar

	ldi		reg_addrL,CHAR_SIZE
	ldi		reg_addrH,3
	ldi		reg_lettre,C_N
	rcall	addImgChar

	ldi		reg_addrL,0
	ldi		reg_addrH,3
	ldi		reg_lettre,C_D
	rcall	addImgChar
	
	ldi		reg_addrL,CHAR_SIZE*10-2
	ldi		reg_addrH,1
	ldi		reg_lettre,C_R
	rcall	addImgChar

	ldi		reg_addrL,CHAR_SIZE*9-2
	ldi		reg_addrH,1
	ldi		reg_lettre,C_E
	rcall	addImgChar

	ldi		reg_addrL,CHAR_SIZE*8-2
	ldi		reg_addrH,1
	ldi		reg_lettre,C_PT
	rcall	addImgChar

	ldi		reg_addrL,CHAR_SIZE*7-2
	ldi		reg_addrH,1
	ldi		reg_lettre,C_T
	rcall	addImgChar

	rcall	writeFullSreen
.endmacro
