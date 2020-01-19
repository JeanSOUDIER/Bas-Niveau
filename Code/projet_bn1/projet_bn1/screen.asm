;********************************
; Programme du jeu entre 2 Gameboy connect�es en bluetooth (�lectif bas niveau) [fichier de gestion de l'�cran]
;
; Fichier : screen.asm
;
; Microcontr�leur Atmega16A
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
; Description : s�lectionne le c�t� de l'�cran gauche
;
; Entr�e : X
;
; Sorties : X
;--------------------------------
.macro screenL[]					;choix du c�t� de l'�cran � gauche
	sbi		PORTB,0
	cbi		PORTB,1
.endmacro

;--------------------------------
; Nom de la macro : screenR[]
;
; Description : s�lectionne le c�t� de l'�cran droit
;
; Entr�e : X
;
; Sorties : X
;--------------------------------
.macro screenR[]					;choix du c�t� de l'�cran � droite
	sbi		PORTB,1
	cbi		PORTB,0
.endmacro

;--------------------------------
; Nom de la macro : Enable[]
;
; Description : valide la donn�e sur le port de l'�cran
;
; Entr�e : - r17 (reg_cpt3) compteur de temporaisation
;
; Sorties : appel la fonction "tempo_US" [screen.asm]
;--------------------------------
.macro Enable[]						;validation de la commande sur l'�cran
	cbi		PORTB,3
	ldi		reg_cpt3,250
	rcall	tempo_US
	sbi		PORTB,3
.endmacro

;--------------------------------
; Nom de la macro : SetPosX[]
;
; Description : place le curseur sur l'�cran en X
;
; Entr�e : - r17 (reg_cpt3) compteur de temporaisation
;		   - r17 (reg_screen) variable de l'�cran => position de 0 � 7
;
; Sorties : appel les macros "RS_clear[]", "Enable[]" et "RS_set[]" [screen.asm]
;--------------------------------
.macro SetPosX[]					;pos de 0 � 7 (� changer � chaque fois)
	RS_clear[]
	ori		reg_screen,0xB8
	out		PORTC,reg_screen
	Enable[]
	RS_set[]
.endmacro

;--------------------------------
; Nom de la macro : SetPosY[]
;
; Description : place le curseur sur l'�cran en Y
;
; Entr�e : - r17 (reg_cpt3) compteur de temporaisation
;		   - r17 (reg_screen) variable de l'�cran => position de 0 � 64
;
; Sorties : appel les macros "RS_clear[]", "Enable[]" et "RS_set[]" [screen.asm]
;--------------------------------
.macro SetPosY[]					;pos de 0 � 64 (auto)
	RS_clear[]
	ori		reg_screen,0x40
	out		PORTC,reg_screen
	Enable[]
	RS_set[]
.endmacro

;--------------------------------
; Nom de la macro : RS_clear[]
;
; Description : active le mode instruction sur l'�cran
;
; Entr�e : X
;
; Sorties : X
;--------------------------------
.macro RS_clear[]					;changement de bit instruction/donn�es
	cbi		PORTB,2
.endmacro

;--------------------------------
; Nom de la macro : RS_set[]
;
; Description : active le mode donn�es sur l'�cran
;
; Entr�e : X
;
; Sorties : X
;--------------------------------
.macro RS_set[]						;changement de bit instruction/donn�es
	sbi		PORTB,2
.endmacro

;--------------------------------
; Nom de la macro : ScreenWrite[]
;
; Description : �crit une donn�e sur l'�cran
;
; Entr�e : - r17 (reg_screen) variable de l'�cran
;
; Sorties : appel la macro "Enable[]" [screen.asm]
;--------------------------------
.macro ScreenWrite[]				;affichage sur l'�cran
	out		PORTC,reg_screen
	Enable[]
.endmacro

;--------------------------------
; Nom de la macro : placePosPerso[]
;
; Description : convertie la position du X/Y du personnage en adresse et pixels
;
; Entr�e : - r17 (reg_screen) variable de l'�cran
;		   - r28 (reg_calcul1) variable temporaire
;		   - Table (SRAM) table de convertion pour le binaire vers la pixel � allumer
;		   - PosX (SRAM) de 0 � 20
;		   - PosY (SRAM) de 0 � 20
;		   - XL (r26) registre interne pour se d�placer la la SRAM
;		   - XH (r27)
;
; Sorties : - conv (SRAM) valeur sur 8 bits qui correspond au pixel � allumer
;		    - conv2 (SRAM) positionnement en X
;			- convB (SRAM) positionnement en Y
;--------------------------------
.macro placePosPerso[]				;converti la position xy du personnage pour faire un test � l'affichage sur l'ecran
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
; Entr�e : - r17 (reg_screen) variable de l'�cran
;		   - r28 (reg_calcul1) variable temporaire
;		   - r24 (reg_spi) registre de r�ception des donn�es de la m�moire SPI
;		   - r21 (reg_cpt1) compteur d'affichage Y
;		   - r22 (reg_cpt2) compteur d'affichage X
;		   - PosX (SRAM) 0xFF pour iniber la fonction
;		   - conv (SRAM) valeur sur 8 bits qui correspond au pixel � allumer
;		   - conv2 (SRAM) positionnement en X
;		   - convB (SRAM) positionnement en Y
;
; Sorties : - si(PosX != 0xFF) (reg_spi | conv)
;--------------------------------
.macro SetPosPerso[]				;affiche le point � l'endroit calcul�
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
; Description : �teint le pixel de la position du personnage
;
; Entr�e : - r17 (reg_screen) variable de l'�cran
;		   - r28 (reg_calcul1) variable temporaire
;		   - r24 (reg_spi) registre de r�ception des donn�es de la m�moire SPI
;		   - r21 (reg_cpt1) compteur d'affichage Y
;		   - r22 (reg_cpt2) compteur d'affichage X
;		   - PosX (SRAM) 0xFF pour iniber la fonction
;		   - conv (SRAM) valeur sur 8 bits qui correspond au pixel � allumer
;		   - conv2 (SRAM) positionnement en X
;		   - convB (SRAM) positionnement en Y
;
; Sorties : - reg_spi & ~conv
;--------------------------------
.macro ClearPosPerso[]				;efface le point � l'endroit calcul�
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
; Description : intialise l'�cran
;
; Entr�e : - r17 (reg_screen) variable de gestion de l'�cran
;
; Sorties : appel les macros "Enable[]" et "RS_set[]" [screen.asm]
;--------------------------------
SCREEN_Init:
	sbi		PORTB,3					;set E and clear RS
	cbi		PORTB,2
	ldi		reg_screen,63			;instruction de d�but de l'�cran pour activer l'affichage
	out		PORTC,reg_screen
	Enable[]						;validation
	RS_set[]						;mode donn�es
	rjmp	SCREEN_INC

;--------------------------------
; Nom de la fonction : tempo_US
;
; Description : cr�e une attente
;
; Entr�e : - r17 (reg_cpt3) variable de comptage
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
; Description : affiche 1k m�moire EEPROM SPI sur l'�cran
;
; Entr�e : - r17 (reg_screen) variable de l'�cran
;		   - r21 (reg_cpt1) compteur d'affichage Y
;		   - r22 (reg_cpt2) compteur d'affichage X
;		   - r19 (reg_addrL) variable de positionnement dans la m�moire SPI (LOW)
;		   - r20 (reg_addrH) variable de positionnement dans la m�moire SPI (HIGH)
;		   - r24 (reg_spi) registre de r�ception des donn�es de la m�moire SPI
;
; Sorties : appel les macros "placePosPerso[]", "screenR[]", "SetPosY[]", "SetPosX[]", "ScreenWrite[]", "screenL[]", "SetPosPerso[]" et "ClearPosPerso[]" [screen.asm]
;--------------------------------
writeFullSreen:						;fonction d'affichage de la m�moire SPI vers l'�cran
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
	rcall	Read_Mem				;lecture de la m�moire spi
	mov		reg_screen,reg_spi
	ScreenWrite[]					;�criture sur l'�cran
	inc		reg_addrL				;incr�ment de l'adresse LOW
	cpi		reg_addrL,0
	brne	addr_carry1				;test du carry
	inc		reg_addrH
addr_carry1:

	inc		reg_cpt1				;incr�ment du compteur 1
	sbrs	reg_cpt1,6				;test de fin de boucle = 64
	rjmp	loop2

	inc		reg_cpt2				;incr�ment du copteur 2
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
	rcall	Read_Mem				;lecture de la m�moire spi
	cpi		reg_cptT0,8
	brsh	PRINT
	ClearPosPerso[]
PRINT:
	cpi		reg_cptT0,8
	brlo	PRINT1
	SetPosPerso[]
PRINT1:
	mov		reg_screen,reg_spi
	ScreenWrite[]					;�criture sur l'�cran
	inc		reg_addrL				;incr�ment de l'adresse LOW
	cpi		reg_addrL,0
	brne	addr_carry2				;test du carry
	inc		reg_addrH
addr_carry2:

	inc		reg_cpt1				;incr�ment du compteur 1
	sbrs	reg_cpt1,6				;test de fin de boucle = 64
	rjmp	loop4

	inc		reg_cpt2				;incr�ment du copteur 2
	sbrs	reg_cpt2,3				;test de fin de boucle = 8
	rjmp	loop3
	ret

;--------------------------------
; Nom de la fonction : clearFullSreen
;
; Description : efface l'�cran
;
; Entr�e : - r17 (reg_screen) variable de l'�cran
;		   - r21 (reg_cpt1) compteur d'affichage Y
;		   - r22 (reg_cpt2) compteur d'affichage X
;
; Sorties : appel les macros "screenR[]", "SetPosY[]", "SetPosX[]", "ScreenWrite[]" et "screenL[]" [screen.asm]
;--------------------------------
clearFullSreen:						;fonction pour effacer l'�cran (ressemble beaucoup � "writeFullSreen")
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
	ScreenWrite[]					;�criture sur l'�cran

	inc		reg_cpt1				;incr�ment du compteur 1
	sbrs	reg_cpt1,6				;test de fin de boucle = 64
	rjmp	loop6

	inc		reg_cpt2				;incr�ment du copteur 2
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
	ScreenWrite[]					;�criture sur l'�cran

	inc		reg_cpt1				;incr�ment du compteur 1
	sbrs	reg_cpt1,6				;test de fin de boucle = 64
	rjmp	loop8

	inc		reg_cpt2				;incr�ment du copteur 2
	sbrs	reg_cpt2,3				;test de fin de boucle = 8
	rjmp	loop7
	ret

;--------------------------------
; Nom de la fonction : writeChar
;
; Description : efface l'�cran
;
; Entr�e : - r17 (reg_screen) variable de l'�cran
;		   - r21 (reg_cpt1) compteur d'affichage Y
;		   - r22 (reg_cpt2) compteur d'affichage X
;		   - C_Wait (SRAM) caract�re d'attente du ping
;		   - XL (r26) registre interne pour se d�placer la la SRAM
;		   - XH (r27)
;		   - r19 (reg_addrL) variable de positionnement dans la m�moire SPI (LOW)
;
; Sorties : appel les macros "SetPosY[]", "SetPosX[]", "ScreenWrite[]" et "screenL[]" [screen.asm]
;--------------------------------
writeChar:							;affiche un caract�re de la SRAM sur l'�cran
	screenL[]
	ldi		reg_screen,10
	add		reg_screen,reg_addrL	;placement sur l'�cran
	SetPosY[]
	ldi		reg_screen,4
	SetPosX[]
	ldi		XL,LOW(C_Wait)			;placement dans la SRAM
	ldi		XH,HIGH(C_Wait)
	ld		reg_screen,X+			;affichage du caract�re en 5*8
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