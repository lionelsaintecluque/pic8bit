library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
library work;
use work.mapping_508.all;

entity fregister is
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
end entity;

architecture test of fregister is
signal memory_cell: std_logic_vector(data_w-1 downto 0);
begin
	process (clk, reset_n) is
	begin
	  if reset_n = '0' then
	    memory_cell <= (others => '0');
	  elsif rising_edge(clk) then
	    if write_strobes(strobe_index) = '1' then
	      memory_cell <= data_in;
	    end if;
	  end if;
	end process;

  with read_strobes(strobe_index) select
	    data_out <= memory_cell when '1',
	    (others => 'Z') when others;

  fregister <= memory_cell;
                 
end;
