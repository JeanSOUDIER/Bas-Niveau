;********************************
; Programme du jeu entre 2 Gameboy connectées en bluetooth (électif bas niveau) [fichier de gestion de l'écran]
;
; Fichier : screen.asm
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
; Nom de la macro : screenL[]
;
; Description : sélectionne le côté de l'écran gauche
;
; Entrée : X
;
; Sorties : X
;--------------------------------
.macro screenL[]					;choix du côté de l'écran à gauche
	sbi		PORTB,0
	cbi		PORTB,1
.endmacro

;--------------------------------
; Nom de la macro : screenR[]
;
; Description : sélectionne le côté de l'écran droit
;
; Entrée : X
;
; Sorties : X
;--------------------------------
.macro screenR[]					;choix du côté de l'écran à droite
	sbi		PORTB,1
	cbi		PORTB,0
.endmacro

;--------------------------------
; Nom de la macro : Enable[]
;
; Description : valide la donnée sur le port de l'écran
;
; Entrée : - r17 (reg_cpt3) compteur de temporaisation
;
; Sorties : appel la fonction "tempo_US" [screen.asm]
;--------------------------------
.macro Enable[]						;validation de la commande sur l'écran
	cbi		PORTB,3
	ldi		reg_cpt3,250
	rcall	tempo_US
	sbi		PORTB,3
.endmacro

;--------------------------------
; Nom de la macro : SetPosX[]
;
; Description : place le curseur sur l'écran en X
;
; Entrée : - r17 (reg_cpt3) compteur de temporaisation
;		   - r17 (reg_screen) variable de l'écran => position de 0 à 7
;
; Sorties : appel les macros "RS_clear[]", "Enable[]" et "RS_set[]" [screen.asm]
;--------------------------------
.macro SetPosX[]					;pos de 0 à 7 (à changer à chaque fois)
	RS_clear[]
	ori		reg_screen,0xB8
	out		PORTC,reg_screen
	Enable[]
	RS_set[]
.endmacro

;--------------------------------
; Nom de la macro : SetPosY[]
;
; Description : place le curseur sur l'écran en Y
;
; Entrée : - r17 (reg_cpt3) compteur de temporaisation
;		   - r17 (reg_screen) variable de l'écran => position de 0 à 64
;
; Sorties : appel les macros "RS_clear[]", "Enable[]" et "RS_set[]" [screen.asm]
;--------------------------------
.macro SetPosY[]					;pos de 0 à 64 (auto)
	RS_clear[]
	ori		reg_screen,0x40
	out		PORTC,reg_screen
	Enable[]
	RS_set[]
.endmacro

;--------------------------------
; Nom de la macro : RS_clear[]
;
; Description : active le mode instruction sur l'écran
;
; Entrée : X
;
; Sorties : X
;--------------------------------
.macro RS_clear[]					;changement de bit instruction/données
	cbi		PORTB,2
.endmacro

;--------------------------------
; Nom de la macro : RS_set[]
;
; Description : active le mode données sur l'écran
;
; Entrée : X
;
; Sorties : X
;--------------------------------
.macro RS_set[]						;changement de bit instruction/données
	sbi		PORTB,2
.endmacro

;--------------------------------
; Nom de la macro : ScreenWrite[]
;
; Description : écrit une donnée sur l'écran
;
; Entrée : - r17 (reg_screen) variable de l'écran
;
; Sorties : appel la macro "Enable[]" [screen.asm]
;--------------------------------
.macro ScreenWrite[]				;affichage sur l'écran
	out		PORTC,reg_screen
	Enable[]
.endmacro

;--------------------------------
; Nom de la macro : placePosPerso[]
;
; Description : convertie la position du X/Y du personnage en adresse et pixels
;
; Entrée : - r17 (reg_screen) variable de l'écran
;		   - r28 (reg_calcul1) variable temporaire
;		   - Table (SRAM) table de convertion pour le binaire vers la pixel à allumer
;		   - PosX (SRAM) de 0 à 20
;		   - PosY (SRAM) de 0 à 20
;		   - XL (r26) registre interne pour se déplacer la la SRAM
;		   - XH (r27)
;
; Sorties : - conv (SRAM) valeur sur 8 bits qui correspond au pixel à allumer
;		    - conv2 (SRAM) positionnement en X
;			- convB (SRAM) positionnement en Y
;--------------------------------
.macro placePosPerso[]				;converti la position xy du personnage pour faire un test à l'affichage sur l'ecran
	lds		reg_screen,pos_x
	mov		reg_calcul1,reg_screen	;test Y
	andi	reg_screen,7
	ldi		XL,LOW(Table)			;table de convertion 2^(8-X) = Y
	ldi		XH,HIGH(Table)
	add		XL,reg_screen			;test X
	ld		reg_screen,X
	sts		conv,reg_screen

	ldi		reg_screen,255			;convertion des positions par 8 pixels
	cpi		reg_calcul1,8
	brlo	END_PERSO
	cpi		reg_calcul1,16
	ldi		reg_screen,191
	brlo	END_PERSO
	ldi		reg_screen,127
END_PERSO:
	lds		reg_calcul1,pos_y
	sub		reg_screen,reg_calcul1	;affectation de la SRAM
	sts		convB,reg_screen
	lds		reg_calcul1,pos_x
	ldi		reg_screen,7
	cpi		reg_calcul1,8
	brlo	END_PERSO2
	cpi		reg_calcul1,16
	ldi		reg_screen,6
	brlo	END_PERSO2
	ldi		reg_screen,5
END_PERSO2:
	sts		conv2,reg_screen
.endmacro

;--------------------------------
; Nom de la macro : SetPosPerso[]
;
; Description : allume le pixel de la position du personnage
;
; Entrée : - r17 (reg_screen) variable de l'écran
;		   - r28 (reg_calcul1) variable temporaire
;		   - r24 (reg_spi) registre de réception des données de la mémoire SPI
;		   - r21 (reg_cpt1) compteur d'affichage Y
;		   - r22 (reg_cpt2) compteur d'affichage X
;		   - PosX (SRAM) 0xFF pour iniber la fonction
;		   - conv (SRAM) valeur sur 8 bits qui correspond au pixel à allumer
;		   - conv2 (SRAM) positionnement en X
;		   - convB (SRAM) positionnement en Y
;
; Sorties : - si(PosX != 0xFF) (reg_spi | conv)
;--------------------------------
.macro SetPosPerso[]				;affiche le point à l'endroit calculé
	lds		reg_calcul1,pos_x
	cpi		reg_calcul1,255
	breq	END_SetPerso
	lds		reg_screen,conv2
	cp		reg_cpt2,reg_screen		;comparaison en X
	brne	END_SetPerso
	lds		reg_screen,convB
	andi	reg_screen,0x3F
	cp		reg_cpt1,reg_screen		;comparaison en Y
	brne	END_SetPerso
	lds		reg_screen,conv
	or		reg_spi,reg_screen		;affectation
END_SetPerso:
.endmacro

;--------------------------------
; Nom de la macro : ClearPosPerso[]
;
; Description : éteint le pixel de la position du personnage
;
; Entrée : - r17 (reg_screen) variable de l'écran
;		   - r28 (reg_calcul1) variable temporaire
;		   - r24 (reg_spi) registre de réception des données de la mémoire SPI
;		   - r21 (reg_cpt1) compteur d'affichage Y
;		   - r22 (reg_cpt2) compteur d'affichage X
;		   - PosX (SRAM) 0xFF pour iniber la fonction
;		   - conv (SRAM) valeur sur 8 bits qui correspond au pixel à allumer
;		   - conv2 (SRAM) positionnement en X
;		   - convB (SRAM) positionnement en Y
;
; Sorties : - reg_spi & ~conv
;--------------------------------
.macro ClearPosPerso[]				;efface le point à l'endroit calculé
	lds		reg_screen,conv2
	cp		reg_cpt2,reg_screen		;comparaison en X
	brne	END_ClearPerso
	lds		reg_screen,convB
	andi	reg_screen,0x3F
	cp		reg_cpt1,reg_screen		;comparaison en Y
	brne	END_ClearPerso
	lds		reg_screen,conv
	com		reg_screen
	and		reg_spi,reg_screen		;affectation
END_ClearPerso:
.endmacro

;--------------------------------
; Nom de la fonction : SCREEN_Init
;
; Description : intialise l'écran
;
; Entrée : - r17 (reg_screen) variable de gestion de l'écran
;
; Sorties : appel les macros "Enable[]" et "RS_set[]" [screen.asm]
;--------------------------------
SCREEN_Init:
	sbi		PORTB,3					;set E and clear RS
	cbi		PORTB,2
	ldi		reg_screen,63			;instruction de début de l'écran pour activer l'affichage
	out		PORTC,reg_screen
	Enable[]						;validation
	RS_set[]						;mode données
	rjmp	SCREEN_INC

;--------------------------------
; Nom de la fonction : tempo_US
;
; Description : crée une attente
;
; Entrée : - r17 (reg_cpt3) variable de comptage
;
; Sorties : X
;--------------------------------
tempo_US:							;boucle de temporisation
	dec		reg_cpt3
	nop
	brne	tempo_US
	ret

;--------------------------------
; Nom de la fonction : writeFullSreen
;
; Description : affiche 1k mémoire EEPROM SPI sur l'écran
;
; Entrée : - r17 (reg_screen) variable de l'écran
;		   - r21 (reg_cpt1) compteur d'affichage Y
;		   - r22 (reg_cpt2) compteur d'affichage X
;		   - r19 (reg_addrL) variable de positionnement dans la mémoire SPI (LOW)
;		   - r20 (reg_addrH) variable de positionnement dans la mémoire SPI (HIGH)
;		   - r24 (reg_spi) registre de réception des données de la mémoire SPI
;
; Sorties : appel les macros "placePosPerso[]", "screenR[]", "SetPosY[]", "SetPosX[]", "ScreenWrite[]", "screenL[]", "SetPosPerso[]" et "ClearPosPerso[]" [screen.asm]
;--------------------------------
writeFullSreen:						;fonction d'affichage de la mémoire SPI vers l'écran
	placePosPerso[]
	screenR[]						;set side screen
	ldi		reg_cpt2,0				;reset var
loop1:
	ldi		reg_cpt1,0
	ldi		reg_screen,0			;set pos Y = 0
	SetPosY[]
	mov		reg_screen,reg_cpt2		;set pos X = reg_cpt2
	SetPosX[]
loop2:
	rcall	Read_Mem				;lecture de la mémoire spi
	mov		reg_screen,reg_spi
	ScreenWrite[]					;écriture sur l'écran
	inc		reg_addrL				;incrément de l'adresse LOW
	cpi		reg_addrL,0
	brne	addr_carry1				;test du carry
	inc		reg_addrH
addr_carry1:

	inc		reg_cpt1				;incrément du compteur 1
	sbrs	reg_cpt1,6				;test de fin de boucle = 64
	rjmp	loop2

	inc		reg_cpt2				;incrément du copteur 2
	sbrs	reg_cpt2,3				;test de fin de boucle = 8
	rjmp	loop1

	screenL[]						;set side screen
	ldi		reg_cpt2,0				;reset var
loop3:
	ldi		reg_cpt1,0
	ldi		reg_screen,0			;set pos Y = 0
	SetPosY[]
	mov		reg_screen,reg_cpt2		;set pos X = reg_cpt2
	SetPosX[]
loop4:
	rcall	Read_Mem				;lecture de la mémoire spi
	cpi		reg_cptT0,8
	brsh	PRINT
	ClearPosPerso[]
PRINT:
	cpi		reg_cptT0,8
	brlo	PRINT1
	SetPosPerso[]
PRINT1:
	mov		reg_screen,reg_spi
	ScreenWrite[]					;écriture sur l'écran
	inc		reg_addrL				;incrément de l'adresse LOW
	cpi		reg_addrL,0
	brne	addr_carry2				;test du carry
	inc		reg_addrH
addr_carry2:

	inc		reg_cpt1				;incrément du compteur 1
	sbrs	reg_cpt1,6				;test de fin de boucle = 64
	rjmp	loop4

	inc		reg_cpt2				;incrément du copteur 2
	sbrs	reg_cpt2,3				;test de fin de boucle = 8
	rjmp	loop3
	ret

;--------------------------------
; Nom de la fonction : clearFullSreen
;
; Description : efface l'écran
;
; Entrée : - r17 (reg_screen) variable de l'écran
;		   - r21 (reg_cpt1) compteur d'affichage Y
;		   - r22 (reg_cpt2) compteur d'affichage X
;
; Sorties : appel les macros "screenR[]", "SetPosY[]", "SetPosX[]", "ScreenWrite[]" et "screenL[]" [screen.asm]
;--------------------------------
clearFullSreen:						;fonction pour effacer l'écran (ressemble beaucoup à "writeFullSreen")
	screenR[]						;set side screen
	ldi		reg_cpt2,0				;reset var
loop5:
	ldi		reg_cpt1,0
	ldi		reg_screen,0			;set pos Y = 0
	SetPosY[]
	mov		reg_screen,reg_cpt2		;set pos X = reg_cpt2
	SetPosX[]
loop6:
	ldi		reg_screen,0
	ScreenWrite[]					;écriture sur l'écran

	inc		reg_cpt1				;incrément du compteur 1
	sbrs	reg_cpt1,6				;test de fin de boucle = 64
	rjmp	loop6

	inc		reg_cpt2				;incrément du copteur 2
	sbrs	reg_cpt2,3				;test de fin de boucle = 8
	rjmp	loop5

	screenL[]						;set side screen
	ldi		reg_cpt2,0				;reset var
loop7:
	ldi		reg_cpt1,0
	ldi		reg_screen,0			;set pos Y = 0
	SetPosY[]
	mov		reg_screen,reg_cpt2		;set pos X = reg_cpt2
	SetPosX[]
loop8:
	ldi		reg_screen,0
	ScreenWrite[]					;écriture sur l'écran

	inc		reg_cpt1				;incrément du compteur 1
	sbrs	reg_cpt1,6				;test de fin de boucle = 64
	rjmp	loop8

	inc		reg_cpt2				;incrément du copteur 2
	sbrs	reg_cpt2,3				;test de fin de boucle = 8
	rjmp	loop7
	ret

;--------------------------------
; Nom de la fonction : writeChar
;
; Description : efface l'écran
;
; Entrée : - r17 (reg_screen) variable de l'écran
;		   - r21 (reg_cpt1) compteur d'affichage Y
;		   - r22 (reg_cpt2) compteur d'affichage X
;		   - C_Wait (SRAM) caractère d'attente du ping
;		   - XL (r26) registre interne pour se déplacer la la SRAM
;		   - XH (r27)
;		   - r19 (reg_addrL) variable de positionnement dans la mémoire SPI (LOW)
;
; Sorties : appel les macros "SetPosY[]", "SetPosX[]", "ScreenWrite[]" et "screenL[]" [screen.asm]
;--------------------------------
writeChar:							;affiche un caractère de la SRAM sur l'écran
	screenL[]
	ldi		reg_screen,10
	add		reg_screen,reg_addrL	;placement sur l'écran
	SetPosY[]
	ldi		reg_screen,4
	SetPosX[]
	ldi		XL,LOW(C_Wait)			;placement dans la SRAM
	ldi		XH,HIGH(C_Wait)
	ld		reg_screen,X+			;affichage du caractère en 5*8
	ScreenWrite[]
	ld		reg_screen,X+
	ScreenWrite[]
	ld		reg_screen,X+
	ScreenWrite[]
	ld		reg_screen,X+
	ScreenWrite[]
	ld		reg_screen,X+
	ScreenWrite[]
	ret