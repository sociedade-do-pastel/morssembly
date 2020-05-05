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
;; registradores para verificar a entrada
ENTR   EQU R6
ENDR   EQU R5

org 0h
INICIO:
	LJMP MAIN_LOOP

org 3h
ZERAR:
	MOV TH0, #0
	MOV TL0, #0
	RET

;; interrupção externa força reset
;; e "empurra" caractere atual no lcd
org 0Bh
PUSHLCD:
	LCALL OPERAR_LCD		
	ACALL ZERAR
	RETI

org 11h
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
	MOV ENTR, #1 ;; 1 indica linha
VOLTA:	
	ACALL ATT_ENDR

org 21h
MENOR:
	MOV ENTR, #0 ;; 0 indica clique
	ACALL VOLTA

org 25h
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
	MOV ENDR, #31 ;; endereço inicial
	;; R4 indica se o inserido é o
	;; primeiro ou não
	MOV R4, #1 
	;; R0 será usado em operações de endereço
	MOV R0, #32
CONTROLE:
	JB BOTAO, $
	ACALL TEMP
	JNB BOTAO, $
	ACALL TEMP
	LJMP CONTINHAS 
ATT_ENDR:
	CLR C ;; limpa carry
	;; verifica se é o primeiro pelo R4
	MOV A, R4 
	JNZ PRIMEIRO 
	;; verifica se deve ir pelo caminho
	;; positivo ou negativo pelo R1
	MOV A, R1
	JNZ NEG
POS:
	MOV A, ENTR
	JNZ DIR_POS
ESQ_POS:
	INC ENDR
	LJMP FINAL
DIR_POS:
	MOV A, ENDR
	ADD A, R0
	MOV ENDR, A
	AJMP FINAL
NEG:
	MOV A, ENTR
	JNZ DIR_NEG
ESQ_NEG:
	DEC ENDR
	LJMP FINAL
DIR_NEG:
	CLR C
	MOV A, ENDR
	SUBB A, R0
	MOV ENDR, A
	AJMP FINAL
PRIMEIRO:
	MOV R4, #0 ;; R4 != 0 não é mais primeiro
	MOV A, ENTR
	JNZ PRI_DIREITA
PRI_ESQUERDA:
	MOV R1, #0 ;; R1 = 0 operações positivas
	MOV A, ENDR
	SUBB A, #31
	MOV ENDR, A
	AJMP FINAL
PRI_DIREITA:
	MOV R1, #1 ;; R1 = 1 operações negativas
	MOV A, ENDR
	ADD A, #31
	MOV ENDR, A
FINAL:
	MOV A, R0
	MOV B, #2
	DIV AB
	MOV R0, A
	LCALL ZERAR
	SJMP CONTROLE

OPERAR_LCD:
	MOV B, R1
	RET 

TEMP: 
	CPL TR0
	RET
