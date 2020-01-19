;********************************
; Programme du jeu entre 2 Gameboy connectées en bluetooth (électif bas niveau) [fichier de gestion de l'uart (bluetooth)]
;
; Fichier : uart.asm
;
; Microcontrôleur Atmega16A
;
; Version atmel studio : 7.0.2397
; Created: 25/10/2019 13:42:48
;
; Author : jsoudier01 & atessier01
; INSA Strasbourg
;********************************

.equ baud = 51								;9600 =>103

;--------------------------------
; Nom de la macro : UART_X[]
;
; Description : récupère la position X du personnage enemi en bluetooth
;
; Entrée : - r18 (reg_RX) registre de réception en UART
;
; Sorties : - r11 variable de position X enemi
;--------------------------------
.macro UART_X[]
	andi	reg_RX,0x3F						;reception de la position X en interruption (SRAM innacessible en interruption pour éviter de les désactiver)
	mov		r11,reg_RX
.endmacro

;--------------------------------
; Nom de la macro : UART_Y[]
;
; Description : récupère la position Y du personnage enemi en bluetooth
;
; Entrée : - r18 (reg_RX) registre de réception en UART
;
; Sorties : - r10 variable de position Y enemi
;--------------------------------
.macro UART_Y[]
	andi	reg_RX,0x3F						;masque de réception
	mov		r10,reg_RX
.endmacro

;--------------------------------
; Nom de la macro : PosPerso[]
;
; Description : stock les données de position du personnage enemi dans la SRAM en dehors des interuptions
;
; Entrée : - r10 variable de position Y enemi
;		   - r11 variable de position X enemi
;
; Sorties : - pos_x_adv (SRAM) position du personnage enemi en X
;			- pos_y_adv (SRAM) position du personnage enemi en Y
;--------------------------------
.macro PosPerso[]
	sts		pos_x_adv,r11
	sts		pos_y_adv,r10
.endmacro

;--------------------------------
; Nom de la fonction : USART_Init
;
; Description : initialisation de l'UART
;
; Entrée : - r30 (reg_TX) variable temporaire
;
; Sorties : X
;--------------------------------
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
	rjmp	UART_INC						;go to main

;--------------------------------
; Nom de la fonction : USART_Transmit
;
; Description : transmet une donnée en UART
;
; Entrée : - r30 (reg_TX) registre de la donnée à envoyer /!\ posX : ori reg_TX,0x80 / posY : ori reg_TX,0x40 / meutre : ldi reg_TX,0 / ping : ldi reg_TX,1
;
; Sorties : X
;--------------------------------
USART_Transmit:								; Wait for empty transmit buffer
	sbis	UCSRA,UDRE 
	rjmp	USART_Transmit					; Put data into buffer, sends the data   
	out		UDR,reg_TX   
	ret 

;--------------------------------
; Nom de la fonction : UART_Interrupt
;
; Description : fonction d'interruption en UART
;
; Entrée : - r2 (tri) registre de sauvegarde du contexte
;		   - r18 (reg_RX) registre de réception en UART
;
; Sorties : - dead (SRAM) état du personnage
;			- appel des macros "UART_X[]" et "UART_Y[]" [uart.asm]
;--------------------------------
UART_Interrupt:
	in		tri,SREG						; save content of flag reg.
	in		reg_RX,UDR
	cpi		reg_RX,0						;test si on recoit un coup
	brne	DEATH_POS
	sts		dead,reg_RX						;mise à jour de l'état du personnage
	rjmp	END_UART
DEATH_POS:
	cpi		reg_RX,0x80						;gestion de la position
	brlo	POSITON_PERSO_Y
	UART_X[]
	rjmp	END_UART
POSITON_PERSO_Y:
	UART_Y[]
END_UART:
	out		SREG,tri						; restore flag register
	reti 									; Return from interrupt