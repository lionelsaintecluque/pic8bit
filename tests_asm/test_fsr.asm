INCLUDE tests_asm/12C508A.asm

	org 0


	movlw	0x08
	movwf	FSR
loop_INDF1:
	movf	FSR, w
	nop
	nop
	movwf	INDF
	incf	FSR, f
	movlw	0x20
	subwf	FSR, w
	nop
	btfss	STATUS, Z
	goto	loop_INDF1
	
	movlw	0x08
	movwf	FSR
	nop
loop_INDF2:
	nop
	movf	INDF, w
	subwf	FSR, w
	nop
	btfss	STATUS, Z
	goto	fail
	incf	FSR, f
	movlw	0x20
	subwf	FSR, w
	nop
	btfss	STATUS, Z
	goto	loop_INDF2
end_INDF:
	goto	end_INDF
fail:
	goto	fail
	
	end;
