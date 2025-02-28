;
; Tests goto instruction
;
;
; Test is successful if PC achieves
; Success adress in 12 branches
;


INCLUDE	tests_asm/12C508A.asm

	org	0

; goto on alu1
	goto	goto1

	org	0x01F
goto1:
	goto	goto2

	org	0x1BC
goto2:
	goto	goto3

	org	0x003
goto3:
	goto	goto4

	org	0x109
goto4:
	goto	goto5

	org	0x111
goto5:
	goto	goto6

	org	0x17F
goto6:
	nop	; shift by one operation to perform gotos on both alus
; goto on alu2
	goto	goto7

	org	0x0D4
goto7:
	goto	goto8

	org	0x05B
goto8:
	goto	goto9

	org	0x160
goto9:
	goto	gotoA

	org	0x055
gotoA:
	goto	gotoB

	org	0x56
gotoB:
	goto	success


	org	0x01E
success:
	goto	success

	end;
