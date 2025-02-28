;
; this test tests both
;            RRF and iorwf
;            RLF and andwf
; 
; The test is successfull if
; all bits of wreg are set to '1'
; one by one starting with the MSB,
; then are set to '0' one by one
; starting by the LSB.
;
include tests_asm/12C508A.asm
	org 0

reg	equ	0x07

	clrf	reg
	bsf	STATUS, C
	nop

loop_iorwf:
	iorwf	reg, w
;	rrf	reg, f
	rlf	reg, f
	nop
	btfss	STATUS, C
	goto loop_iorwf

	bcf	STATUS, C
	nop
	comf	reg,f	
loop_andwf:
	andwf	reg, w
	rlf	reg, f
	nop
	btfsc	STATUS, C
	goto	loop_andwf

end_test:
	goto	end_test

	end
