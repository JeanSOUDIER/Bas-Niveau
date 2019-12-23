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

.def Init = r16

.def reg_spi = r18
.def reg_addrL = r19
.def reg_addrH = r20

.def reg_lettre = r18
.def reg_out = r19

.def reg_cpt1 = r21
.def reg_cpt2 = r22
.def reg_cpt3 = r23

.def reg_screen = r18

.def reg_bt1 = r24
.def reg_vol = r25
.def reg_son = r28

.def reg_TX = r29
.def reg_RX = r30


.dseg
img: .byte 1024	; reserve une image
addrL: .byte 1  ;addr de départ
addrH: .byte 1
btL:   .byte 1
btH:   .byte 1
TX:    .byte 1

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

	
	ldi		reg_addrL,5
	ldi		reg_addrH,0
	ldi		reg_lettre,0
	rcall	createImgFull
	rcall	addImgChar
	rcall	writeFullSreen

	sbi		PORTD,6

start:

    rjmp	start