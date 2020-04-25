BOTAO EQU p2.7	
org 0h
INICIO:
	LJMP MAIN_LOOP
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
CONTROLE:
	JB BOTAO, $
	LCALL TEMP
	JNB BOTAO, $
	LCALL TEMP
	LJMP CONTINHAS 
FINAL:
	LCALL ZERAR
	SJMP CONTROLE

