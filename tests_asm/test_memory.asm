;
; This test tests the memory locations from 7 to F
; data is passed from F register to w. The register
; is cleared after data is moved.
; 
; The test is successfull if 0x55 is correctly red
; From the 0x0F location.
; 
;

	org 0
	
	movlw	0x55
	movwf	0x07
	clrw
	movf	0x07, w
	clrf	0x07
	movwf	0x08
	clrw
	movf	0x08, w
	clrf	0x08
	movwf	0x09
	clrw
	movf	0x09, w
	clrf	0x09
	movwf	0x0A
	clrw
	movf	0x0A, w
	clrf	0x0A
	movwf	0x0B
	clrw
	movf	0x0B, w
	clrf	0x0B
	movwf	0x0C
	clrw
	movf	0x0C, w
	clrf	0x0C
	movwf	0x0D
	clrw
	movf	0x0D, w
	clrf	0x0D
	movwf	0x0E
	clrw
	movf	0x0E, w
	clrf	0x0E
	movwf	0x0F
	clrw
	movf	0x0F, w

	end
