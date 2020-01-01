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

.def tri = r1						; TimerInterruptRegister.

.def reg_init = r16

;.def reg_test1 = r15
;.def reg_test2 = r14
;.def reg_test3 = r13
;.def reg_bt1 = r24
;r17

.def reg_spi = r18
.def reg_addrL = r19
.def reg_addrH = r20

.def reg_lettre = r24
.def reg_out = r31

.def reg_cpt1 = r21
.def reg_cpt2 = r22
.def reg_cpt3 = r23

.def reg_screen = r18

.def reg_vol = r25
.def reg_son = r28

.def reg_TX = r29
.def reg_RX = r27

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
.org 0x0C
	reti
.org 0x0A
	reti
.org 0x10
	jmp		TI_Interrupt
.org 0x16
	jmp		UART_Interrupt

.org 0x30							; se placer � la case m�moire 10 en hexa
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
	.include "char_array.asm"
CHAR_INC:

	;sei


	ldi		reg_init,128
	ldi		reg_cpt2,128

loop_Aff:
	rcall CLR_RAM
	cursor[]
	rjmp	Fenetre_Debut							;affichage des caract�res de la page principale
FEN_lab:
	ldi		reg_addrL,0x00
	ldi		reg_addrH,0x70
	rcall	writeFullSreen					;affichage de l'�cran

loopMain:
	mov		reg_cpt2,reg_init				;r�cup�ration de la position du curseur
	bHa[]									;test du bouton "vers le haut"
	rjmp	UP
	bBa[]									;test du bouton "vers le bas"
	rjmp	DOWN
END:
	cp		reg_cpt2,reg_init
	brne	loop_Aff

	bA[]									;test du bouton validation
	rjmp	CHOIX
END_CHOIX:
	rjmp	loopMain							;boucle infini

UP:
	cpi		reg_init,128						;test si on est tout en haut
	breq	END
	cpi		reg_init,64							;test si on est au milieu
	ldi		reg_init,128
	breq	END
	ldi		reg_init,64
	rjmp	END

DOWN:
	cpi		reg_init,0							;idem
	breq	END
	cpi		reg_init,64
	ldi		reg_init,0
	breq	END
	ldi		reg_init,64
	rjmp	END

CHOIX:
	cpi		reg_init,128						;test du curseur pour �guiller la fonction
	breq	GAME
	cpi		reg_init,64
	breq	RESEAU
	rjmp	MENTION

GAME:
	ldi		reg_addrL,0
	ldi		reg_addrH,0

	rcall	writeFullSreen

	bB[]
	ldi		reg_init,128
	bB[]
	rjmp	loop_Aff
	rjmp	GAME

RESEAU:
	rcall	CLR_RAM

	ldi		reg_addrL,CHAR_SIZE*6
	ldi		reg_addrH,3
	ldi		reg_lettre,C_MUL
	rcall	addImgChar

	ldi		reg_addrL,0x00
	ldi		reg_addrH,0x70
	rcall	writeFullSreen

	ldi		reg_TX,65								;ping en UART
	rcall	USART_Transmit

	ldi		reg_addrL,CHAR_SIZE*5
	ldi		reg_addrH,3
	ldi		reg_lettre,C_MUL
	rcall	addImgChar

	ldi		reg_addrL,0x00
	ldi		reg_addrH,0x70
	rcall	writeFullSreen

	ldi		reg_cpt3,255
	rcall	tempo_MS

	ldi		reg_addrL,CHAR_SIZE*4
	ldi		reg_addrH,3
	ldi		reg_lettre,C_MUL
	rcall	addImgChar

	ldi		reg_addrL,0x00
	ldi		reg_addrH,0x70
	rcall	writeFullSreen

loopReseau1:

	sbrc	reg_init,1
	rjmp	loopReseau2

	cpi		reg_RX,65								;r�sultat du ping
	breq	loopReseau3
	NO_CONNECTED[]

	rjmp	loopReseau2

loopReseau3:

	ldi		reg_init,2
	CONNECTED[]


loopReseau2:
	ldi		reg_addrL,0x00
	ldi		reg_addrH,0x70
	rcall	writeFullSreen
	bB[]
	ldi		reg_init,128
	bB[]
	rjmp	loop_Aff
	rjmp	loopReseau1
	

MENTION:
	MENTION_MA[]									;affichage des mentions
	ldi		reg_addrL,0x00
	ldi		reg_addrH,0x70
	rcall	writeFullSreen
MENTION1:
	bB[]
	ldi		reg_init,128
	bB[]
	rjmp	loop_Aff
	rjmp	MENTION1

; sous programme de temporisation
tempo_MS:
	ldi	reg_screen, 255
boucletempo:
	nop
	dec	reg_screen
	brne boucletempo
	dec	reg_cpt3
	brne tempo_MS
	ret
