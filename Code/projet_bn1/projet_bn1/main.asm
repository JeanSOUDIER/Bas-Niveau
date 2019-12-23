;
; main.asm
;
; Created: 25/10/2019 13:42:48
; Author : jsoudier01
;
;code programme

;.nolist 
;.include "m16def.inc"
;.list 

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


.def tri = r1						; TimerInterruptRegister.

.def reg_init = r16

.def reg_spi = r18
.def reg_addrL = r19
.def reg_addrH = r20

.def reg_lettre = r18
.def reg_out = r31

.def reg_cpt1 = r21
.def reg_cpt2 = r22
.def reg_cpt3 = r23

.def reg_screen = r18

.def reg_bt1 = r24
.def reg_vol = r25
.def reg_son = r28

.def reg_TX = r29
.def reg_RX = r30

.macro Fenetre_Debut[]
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


.dseg
img: .byte 1024	; reserve une image
addrL: .byte 1  ;addr de départ
addrH: .byte 1
btL:   .byte 1
btH:   .byte 1
TX:    .byte 1
POS:   .byte 1

.cseg  ; codesegment
.org	0x00
   rjmp	RESET 

; interrupt-vector commands, 1 Byte each:
/*	reti							; 1:  $000(1) RESET External Pin, Power-on Reset, Brown-out Reset, Watchdog Reset, and JTAG AVR Reset
	reti							; 2:  $002 INT0 External Interrupt Request 0 
	reti							; 3:  $004 INT1 External Interrupt Request 1 
	reti							; 4:  $006 TIMER2 COMP Timer/Counter2 Compare Match 
	reti							; 5:  $008 TIMER2 OVF Timer/Counter2 Overflow 
	reti							; 6:  $00A TIMER1 CAPT Timer/Counter1 Capture Event
	reti							; 7:  $00C TIMER1 COMPA Timer/Counter1 Cmp Match A 
	reti							; 8:  $00E TIMER1 COMPB Timer/Counter1 Cmpe Match B
	rjmp TI_Interrupt				; 9:  $010 TIMER1 OVF Timer/Counter1 Overflow
	reti							; 10: $012 TIMER0 OVF Timer/Counter0 Overflow
	reti							; 11: $014 SPI, STC Serial Transfer Complete
	rjmp UART_Interrupt				; 12: $016 USART, RXC USART, Rx Complete
	reti							; 13: $018 USART, UDRE USART Data Register Empty 
	reti							; 14: $01A USART, TXC USART, Tx Complete 
	reti							; 15: $01C ADC ADC Conversion Complete 
	reti							; 16: $01E EE_RDY EEPROM Ready
	reti							; 17: $020 ANA_COMP Analog Comparator 
	reti							; 18: $022 TWI Two-wire Serial Interface
	reti							; 19: $024 INT2 External Interrupt Request 2
	reti							; 20: $026 TIMER0 COMP Timer/Counter0 Compare Match
	reti							; 21 $028 SPM_RDY Store Program Memory Reazdy
	*/
.org 0x10
	jmp		TI_Interrupt
.org 0x16
	jmp		UART_Interrupt

.org 0x30							; se placer à la case mémoire 10 en hexa
reset:								; adresse du vecteur de reset
	ldi		r16,high(RAMEND)		; initialisation de la pile
	out		SPH,r16
	ldi		r16,low(RAMEND)
	out		SPL,r16

	ldi		reg_cpt3,255
	rcall	tempo


	;ajout des programmes pour la gestion des modules
	.include "lettre.asm"
LETTRE_INC:
	.include "io.asm"
IO_INC:
	.include "uart.asm"
UART_INC:
	.include "adc.asm"
ADC_INC:
	.include "timer.asm"
TIMER_INC:
	.include "spi.asm"
SPI_INC:
	.include "screen.asm"
SCREEN_INC:

	;sei



	ldi		reg_init,0

loopMain:
	
	Fenetre_Debut[]

	mov		reg_cpt2,reg_init
	b3[]
	rjmp	UP
	b1[]
	rjmp	DOWN
END:
	mov		reg_init,reg_cpt2
	b5[]
	rcall	CHOIX


	ldi		reg_addrL,CHAR_SIZE*39
	add		reg_addrL,reg_cpt2
	ldi		reg_addrH,2
	cp		reg_addrL,reg_cpt2
	brsh	testMain
	inc		reg_addrH
testMain:
	ldi		reg_lettre,C_CH
	rcall	addImgChar
	
	rcall	writeFullSreen

	rjmp	loopMain

start:

    rjmp	start

UP:
	cpi		reg_cpt2,128
	breq	END
	cpi		reg_cpt2,64
	ldi		reg_cpt2,128
	breq	END
	ldi		reg_cpt2,64
	rjmp	END

DOWN:
	cpi		reg_cpt2,0
	breq	END
	cpi		reg_cpt2,64
	ldi		reg_cpt2,0
	breq	END
	ldi		reg_cpt2,64
	rjmp	END

CHOIX:
	cpi		reg_cpt2,128
	breq	GAME
	cpi		reg_cpt2,64
	breq	RESEAU
	rjmp	MENTION



GAME:
	b5[]
	ret
	rjmp	GAME

RESEAU:
	b5[]
	ret
	rjmp	RESEAU

MENTION:
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

	ldi		reg_addrL,CHAR_SIZE*10-2
	ldi		reg_addrH,1
	ldi		reg_lettre,C_D
	rcall	addImgChar
	
	ldi		reg_addrL,CHAR_SIZE*9-2
	ldi		reg_addrH,1
	ldi		reg_lettre,C_R
	rcall	addImgChar

	ldi		reg_addrL,CHAR_SIZE*8-2
	ldi		reg_addrH,1
	ldi		reg_lettre,C_E
	rcall	addImgChar

	ldi		reg_addrL,CHAR_SIZE*7-2
	ldi		reg_addrH,1
	ldi		reg_lettre,C_PT
	rcall	addImgChar

	ldi		reg_addrL,CHAR_SIZE*6-2
	ldi		reg_addrH,1
	ldi		reg_lettre,C_T
	rcall	addImgChar

	rcall	writeFullSreen

	b4[]
	ret
	rjmp	MENTION
