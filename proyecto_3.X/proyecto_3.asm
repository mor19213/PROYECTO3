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
RECIBIDO    RES 1
SERVO1_TX   RES 1
SERVO2_TX   RES 1
SERVO_T2    RES 1
SERVO_T1    RES 1
TX_B	    RES 1	
SERVO1_R    RES 1
SERVO2_R    RES 1
SERVO1_T    RES 1
SERVO2_T    RES 1
SERVO11	    RES 1
SERVO12	    RES 1
SERVO21	    RES 1
SERVO22	    RES 1
CONTADOR2   RES 1
CONTADOR3   RES 1
SENAL	    RES 1
PRUEBA	    RES 1
PRUEBA2	    RES 1
BANDERA1    RES 1
BANDERA2    RES 1
   
   
	    
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
    BTFSC   PIR1, RCIF
    CALL    COSO_RX	    ; RECIBIR DATOS
    BTFSC   PIR1, TXIF
    CALL    COSO_TX
    
POP:
    SWAPF   VAR_STATUS, W
    MOVWF   STATUS
    SWAPF   W_TEMP, F
    SWAPF   W_TEMP, W
    RETFIE

;		    SUB-RUTINAS DE LA INTERRUPCION 
;*******************************************************************************
   
COSO_TX:
    BTFSS   TX_B, 0
    GOTO    PRIMERO
    BTFSC   TX_B, 0
    GOTO    SEGUNDO
PRIMERO
    BTFSC   TX_B, 1
    GOTO    A1
    MOVFW   SERVO1
    ADDLW   0x30
    MOVWF   TXREG
    ;MOVLW   0x30
    ;ADDWF   SERVO1, W
    ;MOVWF   TXREG
    BSF	    TX_B, 1
    GOTO    TERMINARR
    RETURN
    
    A1
    MOVLW   .44
    MOVWF   TXREG
    BCF	    TX_B, 1
    BSF	    TX_B, 0
    GOTO    TERMINARR
    RETURN
    
SEGUNDO
    BTFSC   TX_B, 1
    GOTO    A2
    MOVLW   0x30
    ADDWF   SERVO2, W
    MOVWF   TXREG
    BSF	    TX_B, 1
    GOTO    TERMINARR
    RETURN
    
    A2
    MOVLW   .10
    MOVWF   TXREG
    BCF	    TX_B, 1
    BCF	    TX_B, 0
    GOTO    TERMINARR
    RETURN

    TERMINARR
 ;BANKSEL TRISA
 ;   BCF	    PIE1, TXIE
 ;   BANKSEL PORTA
    RETURN
    
COSO_RX:
    
    CLRF    BANDERA2
    CLRF    PORTC
    BCF	    PORTC, RC1
    BCF	    PORTC, RC2
    
    MOVLW   0x31
    SUBWF   RCREG, W
    BTFSC   STATUS, Z
    BSF	    PORTC, RC0
    BSF	    BANDERA2, 0
    
    MOVLW   0x32
    SUBWF   RCREG, W
    BTFSC   STATUS, Z
    BSF	    PORTC, RC3
    BSF	    BANDERA2, 1
    
    MOVLW   0x33
    SUBWF   RCREG, W
    BTFSC   STATUS, Z
    BSF	    PORTC, RC4
    BSF	    BANDERA2, 2
    
    MOVLW   0x34
    SUBWF   RCREG, W
    BTFSC   STATUS, Z
    BSF	    PORTC, RC5
    BSF	    BANDERA2, 3
    
    RETURN
    
