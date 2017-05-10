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
CUENTA40  EQU 22H	; COMIDA
CUENTA80  EQU 23H	; CAFE
CUENTA100  EQU 24H	; AMOR
CUENTA5 EQU 25H		; HELPER

/*VARIABLES DE MIKE*/ ;MOVI LAS DIRECCIONES UN LUGAR PORQUE VIDA ERA 25H Y ESA YA ESTA
VIDA  EQU 26H
COMIDA  EQU 27H
SUENO EQU 28H

/*VARIABLES BIT*/
WAIT50 EQU 70H
DORMIDO EQU 71H
MUERTO EQU 72H
OJOS EQU 73H
LLENA1 EQU 74H
VACIA1 EQU 75H
LLENA2 EQU 76H
VACIA2 EQU 77H
LLENA3 EQU 78H
VACIA3 EQU 79H

/*DIRECCIONES TIMER 2*/
T2CON EQU 00C8H
RCAP2L EQU 00CAH
RCAP2H EQU 00CBH
TL2 EQU 00CCH
TH2 EQU 00CDH
TF2 EQU 00CFH
TR2 EQU 0CAH
	
/*TOPS, BOTTOMS Y POS DE PILAS*/
POS_PILA1 EQU 29H
TOP_PILA1 EQU 4AH
BOTTOM_PILA1 EQU 4EH
	
POS_PILA2 EQU 2AH
TOP_PILA2 EQU 52H
BOTTOM_PILA2 EQU 56H

POS_PILA3 EQU 2BH
TOP_PILA3 EQU 5AH
BOTTOM_PILA3 EQU 5EH



/* ===============================    I N I T    ======================================= */
INIT:
	MOV SP, #40H
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
	
	/*VALORES INICIALES DEL PERSONAJE*/
	MOV VIDA, #(100)
	MOV COMIDA, #(100)
	MOV SUENO, #(100)
	CLR MUERTO
	CLR DORMIDO
	CLR OJOS
	
	/*INICIALIZANDO PILA1*/
	MOV POS_PILA1, #TOP_PILA1
	SETB LLENA1
	CLR VACIA1
	
	/*INICIALIZANDO PILA2*/
	MOV POS_PILA2, #TOP_PILA2
	SETB LLENA2
	CLR VACIA2
	
	/*INICIALIZANDO PILA3*/
	MOV POS_PILA3, #TOP_PILA3
	SETB LLENA3
	CLR VACIA3
	

	
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
	JB MUERTO, MORIR		; CHECAR SI ESTA MUERTO
    JB DORMIDO, DORMIR 	; CHECAR SI ESTA DORMIDO
	
	ACALL SUMAR40				; SUMAR NUESTROS CONTADORES
	ACALL SUMAR80
	ACALL SUMAR100
/* ------------------------------------------------------------------------------------- */
	DEC_COMIDA: 
	MOV A, CUENTA40				; CHECAR SI YA SE CONTO A 10
	CJNE A, #(40), DEC_CAFE	; SI NO, PASAR A LO SIGUIENTE
	
	MOV A, #00H
	MOV CUENTA40, A				; RESET DE CUENTA
	ACALL ANIMA_OJOS
	
	ACALL DECREMENTA_PILA1
/* ------------------------------------------------------------------------------------- */
	DEC_CAFE:
	MOV A, CUENTA80			; CHECAR SI YA SE CONTO A 12
	CJNE A, #(80), DEC_AMOR	; SI NO, PASAR A LO SIGUIENTE
	
	MOV A, #00H
	MOV CUENTA80, A				; RESET DE CUENTA
	
	ACALL DECREMENTA_PILA2		; DE LO CONTRARIO, MORIR
/* ------------------------------------------------------------------------------------- */	
	DEC_AMOR:
	MOV A, CUENTA100			; CHECAR SI YA SE CONTO A 17
	CJNE A, #(100), FIN_TIM2	; SI NO, TERMINAR
	
	MOV A, #00H
	MOV CUENTA100, A				; RESET DE CUENTA
	
	ACALL DECREMENTA_PILA3			; DE LO CONTRARIO, DORMIR
	
	JMP FIN_TIM2
