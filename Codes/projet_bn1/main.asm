;********************************
; Programme du jeu entre 2 Gameboy connectées en bluetooth (électif bas niveau) [fichier principal]
;
; Fichier : main.asm
;
; Microcontrôleur Atmega16A
;
; Version atmel studio : 7.0.2397
; Created: 25/10/2019 13:42:48
;
; Author : jsoudier01 & atessier01
; INSA Strasbourg
;********************************

.def tri = r2							;timerInterruptRegister.

.def reg_init = r29						;registre d'initialisation de tous les paramètres et temporaires

.def reg_spi = r24						;registre d'envoi et réception en spi & tempo MS
.def reg_addrL = r19					;registres de sélection d'adresse dans la mémoire SPI (LOW)
.def reg_addrH = r20					;registres de sélection d'adresse dans la mémoire SPI (HIGH)

.def reg_cpt1 = r21						;registre temporaire de comptage pour l'affichage sur l'écran
.def reg_cpt2 = r22						;idem
.def reg_cpt3 = r17						;registre de comptage tempo
.def reg_screen = r17					;registre d'affichage sur l'écran

.def reg_cptT0 = r23					;prescaler du timer0 pour ralentir le clignotement

.def reg_vol = r25						;registre de son et de volume

.def reg_TX = r30						;registre d'envoi en bluetooth
.def reg_RX = r18						;registre de réception en bluetooth

.def reg_calcul1 = r28					;registre de calcul temporaire

.dseg
	num_son:		.byte 1				;variable SRAM du son (LOW)
	num_son2:		.byte 1				;idem (HIGH)
	C_Wait:			.byte 5				;variable avec le caractère de chargement pour les images
	Table:			.byte 8				;table de conversion
	conv:			.byte 1				;varaible de conversion de la position du personnage X
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

;--------------------------------
; Nom de la fonction : RESET
;
; Description : fonction de lancement du programme et d'initialisation de tous les autres fichiers
;
; Entrées : - r16 variable temporaire
;		    - r17 (reg_cpt3) varaible d'attente
;		    - r29 (reg_init) pointeur à l'écran
;
; Sorties : appel des fonctions "Init_char_array" [char_array.asm], "ADC_Init" [adc.asm], "IO_Init" [io.asm], "SCREEN_Init" [screen.asm], "SPI_Init" [spi.asm],
;			"TIMER_Init" [timer.asm], "USART_Init" [uart.asm] et "csgo_init" [csgo.asm]
;--------------------------------
.org 0x30								; se placer à la case mémoire 30 en hexa
RESET:									; adresse du vecteur de reset
	ldi		r16,high(RAMEND)			; initialisation de la pile
	out		SPH,r16
	ldi		r16,low(RAMEND)
	out		SPL,r16

	ldi		reg_cpt3,255				;tempo de début
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
	
	sei										;activation des interruptions

	ldi		reg_init,8						;initialisation du curseur

;--------------------------------
; Nom de la fonction : loopMain
;
; Description : boucle de la vue principale
;
; Entrées : - r29 (reg_init) pointeur à l'écran
;		    - r22 (reg_cpt2) varaible temporaire
;
; Sorties : appel des macros "bHa[]" [timer.asm], "bBa[]" [timer.asm], "bA[]" [timer.asm] et "Fenetre_Debut[]" [screen.asm]
;--------------------------------
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

;--------------------------------
; Nom de la fonction : UP
;
; Description : gestion du déplacement du curseur vers le haut
;
; Entrée : - r29 (reg_init) pointeur à l'écran
;
; Sortie : - r29 (reg_init)
;--------------------------------
UP:
	cpi		reg_init,8						;test si on est tout en haut
	breq	END
	cpi		reg_init,4						;test si on est au milieu
	ldi		reg_init,8
	breq	END
	ldi		reg_init,4
	rjmp	END

;--------------------------------
; Nom de la fonction : DOWN
;
; Description : gestion du déplacement du curseur vers le bas
;
; Entrée : - r29 (reg_init) pointeur à l'écran
;
; Sortie : - r29 (reg_init)
;--------------------------------
DOWN:
	cpi		reg_init,0						;idem
	breq	END
	cpi		reg_init,4
	ldi		reg_init,0
	breq	END
	ldi		reg_init,4
	rjmp	END

