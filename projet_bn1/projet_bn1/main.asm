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

.def tri = r1    ; TimerInterruptRegister.

.cseg  ; codesegment
.org 0x00
   rjmp RESET 

; interrupt-vector commands, 1 Byte each:
	reti ; 1:  $000(1) RESET External Pin, Power-on Reset, Brown-out Reset, Watchdog Reset, and JTAG AVR Reset
	reti ; 2:  $002 INT0 External Interrupt Request 0 
	reti ; 3:  $004 INT1 External Interrupt Request 1 
	reti ; 4:  $006 TIMER2 COMP Timer/Counter2 Compare Match 
	reti ; 5:  $008 TIMER2 OVF Timer/Counter2 Overflow 
	reti ; 6:  $00A TIMER1 CAPT Timer/Counter1 Capture Event
	reti ; 7:  $00C TIMER1 COMPA Timer/Counter1 Cmp Match A 
	reti ; 8:  $00E TIMER1 COMPB Timer/Counter1 Cmpe Match B
	rjmp TI_Interrupt ; 9:  $010 TIMER1 OVF Timer/Counter1 Overflow
	reti ; 10: $012 TIMER0 OVF Timer/Counter0 Overflow
	reti ; 11: $014 SPI, STC Serial Transfer Complete
	rjmp UART_Interrupt ; 12: $016 USART, RXC USART, Rx Complete
	reti ; 13: $018 USART, UDRE USART Data Register Empty 
	reti ; 14: $01A USART, TXC USART, Tx Complete 
	reti ; 15: $01C ADC ADC Conversion Complete 
	reti ; 16: $01E EE_RDY EEPROM Ready
	reti ; 17: $020 ANA_COMP Analog Comparator 
	reti ; 18: $022 TWI Two-wire Serial Interface
	reti ; 19: $024 INT2 External Interrupt Request 2
	reti ; 20: $026 TIMER0 COMP Timer/Counter0 Compare Match
	reti ; 21 $028 SPM_RDY Store Program Memory Reazdy



.org 0x30						; se placer à la case mémoire 10 en hexa
reset:							; adresse du vecteur de reset
	ldi r16,high(RAMEND)	; initialisation de la pile
	out	SPH,r16
	ldi	r16,low(RAMEND)
	out	SPL,r16

	;ajout des programmes pour la gestion des modules
	.include "uart.asm"
	.include "timer.asm"
	.include "io.asm"
	.include "adc.asm"
	.include "spi.asm"
	.include "screen.asm"

	;init
	rcall   IO_Init
	rcall   USART_Init
	rcall   ADC_Init
	rcall   SPI_Init
	rcall   SCREEN_Init
	rcall   TIMER_Init

	;sei

start:
    sbi PORTD,6
	nop
    rjmp start
