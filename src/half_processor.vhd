library IEEE;
use IEEE.std_logic_1164.all;
library work;
use work.instructionSet_12.all;

-- this is the entity
entity half_processor is
   generic(
	w_w: integer;
	data_w: integer;
	fadd_w: integer;-- internal registers adress bus size
	inst_w: integer --instruction size
	);
   port (
	clk: 	in std_logic; -- global clock, rising edge
	reset_n:	in std_logic; -- global reset active low
	fin: in std_logic;
	win: in std_logic;
	fout: out std_logic;
	wout: out std_logic;
	z,c,dc: out std_logic;
	carry_in: in std_logic;
	update_z, update_dc, update_c: out std_logic;
	instruction: in std_logic_vector(inst_w-1 downto 0);
	start_cycle, end_cycle: in std_logic;
	--fin_en, 
	fout_en: out std_logic;
	fadd, fadd_next: out std_logic_vector(fadd_w-1 downto 0);
	push, pop, goto: out std_logic;
	cancel: out std_logic;
	cancel_in: in std_logic
	);
end half_processor;

architecture black_boxes of half_processor is
component alu 
   port (
	clk: in std_logic;
	reset_n: in std_logic;
	start_cycle: in std_logic;
	end_cycle: in std_logic;
	win, fin, kin: in std_logic;
	wout, fout: out std_logic;
	inst_alu: in aluucode_t;
	muxalu_cmd: in muxalu_t;
	z, c,dc: out std_logic;
	carry_in: in std_logic
	);
end component alu;

component wreg
   generic(w_w: integer);
   port(
	clk: in std_logic;
	reset_n: in std_logic;
	cancel: in std_logic;
	Win_halfproc: in std_logic;
	Wout_halfproc: out std_logic;
	result: in std_logic;
	operand: out std_logic
	);
end component wreg;

component decoder
   generic (
	inst_w: integer;
	fadd_w: integer;
	data_w: integer
	);
   port (
	clk: in std_logic;
	reset_n: in std_logic;
	instruction: in std_logic_vector(inst_w-1 downto 0);
	push, pop, goto: out std_logic;
	litteral: out std_logic;
	inst_alu: out aluucode_t;
	muxalu_cmd: out muxalu_t;
	fadd : out std_logic_vector(fadd_w-1 downto 0);
	fadd_next : out std_logic_vector(fadd_w-1 downto 0);
	--fin_en, 
	fout_en: out std_logic;
	z, c, dc: in std_logic;
	update_z, update_dc, update_c: out std_logic;
	cancel: out std_logic;
	cancel_in: in std_logic;
	start_cycle, end_cycle: in std_logic
	);
end component decoder;

signal alu_win, alu_wout: std_logic;
signal cancel_int: std_logic;
signal z_int, c_int, dc_int: std_logic;
signal inst_alu: aluucode_t;
signal muxalu_cmd: muxalu_t;
signal litteral: std_logic;

begin

the_w: wreg 
   generic map (
	w_w => w_w
	) 
   port map (
	clk => clk, 
	reset_n => reset_n,
	cancel => cancel_int,
	Win_halfproc => win, 
	Wout_halfproc => wout,
	result => alu_wout,
	operand => alu_win
	);

the_alu: alu 
   port map (
	clk => clk,
	reset_n => reset_n,
	start_cycle => start_cycle,
	end_cycle => end_cycle,
	win => alu_win,
	kin => litteral,
	fin => fin,
	wout => alu_wout,
	fout => fout,
	inst_alu => inst_alu,
	muxalu_cmd => muxalu_cmd,
	z => z_int, c => c_int, dc => dc_int,
	carry_in => carry_in
	);

the_decoder: decoder 
   generic map (
	inst_w => inst_w,
	fadd_w => fadd_w,
	data_w => data_w
	)
   port map (
	clk => clk,
	reset_n => reset_n,
	instruction => instruction,
	push => push,
	pop => pop,
	goto => goto,
	litteral => litteral,
	inst_alu => inst_alu,
	muxalu_cmd => muxalu_cmd,
	fadd => fadd,
	fadd_next => fadd_next,
	--fin_en => fin_en,
	fout_en => fout_en,
	z => z_int,
	c => c_int,
	dc => dc_int,
	update_z => update_z,
	update_dc => update_dc,
	update_c => update_c,
	cancel => cancel_int,
	cancel_in => cancel_in,
	start_cycle => start_cycle,
	end_cycle => end_cycle
	);

  c <= c_int;
  z <= z_int;
  dc <= dc_int;
  cancel <= cancel_int;
end black_boxes;
