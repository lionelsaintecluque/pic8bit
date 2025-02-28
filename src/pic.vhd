library IEEE;
use IEEE.std_logic_1164.all;
library work;
use work.instructionSet_12.all;
use work.mapping_508.all;

-- this is the entity
entity pic is
   generic(
	pipeline_n: integer;
	w_w: integer;
	data_w: integer;	--processed data size: 4*2
	fadd_w: integer;-- internal registers adress bus size
	inst_w: integer; --instruction size
	pgmadd_w: integer;--program memory adress bus size
	pins_w: integer -- number of discretes inouts
	);
   port (
	clk: 	in std_logic; -- global clock, rising edge
	reset_n:	in std_logic; -- global reset active low
	pgmadd: out std_logic_vector (pgmadd_w-1 downto 0);
	instruction: in std_logic_vector (inst_w-1 downto 0)
--	pins: inout std_logic_vector (pins_w-1 downto 0);
	);
end pic;

architecture essai of pic is
component half_processor is
   generic(
	w_w: integer;
	data_w: integer;	--processed data size: 4*2
	fadd_w: integer;-- internal registers adress bus size
	inst_w: integer );
   port (
	clk:    in std_logic; -- global clock, rising edge
	reset_n:        in std_logic; -- global reset active low
	fin: in std_logic;
	win: in std_logic;
	fout: out std_logic;
	wout: out std_logic;
	z,c,dc: out std_logic;
	carry_in: in std_logic;
	update_z, update_dc, update_c: out std_logic;
	instruction: in std_logic_vector(inst_w-1 downto 0);
	start_cycle, end_cycle: in std_logic;
	fout_en: out std_logic;
	fadd, fadd_next: out std_logic_vector (fadd_w-1 downto 0);
	push, pop, goto: out std_logic;
	cancel: out std_logic;
	cancel_in: in std_logic
	);
end component;

component fregisters 
  generic(fadd_w: integer; data_w: integer; w_w: integer);
  port (
	clk: in std_logic;
	reset_n: in std_logic;
	start_cycle1, start_cycle2: in std_logic;
	end_cycle1, end_cycle2: in std_logic;
	PC_strobe1, PC_strobe2: in std_logic;
	fin1, fin2: in std_logic;
	fout1, fout2: out std_logic;
	fout1_en, fout2_en: in std_logic;
	cancel1, cancel2: in std_logic;
	fadd1, fadd2: in std_logic_vector (fadd_w-1 downto 0);
	fadd1_next, fadd2_next: in std_logic_vector (fadd_w-1 downto 0);
	data_out: out std_logic_vector(data_w-1 downto 0);
	data_in: in std_logic_vector(data_w-1 downto 0);
        add_in, add_out: out std_logic_vector(fadd_w-1 downto 0);
	write_strobes: out mapping_t;
	read_strobes: out mapping_t
	);
end component fregisters;

component coeur
   generic(
	pipeline_n: integer;
	w_w: integer;
	data_w: integer);
   port(
	clk: in std_logic;
	reset_n: in std_logic;
	ME1, ME2: out std_logic_vector (data_w-1 downto 0);
	start_cycle1, start_cycle2: out std_logic;
	end_cycle1, end_cycle2: out std_logic;
	PC_strobe1, PC_strobe2: out std_logic
	);
end component coeur;

component PC_register is
	generic (
	pgmadd_w: integer;
	strobe_index: integer;
	data_w: integer;
	inst_w: integer);
	port (
	clk: in std_logic;
	reset_n: in std_logic;
	data_in: in std_logic_vector(data_w-1 downto 0);
	data_out: out std_logic_vector(data_w-1 downto 0);
	PC_address: out std_logic_vector(pgmadd_w-1 downto 0);
	read_strobes: in mapping_t;
	write_strobes: in mapping_t;
	instruction: in std_logic_vector(inst_w-1 downto 0);
	cancel1, cancel2: in std_logic;
	PC_strobe1, PC_strobe2: in std_logic;
	start_cycle1, start_cycle2: in std_logic;
	goto1, goto2: in std_logic;
	push1, push2: in std_logic;
	pop1, pop2: in std_logic;
	PA0, PA1: in std_logic
	);
end component;

