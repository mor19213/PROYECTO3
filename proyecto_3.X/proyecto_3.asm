; PIC16F887 Configuration Bit Settings

#include "p16f887.inc"

; CONFIG1
; __config 0xE0D4
 __CONFIG _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_OFF & _CP_OFF & _CPD_OFF & _BOREN_OFF & _IESO_OFF & _FCMEN_OFF & _LVP_OFF
; CONFIG2
; __config 0xFFFF
 __CONFIG _CONFIG2, _BOR4V_BOR40V & _WRT_OFF
 

;				VARIABLES
;*******************************************************************************
GPR_VAR	    UDATA
TIEMPO_1    RES 1
TIEMPO_2    RES 1
W_TEMP	    RES 1
VAR_STATUS  RES 1
BANDERA	    RES 1
SERVO1	    RES 1
SERVO2	    RES 1
MODO	    RES 1
TIEMPOO	    RES 1
SERVO2_EEPROM	RES 1
SERVO1_EEPROM	RES 1
NADA	RES 1
COSO	RES 1
CONTADOR    RES 1
SERVO3	    RES 1
SERVO4	    RES 1
SENAL3	    RES 1
	   
   
   
	    
;				INTERRUPCIONES
;*******************************************************************************
 
RES_VECT  CODE    0x0000            ; processor reset vector
    GOTO    START                   ; go to beginning of program

ISR_VECT    CODE    0x0004

PUSH:
    BCF	    INTCON, GIE
    MOVWF   W_TEMP
    SWAPF   STATUS, W
    MOVWF   VAR_STATUS

ISR:
    BTFSC   PIR1, ADIF
    CALL    COSO_ADC	    ; CONVERSION
    BTFSC   INTCON, T0IF
    CALL    COSO_TMR0
    
POP:
    SWAPF   VAR_STATUS, W
    MOVWF   STATUS
    SWAPF   W_TEMP, F
    SWAPF   W_TEMP, W
    RETFIE

;		    SUB-RUTINAS DE LA INTERRUPCION 
;*******************************************************************************
COSO_TMR0:
    MOVFW   CONTADOR
    SUBLW   .30
    BTFSS   STATUS, Z
    GOTO    BANDERAS
    CLRF    CONTADOR
   
    BSF	    PORTB, RB0
    BSF	    PORTB, RB1
    BSF	    PORTB, RB2
    
    BANDERAS
    
    COSO1
    MOVFW   CONTADOR
    SUBWF   SERVO3
    BTFSC   STATUS, Z
    BCF	    PORTB, RB0
    
    MOVFW   CONTADOR
    SUBWF   SERVO4
    BTFSC   STATUS, Z
    BCF    PORTB, RB1
    
    MOVFW   CONTADOR
    BTFSC   PORTB, RB6
    SUBLW   .10
    BTFSS   PORTB, RB6
    SUBLW   .2
    BTFSC   STATUS, Z
    BCF    PORTB, RB2

    
    INCF    CONTADOR, 1
    BCF	    INTCON, T0IF 
    RETURN
    
COSO_ADC:
   BTFSC    BANDERA, 0
   GOTO	    COSO2
  ; COSO1	     ; VARIAR EN QUE VARIABLE SE GUARDA EL VALOR Y EL CANAL	    
   MOVFW    ADRESH	   
   MOVWF    SERVO2	    ;VALOR DE ADRESH A VARIABLE ENVIAR
   BSF	    BANDERA, 0
   BSF	    ADCON0, 2
   CALL	    DELAY_2	; DARLE TIEMPO ANTES DE LA SIGUIENTE CONVERSION
   GOTO	    TERMINAR
   
   COSO2	    ; CONVERSION EN EL CANAL AN1
   MOVFW    ADRESH  ; GUARDAR VALOR EN LA VARIABLE PARA EL EJE Y
   MOVWF    SERVO1	  
   BCF	    BANDERA, 0
   BCF	    ADCON0, 2
   CALL	    DELAY_2
   
   TERMINAR
   BSF	    ADCON0, GO
   BCF	    PIR1, ADIF	    ;BANDERA TERMINAR CONVERSION
   RETURN
;			    PRINCIPAL 
;****************************************************************************
MAIN_PROG   CODE

START			    ; CONFIGURACIONES
   CALL	    CONFIG_IO
   CALL	    UGHHHHHH
   CALL	    CONFIG_ADC
   CALL	    CONFIG_INTERRUPT
   CALL	    CONFIG_TMR0
   CALL	    CONFIG_INTERRUPT0
   GOTO	    LOOP
   