/* ------------------------------------------------------------------------------------- */	
	
/* ------------------------------------------------------------------------------------- */	
	DORMIR:
	ACALL OJO_DORMIDO
	ACALL INCREMENTA_PILA2
	JNB LLENA2, FIN_TIM2
	CLR DORMIDO
	JMP FIN_TIM2
/* ------------------------------------------------------------------------------------- */
	MORIR:
	ACALL OJO_MUERTO
/* ------------------------------------------------------------------------------------- */
	FIN_TIM2:
	MOV A, AAUX
	RETI
/* ===============================    E X T  1   ======================================= */
EXT1:
	JB MUERTO, FIN_EXT1
	JB DORMIDO,FIN_EXT1
	MOV AAUX, A		 
	MOV A, KEY			;TOMA EL NUMERO DEL TECLADO
/* ------------------------------------------------------------------------------------- */
	ALIMENTAR:
	CJNE A, #02H, ARROPAR	; SI NO ES ESE # DEL TECLADO, CHECAMOS LOS DEMAS
	ACALL INCREMENTA_PILA1	
		
	JMP FIN_EXT1
/* ------------------------------------------------------------------------------------- */	
	ARROPAR:
	CJNE A, #01H, AMAR		; SI NO ES ESE # DEL TECLADO, CHECAMOS LOS DEMAS
	SETB DORMIDO
			
	JMP FIN_EXT1
/* ------------------------------------------------------------------------------------- */	
	AMAR:
	CJNE A, #00H, FIN_EXT1	; SI NO ES ESE # DEL TECLADO, CHECAMOS LOS DEMAS
	ACALL INCREMENTA_PILA3
							
	JMP FIN_EXT1
/* ------------------------------------------------------------------------------------- */	
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
	
	MOV DBUS, #0CH
	ACALL EXECUTE_E	
	
	ACALL INIT_ICONOS
	ACALL DIBUJA_ICONOS
	
	RET

DIBUJA_ICONOS:

	MOV DBUS, #82H
	ACALL EXECUTE_E
	MOV DBUS, #00H	;OJOS
	ACALL ESCRIBE_DATO
	ACALL ESCRIBE_DATO
	
	MOV DBUS, #85H
	ACALL EXECUTE_E
	MOV DBUS, #01H	;PILA 1
	ACALL ESCRIBE_DATO
	
	MOV DBUS, #87H
	ACALL EXECUTE_E
	MOV DBUS, #02H	;PILA 2
	ACALL ESCRIBE_DATO
	
	MOV DBUS, #89H
	ACALL EXECUTE_E
	MOV DBUS, #03H 	;PILA 3
	ACALL ESCRIBE_DATO
	
	MOV DBUS, #0C5H
	ACALL EXECUTE_E
	MOV DBUS, #04H	;HUESO
	ACALL ESCRIBE_DATO
	
	MOV DBUS, #0C7H
	ACALL EXECUTE_E
	MOV DBUS, #05H	;CAFE
	ACALL ESCRIBE_DATO
	
	MOV DBUS, #0C9H
	ACALL EXECUTE_E
	MOV DBUS, #06H	;CORAZON
	ACALL ESCRIBE_DATO
	
	
	RET

EXECUTE_E:
	CPL E
	CPL E
	ACALL DELAY_50MS
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
	
OJO_A:	;DIBUJA EL OJO_A EN EL PRIMER CARACTER DE LA CGRAM
	
	MOV DBUS, #40H 
	ACALL EXECUTE_E
	
	MOV DBUS, #4EH
	ACALL ESCRIBE_DATO
	MOV DBUS, #51H	
	ACALL ESCRIBE_DATO
	ACALL ESCRIBE_DATO
	MOV DBUS, #57H
	ACALL ESCRIBE_DATO
	ACALL ESCRIBE_DATO
	ACALL ESCRIBE_DATO
	MOV DBUS, #51H	
	ACALL ESCRIBE_DATO
	MOV DBUS, #4EH
	ACALL ESCRIBE_DATO
	
	/*
	  0***0
	  *000*
	  *000*
	  *0***
	  *0***
	  *0***
	  *000*
	  0***0
	 */
	
	RET