COSO_TMR0:
    
    MOVFW   CONTADOR
    SUBLW   .30
    BTFSS   STATUS, Z
    GOTO    BANDERAS
    CLRF    CONTADOR
   
    ;BSF	    PORTB, RB0
    BSF	    PORTB, RB1
    BSF	    PORTB, RB2
    ;BSF	    PORTB, RB3
    BSF	    PORTB, RB4
    ;CALL    COSO_TX
    
    BANDERAS
    
    COSO1
    ;MOVFW   CONTADOR
    ;BTFSC   PORTB, RB7
    ;SUBLW   .10
    ;BTFSS   PORTB, RB7
    ;SUBLW   .2
    ;BTFSC   STATUS, Z
    ;BCF    PORTB, RB1
    
    MOVFW   CONTADOR
    SUBWF   SERVO2_T
    ;SUBLW   .7
    BTFSC   STATUS, Z
    BCF    PORTB, RB1
    
    MOVFW   CONTADOR
    SUBWF   SERVO1_T
    ;SUBLW   .7
    BTFSC   STATUS, Z
    BCF    PORTB, RB2
    
    MOVFW   CONTADOR
    BTFSC   PORTB, RB6
    SUBLW   .10
    BTFSS   PORTB, RB6
    SUBLW   .2
    BTFSC   STATUS, Z
    BCF    PORTB, RB4
    
    BTFSS   CONTADOR2, 7
    GOTO    T
    INCF    CONTADOR3, 1
    CLRF    CONTADOR2
    ;BTFSS   CONTADOR3, 5
   ;GOTO    T
    ;CLRF    CONTADOR3
    INCF    SENAL, 1
    
    T
    INCF    CONTADOR2, 1
    INCF    CONTADOR, 1
    BCF	    INTCON, T0IF 
    RETURN
    
COSO_ADC:
   BTFSC    BANDERA, 0
   GOTO	    COSO2
   
   SWAPF    ADRESH, W
   MOVWF    SERVO_T2
   RRF	    SERVO_T2, 0
   ANDLW    b'00000111'
   ADDLW    .2
   MOVWF    SERVO2
   BSF	    BANDERA, 0
   BSF	    ADCON0, 2
   ;CALL	    DELAY_2	
   GOTO	    TERMINAR
   
   COSO2	    ; CONVERSION EN EL CANAL AN1
   SWAPF    ADRESH, W
   MOVWF    SERVO_T1
   RRF	    SERVO_T1, 0
   ANDLW    b'00000111'
   ADDLW    .2
   MOVWF    SERVO1	  
   BCF	    BANDERA, 0
   BCF	    ADCON0, 2
   ;CALL	    DELAY_2
   
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
   CALL	    CONFIG_SERIAL
   BANKSEL  PORTA
   GOTO	    LOOP
   
LOOP:
   ;MOVLW    0x2
   ;MOVWF    SERVO1
   ;MOVLW    0x4
   ;MOVWF    SERVO2
   ;MOVLW    0x8
   ;MOVWF    SERVO3

   
    BTFSC   PORTD, RD3
    CALL    INC_MODO
    
    ;BANKSEL TRISA
    ;BSF	    PIE1, TXIE
    ;BANKSEL PORTA
        
    MOVFW   MODO
    SUBLW   .1
    BTFSC   STATUS, Z
    GOTO    MODO2
    
    MOVFW   MODO
    SUBLW   .2
    BTFSC   STATUS, Z
    GOTO    MODO3
    
    MOVFW   MODO
    SUBLW   .0
    BTFSC   STATUS, Z
    GOTO    MODO1

    GOTO    LOOP
    
MODO3:
    BTFSC   PORTC, RC0
    GOTO    SE1
    BTFSC   PORTC, RC3
    GOTO    SE2
    BTFSC   PORTC, RC4
    GOTO    SE3
    BTFSC   PORTC, RC5
    GOTO    SE4
    GOTO    LOOP
    
SE1
    BTFSC   SENAL, 5
    MOVLW   .8
    BTFSS   SENAL, 5
    MOVLW   .2
    MOVWF   SERVO1_T
    
    BTFSC   SENAL, 5
    MOVLW   .8   
    BTFSS   SENAL, 5
    MOVLW   .2
    MOVWF   SERVO2_T
    GOTO	LOOP 
    
SE2
    BTFSC   SENAL, 5
    MOVLW   .8
    BTFSS   SENAL, 5
    MOVLW   .2
    MOVWF   SERVO1_T
    
    BTFSC   SENAL, 5
    MOVLW   .2   
    BTFSS   SENAL, 5
    MOVLW   .8
    MOVWF   SERVO2_T
    GOTO	LOOP 
    
