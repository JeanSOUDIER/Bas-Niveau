;use r20 and r21 and r23 and r24

.def reg_bt1 = r20
.def reg_bt2 = r21
.def reg_vol = r23
.def reg_son = r24

.macro b0[]								;macro test bouton 0 vrai
 sbrc	reg_bt1,1
.endmacro
.macro b0n[]							;macro test bouton 0 faux
 sbrs	reg_bt1,1
.endmacro
.macro b1[]
 sbrc	reg_bt1,2
.endmacro
.macro b1n[]
 sbrs	reg_bt1,2
.endmacro
.macro b2[]
 sbrc	reg_bt1,3
.endmacro
.macro b2n[]
 sbrs	reg_bt1,3
.endmacro
.macro b3[]
 sbrc	reg_bt1,4
.endmacro
.macro b3n[]
 sbrs	reg_bt1,4
.endmacro
.macro b4[]
 sbrc	reg_bt1,5
.endmacro
.macro b4n[]
 sbrs	reg_bt1,5
.endmacro
.macro b5[]
 sbrc	reg_bt1,6
.endmacro
.macro b5n[]
 sbrs	reg_bt1,6
.endmacro
.macro b6[]
 sbrc	reg_bt1,7
.endmacro
.macro b6n[]
 sbrs	reg_bt1,7
.endmacro
.macro b7[]
 sbrc	reg_bt2,2
.endmacro
.macro b7n[]
 sbrs	reg_bt2,2
.endmacro
.macro b8[]
 sbrc	reg_bt2,3
.endmacro
.macro b8n[]
 sbrs	reg_bt2,3
.endmacro
.macro b9[]
 sbrc	reg_bt2,4
.endmacro
.macro b9n[]
 sbrs	reg_bt2,4
.endmacro


TIMER_Init:
	ldi		reg_vol,0
	ldi		reg_son,(1<<CS11)
	out		TCCR1A,reg_vol
	out		TCCR1B,reg_son				;démarrage du timer à 16KHz => soit à 8k
	in		reg_vol,TIFR				;clear flag
	andi	reg_vol,0xFB
	out		TIFR,reg_vol
	in		reg_vol,TIMSK				;interrupt enable
	ori		reg_vol,(1<<TOIE1)
	out		TIMSK,reg_vol
	ldi		reg_vol,100
	ldi		reg_son,0
	out		TCNT1L,reg_vol				;on met le résultat dans le timer
	out		TCNT1H,reg_son
	rjmp	TIMER_INC

TI_Interrupt:
	in		tri,SREG					; save content of flag reg.

	;gestion des boutons
	in		reg_bt1,PINA				;on lit le port bouton
	in		reg_bt2,PIND				;on lit le port bouton
	andi	reg_bt1,0xFE				;on garde les boutons
	andi	reg_bt2,0x1C

	sbic	PIND,6						;si buzzer on
	rcall	BUZZ_OFF					;on met on
	sbis	PIND,6						;sinon
	rcall	BUZZ_ON

	;gestion de la led
	sbic	PIND,6						;blink led
	cbi		PORTD,6
	sbis	PIND,6
	sbi		PORTD,6


	
	out		SREG,tri					; restore flag register
	reti 								; Return from interrupt

BUZZ_ON:
	;gestion du volume
	in		reg_vol,ADCH				;on lit la valeur de l'adc convertie

	;gestion du son
	mul		reg_vol,reg_son				;on mulitplie le son et le volume
	movw	reg_son,r0					;on met le résultat dans reg_son et reg_vol
	out		TCNT1L,reg_vol				;on met le résultat dans le timer
	out		TCNT1H,reg_son

	;gestion volume suite
	in		reg_vol,ADCSRA
	ori		reg_vol,(1<<ADSC)			;relance d'une conversion
	out		ADCSRA,reg_vol

	sbi		PORTD,5

	ret

BUZZ_OFF:
	com		reg_vol						;on fait (1-duty)
	com		reg_son
	out		TCNT1L,reg_vol				;on met le résultat dans le timer
	out		TCNT1H,reg_son

	cbi		PORTD,5

	ret
