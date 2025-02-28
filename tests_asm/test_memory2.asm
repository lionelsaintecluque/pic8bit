;
;  this test checks wether each General Purpose Register
;  can be independantly written and red. A different value
;  is written in each memory location. Then memory
;  locations are red.

;  the test is successful if each read operation optputs
;  the right value.
;

	org 0
	
	movlw	0x07
	movwf	0x07
	movlw	0x08
	movwf	0x08
	movlw	0x09
	movwf	0x09
	movlw	0x0A
	movwf	0x0A
	movlw	0x0B
	movwf	0x0B
	movlw	0x0C
	movwf	0x0C
	movlw	0x0D
	movwf	0x0D
	movlw	0x0E
	movwf	0x0E
	movlw	0x0F
	movwf	0x0F
	movf	0x07, f
	movf	0x08, f
	movf	0x09, f
	movf	0x0A, f
	movf	0x0B, f
	movf	0x0C, f
	movf	0x0D, f
	movf	0x0E, f
	movf	0x0F, f

	end