SE3
    BTFSC   SENAL, 5
    MOVLW   .4
    BTFSS   SENAL, 5
    MOVLW   .9
    MOVWF   SERVO1_T
    
    BTFSC   SENAL, 5
    MOVLW   .4  
    BTFSS   SENAL, 5
    MOVLW   .4
    MOVWF   SERVO2_T
    GOTO	LOOP 
    
SE4
    BTFSC   SENAL, 6
    MOVLW   .4
    BTFSS   SENAL, 6
    MOVLW   .2
    MOVWF   SERVO1_T
    
    BTFSC   SENAL, 6
    MOVLW   .4
    BTFSS   SENAL, 6
    MOVLW   .2
    MOVWF   SERVO2_T
    GOTO	LOOP 

MODO2:
    ;CALL    LEER
    MOVFW   SERVO1_EEPROM
    MOVWF   SERVO1_T
    
    MOVFW   SERVO2_EEPROM
    MOVWF   SERVO2_T
    GOTO    LOOP
    
    
MODO1:
    BSF	    ADCON0, GO
    
    
    MOVFW   SERVO1
    MOVWF   SERVO1_T
    MOVFW   SERVO2
    MOVWF   SERVO2_T

    ;BTFSS   PORTD, RD4
    GOTO    LOOP
    
    ;GOTO    ESCRITURA
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
    BANKSEL EEADR
    MOVLW   .0
    MOVWF   EEADR
    BANKSEL CCPR2L
    MOVFW   CCPR2L
    BANKSEL EEDATA
    MOVWF   EEDATA
    
    BANKSEL EECON1
    BCF	    EECON1, EEPGD
    BSF	    EECON1, WREN
    
    
    BCF	    INTCON, GIE
    
    MOVLW   0x55
    MOVWF   EECON2
    MOVLW   0xAA
    MOVWF   EECON2
    BSF	    EECON1, WR
    
    ;BSF	    INTCON, GIE
    BCF	    EECON1, WREN
    
    BANKSEL PORTA
    
PRIMERCOSO
    BANKSEL EEADR
    MOVLW   .1
    MOVWF   EEADR
    BANKSEL CCPR1L
    MOVFW   CCPR1L
    BANKSEL EEDATA
    MOVWF   EEDATA
    
    BANKSEL EECON1
    BCF	    EECON1, EEPGD
    BSF	    EECON1, WREN
    BCF	    INTCON, GIE
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
    BTFSC   PORTD, RD3
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

CONFIG_TMR0:
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
    
CONFIG_IO:
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
   BSF	    TRISB, 7
   BANKSEL  PORTD
   CLRF	    PORTB
   CLRF	    PORTA
   CLRF	    PORTC
   CLRF	    PORTD
   CLRF	    MODO
   CLRF	    CONTADOR
   MOVLW    0x2
   MOVWF    SERVO1
   MOVLW    0x2
   MOVWF    SERVO2
   MOVLW    0x2
   MOVWF    SERVO3
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
    
    BSF	    PIE1, RCIE
    BSF	    PIE1, TXIE
    BSF	    INTCON, T0IE
    BSF	    INTCON, PEIE
    
    BANKSEL PORTA
    BSF	    INTCON, GIE
    
    BCF	    INTCON, T0IF
    RETURN
    
  
CONFIG_SERIAL
    BANKSEL TXSTA	    ; CONFIGURACION DEL TX
    BCF	    TXSTA, SYNC
    BSF	    TXSTA, TXEN
    BSF	    TXSTA, BRGH
    BCF	    TXSTA, TX9
    
    BANKSEL BAUDCTL	    ; CONFIGURACION DE LA VELOCIDAD
    BCF	    BAUDCTL, BRG16
    BANKSEL SPBRG
    MOVLW   .25
    MOVWF   SPBRG
    CLRF    SPBRGH
    BANKSEL RCSTA
    BSF	    RCSTA, SPEN	    ; CONFIGURACION DEL RX
    BCF	    RCSTA, RX9
    BSF	    RCSTA, CREN
    BANKSEL PORTA
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