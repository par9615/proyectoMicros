ORG 0000H
JMP INIT

ORG 0003H ;INTERRUPCION PARA SEND
JMP EXT0

ORG 000BH	;TIMER PARA DELAY
JMP TIM0

ORG 0013H ;INTERRUPCION DEL TECLADO MATRICIAL
JMP EXT1

ORG 002BH
CLR TF2
JMP TIM2

/*RENOMBRAMIENTOS*/
RS EQU P3.5
RW	EQU P3.6
E	EQU	P3.7
DBUS EQU P2
KEY EQU P0
ALT EQU P3.4
	
/*VARIABLES*/
AAUX EQU 20H
CUENTA200 EQU 21H
CUENTA10  EQU 22H	; VIDA
CUENTA12  EQU 23H	; COMIDA
CUENTA17  EQU 24H	; SUENO

/*VARIABLES DE MIKE*/
VIDA  EQU 25H
COMIDA  EQU 26H
SUENO EQU 27H

/*VARIABLES BIT*/
WAIT50 EQU 70H
DORMIDO EQU 71H
MUERTO EQU 72H

/*DIRECCIONES TIMER 2*/
T2CON EQU 00C8H
RCAP2L EQU 00CAH
RCAP2H EQU 00CBH
TL2 EQU 00CCH
TH2 EQU 00CDH
TF2 EQU 00CFH
TR2 EQU 0CAH
/* ===============================    I N I T    ======================================= */
INIT:
	MOV IE, #10100111B
	MOV IP, #00000010B
	MOV TCON, #00000101B
	MOV SCON, #01000010B
	MOV TMOD, #00100010B
	MOV TH0, #-250
	MOV TL0, #-250	
	MOV TH1, #(-3)
	MOV TL1, #(-3)

	MOV RCAP2H, #HIGH(-50000); 
	MOV RCAP2L, #LOW(-50000)
	MOV TH2, #HIGH(-50000)
	MOV TL2, #LOW(-50000)
	MOV T2CON, #00000000B	
	
	MOV DPTR, #1000H
	ACALL DELAY_50MS		
	
	SETB E
	CLR RS
	CLR RW
	
	ACALL INIT_DISPLAY		
		
	SETB TR2
	
	JMP $
/* =============================== T I M E R   0 ======================================= */
TIM0:	
	 JB WAIT50, WAITING50 
	 
	 WAITING50: 
	 
	 MOV A, CUENTA200	;CARGA EL ACUMULADOR CON LA CUENTA ACTUAL
	 INC A				
	 CJNE A, #0C8H, FIN_TIM0;VERIFICA SI LA CUENTA YA LLEGO A 200
	 
	 MOV A, #00H	;SI LA CUENTA ES 200 LA BORRA PARA VOLVER A CONTAR
	 CLR WAIT50		;LIMPIA LA BANDERA DE CONTEO PARA INDICAR QUE YA TERMINO EL DELAY
	 
	 FIN_TIM0:
	 MOV CUENTA200, A ;GUARDA LA CUENTA 
		 
	 RETI
/* =============================== T I M E R   2 ======================================= */
TIM2:
	MOV AAUX, A
	JB MUERTO, FIN_TIM2			; CHECAR SI ESTA MUERTO
	JB DORMIDO, ISDESCANSADO 	; CHECAR SI ESTA DORMIDO
	
	ACALL SUMAR10				; SUMAR NUESTROS CONTADORES
	ACALL SUMAR12
	ACALL SUMAR17
/* ------------------------------------------------------------------------------------- */
	DEC_VIDA: 
	MOV A, CUENTA10				; CHECAR SI YA SE CONTO A 10
	CJNE A, #0AH, DEC_COMIDA	; SI NO, PASAR A LO SIGUIENTE
	
	MOV A, #00H
	MOV CUENTA10, A				; RESET DE CUENTA
	
	MOV A, VIDA
	DEC A
	MOV VIDA, A					; RESTAR VIDA
	
	CJNE A, #00H, DEC_COMIDA	; SI LA VIDA NO ES 0, RESTAR COMIDA
	JMP MORIR					; DE LO CONTRARIO, MORIR
/* ------------------------------------------------------------------------------------- */
	DEC_COMIDA:
	MOV A, CUENTA12			; CHECAR SI YA SE CONTO A 12
	CJNE A, #0CH, DEC_SUENO	; SI NO, PASAR A LO SIGUIENTE
	
	MOV A, #00H
	MOV CUENTA12, A				; RESET DE CUENTA
	
	MOV A, COMIDA
	DEC A
	MOV COMIDA, A				; RESTAR COMIDA
	
	CJNE A, #00H, DEC_SUENO		; SI LA COMIDA NO ES 0, RESTAR SUENO
	JMP MORIR					; DE LO CONTRARIO, MORIR
/* ------------------------------------------------------------------------------------- */	
	DEC_SUENO:
	MOV A, CUENTA17			; CHECAR SI YA SE CONTO A 17
	CJNE A, #11H, FIN_TIM2	; SI NO, TERMINAR
	
	MOV A, #00H
	MOV CUENTA17, A				; RESET DE CUENTA
	
	MOV A, SUENO
	DEC A
	MOV SUENO, A				; RESTAR SUENO
	
	CJNE A, #00H, DEC_SUENO		; SI EL SUENO NO ES 0, SALIR
	JMP DESMAYARSE				; DE LO CONTRARIO, DORMIR
/* ------------------------------------------------------------------------------------- */	
	ISDESCANSADO:
	ACALL CHECK_DESCANSO
	JMP FIN_TIM2
