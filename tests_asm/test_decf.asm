; Tests decf instruction
;
; The test is successfull if it
; achieves end_clear label without
; branching to fail.
;
; run 40µs with a 2ns clock
;

INCLUDE tests_asm/12C508A.asm

	org	0
	
reg1	equ	0x07
reg2	equ	0x08
	
	clrf	reg2
	clrf	reg1

loop_decf:
	bcf	STATUS, Z
	bcf	STATUS, C
	movf	reg1, w
	subwf	reg2, w
	nop
	btfss	STATUS, Z
	goto	fail
	btfss	STATUS, C
	goto	fail
	decf	reg1, f
	decfsz	reg2, f
	goto	loop_decf
	
	btfss	STATUS, Z
	goto	fail

fin_decf:
	goto	fin_decf
	nop

fail:
	goto	fail

	end
