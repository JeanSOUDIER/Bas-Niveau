;use r16, r13, r17, r24

csgo_init:
	ldi		r16,0x00					;placement orientation Nord
	mov		reg_csgo_orientation,r16
	ldi		r16,0x00					;placement à la case 124 de la mémoire
	mov		reg_csgo_mapL,r16
	ldi		r16,0x48
	mov		reg_csgo_mapH,r16
	rjmp	Affichage_Image
	rjmp	CSGO_INC


Avancer:
	mov		reg_addrL,reg_csgo_mapL		;on se replace à la case actuelle dans la mémoire
	mov		reg_addrH,reg_csgo_mapH
	add		reg_addrL,reg_csgo_orientation	;on se place à la case mémoire qui contient l'adresse de la case qui est en face de nous
	rcall	Read_Mem					;cette adresse vaut 0xFF si on est face à un mur
	mov		r16,reg_spi
	cpi		r16,255						;si la donnée ne vaut pas 0xFF
	brne	Mouvement_Confirme			;alors on confirme le mouvement et cette donnée devient la prochaine adresse
	rjmp	start						;sinon on revient au start
Reculer:
	rjmp	start
Mouvement_Confirme:
	ldi		r17,0x08					;on calcule l'adresse de la nouvelle case à partir de son numéro: addr = 0x4800 + 8*n
	mul		r16,r17
	movw	reg_csgo_mapL,r0
	ldi		r16,0x48
	add		reg_csgo_mapH,r16
	rjmp	Affichage_Image
Tourner_Gauche:
	mov		r16,reg_csgo_orientation	;on augmente d'un l'orientation
	subi	r16,-0x01
	sbrc	r16,2
	ldi		r16,0x00
	mov		reg_csgo_orientation,r16
	rjmp	Affichage_Image
Tourner_Droite:
	mov		r16,reg_csgo_orientation	;on diminue d'un l'orientation
	subi	r16,0x01
	sbrc	r16,7
	ldi		r16,0x03
	mov		reg_csgo_orientation,r16
	rjmp	Affichage_Image
Affichage_Image:
	mov		reg_addrL,reg_csgo_mapL		;on se replace à la case actuelle dans la mémoire
	mov		reg_addrH,reg_csgo_mapH
	mov		r16,reg_csgo_orientation	;on se place à la bonne orientation
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

