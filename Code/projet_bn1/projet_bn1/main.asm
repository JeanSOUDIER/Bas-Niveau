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

.def reg_lettre = r18
.def reg_out = r31

.def reg_cpt1 = r21
.def reg_cpt2 = r22
.def reg_cpt3 = r23

.def reg_screen = r18

.def reg_vol = r25
.def reg_son = r28

.def reg_TX = r29
.def reg_RX = r30

.dseg
img: .byte 1024	; reserve une image

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
	.include "char_array.asm"

	sei

DEBUT:
	ldi		reg_addrL,0xA8				;placement à la case 0x4804 de la mémoire
	subi	reg_addrL,-0x04				;placement à la vue Nord
	ldi		reg_addrH,0x4D
	rcall	Read_Mem					;lecture de la mémoire spi
	mov		r16,reg_spi
	lsr		r16
	lsr		r16
	lsr		r16
	lsr		r16
	cpi		r16,0x08
	brne	DETERMINATION_IMAGE
	ldi		r16,0x04
	rjmp	CREATION_IMAGE
DETERMINATION_IMAGE:
	ldi		r17,0x04
	mul		r17,r16
	mov		r16,r0
	subi	r16,-0x08
	rjmp	CREATION_IMAGE

start:
	bB[]
	;rcall	IMAGE_PRECEDENTE
	bA[]
	;rcall	IMAGE_SUIVANTE
	rjmp	start


CREATION_IMAGE:
	ldi		reg_addrL,0x00
	mov		reg_addrH,r16
	createImgFull[]
	rcall	writeFullSreen
	rjmp start


/*IMAGE_SUIVANTE:
	subi	r16,-0x04
	cpi		r16,0x48
	brne	CREATION_IMAGE
	ldi		r16,0x04
	rjmp	CREATION_IMAGE
IMAGE_PRECEDENTE:
	subi	r16,0x04
	cpi		r16,0x00
	brne	CREATION_IMAGE
	ldi		r16,0x44*/

	/*ldi		reg_init,128

loopMain:
	
	Fenetre_Debut[]							;affichage des caractères de la page principale

	mov		reg_cpt2,reg_init				;récupération de la position du curseur
	bHa[]									;test du bouton "vers le haut"
	rjmp	UP
	bBa[]									;test du bouton "vers le bas"
	rjmp	DOWN
END:
	mov		reg_init,reg_cpt2
	bA[]									;test du bouton validation
	rjmp	CHOIX
END_CHOIX:

	ldi		reg_addrL,CHAR_SIZE*40				;cursor
	add		reg_addrL,reg_cpt2					;chargement de la position
	ldi		reg_addrH,2
	cp		reg_addrL,reg_cpt2					;test de carry
	brsh	testMain
	inc		reg_addrH
testMain:
	ldi		reg_lettre,C_CH						;chargement de la lettre ">"
	rcall	addImgChar							;stockage de la lettre dans la mémoire
	
	rcall	writeFullSreen						;affichage de l'écran

	rjmp	loopMain							;boucle infini

UP:
	cpi		reg_cpt2,128						;test si on est tout en haut
	breq	END
	cpi		reg_cpt2,64							;test si on est au milieu
	ldi		reg_cpt2,128
	breq	END
	ldi		reg_cpt2,64
	rjmp	END

DOWN:
	cpi		reg_cpt2,0							;idem
	breq	END
	cpi		reg_cpt2,64
	ldi		reg_cpt2,0
	breq	END
	ldi		reg_cpt2,64
	rjmp	END

CHOIX:
	cpi		reg_cpt2,128						;test du curseur pour éguiller la fonction
	breq	GAME
	cpi		reg_cpt2,64
	breq	RESEAU
	rjmp	MENTION



GAME:
	ldi		reg_addrL,0
	ldi		reg_addrH,0
	createImgFull[]

	rcall	writeFullSreen

	bB[]
	rjmp	END_CHOIX
	rjmp	GAME

RESEAU:
	CLR_RAM[]

	ldi		reg_addrL,CHAR_SIZE*6
	ldi		reg_addrH,3
	ldi		reg_lettre,C_MUL
	rcall	addImgChar

	rcall	writeFullSreen

	ldi		reg_TX,65								;ping en UART
	rcall	USART_Transmit

	ldi		reg_addrL,CHAR_SIZE*5
	ldi		reg_addrH,3
	ldi		reg_lettre,C_MUL
	rcall	addImgChar

	rcall	writeFullSreen

	ldi		reg_cpt2,255

loopReseau:											;tempo
	ldi		reg_cpt3,255
	rcall	tempo
	dec		reg_cpt1
	cpi		reg_cpt1,0
	brne	loopReseau

	ldi		reg_addrL,CHAR_SIZE*4
	ldi		reg_addrH,3
	ldi		reg_lettre,C_MUL
	rcall	addImgChar

	rcall	writeFullSreen

loopReseau1:

	sbrc	reg_init,1
	rjmp	loopReseau3

	cpi		reg_RX,65								;résultat du ping
	brne	N_CONNECTED

loopReseau3:

	ldi		reg_init,2

	CONNECTED[]

loopReseau2:

	rcall	writeFullSreen

	bB[]
	ldi		reg_init,128
	bB[]
	rjmp	END_CHOIX
	rjmp	loopReseau1

N_CONNECTED:
	NO_CONNECTED[]

	rjmp	loopReseau2

MENTION:
	MENTION_MA[]									;affichage des mentions

	bB[]
	ldi		reg_init,128
	bB[]
	rjmp	END_CHOIX
	rjmp	MENTION*/
