;
;  This test tests arithemetic operations.
;  reg 0x07 is decremented from 0 to 1.
;  It's value is subrstracted from itself.
;  
;  The test is successfull if the register
;  0x07 decrements from 0 to 1 and the
;  program never branches to fail. At the
;  end it should stop on subwf_end.
;
;

include tests_asm/12C508A.asm

reg	equ 	0x07
reg2	equ 	0x08

	org	0
	clrf	reg
subwf_loop:
	movf	reg, w
	subwf	reg, w
	nop
	btfss	STATUS, Z
	goto	fail
	decfsz	reg, f
	goto	subwf_loop 
subwf_end:
	goto	subwf_end
fail:
	goto	fail

	end