OJO_B:
	
	MOV DBUS, #40H 
	ACALL EXECUTE_E
	
	MOV DBUS, #4EH
	ACALL ESCRIBE_DATO
	MOV DBUS, #51H	
	ACALL ESCRIBE_DATO
	ACALL ESCRIBE_DATO
	MOV DBUS, #5DH
	ACALL ESCRIBE_DATO
	ACALL ESCRIBE_DATO
	ACALL ESCRIBE_DATO
	MOV DBUS, #51H	
	ACALL ESCRIBE_DATO
	MOV DBUS, #4EH
	ACALL ESCRIBE_DATO
	
	/*
	  0***0
	  *000*
	  *000*
	  ***0*
	  ***0*
	  ***0*
	  *000*
	  0***0
	 */
	
	RET

OJO_DORMIDO:

	MOV DBUS, #40H 
	ACALL EXECUTE_E
	
	MOV DBUS, #4EH	
	ACALL ESCRIBE_DATO
	MOV DBUS, #51H	
	ACALL ESCRIBE_DATO
	ACALL ESCRIBE_DATO
	ACALL ESCRIBE_DATO
	MOV DBUS, #5FH
	ACALL ESCRIBE_DATO
	MOV DBUS, #51H
	ACALL ESCRIBE_DATO
	ACALL ESCRIBE_DATO
	MOV DBUS, #4EH
	ACALL ESCRIBE_DATO
	
	/*
	  0***0
	  *000*
	  *000*
	  *000*
	  *****
	  *000*
	  *000*
	  0***0
	 */
	 
	RET

OJO_MUERTO:
	
	MOV DBUS, #40H 
	ACALL EXECUTE_E
	
	MOV DBUS, #4EH	
	ACALL ESCRIBE_DATO
	MOV DBUS, #51H	
	ACALL ESCRIBE_DATO
	ACALL ESCRIBE_DATO
	MOV DBUS, #5BH
	ACALL ESCRIBE_DATO
	MOV DBUS, #55H
	ACALL ESCRIBE_DATO
	MOV DBUS, #5BH
	ACALL ESCRIBE_DATO
	MOV DBUS, #51H
	ACALL ESCRIBE_DATO
	MOV DBUS, #4EH
	ACALL ESCRIBE_DATO
	
	/*
	  0***0
	  *000*
	  *000*
	  **0**
	  *0*0*
	  **0**
	  *000*
	  0***0
	 */
	
	RET

PILA_LLENA:
	
	MOV DBUS ,#4EH	
	ACALL ESCRIBE_DATO
	MOV DBUS, #5FH
	ACALL ESCRIBE_DATO
	ACALL ESCRIBE_DATO
	ACALL ESCRIBE_DATO
	ACALL ESCRIBE_DATO
	ACALL ESCRIBE_DATO
	ACALL ESCRIBE_DATO
	ACALL ESCRIBE_DATO
	
	/*
	  0***0
	  *****	P1	P2	P3 	EN HEXA
	  *****	4A	52	5A
	  *****	4B	53	5B
	  *****	4C	54	5C
	  ***** 4D	55	5D
	  *****	4E	56	5E
	  *****
	 */	
	
	RET

ICONO_HUESO:
	
	MOV DBUS, #01001010B
	ACALL ESCRIBE_DATO	
	MOV DBUS, #01010101B
	ACALL ESCRIBE_DATO
	MOV DBUS, #01010001B
	ACALL ESCRIBE_DATO
	MOV DBUS, #01001010B
	ACALL ESCRIBE_DATO
	ACALL ESCRIBE_DATO
	MOV DBUS, #01010001B
	ACALL ESCRIBE_DATO
	MOV DBUS, #01010101B
	ACALL ESCRIBE_DATO
	MOV DBUS, #01001010B
	ACALL ESCRIBE_DATO	
	
	/*
	  0*0*0
	  *0*0*
	  *000*
	  0*0*0
	  0*0*0
	  *000*
	  *0*0*
	  0*0*0
	 */
	
	RET
	
