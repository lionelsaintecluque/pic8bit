HDL= 	src/instructionset_12.vhd\
	src/mapping_508.vhd\
	src/fmemory.vhd\
	src/fregister.vhd\
	src/status_register.vhd\
	src/alu.vhd\
	src/coeur.vhd\
	src/fmux.vhd\
	src/fregisters.vhd\
	src/wreg.vhd\
	src/decoder.vhd\
	src/half_processor.vhd\
	src/pc_register.vhd\
	src/pic.vhd

TESTBENCH= \
	tests_hdl/hexfile_package.vhd \
	tests_hdl/hexfile_testbench.vhd

HEX_TB=\
	tests_asm/push_pop.hex\
	tests_asm/test_memory.hex

TESTCASE=tests_asm/test_litt.hex

VFLAGS=--std=93 --ieee=synopsys
AFLAGS=

TOP=hexfile_testbench

compile: $(HDL) $(TESTBENCH)
	ghdl -i --workdir=work $(VFLAGS) $(HDL) $(TESTBENCH)
	ghdl -m --workdir=work $(TOP)

simule: $(TOP) $(TESTCASE)
	cp $(TESTCASE) tests_hdl/testcase.hex
	./$(TOP) --stop-time=22000ns --vcd=$(TOP).vcd

affiche: 
	gtkwave $(TOP).vcd

clean:
	ghdl --clean --workdir=work
	rm $(TOP).vcd

# assembly files
%.hex: %.asm
	gpasm $(AFLAGS) $^

compile_hex:	$(HEX_TB)
