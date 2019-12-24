.equ C_A = 0
.equ C_B = 5
.equ C_C = 10
.equ C_D = 15
.equ C_E = 20
.equ C_F = 25
.equ C_G = 30
.equ C_H = 35
.equ C_I = 40
.equ C_J = 45
.equ C_K = 50
.equ C_L = 55
.equ C_M = 60
.equ C_N = 65
.equ C_O = 70
.equ C_P = 75
.equ C_Q = 80
.equ C_R = 85
.equ C_S = 90
.equ C_T = 95
.equ C_U = 100
.equ C_V = 105
.equ C_W = 110
.equ C_X = 115
.equ C_Y = 120
.equ C_Z = 125
.equ C_0 = 130
.equ C_1 = 135
.equ C_2 = 140
.equ C_3 = 145
.equ C_4 = 150
.equ C_5 = 155
.equ C_6 = 160
.equ C_7 = 165
.equ C_8 = 170
.equ C_9 = 175
.equ C_IN = 180
.equ C_EX = 185
.equ C_PT = 190
.equ C_DA = 195
.equ C_PAO = 200
.equ C_PAF = 205
.equ C_PL = 210
.equ C_MO = 215
.equ C_SL = 220
.equ C_MUL = 225
.equ C_DP = 230
.equ C_EG = 235
.equ C_# = 240
.equ C_CH = 245
.equ CHAR_SIZE = 6

rjmp		LETTRE_INC

conv_lettre:
	sbic	EECR,EEWE				;test de d'écriture dans l'eeprom
	rjmp	conv_lettre

	ldi		reg_out,0				;chargement de l'addresse du caractère
	out		EEARH,reg_out
	out		EEARL,reg_lettre
	
	sbi		EECR,EERE				;test de fin de lecture
	in		reg_out,EEDR			;lecture
	ret