ICONO_SUENO:	;TODAVIA NO ESTA DEFINIDO
	
	MOV DBUS, #01001000B
	ACALL ESCRIBE_DATO	
	MOV DBUS, #01000100B
	ACALL ESCRIBE_DATO
	MOV DBUS, #01001000B
	ACALL ESCRIBE_DATO
	MOV DBUS, #01000000B
	ACALL ESCRIBE_DATO
	MOV DBUS, #01011111B
	ACALL ESCRIBE_DATO
	MOV DBUS, #01011101B
	ACALL ESCRIBE_DATO
	MOV DBUS, #01011111B
	ACALL ESCRIBE_DATO	
	MOV DBUS, #01011100B
	ACALL ESCRIBE_DATO
	
	/*
	  0*000
	  00*00
	  0*000
	  00000
	  *****
	  ***0*
	  *****
	  ***00
	 */
	
	RET
	
ICONO_CORAZON:
	
	MOV DBUS, #01000000B
	ACALL ESCRIBE_DATO
	MOV DBUS, #01001010B
	ACALL ESCRIBE_DATO
	MOV DBUS, #01010101B
	ACALL ESCRIBE_DATO
	MOV DBUS, #01010001B
	ACALL ESCRIBE_DATO
	MOV DBUS, #01001010B
	ACALL ESCRIBE_DATO
	MOV DBUS, #01000100B
	ACALL ESCRIBE_DATO
	MOV DBUS, #01000000B
	ACALL ESCRIBE_DATO
	ACALL ESCRIBE_DATO
	
	/*
	  00000
	  0*0*0
	  *0*0*
	  *000*
	  0*0*0
	  00*00
	  00000
	  00000
	 */
	
	RET
	
INIT_ICONOS:	;CREAR LOS ICONOS EN LA CGRAM NECESARIOS PARA EL MANEJO DEL PERSONAJE	
	
	ACALL OJO_A
	ACALL PILA_LLENA
	ACALL PILA_LLENA
	ACALL PILA_LLENA
	ACALL ICONO_HUESO
	ACALL ICONO_SUENO
	ACALL ICONO_CORAZON	
	
	RET

ANIMA_OJOS:
	JB OJOS, OJO1
	
	OJO2:
	ACALL OJO_B
	JMP FIN_ANIMA_OJOS
	
	OJO1:
	ACALL OJO_A
	
	FIN_ANIMA_OJOS:
	CPL OJOS
	RET
	
INCREMENTA_PILA1:
	CLR VACIA1
	JB LLENA1, FIN_INCREMENTA_PILA1
	
	MOV DBUS, POS_PILA1
	ACALL EXECUTE_E
	MOV DBUS, #5FH
	ACALL ESCRIBE_DATO
	
	MOV A, POS_PILA1
	CJNE A, #TOP_PILA1, DEC_POS_PILA1
	SETB LLENA1
	JMP FIN_INCREMENTA_PILA1
	
	DEC_POS_PILA1:
	DEC POS_PILA1
	
	FIN_INCREMENTA_PILA1:
	RET

DECREMENTA_PILA1:
	CLR LLENA1
	JB VACIA1, FIN_DECREMENTA_PILA1
	
	MOV DBUS, POS_PILA1
	ACALL EXECUTE_E
	MOV DBUS, #51H
	ACALL ESCRIBE_DATO
	
	MOV A, POS_PILA1
	CJNE A, #BOTTOM_PILA1, INC_POS_PILA1
	SETB VACIA1
	SETB MUERTO
	JMP FIN_DECREMENTA_PILA1
	
	INC_POS_PILA1:
	INC POS_PILA1
	MOV A, POS_PILA1
	CJNE A, #BOTTOM_PILA1, FIN_DECREMENTA_PILA1
	ACALL SEND_ALERTA
	
	FIN_DECREMENTA_PILA1:
	RET

INCREMENTA_PILA2:
	CLR VACIA2
	JB LLENA2, FIN_INCREMENTA_PILA2
	
	MOV DBUS, POS_PILA2
	ACALL EXECUTE_E
	MOV DBUS, #5FH
	ACALL ESCRIBE_DATO
	
	MOV A, POS_PILA2
	CJNE A, #TOP_PILA2, DEC_POS_PILA2
	SETB LLENA2
	JMP FIN_INCREMENTA_PILA2
	
	DEC_POS_PILA2:
	DEC POS_PILA2
	
	FIN_INCREMENTA_PILA2:
	RET

