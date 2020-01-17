;
; main.asm
;
; Created: 25/10/2019 13:42:48
; Author : jsoudier01 & atessier01
;
;code programme

.def tri = r2							;timerInterruptRegister.

.def reg_init = r29						;registre d'initialisation de tout les paramètre et temporaire

;.def reg_posX = r28					;position du personnage en X
;.def reg_posY = r29					;position du personnage en Y

.def reg_spi = r24						;registre d'envoi et réception en spi & tempo MS
.def reg_addrL = r19					;registres de sélection d'adresse dans la mémoire SPI (LOW)
.def reg_addrH = r20					;registres de sélection d'adresse dans la mémoire SPI (HIGH)

.def reg_cpt1 = r21						;registre temporaire de comptage pour l'affichage sur l'écran
.def reg_cpt2 = r22						;idem
.def reg_cpt3 = r17						;registre de comptage tempo
.def reg_screen = r17					;registre d'affichage sur l'écran

.def reg_cptT0 = r23					;prescaler du timer0 pour ralentire le clignotement

.def reg_vol = r25						;registre de son et de volume

.def reg_TX = r30						;registre d'envoi en bluetooth
.def reg_RX = r18						;registre de réception en bluetooth

;.def reg_csgo_orientation = r13		;orientation du personnage
;.def reg_csgo_mapL = r28				;position du personnage dans la map
;.def reg_csgo_mapH = r29
.def reg_calcul1 = r28
;.def reg_calcul2 = r29

.dseg
	num_son:		.byte 1				;variable SRAM de son (LOW)
	num_son2:		.byte 1				;idem (HIGH)
	C_Wait:			.byte 5				;variable avec le caractère de chargement pour les images
	Table:			.byte 8				;table de conversion
	conv:			.byte 1				;varaible de convertion de la poistion du personnage X
	convB:			.byte 1				;idem Y
	conv2:			.byte 1				;idem afficher ou non
	dead:			.byte 1				;variable de test si le personnage est en vie
	pos_rand:		.byte 1				;position de départ du personnage (case 0 à 181)
	pos_x:			.byte 1				;position en x du joueur
	pos_y:			.byte 1				;position en y du joueur
	numero_mapL:	.byte 1				;adresse de la case actuelle dans la mémoire
	numero_mapH:	.byte 1
	pos_x_adv:		.byte 1				;position en x de l'adversaire
	pos_y_adv:		.byte 1				;position en y de l'adversaire
	orientation:	.byte 1				;orientation du personnage
	adv_ok:			.byte 1				;si l'adversaire est juste devant nous

.cseg  ; codesegment
.org	0x00
   rjmp	RESET							;vecteur de reset
.org 0x0C								; 7:  $00C TIMER1 COMPA Timer/Counter1 Cmp Match A 
	reti
.org 0x0A								; 6:  $00A TIMER1 CAPT Timer/Counter1 Capture Event
	reti
.org 0x10								; 9:  $010 TIMER1 OVF Timer/Counter1 Overflow
	jmp		TI1_Interrupt
.org 0x12								; 10: $012 TIMER0 OVF Timer/Counter0 Overflow
	jmp		TI0_interrupt
.org 0x16								; 12: $016 USART, RXC USART, Rx Complete
	jmp		UART_Interrupt

.org 0x30								; se placer à la case mémoire 30 en hexa
RESET:									; adresse du vecteur de reset
	ldi		r16,high(RAMEND)			; initialisation de la pile
	out		SPH,r16
	ldi		r16,low(RAMEND)
	out		SPL,r16

	ldi		reg_cpt3,255			;tempo de début
	rcall	tempo_US



	;ajout des programmes pour la gestion des modules
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
	.include "csgo.asm"
CSGO_INC:
	
	sei

	ldi		reg_init,8						;initialisation du curseur

	

loopMain:									;premier menu
	mov		reg_cpt2,reg_init				;récupération de la position du curseur
	bHa[]									;test du bouton "vers le haut"
	rjmp	UP
	bBa[]									;test du bouton "vers le bas"
	rjmp	DOWN
END:
	Fenetre_Debut[]							;affichage des caractères de la page principale
	bA[]									;test du bouton validation
	rjmp	CHOIX
END_CHOIX:
	rjmp	loopMain						;boucle infini

UP:
	cpi		reg_init,8						;test si on est tout en haut
	breq	END
	cpi		reg_init,4						;test si on est au milieu
	ldi		reg_init,8
	breq	END
	ldi		reg_init,4
	rjmp	END

DOWN:
	cpi		reg_init,0						;idem
	breq	END
	cpi		reg_init,4
	ldi		reg_init,0
	breq	END
	ldi		reg_init,4
	rjmp	END

CHOIX:
	cpi		reg_init,4						;test du curseur pour éguiller la fonction
	breq	RESEAU
	cpi		reg_init,0
	breq	MENTION
	ldi		reg_init,0
	rjmp	GAME

MENTION:
	MENTION_MA[]							;affichage des mentions
	bB[]
	ldi		reg_init,8
	bB[]
	rjmp	loopMain
	rjmp	MENTION

	RESEAU:									;boucle du test de connection réseau
	CONN1[]

	ldi		reg_TX,1						;ping en UART
	rcall	USART_Transmit

	CONN2[]

	ldi		reg_cpt3,255
	rcall	tempo_MS

	CONN3[]

