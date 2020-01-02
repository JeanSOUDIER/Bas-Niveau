	rjmp	CHAR_INC

Fenetre_Debut:				;affichage de "JOUER / RESEAU / MENTION"
	ldi		reg_addrL,CHAR_SIZE*17+4
	ldi		reg_addrH,3
	ldi		reg_lettre,C_J
	rcall	addImgChar

	ldi		reg_addrL,CHAR_SIZE*16+4
	ldi		reg_addrH,3
	ldi		reg_lettre,C_O
	rcall	addImgChar
	
	ldi		reg_addrL,CHAR_SIZE*15+4
	ldi		reg_addrH,3
	ldi		reg_lettre,C_U
	rcall	addImgChar
	
	ldi		reg_addrL,CHAR_SIZE*14+3
	ldi		reg_addrH,3
	ldi		reg_lettre,C_E
	rcall	addImgChar
	
	ldi		reg_addrL,CHAR_SIZE*13+2
	ldi		reg_addrH,3
	ldi		reg_lettre,C_R
	rcall	addImgChar
	
	ldi		reg_addrL,CHAR_SIZE*7
	ldi		reg_addrH,3
	ldi		reg_lettre,C_R
	rcall	addImgChar
	
	ldi		reg_addrL,CHAR_SIZE*6-1
	ldi		reg_addrH,3
	ldi		reg_lettre,C_E
	rcall	addImgChar

	ldi		reg_addrL,CHAR_SIZE*5-2
	ldi		reg_addrH,3
	ldi		reg_lettre,C_S
	rcall	addImgChar

	ldi		reg_addrL,CHAR_SIZE*4-2
	ldi		reg_addrH,3
	ldi		reg_lettre,C_E
	rcall	addImgChar

	ldi		reg_addrL,CHAR_SIZE*3-3
	ldi		reg_addrH,3
	ldi		reg_lettre,C_A
	rcall	addImgChar

	ldi		reg_addrL,CHAR_SIZE*2-3
	ldi		reg_addrH,3
	ldi		reg_lettre,C_U
	rcall	addImgChar

	ldi		reg_addrL,CHAR_SIZE*39
	ldi		reg_addrH,2
	ldi		reg_lettre,C_M
	rcall	addImgChar

	ldi		reg_addrL,CHAR_SIZE*38-1
	ldi		reg_addrH,2
	ldi		reg_lettre,C_E
	rcall	addImgChar

	ldi		reg_addrL,CHAR_SIZE*37-2
	ldi		reg_addrH,2
	ldi		reg_lettre,C_N
	rcall	addImgChar

	ldi		reg_addrL,CHAR_SIZE*36-3
	ldi		reg_addrH,2
	ldi		reg_lettre,C_T
	rcall	addImgChar

	ldi		reg_addrL,CHAR_SIZE*35-3
	ldi		reg_addrH,2
	ldi		reg_lettre,C_I
	rcall	addImgChar

	ldi		reg_addrL,CHAR_SIZE*34-3
	ldi		reg_addrH,2
	ldi		reg_lettre,C_O
	rcall	addImgChar

	ldi		reg_addrL,CHAR_SIZE*33-3
	ldi		reg_addrH,2
	ldi		reg_lettre,C_N
	rcall	addImgChar

	rjmp	FEN_lab

.macro CONNECTED[]				;affichage de "connecte"
	rcall CLR_RAM

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
	rcall CLR_RAM

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
.endmacro

.macro cursor[]
	ldi		reg_addrL,CHAR_SIZE*40				;cursor
	add		reg_addrL,reg_init					;chargement de la position
	ldi		reg_addrH,2
	cp		reg_addrL,reg_init					;test de carry
	brsh	testMain
	inc		reg_addrH
testMain:
	ldi		reg_lettre,C_CH						;chargement de la lettre ">"
	rcall	addImgChar							;stockage de la lettre dans la mémoire
.endmacro
