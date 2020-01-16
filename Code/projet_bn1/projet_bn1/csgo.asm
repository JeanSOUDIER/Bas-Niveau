;use r16, r13, r17, r24

csgo_init:
	ldi		r16,0x00					;placement orientation Nord
	sts		orientation,r16
	ldi		r16,0x08					;placement � la case 124 de la m�moire
	sts		numero_mapL,r16
	ldi		r16,0x48
	sts		numero_mapH,r16
	ldi		r16,0x00
	sts		pos_x_adv,r16
	sts		pos_y_adv,r16
	rjmp	Affichage_Image
	rjmp	CSGO_INC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Mouvement du personnage
Avancer:
	lds		reg_addrL,numero_mapL		;on se replace � la case actuelle dans la m�moire
	lds		reg_addrH,numero_mapH
	lds		r16,orientation
	add		reg_addrL,r16				;on se place � la case m�moire qui contient l'adresse de la case qui est en face de nous
	rcall	Read_Mem					;cette adresse vaut 0xFF si on est face � un mur
	mov		r16,reg_spi
	cpi		r16,255						;si la donn�e ne vaut pas 0xFF
	brne	Mouvement_Confirme			;alors on confirme le mouvement et cette donn�e devient la prochaine adresse
	rjmp	start						;sinon on revient au start
Reculer:
	rjmp	start
Mouvement_Confirme:
	ldi		r17,0x08					;on calcule l'adresse de la nouvelle case � partir de son num�ro: addr = 0x4800 + 8*n
	mul		r16,r17
	sts		numero_mapL,r0
	sts		numero_mapH,r1
	ldi		r16,0x48
	lds		reg_calcul1, numero_mapH
	add		reg_calcul1,r16
	sts		numero_mapH,reg_calcul1
	lds		r16,numero_mapH				;on stocke la nouvelle position en x y dans la m�moire
	lds		r17,numero_mapL
	subi	r17,-0x06
	rcall	Read_Mem					;on r�cup�re la position x
	sts		pos_x,reg_spi
	subi	r17,-0x01
	rcall	Read_Mem					;on r�cup�re la position y
	sts		pos_y,reg_spi
	rjmp	Affichage_Image
Tourner_Gauche:
	lds		r16,orientation				;on augmente d'un l'orientation
	subi	r16,-0x01
	sbrc	r16,2
	ldi		r16,0x00
	sts		orientation,r16
	rjmp	Affichage_Image
Tourner_Droite:
	lds		r16,orientation				;on diminue d'un l'orientation
	subi	r16,0x01
	sbrc	r16,7
	ldi		r16,0x03
	sts		orientation,r16
	rjmp	Affichage_Image

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Mise � jour de l'affichage
Affichage_Image:
	lds		reg_addrL,numero_mapL		;on se replace � la case actuelle dans la m�moire
	lds		reg_addrH,numero_mapH
	lds		r16,orientation				;on se place � la bonne orientation
	cpi		r16,0x00
	breq	Orientation_Nord
	cpi		r16,0x01
	breq	Orientation_Ouest
	cpi		r16,0x02
	breq	Orientation_Sud
	cpi		r16,0x03
	breq	Orientation_Est
Orientation_Nord:
	subi	reg_addrL,-0x04				;placement � la vue Nord-Ouest
	rcall	Read_Mem					;lecture de la m�moire spi
	mov		r16,reg_spi
	ldi		r17,0x10					;s�lection du quartet de l'orientation Nord
	mul		r17,r16
	mov		r16,r1
	rjmp	Determination_Image_1
Orientation_Ouest:
	subi	reg_addrL,-0x04				;placement � la vue Nord-Ouest
	rcall	Read_Mem					;lecture de la m�moire spi
	mov		r16,reg_spi
	andi	r16,0x0F					;s�lection du quartet de l'orientation Ouest
	rjmp	Determination_Image_1
