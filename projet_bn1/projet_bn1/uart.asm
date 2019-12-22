;use r16(L) and r17 and r24
.equ baud = 103								;9600 =>103
.def reg_uart = r17
.def reg_TX = r16
.def reg_RX = r24

USART_Init:									; Set baud rate to UBRR0 
	ldi		reg_TX,baud
	ldi		reg_uart,0 
	out		UBRRH, reg_uart   
	out		UBRRL, reg_TX					; Enable receiver and transmitter   
	ldi		reg_TX,(1<<U2X)
	out		UCSRA,reg_TX
	ldi		reg_TX, (1<<RXEN)|(1<<TXEN)|(1<<RXCIE)   
	out		UCSRB,reg_TX					; Set frame format: 8data, 2stop bit   
	ldi		reg_TX, (1<<USBS)|(3<<UCSZ0)   
	out		UCSRC,reg_TX  

	rjmp	UART_INC					;go to main

USART_Transmit:								; Wait for empty transmit buffer
	in		reg_uart, UCSRA   
	sbrs	reg_uart, UDRE   
	rjmp	USART_Transmit					; Put data (r16) into buffer, sends the data   
	out		UDR,reg_TX   
	ret 

UART_Interrupt:
	in		tri,SREG						; save content of flag reg.
	in		reg_RX,UDR
	out		SREG,tri						; restore flag register
	reti 									; Return from interruptt