LOOP:
    
    MOVLW   .4
    MOVWF   SERVO3
    MOVLW   .10
    MOVWF   SERVO4
    
    BTFSC   PORTD, RD2
    CALL    INC_MODO
    
    MOVFW   MODO
    SUBLW   .0
    BTFSC   STATUS, Z
    GOTO    MODO1
    
    MOVFW   MODO
    SUBLW   .1
    BTFSC   STATUS, Z
    GOTO    MODO2
    
    MOVFW   MODO
    SUBLW   .2
    BTFSC   STATUS, Z
    GOTO    MODO3
    GOTO    LOOP
    
MODO3
    GOTO    LOOP

MODO2
    CALL    LEER
    MOVFW   SERVO2_EEPROM
    MOVWF   CCPR2L
    
    MOVFW   SERVO1_EEPROM
    MOVWF   CCPR1L
    BCF	    PORTB, RB2
    GOTO    LOOP
    
    
MODO1
    
    BSF	    PORTB, RB3
    BCF	    PORTB, RB2
    ;BTFSS   PORTD, RD4
    ;GOTO    SERVOS
    ;PRUEBA
    ;BSF	    PORTB, RB2
    ;CALL    ESCRITURA
    
 SERVOS
    RRF	    SERVO1, 0
    ANDLW   b'01111111'
    ADDLW   .32
    MOVWF   CCPR1L
    
    RRF	    SERVO2, 0
    ANDLW   b'01111111'
    ADDLW   .32
    MOVWF   CCPR2L
    
    BSF	    ADCON0, GO
    BTFSS   PORTD, RD4
    GOTO    LOOP
    GOTO    ESCRITURA
    GOTO    LOOP
    
;**************************** SUBRUTINAS ***************************************
    
LEER:
    BANKSEL INTCON
    BCF	    INTCON, GIE
    BANKSEL EEADR
    MOVLW   .1
    MOVWF   EEADR
    
    BANKSEL EECON1
    BCF	    EECON1, EEPGD
    BSF	    EECON1, RD
    
    BANKSEL EEDATA
    MOVFW   EEDATA
    BANKSEL PORTA
    MOVWF   SERVO1_EEPROM
    ;CALL    DELAY_1
    BANKSEL INTCON
    BSF	    INTCON, GIE
    BANKSEL PORTA
    
SEGUNDOSERVO
    BANKSEL INTCON
    BCF	    INTCON, GIE
    BANKSEL EEADR
    MOVLW   .0
    MOVWF   EEADR
    
    BANKSEL EECON1
    BCF	    EECON1, EEPGD
    BSF	    EECON1, RD
    
    BANKSEL EEDATA
    MOVFW   EEDATA
    BANKSEL PORTA
    MOVWF   SERVO2_EEPROM
    ;CALL    DELAY_1
    BANKSEL INTCON
    BSF	    INTCON, GIE
    BANKSEL PORTA
    RETURN
       
    
ESCRITURA:
    BANKSEL EECON1
    ES2
    BTFSC   EECON1, WR
    GOTO    ES2
    BANKSEL EEADR
    MOVLW   .0
    MOVWF   EEADR
    BANKSEL PORTA
    MOVFW   CCPR2L
    BANKSEL EEDATA
    MOVWF   EEDATA
    
    BANKSEL EECON1
    BCF	    EECON1, EEPGD
    BSF	    EECON1, WREN
    BCF	    INTCON, GIE
    BTFSC   INTCON, GIE
    GOTO    $-2
    
    MOVLW   0x55
    MOVWF   EECON2
    MOVLW   0xAA
    MOVWF   EECON2
    BSF	    EECON1, WR
    ;BSF	    INTCON, GIE
    BCF	    EECON1, WREN
    
    BANKSEL PORTA
    
PRIMERCOSO
    BANKSEL EECON1
    ES1
    BTFSC   EECON1, WR
    GOTO    ES1
    BANKSEL EEADR
    MOVLW   .1
    MOVWF   EEADR
    BANKSEL PORTA
    MOVFW   CCPR1L
    BANKSEL EEDATA
    MOVWF   EEDATA
    
    BANKSEL EECON1
    BCF	    EECON1, EEPGD
    BSF	    EECON1, WREN
    BCF	    INTCON, GIE
    BTFSC   INTCON, GIE
    GOTO    $-2
    
    MOVLW   0x55
    MOVWF   EECON2
    MOVLW   0xAA
    MOVWF   EECON2
    BSF	    EECON1, WR
    ;BSF	    INTCON, GIE
    BCF	    EECON1, WREN
    
    BANKSEL PORTA
    GOTO    LOOP
    
