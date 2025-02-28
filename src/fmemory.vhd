library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
library work;
use work.InstructionSet_12.all;
use work.mapping_508.all;

entity fmemory is
	generic(
	data_w: integer;
	strobe_index_mem: integer;
	strobe_index_FSR: integer;
	strobe_index_INDF: integer;
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
end entity;

architecture test of fmemory is
-- bugge en simulation: type memory_type is array (natural range memory_add to 2**fadd_w-1) of std_logic_vector(data_w-1 downto 0);
type memory_type is array (natural range 0 to 2**fadd_w-1) of std_logic_vector(data_w-1 downto 0);
signal memory: memory_type;
signal spy1, spy2: std_logic_vector(data_w-1 downto 0);

signal FSR_register: std_logic_vector(data_w-1 downto 0);
signal FSR_strobes: mapping_t;
begin
	process (clk, reset_n) is
	begin
	  if reset_n = '0' then
	    memory <= (others => (others => '0'));
	  elsif rising_edge(clk) then
	    if write_strobes(strobe_index_mem) = '1' then
	      memory(to_integer(unsigned(fadd_in(fadd_w-1 downto 0)))) <= data_in;
	    elsif write_strobes(strobe_index_INDF) = '1' and FSR_strobes(strobe_index_mem) = '1' then
	      memory(to_integer(unsigned(FSR_register(fadd_w-1 downto 0)))) <= data_in;
	    end if;
	  end if;
	end process;
	
	process (clk, reset_n) is
	begin
	  if reset_n = '0' then
	    FSR_register <= (others => '0');
	  elsif rising_edge(clk) then
	    if write_strobes(strobe_index_FSR) = '1' then
	       FSR_register <= data_in;
	    end if;
	  end if;
	end process;
  FSR_strobes <= mapping_strobes(FSR_register(fadd_w-1 downto 0));

	process (read_strobes, memory, fadd_out, FSR_register, FSR_strobes) is
	begin
	  if read_strobes(strobe_index_FSR) = '1' then
	    data_out <= FSR_register;
	  elsif read_strobes(strobe_index_mem) = '1' then
	    report "direct memory access " & integer'image(to_integer(unsigned(fadd_out(fadd_w-1 downto 0)))) severity note;
	    data_out <= memory(to_integer(unsigned(fadd_out(fadd_w-1 downto 0))));
	  elsif read_strobes(strobe_index_INDF) = '1' and FSR_strobes(strobe_index_mem) = '1' then
	    report "indirect memory access " & integer'image(to_integer(unsigned(FSR_register(fadd_w-1 downto 0)))) severity note;
	    data_out <= memory(to_integer(unsigned(FSR_register(fadd_w-1 downto 0))));
	  elsif read_strobes(strobe_index_INDF) = '1' and FSR_strobes(strobe_index_mem) = '0' then
	    report "indirect memory access at an invalid addrss" & integer'image(to_integer(unsigned(FSR_register(fadd_w-1 downto 0)))) severity warning;
	    data_out <= (others => '0');
	  else
	    data_out <= (others => 'Z');
	  end if;
	end process;

spy1 <= memory(to_integer(unsigned(fadd_out(fadd_w-1 downto 0))));
spy2 <= memory(to_integer(unsigned(FSR_register(fadd_w-1 downto 0))));
                 
end;
