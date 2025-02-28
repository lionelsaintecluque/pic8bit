library IEEE;
use IEEE.std_logic_1164.all;
library work;
use work.instructionSet_12.all;

entity alu is
	port(
	clk: in std_logic;
	reset_n: in std_logic;
	start_cycle: in std_logic;
	end_cycle: in std_logic;
	win, fin, kin: in std_logic;
	wout, fout: out std_logic;
	inst_alu: in aluucode_t;
	muxalu_cmd: in muxalu_t;
	z, c, dc: out std_logic;
	carry_in: in std_logic
	);
end entity alu;

architecture void of alu is
signal aluresult: std_logic;
signal z_int, z_reg, cq: std_logic;
signal carry_next: std_logic;
signal win_mux, fin_com, win_com: std_logic;
signal win_adder, fin_adder, cin_adder: std_logic;
signal forw: std_logic;
signal xor_adder, and_adder, sum_adder, cout_adder: std_logic;
begin
  z <= z_int;
  c <= carry_next;
  dc <= '0';
  
  with inst_alu(muxw) select
  wout <= win when '1',
	  aluresult when others;

  with inst_alu(muxf) select
  fout <= fin when '1',
	  aluresult when others;
  
  with inst_alu(bmask) select 
  win_mux <= kin when '1',
	win when '0',
	'U' when others;

  fin_com <= fin xor inst_alu(comf);
  win_com <= win_mux xor inst_alu(comw);
  win_adder <= (win_com and not inst_alu(incf)) or inst_alu(decf);
  fin_adder <= (fin_com and not(inst_alu(litt))) or (kin and inst_alu(litt));
  cin_adder <= cq  or (inst_alu(carry_preset) and start_cycle) or (not inst_alu(carry_preset) and not inst_alu(carry_preclr) and start_cycle and carry_in);
  with inst_alu(rlf) select
    carry_next <= 
	fin when '1',
	cout_adder when '0',
	'U' when others;

  process (reset_n, clk) is
  begin
    if (reset_n = '0') then
      cq <= '0';
    elsif rising_edge(clk) then
      if end_cycle = '1' then 
	cq <= '0';
      else
	cq <=  carry_next;
      end if;
    end if;
  end process;

  process (clk, reset_n) is
  begin
    if reset_n = '0' then
      z_reg <= '0';
    elsif rising_edge (clk) then
      if end_cycle = '1' then
	z_reg <= '1';
      else
	z_reg <= z_int;
      end if;
    end if;
  end process;
  z_int <= z_reg and not aluresult;

  forw <= fin_adder or win_adder;

  xor_adder <= fin_adder xor win_adder;
  and_adder <= fin_adder and win_adder;
  sum_adder <= cin_adder xor xor_adder;
  cout_adder <= and_adder or (xor_adder and cin_adder);

  with muxalu_cmd select
  aluresult <=
	kin       when muxalu_kin,
	fin       when muxalu_f,
	win       when muxalu_w,
	cin_adder	when muxalu_cq,
	'0'       when muxalu_0,
	sum_adder when muxalu_s,
	and_adder when muxalu_and,
	xor_adder when muxalu_xor,
	forw      when muxalu_or,
	fin_com   when muxalu_com ;
end;