INC_MODO
    BTFSC   PORTD, RD2
    GOTO    INC_MODO
    INCF    MODO
    
    MOVLW   .250
    MOVWF   TIEMPOO
    AA
    DECFSZ  TIEMPOO, F
    GOTO    AA
    
    MOVLW   .250
    MOVWF   TIEMPOO
    AA2
    DECFSZ  TIEMPOO, F
    GOTO    AA2
    
    MOVFW   MODO
    SUBLW   .3
    BTFSS   STATUS, Z
    RETURN
    CLRF    MODO
    CLRF    PORTB
    RETURN
;				CONFIGURACIONES
;*******************************************************************************
UGHHHHHH:
    BSF	STATUS,RP0
    MOVLW   .187
    MOVWF   PR2
    BCF	    STATUS,RP0
    MOVLW   0x9d
    MOVWF   CCPR1L
    BCF	    CCP1CON,7
    BCF	    CCP1CON,6
    BCF	    CCP1CON,5 
    BCF	    CCP1CON,4
    BSF	    CCP1CON,3
    BSF	    CCP1CON,2
    BCF	    CCP1CON,1
    BCF	    CCP1CON,0

    MOVLW   0x20
    MOVWF   CCPR2L
    BSF	    CCP2CON,5
    BCF	    CCP2CON,4
    BSF	    CCP2CON,3   
    BSF	    CCP2CON,2
    BSF	    CCP2CON,1
    BSF	    CCP2CON,0
	
    BANKSEL OPTION_REG
    CLRWDT
    MOVLW   b'01010111'
    MOVWF   OPTION_REG	
    BANKSEL PORTA
    MOVLW   .255
    MOVWF   T2CON
    RETURN
    
   CONFIG_OSC:		; CONFIGURACION DEL RELOJ
   BANKSEL  OSCCON
   MOVLW    B'01100001'
   MOVFW    OSCCON
   RETURN

CONFIG_TMR0
    BANKSEL OPTION_REG
    BCF	    OPTION_REG, T0CS
    BSF	    OPTION_REG, PSA
    BCF	    OPTION_REG, PS2
    BCF	    OPTION_REG, PS1
    BCF	    OPTION_REG, PS0
    
    BANKSEL PORTA
    MOVLW   .156
    MOVWF   TMR0
    BCF	    INTCON, T0IF
    RETURN
 
CONFIG_INTERRUPT0
    ; CUANDO SE PRENDE LA BANDERA HABRA UNA INTERRUPCION
    BSF	    INTCON, GIE
    BSF	    INTCON, T0IE
    BCF	    INTCON, T0IF
    RETURN
    
CONFIG_IO
   BANKSEL  ANSEL
   CLRF	    ANSEL
   BSF	    ANSEL, 0	; CONFIGURAR ANSEL PARA EL CANAL AN0 Y AN1
   BSF	    ANSEL, 1
   CLRF	    ANSELH
   BANKSEL  TRISA
   CLRF	    TRISA
   COMF	    TRISA	; PONER COMO INPUT EL PUERTO A
   CLRF	    TRISC	; COLOCAR PUERTOS COMO SALIDAS
   CLRF	    TRISD
   COMF	    TRISD
   CLRF	    TRISB
   BSF	    TRISB, 6
   BANKSEL  PORTD
   CLRF	    PORTB
   CLRF	    PORTA
   CLRF	    PORTC
   CLRF	    PORTD
   CLRF	    MODO
   CLRF	    CONTADOR
   CLRF	    SERVO3
   CLRF	    SERVO4
   RETURN
   
CONFIG_ADC:		    ; CONFIGURACION ADC
   BANKSEL  ADCON1
   CLRF	    ADCON1
   BANKSEL  ADCON0
   MOVLW    B'10000111'	    ; CANAL INICIAL AN1
   MOVWF    ADCON0
   RETURN
    
CONFIG_INTERRUPT:
    BANKSEL TRISA
    BSF	    PIE1, ADIE
    BSF	    INTCON, PEIE
    
    BANKSEL PORTA
    ;BSF	    INTCON, GIE
    RETURN
    
    DELAY_1		    ; DELAYS
    MOVLW   .250
    MOVWF   TIEMPO_1
    CONFIG1
    CALL    DELAY_2
    DECFSZ  TIEMPO_1, F
    GOTO    CONFIG1
    RETURN

    DELAY_2
    MOVLW   .250
    MOVWF    TIEMPO_2
    CONFIG2
    DECFSZ  TIEMPO_2, F
    GOTO    CONFIG2
    RETURN

END