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

;; interrupção externa força reset
;; e "empurra" caractere atual no lcd
org 0Bh
PUSHLCD:
	LCALL PEGAR_ENDR
	LCALL OPERAR_LCD		
	LCALL ZERAR
	DJNZ 0X7D, CHECK_LCD
	SJMP LIMPAR_LCD
VOLTA_LCD:
	RETI

org 23h
CHECK_LCD:
	MOV A, 0X7D
	CJNE A, #16, NOT_EQUAL
	ACALL SEG_LINHA
	NOP 
NOT_EQUAL:
	SJMP VOLTA_LCD
LIMPAR_LCD:
	SETB ENABLE
	CLR RS
	;; instrução para limpar o disp
	MOV DADOS, #01H
	CLR ENABLE
	LCALL ESPERA
	MOV 0X7D, #32
	SJMP VOLTA_LCD
SEG_LINHA:
	SETB ENABLE
	CLR RS
	;; move para a posição 40 do disp
	MOV DADOS, #0C0h 
	CLR ENABLE
	LCALL ESPERA
	RET
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

MENOR:
	MOV ENTR, #0 ;; 0 indica clique
	ACALL VOLTA

MAIN_LOOP:
	LCALL INIT_LCD
	MOV TMOD, #00001001h 
	;; interesse está no tempo apertado
	MOV TH0, #0
	MOV TL0, #0
	;; 16MS é 3e80 (16bits) 
	MOV R2, #0X3E 
	MOV R3, #0X80
	MOV 0x7D, #32
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
	ACALL ZERAR
	SJMP CONTROLE
;; subrotina para zerar temporizador
ZERAR:
	MOV TH0, #0
	MOV TL0, #0
	RET
;; simplesmente copia o caractere atual
;; para o display
OPERAR_LCD:
	SETB ENABLE
	SETB RS
	MOV DADOS, REGLCD
	CLR ENABLE
	ACALL ESPERA
	RET 

TEMP: 
	CPL TR0
	RET


INIT_LCD:
	;; forçar borda de descida
	SETB ENABLE
	CLR RS
	;; iniciar como display de 2 linhas
	;; e 8 bit
	MOV DADOS, #38h
	CLR ENABLE
	ACALL ESPERA 
	SETB ENABLE
	CLR RS
	MOV DADOS, #0Eh
	CLR ENABLE
	ACALL ESPERA
	SETB ENABLE
	CLR RS
	MOV DADOS, #06h
	CLR ENABLE
	ACALL ESPERA
	RET

ESPERA:
	;; valor aleatório da ram
	;; delay alto? datasheet diz 40us
	MOV 0X7F, #0x40
	DJNZ 0X7F, $
	MOV 0X7F, #0x40
	RET

org 10Fh
PEGAR_ENDR:
	MOV A, R5
	MOV DPTR,#TABELA
	MOVC A,@A+DPTR
	MOV REGLCD,A
RESET_ENDR:
	MOV R4, #1
	MOV R0, #32
	MOV ENDR, #31
	RET
TABELA:
	DB 45h, 49h, 53h, 48h, 35h, 34h, 56h, 20h, 33h, 55h, 46h, 20h, 20h, 20h, 20h, 32h, 41h, 52h, 4Ch, 20h, 20h, 20h, 2Bh, 20h, 57h, 50h, 20h, 20h, 4Ah, 20h, 31h, 20h, 30h, 39h, 20h, 20h, 38h, 20h, 4Fh, 20h, 20h, 51h, 20h, 37h, 5Ah, 47h, 4Dh, 20h, 20h, 59h, 20h, BCh, 43h, 4Bh, 20h, 2Fh, 58h, 3Dh, 36h, 42h, 44h, 4Eh, 54h
