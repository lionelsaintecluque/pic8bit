	org 	0x00

	call	toto
	call	tata
	nop
	nop
	nop
toto:	retlw	0x11
	retlw	0x2D
	nop
	nop
tata:	retlw	0xFB
	retlw	0x74
	
	end;
