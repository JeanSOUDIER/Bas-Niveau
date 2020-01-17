csgo_init:
	ldi		r16,0x01
	sts		pos_y,r16					;intialisation de la position du personnage
	ldi		r16,255
	sts		pos_x,r16
	rjmp	CSGO_INC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Mouvement du personnage
Avancer:
	lds		reg_addrL,numero_mapL		;on se replace à la case actuelle dans la mémoire
	lds		reg_addrH,numero_mapH
	lds		r16,orientation
	add		reg_addrL,r16				;on se place à la case mémoire qui contient l'adresse de la case qui est en face de nous
	rcall	Read_Mem					;cette adresse vaut 0xFF si on est face à un mur
	mov		r16,reg_spi
	cpi		r16,255						;si la donnée ne vaut pas 0xFF
	brne	Mouvement_Confirme			;alors on confirme le mouvement et cette donnée devient la prochaine adresse
	rjmp	Jeu_En_Cours				;sinon on revient au Jeu_En_Cours
Mouvement_Confirme:
	ldi		r17,0x08					;on calcule l'adresse de la nouvelle case à partir de son numéro: addr = 0x4800 + 8*n
	mul		r16,r17
	sts		numero_mapL,r0
	sts		numero_mapH,r1
	ldi		r16,0x48
	lds		reg_cpt1, numero_mapH
	add		reg_cpt1,r16
	sts		numero_mapH,reg_cpt1
	lds		reg_addrH,numero_mapH		;on stocke la nouvelle position en x y de la mémoire spi vers la ram et on l'enovie par bluetooth
	lds		reg_addrL,numero_mapL
	subi	reg_addrL,-0x06
	rcall	Read_Mem					;on récupère la position x
	sts		pos_x,reg_spi
	mov		reg_TX,reg_spi				;on envoie la position x par bluetooth
	ori		reg_TX,0x80					;code pour la position x
	rcall	USART_Transmit
	subi	reg_addrL,-0x01
	rcall	Read_Mem					;on récupère la position y
	sts		pos_y,reg_spi
	mov		reg_TX,reg_spi				;on envoie la position y par bluetooth
	ori		reg_TX,0x40					;code pour la position y
	rcall	USART_Transmit
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Mise à jour de l'affichage
Affichage_Image:
	lds		reg_addrL,numero_mapL		;on se replace à la case actuelle dans la mémoire
	lds		reg_addrH,numero_mapH
	lds		r16,orientation				;on se place à la bonne orientation
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
	rjmp	Adversaire_Pas_OK			;on va au code adversaire pas ok pour éviter un bug de victoire en tapant dans un mur
Determination_Image_2:
	ldi		r17,0x04					;on regarde à quelle image correspond le code
	mul		r17,r16
	mov		r16,r0
	subi	r16,-0x08
	rjmp	DETECTION_ADVERSAIRE
CREATION_IMAGE:
	ldi		reg_addrL,0x00				;on va chercher l'image correspondant au code dans la mémoire et on l'affiche
	mov		reg_addrH,r16
	rcall	writeFullSreen
	rjmp	Jeu_En_Cours

DETECTION_ADVERSAIRE:
	lds		reg_cpt1,orientation		;on se place à la bonne orientation
	cpi		reg_cpt1,0x00
	breq	Detection_Nord
	cpi		reg_cpt1,0x01
	breq	Detection_Ouest
	cpi		reg_cpt1,0x02
	breq	Detection_Sud
	cpi		reg_cpt1,0x03
	breq	Detection_Est
Detection_Nord:							;on doit avoir pos_y = pos_y_adv et pos_x = pos_x_adv + 1
	lds		reg_cpt1,pos_x			
	lds		reg_cpt2,pos_x_adv
	subi	reg_cpt2,-0x01
	cp		reg_cpt1,reg_cpt2
	breq	CI_X_OK  
	rjmp	Adversaire_Pas_OK
Detection_Ouest:						;on doit avoir pos_x = pos_x_adv et pos_y = pos_y_adv + 1
	lds		reg_cpt1,pos_y
	lds		reg_cpt2,pos_y_adv
	subi	reg_cpt2,-0x01
	cp		reg_cpt1,reg_cpt2
	breq	CI_Y_OK
	rjmp	Adversaire_Pas_OK
Detection_Sud:							;on doit avoir pos_y = pos_y_adv et pos_x = pos_x_adv - 1
	lds		reg_cpt1,pos_x
	lds		reg_cpt2,pos_x_adv
	subi	reg_cpt2,0x01
	cp		reg_cpt1,reg_cpt2
	breq	CI_X_OK
	rjmp	Adversaire_Pas_OK
Detection_Est:							;on doit avoir pos_x = pos_x_adv et pos_y = pos_y_adv - 1
	lds		reg_cpt1,pos_y
	lds		reg_cpt2,pos_y_adv
	subi	reg_cpt2,0x01
	cp		reg_cpt1,reg_cpt2
	breq	CI_Y_OK
	rjmp	Adversaire_Pas_OK
CI_X_OK:
	lds		reg_cpt1,pos_y
	lds		reg_cpt2,pos_y_adv
	cp		reg_cpt1,reg_cpt2
	breq	Adversaire_OK
	rjmp	Adversaire_Pas_OK
CI_Y_OK:
	lds		reg_cpt1,pos_x
	lds		reg_cpt2,pos_x_adv
	cp		reg_cpt1,reg_cpt2
	breq	Adversaire_OK
	rjmp	Adversaire_Pas_OK
Adversaire_OK:
	ldi		reg_cpt1,0x01
	sts		adv_ok,reg_cpt1
	subi	r16,-0x20
	rjmp	CREATION_IMAGE
Adversaire_Pas_OK:
	ldi		reg_cpt1,0x00
	sts		adv_ok,reg_cpt1
	rjmp	CREATION_IMAGE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Attaque de la cible
Attaquer:
	ldi		r16,0
	sts		num_son2,r16

	lds		r16,adv_ok
	sbrs	r16,0
	rjmp	Jeu_En_Cours
ON_ENVOIE_LA_SAUCE:
	ldi		reg_TX,0x00			;on envoie par bluetooth le signal de fin de jeu
	rcall	USART_Transmit
	ldi		reg_addrL,0x00		;on affiche l'écran de victoire
	ldi		reg_addrH,0x5C
	rcall	writeFullSreen
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
	ldi		reg_cpt3,255
	rcall	tempo_MS
	jmp	GAME
	
	