component status_register is
        generic(
        data_w: integer;
        strobe_index: integer);
        port(
        clk: in std_logic;
        reset_n: in std_logic;
        write_strobes: in mapping_t;
        read_strobes: in mapping_t;
        data_in: in std_logic_vector (data_w-1 downto 0);
        data_out: out std_logic_vector (data_w-1 downto 0);
	cancel1, cancel2: std_logic;
	end_cycle1, end_cycle2: in std_logic;
	z1, c1, dc1: in std_logic;
	update_z1, update_dc1, update_c1: in std_logic;
	z2, c2, dc2: in std_logic;
	update_z2, update_dc2, update_c2: in std_logic;
	carry_out: out std_logic;
	PA0, PA1: out std_logic
        );
end component;

component fregister is
	generic(
	data_w: integer;
	strobe_index: integer);
	port(
	clk: in std_logic;
	reset_n: in std_logic;
	write_strobes: in mapping_t;
	read_strobes: in mapping_t;
	data_in: in std_logic_vector (data_w-1 downto 0);
	data_out: out std_logic_vector (data_w-1 downto 0);
	fregister: out std_logic_vector (data_w-1 downto 0)
	);
end component;

component fmemory is
	generic(
	data_w: integer;
	strobe_index_mem: integer;
	strobe_index_fsr: integer;
	strobe_index_indf: integer;
	fadd_w: integer;
	memory_add: integer);
	port(
	clk: in std_logic;
	reset_n: in std_logic;
	write_strobes: in mapping_t;
	read_strobes: in mapping_t;
	data_in: in std_logic_vector (data_w-1 downto 0);
	data_out: out std_logic_vector (data_w-1 downto 0);
	fadd_in: in std_logic_vector (fadd_w-1 downto 0);
	fadd_out: in std_logic_vector (fadd_w-1 downto 0)
	);
end component;

signal win1, win2: std_logic;
signal z1, c1, dc1, z2, c2, dc2: std_logic;
signal carry: std_logic;
signal update_z1, update_dc1, update_c1: std_logic;
signal update_z2, update_dc2, update_c2: std_logic;
signal cancel1, cancel2: std_logic;
signal push1, push2, pop1, pop2, goto1, goto2: std_logic;
signal reg_fin1, reg_fin2, reg_fout1, reg_fout2: std_logic;
signal fout1_en, fout2_en: std_logic;
signal fadd1, fadd2, fadd1_next, fadd2_next: std_logic_vector(fadd_w-1 downto 0);
signal faddin, faddout: std_logic_vector(fadd_w-1 downto 0);
signal ME1, ME2: std_logic_vector(data_w-1 downto 0);
signal start_cycle1, start_cycle2: std_logic;
signal end_cycle1, end_cycle2: std_logic;
signal PC_strobe1, PC_strobe2: std_logic;
signal fdataout, fdatain: std_logic_vector(data_w-1 downto 0);
signal write_strobes, read_strobes: mapping_t;
signal PA0, PA1: std_logic;

begin

one_half: half_processor
   generic map(
	w_w => w_w,
	data_w => data_w,
	fadd_w => fadd_w,
	inst_w => inst_w
	)
   port map(
	clk => clk,
	reset_n => reset_n,
	fin => reg_fout1,
	win => win1,
	fout => reg_fin1,
	wout => win2,
	z => z1, c => c1, dc => dc1,
	carry_in => carry,
	update_z => update_z1,
	update_dc => update_dc1,
	update_c => update_c1,
	instruction => instruction,
	start_cycle => start_cycle1,
	end_cycle => end_cycle1,
	fadd => fadd1, fadd_next => fadd1_next,
	fout_en => fout1_en,
	push => push1,
	pop => pop1,
	goto => goto1,
	cancel => cancel1,
	cancel_in => cancel2
	);

other_half: half_processor
   generic map(
	w_w => w_w,
	data_w => data_w,
	fadd_w => fadd_w,
	inst_w => inst_w
	)
   port map(
	clk => clk,
	reset_n => reset_n,
	fin => reg_fout2,
	win => win2,
	fout => reg_fin2,
	wout => win1,
	z => z2, c => c2, dc => dc2,
	carry_in => carry,
	update_z => update_z2,
	update_dc => update_dc2,
	update_c => update_c2,
	instruction => instruction,
	start_cycle => start_cycle2,
	end_cycle => end_cycle2,
	fadd => fadd2, fadd_next => fadd2_next,
	fout_en => fout2_en,
	push => push2,
	pop => pop2,
	goto => goto2,
	cancel => cancel2,
	cancel_in => cancel1
	);


