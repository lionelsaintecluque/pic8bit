;
; tests call and retlw
;

include tests_asm/12C508A.asm

	org	0
	
	bsf	STATUS, 6
	bsf	STATUS, 5
	nop

valeur	set	0

	while	valeur <= 0xFF
	call	valeur
	nop
valeur	set	valeur + 1
	endw

fin_function:
	goto	fin_function


	org	0x300

valeur	set	0

	while	valeur <= 0xFF
	retlw	valeur
valeur	set	valeur + 1
	endw

	end