loopReseau1:

	sbrc	reg_init,1
	rjmp	loopReseau2

	cpi		reg_RX,1						;résultat du ping
	breq	loopReseau3

	ldi		reg_TX,1						;ping en UART
	rcall	USART_Transmit

	ldi		reg_cpt3,255
	rcall	tempo_MS

	NO_CONNECTED[]

	rjmp	loopReseau2

loopReseau3:

	ldi		reg_init,2						;une fois connecter on le reste !!!
	CONNECTED[]


loopReseau2:
	bB[]
	ldi		reg_init,8
	bB[]
	rjmp	loopMain
	rjmp	loopReseau1


GAME:
	bHa[]									;choix du mode de jeu
	ldi		reg_init,0
	bBa[]
	ldi		reg_init,4

	ldi		reg_addrL,0x00					;affichage en fonction du curseur
	ldi		reg_addrH,0x78
	add		reg_addrH,reg_init
	rcall	writeFullSreen

	bA[]
	rjmp	Lancement_Jeu					;lancement du jeu (1 mode disponible pour l'instant

	bB[]									;test de retour à l'écran principale
	ldi		reg_init,8
	bB[]
	rjmp	loopMain
	rjmp	GAME

Lancement_Jeu:								;on détermine dans quel mode de jeu on est
	ldi		r16,0x00						;placement orientation Nord
	sts		orientation,r16
	cpi		reg_init,0
	breq	MME
	rjmp	Cible
MME:
	;on teste si on est bien connecté, si oui:
	;pos rand devient la position du joueur
	;ldi		r16,0x00					;placement du joueur à la case 1 de la mémoire
	;sts		numero_mapL,r16
	;ldi		r16,0x48
	;sts		numero_mapH,r16

	rcall	rand
	lds		r16,pos_rand				;on met la valeur entre 0 et 128
	ldi		r17,0x08						;on calcule l'adresse de la case de la cible à partir de son numéro: addr = 0x4800 + 8*rand_pos
	mul		r16,r17
	sts		numero_mapL,r0
	mov		r16,r1
	subi	r16,-0x48
	sts		numero_mapH,r16
	lds		reg_TX,numero_mapL
	rcall	USART_Transmit
	lds		reg_TX,numero_mapH
	rcall	USART_Transmit
	rjmp	Affichage_Image
Cible:
	ldi		r16,0x00						;placement du joueur à la case 1 de la mémoire
	sts		numero_mapL,r16
	ldi		r16,0x48
	sts		numero_mapH,r16

	rcall	rand
	lds		r16,pos_rand
	ldi		r17,0x08						;on calcule l'adresse de la case de la cible à partir de son numéro: addr = 0x4800 + 8*rand_pos
	mul		r16,r17
	mov		reg_addrL,r0
	mov		reg_addrH,r1
	subi	reg_addrH,-0x48
	subi	reg_addrL,-0x06
	rcall	Read_Mem						;on récupère la position x
	sts		pos_x_adv,reg_spi
	subi	reg_addrL,-0x01
	rcall	Read_Mem						;on récupère la position y
	sts		pos_y_adv,reg_spi

	rjmp	Affichage_Image					;début du jeu

Jeu_En_Cours:								;boucle du jeu en cours
	cpi		reg_init,0
	breq	POS
Jeu_Continue:
	bSta[]
	ldi		r16,0xff
	bSta[]
	sts		pos_x,r16
	bSta[]
	rjmp	GAME
	bGa[]								
	rjmp	Tourner_Gauche
	bDr[]
	rjmp	Tourner_Droite
	bHa[]
	rjmp	Avancer
	bA[]
	rjmp	Attaquer
	lds		reg_cpt3,dead					;on teste si on est mort
	cpi		reg_cpt3,0
	brne	en_vie
	ldi		reg_addrL,0x00					;on affiche l'écran de défaite
	ldi		reg_addrH,0x58
	rcall	writeFullSreen
	ldi		reg_cpt3,255					;on attend un peu
	rcall	tempo_MS
	ldi		reg_cpt3,255
	rcall	tempo_MS
	ldi		reg_cpt3,255
	rcall	tempo_MS
	ldi		reg_cpt3,255
	rcall	tempo_MS
	ldi		reg_cpt3,255
	rcall	tempo_MS
	ldi		reg_cpt3,255
	rcall	tempo_MS
	ldi		reg_cpt3,255
	rcall	tempo_MS
	jmp	GAME								;et on revient au menu
en_vie:
	ldi		reg_cpt3,100					;sinon on reboucle sur le jeu
	rcall	tempo_MS
	rjmp	Affichage_Image
	;rjmp	Jeu_En_Cours

POS:
	PosPerso[]
	rjmp Jeu_Continue


; sous programme de temporisation, dure approximativement 127.49us si charge 1 dans reg_cpt3
tempo_MS:
	ldi	reg_spi, 255
boucletempo_MS:
	nop
	dec	reg_spi
	brne boucletempo_MS
	dec	reg_cpt3
	brne tempo_MS
	ret
