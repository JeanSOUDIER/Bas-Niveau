;********************************
; Programme du jeu entre 2 Gameboy connectées en bluetooth (électif bas niveau) [fde gestion de l'affichage]
;
; Fichier : char_array.asm
;
; Microcontrôleur Atmega16A
;
; Version atmel studio : 7.0.2397
; Created: 25/10/2019 13:42:48
;
; Author : jsoudier01 & atessier01
; INSA Strasbourg
;********************************

;--------------------------------
; Nom de la fonction : Init_char_array
;
; Description : fonction d'initialisation des variables de la mémoire SRAM
;
; Entrée : - r29 (reg_init) variable temporaire
;
; Sorties : C_Wait (SRAM) caractère d'attent du ping
;			Table (SRAM) table de convertion pour faire clignoter le pixel de la position du personnage
;			dead (SRAM) variable d'état du personnage
;--------------------------------
Init_char_array:
	ldi		XL,LOW(C_Wait)			;load '#'
	ldi		XH,HIGH(C_Wait)
	ldi		reg_init,0x14
	st		X+,reg_init
	ldi		reg_init,0xFF
	st		X+,reg_init
	ldi		reg_init,0x14
	st		X+,reg_init
	ldi		reg_init,0xFF
	st		X+,reg_init
	ldi		reg_init,0x14
	st		X,reg_init
	ldi		XL,LOW(Table)			;load table decod bin to hex (Y = 2^(8-X))
	ldi		XH,HIGH(Table)
	ldi		reg_init,0x80
	st		X+,reg_init
	ldi		reg_init,0x40
	st		X+,reg_init
	ldi		reg_init,0x20
	st		X+,reg_init
	ldi		reg_init,0x10
	st		X+,reg_init
	ldi		reg_init,0x08
	st		X+,reg_init
	ldi		reg_init,0x04
	st		X+,reg_init
	ldi		reg_init,0x02
	st		X+,reg_init
	ldi		reg_init,0x01
	st		X,reg_init
	ldi		reg_init,1
	sts		dead,reg_init			;personnage en vie
	rjmp	CHAR_INC

;--------------------------------
; Nom de la macro : Fenetre_Debut[]
;
; Description : affiche la fenêtre de la vue principale
;
; Entrée : - r19 (reg_addrL) variable de positionnement dans la mémoire SPI (LOW)
;		   - r20 (reg_addrH) variable de positionnement dans la mémoire SPI (HIGH)
;		   - r29 (reg_init) varaible de positionnement du curseur sur l'écran
;
; Sorties : appel la fonction "writeFullSreen" [screen.asm]
;--------------------------------
.macro Fenetre_Debut[]				;affichage de "JOUER / RESEAU / MENTION"
	ldi		reg_addrL,0x00
	ldi		reg_addrH,0x60
	add		reg_addrH,reg_init
	rcall	writeFullSreen

.endmacro

;--------------------------------
; Nom de la macro : CONNECTED[]
;
; Description : affiche la fenêtre de la vue connecté
;
; Entrée : - r19 (reg_addrL) variable de positionnement dans la mémoire SPI (LOW)
;		   - r20 (reg_addrH) variable de positionnement dans la mémoire SPI (HIGH)
;
; Sorties : appel la fonction "writeFullSreen" [screen.asm]
;--------------------------------
.macro CONNECTED[]					;affichage de "connecte"
	ldi		reg_addrL,0x00
	ldi		reg_addrH,0x6C
	rcall	writeFullSreen
.endmacro

;--------------------------------
; Nom de la macro : NO_CONNECTED[]
;
; Description : affiche la fenêtre de la vue non connecté
;
; Entrée : - r19 (reg_addrL) variable de positionnement dans la mémoire SPI (LOW)
;		   - r20 (reg_addrH) variable de positionnement dans la mémoire SPI (HIGH)
;
; Sorties : appel la fonction "writeFullSreen" [screen.asm]
;--------------------------------
.macro NO_CONNECTED[]				;affichage de "non connecte"
	ldi		reg_addrL,0x00
	ldi		reg_addrH,0x70
	rcall	writeFullSreen
.endmacro

;--------------------------------
; Nom de la macro : MENTION_MA[]
;
; Description : affiche la fenêtre de la vue des mentions
;
; Entrée : - r19 (reg_addrL) variable de positionnement dans la mémoire SPI (LOW)
;		   - r20 (reg_addrH) variable de positionnement dans la mémoire SPI (HIGH)
;
; Sorties : appel la fonction "writeFullSreen" [screen.asm]
;--------------------------------
.macro MENTION_MA[]					;affichage des mentions
	ldi		reg_addrL,0x00
	ldi		reg_addrH,0x74
	rcall	writeFullSreen
.endmacro

;--------------------------------
; Nom de la macro : CONN1[]
;
; Description : affiche le premier caractère du chargement de page de ping
;
; Entrée : - r19 (reg_addrL) variable de positionnement dans la mémoire SPI (LOW)
;
; Sorties : appel les fonctions "clearFullSreen" et "writeChar" [screen.asm]
;--------------------------------
.macro CONN1[]						;affichage du chargement pendant le test de connection
	rcall	clearFullSreen
	ldi		reg_addrL,0
	rcall	writeChar
.endmacro

;--------------------------------
; Nom de la macro : CONN2[]
;
; Description : affiche le deuxième caractère du chargement de page de ping
;
; Entrée : - r19 (reg_addrL) variable de positionnement dans la mémoire SPI (LOW)
;
; Sorties : appel la fonction "writeChar" [screen.asm]
;--------------------------------
.macro CONN2[]						;affichage du chargement pendant le test de connection suite
	ldi		reg_addrL,6
	rcall	writeChar
.endmacro

;--------------------------------
; Nom de la macro : CONN3[]
;
; Description : affiche le troisième caractère du chargement de page de ping
;
; Entrée : - r19 (reg_addrL) variable de positionnement dans la mémoire SPI (LOW)
;
; Sorties : appel la fonction "writeChar" [screen.asm]
;--------------------------------
.macro CONN3[]						;affichage du chargement pendant le test de connection suite 2
	ldi		reg_addrL,12
	rcall	writeChar
.endmacro
