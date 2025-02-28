; Tests clear instructions
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
	decf	reg2, f

loop_clear:
	movf	reg2, w
	movwf	reg1
	btfsc	STATUS, Z
	goto	fail
	clrw
	nop
	btfss	STATUS, Z
	goto	fail
	movf	reg1, w
	nop
	btfsc	STATUS, Z
	goto	fail
	clrf	reg1
	nop
	btfss	STATUS, Z
	goto	fail
	decfsz	reg2, f
	goto	loop_clear
	
fin_clear:
	goto	fin_clear

fail:
	goto	fail

	end
