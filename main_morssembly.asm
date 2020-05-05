BOTAO  EQU p2.7	
ENABLE EQU p1.2
;; vou mudar o RS do edsim
;; não precisamos trabalhar com 4 bit
RS     EQU p1.3
DB0    EQU p1.0
DB1    EQU p1.1        
DB2    EQU p1.2
DB3    EQU p1.3
DB4    EQU p1.4
DB5    EQU p1.5
DB6    EQU p1.6
DB7    EQU p1.7
DADOS  EQU p1
;; REGISTRADOR PARA ENVIAR 
;; DADOS AO LCD
REGLCD EQU R7 

org 0h
INICIO:
	LJMP MAIN_LOOP

;; interrupção externa força reset
;; e "empurra" caractere atual no lcd
org 0Bh
PUSHLCD:
	;; PLACEHOLDER, A INDICARÁ QUAL
	;; CARACTERE SERA MOSTRADO
	;; MOV A, REGLCD
	LCALL OPERAR_LCD		
	ACALL ZERAR
	RETI

org 25h
ZERAR:
	MOV TH0, #0
	MOV TL0, #0
	RET

org 30h
CONTINHAS:
	;; gravar o tempo que ficou apertado
	CLR C
	CLR OV	
	MOV A, TL0
	SUBB A, R3 ;; inutil talvez?
	;; A - R3 ainda produziria carry
	MOV A, TH0
	SUBB A, R2 ;; se setar ACC, é menor?
	JC MENOR
	CLR P1.0 ;; teste aqui é uma linha
VOLTA:	
	NOP
	LJMP FINAL

org 65h
MENOR:
	CLR p1.1 ;; aqui um clique
	LJMP VOLTA
	
org 50h
TEMP: 
	CPL TR0
	RET

org 6Bh
OPERAR_LCD:
	MOV B, R1
	RET 

org 80h
MAIN_LOOP:
	MOV TMOD, #00001001h 
	;; interesse está no tempo apertado
	MOV TH0, #0
	MOV TL0, #0
	;; 16MS é 3e80 (16bits) 
	MOV R2, #0X3E 
	MOV R3, #0X80
	SETB EA
	SETB IT0
	SETB EX0
CONTROLE:
	JB BOTAO, $
	LCALL TEMP
	JNB BOTAO, $
	LCALL TEMP
	LJMP CONTINHAS 
FINAL:
	LCALL ZERAR
	SJMP CONTROLE