freg: fregisters 
   generic map (
	fadd_w => fadd_w, data_w => data_w, w_w => w_w
	)
   port map (
	clk => clk,
	reset_n => reset_n,
	start_cycle1 => start_cycle1, start_cycle2 => start_cycle2,
	end_cycle1 => end_cycle1, end_cycle2 => end_cycle2,
	pc_strobe1 => pc_strobe1, pc_strobe2 => pc_strobe2,
	fin1 => reg_fin1, fin2 => reg_fin2,
	fout1 => reg_fout1, fout2 => reg_fout2,
	fout1_en => fout1_en, fout2_en => fout2_en,
	cancel1 => cancel1, cancel2 => cancel2,
	fadd1 => fadd1, fadd2 => fadd2,
	fadd1_next => fadd1_next, fadd2_next => fadd2_next,
	data_out => fdataout, data_in => fdatain,
	add_in => faddin, add_out => faddout,
	write_strobes => write_strobes, read_strobes => read_strobes
	);

coeur_inst: coeur 
   generic map ( 
	pipeline_n => pipeline_n,
	w_w => w_w,
	data_w => data_w)
   port map(
	clk => clk,
	reset_n => reset_n,
	ME1 => ME1,
	ME2 => ME2,
	start_cycle1 => start_cycle1,
	start_cycle2 => start_cycle2,
	end_cycle1 => end_cycle1,
	end_cycle2 => end_cycle2,
	pc_strobe1 => pc_strobe1,
	pc_strobe2 => pc_strobe2
	);

PC: PC_register 
	generic map (
	pgmadd_w => pgmadd_w,
	strobe_index => PCL_add,
	data_w => data_w,
	inst_w => inst_w
	)
	port map (
	clk => clk,
	reset_n => reset_n,
	data_in => fdataout,
	data_out => fdatain,
	PC_address => pgmadd,
	read_strobes => read_strobes,
	write_strobes => write_strobes,
	instruction => instruction,
	cancel1 => cancel1,
	cancel2 => cancel2,
	push1 => push1,
	push2 => push2,
	pop1 => pop1,
	pop2 => pop2,
	goto1 => goto1,
	goto2 => goto2,
	start_cycle1 => start_cycle1,
	start_cycle2 => start_cycle2,
	pc_strobe1 => pc_strobe1,
	pc_strobe2 => pc_strobe2,
	PA0 => PA0,
	PA1 => PA1
	);

the_status: status_register
        generic map(
        data_w => data_w,
        strobe_index => status_add
	)
        port map(
        clk => clk,
        reset_n => reset_n,
        write_strobes => write_strobes,
        read_strobes => read_strobes,
        data_in => fdataout,
        data_out => fdatain,
	cancel1 => cancel1, cancel2 => cancel2,
	end_cycle1 => end_cycle1, end_cycle2 => end_cycle2,
	z1 => z1, c1 => c1, dc1 => dc1,
	carry_out => carry,
	update_z1 => update_z1,
	update_dc1 => update_dc1,
	update_c1=> update_c1,
	z2 => z2, c2 => c2, dc2 => dc2,
	update_z2 => update_z2,
	update_dc2 => update_dc2,
	update_c2 => update_c2,
	PA0 => PA0,
	PA1 => PA1
        );

reg_07h: fregister 
	generic map(
	data_w => data_w,
	strobe_index => memory_07h)
	port map(
	clk => clk,
	reset_n => reset_n,
	write_strobes => write_strobes,
	read_strobes => read_strobes,
	data_in => fdataout,
	data_out => fdatain,
	fregister => open
	);

GPR: fmemory 
	generic map(
	data_w => data_w,
	strobe_index_mem => memory_add,
	strobe_index_FSR => FSR_add,
	strobe_index_INDF => INDF_add,
	fadd_w => fadd_w,
	memory_add => memory_add)
	port map(
	clk => clk,
	reset_n => reset_n,
	write_strobes => write_strobes,
	read_strobes => read_strobes,
	data_in => fdataout,
	data_out => fdatain,
	fadd_in => faddout,
	fadd_out =>faddin
	);

end essai;