;--------------------------------
; Nom de la fonction : CHOIX
;
; Description : gestion du choix sélectionné à l'écran
;
; Entrée : - r29 (reg_init) pointeur à l'écran
;
; Sorties : appel des fonctions "RESEAU", "MENTION" et "GAME" [main.asm]
;--------------------------------
CHOIX:
	cpi		reg_init,4						;test du curseur pour aiguiller la fonction
	breq	RESEAU
	cpi		reg_init,0
	breq	MENTION
	ldi		reg_init,0
	rjmp	GAME

;--------------------------------
; Nom de la fonction : MENTION
;
; Description : affichage des mentions
;
; Entrée : X
;
; Sorties : - r29 (reg_init) pointeur à l'écran pour revenir vers l'écran d'acceuil
;			appel des macros "MENTION_MA[]" [char_array.asm] et "bB[]" [timer.asm]
;--------------------------------
MENTION:
	MENTION_MA[]							;affichage des mentions
	bB[]
	ldi		reg_init,8
	bB[]
	rjmp	loopMain
	rjmp	MENTION

;--------------------------------
; Nom de la fonction : RESEAU
;
; Description : affichage du test réseau (ping)
;
; Entrée : X
;
; Sorties : - r29 (reg_init) pointeur à l'écran pour revenir vers l'écran d'acceuil
;			appel des macros "CONN1[]" [char_array.asm], "CONN2[]" [char_array.asm], "CONN3[]" [char_array.asm], "NO_CONNECTED[]" [char_array.asm], "CONNECTED[]" [char_array.asm] et "bB[]" [timer.asm]
;			appel des fonctions "USART_Transmit" [uart.asm] et "tempo_MS" [main.asm]
;--------------------------------
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

	ldi		reg_init,2						;une fois connecté on le reste !!!
	CONNECTED[]


loopReseau2:
	bB[]
	ldi		reg_init,8
	bB[]
	rjmp	loopMain
	rjmp	loopReseau1

;--------------------------------
; Nom de la fonction : GAME
;
; Description : affichage de la page de lancement du jeu
;
; Entrées : - r19 (reg_addrL) variable de positionnement dans la mémoire SPI (LOW)
;		    - r20 (reg_addrH) variable de positionnement dans la mémoire SPI (HIGH)
;
; Sorties : - r29 (reg_init) pointeur à l'écran pour choisir le mode de jeu
;			appel des macros "bHa[]" [timer.asm], "bBa[]" [timer.asm], "bA[]" [timer.asm] et "bB[]" [timer.asm]
;			appel des fonctions "writeFullSreen" [screen.asm], "Lancement_Jeu" [main.asm] et "loopMain" [main.asm]
;--------------------------------
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
	rjmp	Lancement_Jeu					;lancement du jeu

	bB[]									;test de retour à l'écran principal
	ldi		reg_init,8
	bB[]
	rjmp	loopMain
	rjmp	GAME

;--------------------------------
; Nom de la fonction : Lancement_Jeu
;
; Description : Sélection du mode de jeu en fonction du choix du joueur dans le menu GAME
;
; Entrées : - r29 (reg_init) choix du mode de jeu
;
; Sorties : - numero_mapL et numero_mapH (SRAM) adresse de la case actuelle du joueur dans la mémoire
;			appel des fonctions "rand" [timer.asm], "USART_Transmit" [uart.asm], "Read_Mem" [spi.asm] et "Affichage_Image" [main.asm]
;--------------------------------
Lancement_Jeu:								;on détermine dans quel mode de jeu on est
	ldi		r16,0x00						;placement orientation Nord
	sts		orientation,r16
	cpi		reg_init,0
	breq	MME
	rjmp	Cible
