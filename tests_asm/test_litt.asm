;
; Tests litteral operation
;
include tests_asm/12C508A.asm

	org 0
	
valeur	set	0
constante set	0XA5

loop_litt:
	while 	valeur< 0x100
	movlw	valeur
	andlw	constante ^ 0xFF
	iorlw	constante & (valeur ^ 0xFF)
	xorlw	(constante & (valeur ^0xFF)) | ((constante ^ 0xFF) & valeur)
	nop
	btfss	STATUS, Z
	goto	fail
valeur	set	valeur + 5
	endw	

end_litt:
	goto	end_litt

fail:	goto fail

	end;
