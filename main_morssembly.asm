BOTAO  EQU p2.7	
;; vou mudar o RS e E do edsim
;; não precisamos trabalhar com 4 bit
RS     EQU p0.0
ENABLE EQU p0.1
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

org 03h
MENOR:
	CLR p1.1 ;; aqui um clique
	LJMP VOLTA

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

org 11h
ZERAR:
	MOV TH0, #0
	MOV TL0, #0
	RET

org 18h
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
	AJMP FINAL
	
org 28h
TEMP: 
	CPL TR0
	RET

org 2Bh
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
	ACALL TEMP
	JNB BOTAO, $
	ACALL TEMP
	AJMP CONTINHAS 
FINAL:
	ACALL ZERAR
	SJMP CONTROLE


org 4Eh
OPERAR_LCD:
	
	RET 