MME:										;mode de jeu multijoueur
	rcall	rand							;on récupère une valeur aléatoire entre 0 et 255
	lds		r16,pos_rand					
	ldi		r17,0x08						;on met la valeur entre 0 et 128 (pour être sûr qu'elle soit entre 0 et 181
	mul		r16,r17							;on calcule l'adresse de la case de la cible à partir de son numéro: addr = 0x4800 + 8*rand_pos
	sts		numero_mapL,r0					;on stocke l'adresse
	mov		r16,r1
	subi	r16,-0x48
	sts		numero_mapH,r16					;on stocke l'adresse
	lds		reg_TX,numero_mapL				;et on la transmet à l'autre GameBoy
	rcall	USART_Transmit
	lds		reg_TX,numero_mapH
	rcall	USART_Transmit
	rjmp	Affichage_Image					;début du jeu
Cible:										;mode de jeu solo
	ldi		r16,0x00						;placement du joueur à la case 1 de la mémoire
	sts		numero_mapL,r16
	ldi		r16,0x48
	sts		numero_mapH,r16

	rcall	rand							;on récupère une valeur aléatoire et on la caste entre 0 et 128
	lds		r16,pos_rand
	ldi		r17,0x08						
	mul		r16,r17							;on calcule l'adresse de la case de la cible à partir de son numéro: addr = 0x4800 + 8*rand_pos
	mov		reg_addrL,r0
	mov		reg_addrH,r1
	subi	reg_addrH,-0x48
	subi	reg_addrL,-0x06
	rcall	Read_Mem						;on récupère la position x correspondante
	sts		pos_x_adv,reg_spi
	subi	reg_addrL,-0x01
	rcall	Read_Mem						;on récupère la position y correspondante
	sts		pos_y_adv,reg_spi

	rjmp	Affichage_Image					;début du jeu

;--------------------------------
; Nom de la fonction : Jeu_En_Cours
;
; Description : Boucle de traitement des informations pendant le jeu
;
; Entrées : - r29 (reg_init) regitre indiquant le mode de jeu
;			- dead (SRAM) variable indiquant l'état de vie du personnage
;
; Sorties : - dead (SRAM) variable indiquant l'état de vie du personnage
;			appel des macros "bSta[]" [timer.asm], "bHa[]" [timer.asm], "bGa[]" [timer.asm], "bDr[]" [timer.asm] et "bA[]" [timer.asm]
;			appel des fonctions "GAME" [main.asm], "PosPerso" [uart.asm], "Tourner_Gauche" [csgo.asm], "Tourner_Droite" [csgo.asm], "Avancer" [csgo.asm], "Attaquer" [csgo.asm], "tempo_MS" [main.asm] et "Affichage_Image" [csgo.asm]
;--------------------------------
Jeu_En_Cours:								;boucle du jeu en cours
	cpi		reg_init,0						;si on est en mode multijoueur:
	breq	POS								;on met à jour les coordonnées de l'adversaire, pour éviter d'utiliser la SRAM en interruption	
Jeu_Continue:
	bSta[]									;on retourne au menu si le bouton "start" est appuyé
	ldi		r16,0xff						;on place 255 dans la position x pour désactiver le clignotement de la position
	bSta[]
	sts		pos_x,r16
	bSta[]
	rjmp	GAME
	bGa[]									;détection d'appui du joueur sur un bouton utilisé dans le jeu et lancement de l'action associée
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
	ldi		r16,0x01
	sts		dead,r16						;on réinitialise la variable "dead"
	jmp	GAME								;et on revient au menu
en_vie:										;si le joueur est toujours en vie:
	ldi		reg_cpt3,100					;on reboucle sur le jeu
	rcall	tempo_MS
	rjmp	Affichage_Image
POS:										;fonction qui permet de résoudre un bug concernant le lancement de la macro
	PosPerso[]
	rjmp Jeu_Continue

;--------------------------------
; Nom de la fonction : tempo_MS
;
; Description : crée une attente (dure approximativement 127.49us*reg_cpt3)
;
; Entrées : - r24 (reg_spi) variable de comptage
;		    - r17 (reg_cpt3) variable de comptage
;
; Sortie : X
;--------------------------------
tempo_MS:
	ldi	reg_spi, 255
boucletempo_MS:
	nop
	dec	reg_spi
	brne boucletempo_MS
	dec	reg_cpt3
	brne tempo_MS
	ret