DECREMENTA_PILA2:
	CLR LLENA2
	JB VACIA2, FIN_DECREMENTA_PILA2
	
	MOV DBUS, POS_PILA2
	ACALL EXECUTE_E
	MOV DBUS, #51H
	ACALL ESCRIBE_DATO
	
	MOV A, POS_PILA2
	CJNE A, #BOTTOM_PILA2, INC_POS_PILA2
	SETB VACIA2
	SETB MUERTO
	JMP FIN_DECREMENTA_PILA2
	
	INC_POS_PILA2:
	INC POS_PILA2
	MOV A, POS_PILA2
	CJNE A, #BOTTOM_PILA2, FIN_DECREMENTA_PILA2
	ACALL SEND_ALERTA
	
	FIN_DECREMENTA_PILA2:
	RET
	
INCREMENTA_PILA3:
	CLR VACIA3
	JB LLENA3, FIN_INCREMENTA_PILA3
	
	MOV DBUS, POS_PILA3
	ACALL EXECUTE_E
	MOV DBUS, #5FH
	ACALL ESCRIBE_DATO
	
	MOV A, POS_PILA3
	CJNE A, #TOP_PILA3, DEC_POS_PILA3
	SETB LLENA3
	JMP FIN_INCREMENTA_PILA3
	
	DEC_POS_PILA3:
	DEC POS_PILA3
	
	FIN_INCREMENTA_PILA3:
	RET

DECREMENTA_PILA3:
	CLR LLENA3
	JB VACIA3, FIN_DECREMENTA_PILA3
	
	MOV DBUS, POS_PILA3
	ACALL EXECUTE_E
	MOV DBUS, #51H
	ACALL ESCRIBE_DATO
	
	MOV A, POS_PILA3
	CJNE A, #BOTTOM_PILA3, INC_POS_PILA3
	SETB VACIA3
	SETB MUERTO
	JMP FIN_DECREMENTA_PILA3
	
	INC_POS_PILA3:
	INC POS_PILA3
	MOV A, POS_PILA3
	CJNE A, #BOTTOM_PILA3, FIN_DECREMENTA_PILA3
	ACALL SEND_ALERTA
	
	FIN_DECREMENTA_PILA3:
	RET

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
	
SUMAR40:
	MOV A, CUENTA40
	INC A
	MOV CUENTA40, A
	RET
	
SUMAR80:
	MOV A, CUENTA80
	INC A
	MOV CUENTA80, A
	RET

SUMAR100:
	MOV A, CUENTA100
	INC A
	MOV CUENTA100, A
	RET

;*****************************************************************************************
;																						 *
;								S U B R U T I N A S										 *
;																						 *
;								     BLUETOOTH										 	 *
;																						 *
;*****************************************************************************************
SEND_DATO:
	JNB TI, $	;ESPERA HASTA QUE ENVIA EL DATO	
	CPL TI
	MOV SBUF, A
	RET
	
SEND_ALERTA: ;ENV�A TODOS LOS DATOS DE LA PANTALLA POR SERIAL

	SETB TI		;INICIALIZA BANDERA (ESTA LISTO PARA ENVIAR)
	SETB TR1	;PONE A CONTAR EL TIMER 1	
	MOV A, #'A'   ;
    ACALL SEND_DATO      
    MOV A, #'Y'
    ACALL SEND_DATO      
    MOV A, #'U'
    ACALL SEND_DATO 
    MOV A, #'D'
    ACALL SEND_DATO  
    MOV A, #'A'
    ACALL SEND_DATO 
	MOV A, #'!'
    ACALL SEND_DATO 
	MOV A, #' '
	ACALL SEND_DATO
		 
	
	FIN_SEND: 
	SETB TI		;TERMINA DE ENVIAR Y QUEDA EN ESPERA
	CLR TR1		;TIMER 1 DEJA DE CONTAR
	RET


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