/* ------------------------------------------------------------------------------------- */	
	DESMAYARSE:
	ACALL DORMIR
	JMP FIN_TIM2	
/* ------------------------------------------------------------------------------------- */
	MORIR:
	SETB MUERTO
/* ------------------------------------------------------------------------------------- */
	FIN_TIM2:
	MOV A, AAUX
	RETI
/* ===============================    E X T  1   ======================================= */
EXT1:
	MOV AAUX, A	
	 
	MOV A, KEY			;TOMA EL NUMERO DEL TECLADO
	 
	FIN_EXT1:
	MOV A, AAUX
	RETI
/* ===============================    E X T  0   ======================================= */	 
EXT0:	
	
	RETI

;*****************************************************************************************
;																						 *
;								S U B R U T I N A S										 *
;																						 *
;								       DISPLAY										 	 *
;																						 *
;*****************************************************************************************

INIT_DISPLAY:
	MOV DBUS, #38H
	ACALL EXECUTE_E
	
	MOV DBUS, #38H
	ACALL EXECUTE_E
	
	MOV DBUS, #01H
	ACALL EXECUTE_E
	
	MOV DBUS, #0FH
	ACALL EXECUTE_E	
	
	RET

EXECUTE_E:
	CPL E
	CPL E
	RET

ESCRIBE_DATO:
	SETB RS
	ACALL EXECUTE_E
	CLR RS
	RET

HEX_ASCII:
	MOVC A, @A + DPTR
	RET

BORRAR_PANTALLA:
	MOV DBUS, #01H
	ACALL EXECUTE_E
	RET

/*SEND_ALL: ;ENVIA TODOS LOS DATOS DE LA PANTALLA POR SERIAL

	SETB TI		;INICIALIZA BANDERA (ESTA LISTO PARA ENVIAR)
	SETB TR1	;PONE A CONTAR EL TIMER 1
	MOV A, #80H	;MUEVE LA DIRECCION INICIAL
	MOV ACTUAL_POS, CURSOR_POS 
	INC ACTUAL_POS
	
	ENVIA:
		JNB TI, $	;ESPERA HASTA QUE ENVIA EL DATO	
		
		CJNE A, #90H, NO_SALTO	;CHECA SI NO SE HA PASADO DEL PRIMER RENGLON
		SALTO:
		MOV A, #0C0H	;SE MUEVE AL INICIO DEL SEGUNDO RENGLON
		
		NO_SALTO:
		MOV SEND_POS, A	
		CPL TI					;ESTA LISTO PARA ENVIAR
		MOV SBUF, @SEND_POS		;ENVIA EL DATO QUE CONTIENE LA DIRECCION QUE ESTA ENVIANDO
		INC A					;SE MUEVE A LA SIGUIENTE DIRECCION
		CJNE A, ACTUAL_POS, ENVIA	;CHECA SI YA ENVIO TODO
		
	FIN_SEND: 
	SETB TI		;TERMINA DE ENVIAR Y QUEDA EN ESPERA
	CLR TR1		;TIMER 1 DEJA DE CONTAR
	RET*/

;*****************************************************************************************
;																						 *
;								S U B R U T I N A S										 *
;																						 *
;								       TIMERS										 	 *
;																						 *
;*****************************************************************************************

DELAY_50MS:
	
	SETB TR0
	SETB WAIT50
	SETB TF0	
	
	JB WAIT50, $
	CLR TR0
	RET
	
SUMAR10:
	MOV A, CUENTA10
	INC A
	MOV CUENTA10, A
	RETI
	
SUMAR12:
	MOV A, CUENTA12
	INC A
	MOV CUENTA12, A
	RETI

SUMAR17:
	MOV A, CUENTA17
	INC A
	MOV CUENTA17, A
	RETI	

;*****************************************************************************************
;																						 *
;								S U B R U T I N A S										 *
;																						 *
;								       JUEGO										 	 *
;																						 *
;*****************************************************************************************

/* ============================== D E S C A N S O ====================================== */
CHECK_DESCANSO:
	MOV AAUX, A
	MOV A, SUENO
	CJNE A, #64H, DESCANSAR			; CHECAR SI YA DESCANSO TODO (SUENO = 100)
	CLR DORMIDO						; LO DESPERTAMOS
	JMP FIN_CHK_DESCANSO
	
	DESCANSAR:
	ACALL SUMAR10
	CJNE A, #0AH, FIN_CHK_DESCANSO	; CHECAR SI LA CUENTA YA LLEGO A 10 PARA SUMAR CAD .5 SEG EL SUENO
	
	MOV A, SUENO					; MOVEMOS SUENO A ACC
	INC A							; LE SUMAMOS 1
	MOV SUENO, A					; LO GUARDAMOS
	
	MOV A, #00H						; PONEMOS ACC EN 0 PARA GUARDARLO EN CUENTA10
	MOV CUENTA10, A
	
	FIN_CHK_DESCANSO:
	MOV A, AAUX
	RETI
/* ==============================   D O R M I R   ====================================== */
DORMIR:
	MOV AAUX, A
	
	SETB DORMIDO			; DORMIR
	MOV A, #00H
	MOV CUENTA10, A			; RESET DE CUENTAS
	MOV CUENTA12, A
	MOV CUENTA17, A
	
	MOV A, AAUX
	RETI
/* ===============================   D T P T R   ======================================= */
ORG 1000H
	
DB '0'
DB '1'
DB '2'
DB '3'
DB '4'
DB '5'
DB '6'
DB '7'
DB '8'
DB '9'
DB 'A'
DB 'B'
DB 'C'
DB 'D'
DB 'E'
DB 'F'
	
END
