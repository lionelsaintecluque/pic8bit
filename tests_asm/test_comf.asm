;
;  This test tests some arithmetic operation.
;  Register 0x07 is incremented by one at
;  each cycle, from zero to 0xFF.
;  At each cycle the register is added to 
;  it's two's compelent, calculated with
;  comf and inf instructions.
;  If the result is zero, test continues.
;  If the result is not zero, test branches
;  to fail address.
;
;  Test is successfull if register 0x07
;  increments from 0 to 0xFF and program
;  does not branch to fail, but rather
;  stops on comf_end location.
;

include tests_asm/12C508A.asm

reg	equ 	0x07
reg2	equ 	0x08

	org	0
	clrf	reg
comf_loop:
	comf	reg, w
	movwf	reg2
	incf	reg2,w
	addwf	reg, w
	nop
	btfss	STATUS, Z
	goto	fail
	incfsz	reg, f
	goto	comf_loop 
comf_end:
	goto	comf_end
fail:
	goto	fail

	end
