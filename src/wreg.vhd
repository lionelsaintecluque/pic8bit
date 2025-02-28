library IEEE;
use IEEE.std_logic_1164.all;

entity wreg is
	generic (w_w: integer);
	port (
	clk: in std_logic;
	reset_n: in std_logic;
-- control
	cancel: in std_logic;
--input and output from the half processor
	Win_halfproc: in std_logic;
	Wout_halfproc: out std_logic;
--connection with the alu
	result: in std_logic;
	operand: out std_logic
	);
end entity wreg;


architecture RTL of wreg is
signal wres_int: std_logic_vector(w_w-1 downto 0);
signal wbak_int: std_logic_vector(w_w-1 downto 0);
begin
	process (clk, reset_n) is
	begin
	  if reset_n = '0' then
	    wres_int <= (others => '0');
	  elsif rising_edge(clk) then
	    wres_int <= result & wres_int(w_w-1 downto 1);
	  end if;
	end process;
	
	process (clk, reset_n) is
        begin
          if reset_n = '0' then
            wbak_int <= (others => '0');
          elsif rising_edge(clk) then
            wbak_int <= wres_int(0) & wbak_int(w_w-1 downto 1);
          end if;
        end process;
  
  with cancel select
	 operand <= win_halfproc when '0',
	            wbak_int(0) when '1',
	            'U' when others;

  wout_halfproc <= wres_int(0);
end architecture RTL;
