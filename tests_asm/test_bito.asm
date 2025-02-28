;
; Tests bit oriented instructions
; each bit of a register is set 
; tested, cleared and tested back
; 
; the test is successful if the
; program runs up to the final
; address without branching to
; fail address.
;

INCLUDE tests_asm/12C508A.asm

reg	equ	0x07

	org	0

	clrf	reg

mask	set	0
value	set	0x01
	while mask < 8
	
	bsf	reg, mask
	btfss	reg, mask
	goto	fail
	movlw	value
	xorwf	reg, w
	nop
	btfss	STATUS, Z
	goto	fail
	bcf	reg, mask
	btfsc	reg, mask
	goto	fail
	btfss	STATUS, Z
	goto	fail

mask	set	mask + 1
value	set	value << 1
	endw

end_bito:
	goto	end_bito

fail:
	goto	fail
	
	end