Orientation_Sud:
	subi	reg_addrL,-0x05				;placement � la vue Sud-Est
	rcall	Read_Mem					;lecture de la m�moire spi
	mov		r16,reg_spi
	ldi		r17,0x10					;s�lection du quartet de l'orientation Sud
	mul		r17,r16
	mov		r16,r1
	rjmp	Determination_Image_1
Orientation_Est:
	subi	reg_addrL,-0x05				;placement � la vue Sud-Est
	rcall	Read_Mem					;lecture de la m�moire spi
	mov		r16,reg_spi
	andi	r16,0x0F					;s�lection du quartet de l'orientation Est
	rjmp	Determination_Image_1
Determination_Image_1:
	cpi		r16,0x08					;on v�rifie si l'image correspond au code 8 (mur tr�s proche)
	brne	Determination_Image_2		;sinon, on calcule � quelle image correspond le code
	ldi		r16,0x04					;si on est contre un mur proche, on charge le code 0x04
	rjmp	CREATION_IMAGE
Determination_Image_2:
	ldi		r17,0x04					;on regarde � quelle image correspond le code
	mul		r17,r16
	mov		r16,r0
	subi	r16,-0x08
	rjmp	DETECTION_ADVERSAIRE
CREATION_IMAGE:
	ldi		reg_addrL,0x00				;on va chercher l'image correspondant au code dans la m�moire et on l'affiche
	mov		reg_addrH,r16
	rcall	writeFullSreen
	rjmp	start

DETECTION_ADVERSAIRE:
	lds		reg_calcul1,orientation				;on se place � la bonne orientation
	cpi		reg_calcul1,0x00
	breq	Detection_Nord
	cpi		reg_calcul1,0x01
	breq	Detection_Ouest
	cpi		reg_calcul1,0x02
	breq	Detection_Sud
	cpi		reg_calcul1,0x03
	breq	Detection_Est
Detection_Nord:
	lds		reg_calcul1,pos_x
	lds		reg_calcul2,pos_x_adv
	subi	reg_calcul2,-0x01
	cp		reg_calcul1,reg_calcul2
	breq	CI_X_OK
	rjmp	Adversaire_Pas_OK
Detection_Est:
	lds		reg_calcul1,pos_y
	lds		reg_calcul2,pos_y_adv
	subi	reg_calcul2,-0x01
	cp		reg_calcul1,reg_calcul2
	breq	CI_Y_OK
	rjmp	Adversaire_Pas_OK
Detection_Sud:
	lds		reg_calcul1,pos_x
	lds		reg_calcul2,pos_x_adv
	subi	reg_calcul2,0x01
	cp		reg_calcul1,reg_calcul2
	breq	CI_X_OK
	rjmp	Adversaire_Pas_OK
Detection_Ouest:
	lds		reg_calcul1,pos_y
	lds		reg_calcul1,pos_y_adv
	subi	reg_calcul2,0x01
	cp		reg_calcul1,reg_calcul2
	breq	CI_Y_OK
	rjmp	Adversaire_Pas_OK
CI_X_OK:
	lds		reg_calcul1,pos_y
	lds		reg_calcul2,pos_y_adv
	cp		reg_calcul1,reg_calcul2
	breq	Adversaire_OK
	rjmp	Adversaire_Pas_OK
CI_Y_OK:
	lds		reg_calcul1,pos_x
	lds		reg_calcul2,pos_x_adv
	cp		reg_calcul1,reg_calcul2
	breq	Adversaire_OK
	rjmp	Adversaire_Pas_OK
Adversaire_OK:
	ldi		reg_calcul1,0x01
	sts		adv_ok,reg_calcul1
	subi	r16,-0x20
	rjmp	CREATION_IMAGE
Adversaire_Pas_OK:
	ldi		reg_calcul1,0x00
	sts		adv_ok,reg_calcul1
	rjmp	CREATION_IMAGE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Attaque de la cible
ATTAQUER:
	lds		r16,adv_ok
	cpi		r16,0x01
	breq	ON_ENVOIE_LA_SAUCE
	rjmp	start
ON_ENVOIE_LA_SAUCE:
	;on envoie par bluetooth le signal de fin de jeu
	;on affiche l'�cran de victoire