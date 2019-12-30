;use r16, r13, r17, r24

csgo_init:
	ldi		r16,0x00
	mov		r13,r16
	ldi		reg_addrL,0xE0				;placement à la case 124 de la mémoire
	ldi		r24,0xE0
	ldi		reg_addrH,0x4B
	rjmp	Affichage_Image
	rjmp	CSGO_INC


	Tourner_Gauche:
	ldi		reg_addrL,0xE0
	ldi		reg_addrH,0x4B
	mov		r16,r13
	subi	r16,-0x01
	sbrc	r16,2
	ldi		r16,0x00
	mov		r13,r16
	rjmp	Affichage_Image
	Tourner_Droite:
	ldi		reg_addrL,0xE0
	ldi		reg_addrH,0x4B
	mov		r16,r13
	subi	r16,0x01
	sbrc	r16,7
	ldi		r16,0x03
	mov		r13,r16
	rjmp	Affichage_Image
Affichage_Image:
	mov		reg_addrL,r24
	mov		r16,r13
	cpi		r16,0x00
	breq	Orientation_Nord
	cpi		r16,0x01
	breq	Orientation_Ouest
	cpi		r16,0x02
	breq	Orientation_Sud
	cpi		r16,0x03
	breq	Orientation_Est
Orientation_Nord:
	subi	reg_addrL,-0x04				;placement à la vue Nord-Ouest
	rcall	Read_Mem					;lecture de la mémoire spi
	mov		r16,reg_spi
	ldi		r17,0x10					;sélection du quartet de l'orientation Nord
	mul		r17,r16
	mov		r16,r1
	rjmp	Determination_Image_1
Orientation_Ouest:
	subi	reg_addrL,-0x04				;placement à la vue Nord-Ouest
	rcall	Read_Mem					;lecture de la mémoire spi
	mov		r16,reg_spi
	andi	r16,0x0F					;sélection du quartet de l'orientation Ouest
	rjmp	Determination_Image_1
Orientation_Sud:
	subi	reg_addrL,-0x05				;placement à la vue Sud-Est
	rcall	Read_Mem					;lecture de la mémoire spi
	mov		r16,reg_spi
	ldi		r17,0x10					;sélection du quartet de l'orientation Sud
	mul		r17,r16
	mov		r16,r1
	rjmp	Determination_Image_1
Orientation_Est:
	subi	reg_addrL,-0x05				;placement à la vue Sud-Est
	rcall	Read_Mem					;lecture de la mémoire spi
	mov		r16,reg_spi
	andi	r16,0x0F					;sélection du quartet de l'orientation Est
	rjmp	Determination_Image_1
Determination_Image_1:
	cpi		r16,0x08					;on vérifie si l'image correspond au code 8 (mur très proche)
	brne	Determination_Image_2		;sinon, on calcule à quelle image correspond le code
	ldi		r16,0x04					;si on est contre un mur proche, on charge le code 0x04
	rjmp	CREATION_IMAGE
Determination_Image_2:
	ldi		r17,0x04					;on regarde à quelle image correspond le code
	mul		r17,r16
	mov		r16,r0
	subi	r16,-0x08
	rjmp	CREATION_IMAGE
CREATION_IMAGE:
	ldi		reg_addrL,0x00				;on va chercher l'image correspondant au code dans la mémoire et on l'affiche
	mov		reg_addrH,r16
	createImgFull[]
	rcall	writeFullSreen
	rjmp	start

