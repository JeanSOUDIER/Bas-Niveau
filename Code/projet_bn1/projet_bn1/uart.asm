.equ baud = 51								;9600 =>103

.macro UART_X[]
	andi	reg_RX,0x3F						;reception de la position X en interruption (SRAM innacessible en interruption pour éviter de les désactiver)
	mov		r11,reg_RX
.endmacro

.macro UART_Y[]
	andi	reg_RX,0x3F
	mov		r10,reg_RX
.endmacro

.macro PosPerso[]
	sts		pos_x_adv,r11
	sts		pos_y_adv,r10
.endmacro

USART_Init:									; Set baud rate to UBRR0 
	ldi		reg_TX,baud
	out		UBRRL, reg_TX					; Enable receiver and transmitter  
	ldi		reg_TX,0 
	out		UBRRH, reg_TX    
	ldi		reg_TX,0
	out		UCSRA,reg_TX
	ldi		reg_TX,(1<<RXEN)|(1<<TXEN)|(1<<RXCIE)   
	out		UCSRB,reg_TX					; Set frame format: 8data, 2stop bit   
	ldi		reg_TX,(1<<URSEL)|(1<<USBS)|(3<<UCSZ0)   
	out		UCSRC,reg_TX  

	rjmp	UART_INC					;go to main

;mov		reg_TX,reg_XXXX
;ori		reg_TX,   0x80 (posX), 0x40 (posY), 0x00 (Kill)
USART_Transmit:								; Wait for empty transmit buffer
	sbis	UCSRA,UDRE 
	rjmp	USART_Transmit					; Put data into buffer, sends the data   
	out		UDR,reg_TX   
	ret 

UART_Interrupt:
	in		tri,SREG						; save content of flag reg.
	in		reg_RX,UDR
	cpi		reg_RX,0						;test si on recoit un coup
	brne	DEATH_POS
	sts		dead,reg_RX
	rjmp	END_UART
DEATH_POS:
	cpi		reg_RX,0x80
	brlo	POSITON_PERSO_Y
	UART_X[]
	rjmp	END_UART
POSITON_PERSO_Y:
	UART_Y[]
END_UART:
	out		SREG,tri						; restore flag register
	reti 									; Return from interrupt