Library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity coeur is
   generic(
--        pgmadd_w: integer;
        pipeline_n: integer;
        w_w: integer;
        data_w: integer);
   port(
        clk: in std_logic;
        reset_n: in std_logic;
--        pgmadd: out std_logic_vector(pgmadd_w-1 downto 0);
        ME1, ME2: out std_logic_vector(data_w-1 downto 0);
	start_cycle1, start_cycle2: out std_logic;
	end_cycle1, end_cycle2: out std_logic;
	pc_strobe1, pc_strobe2: out std_logic
        );
end entity;

architecture RTL of coeur is
--signal PC, PCplus1: unsigned(pgmadd_w-1 downto 0);
signal ME1_int: std_logic_vector (data_w-1 downto 0);
signal ME2_int: std_logic_vector (data_w-1 downto 0);
begin

--	process (clk, reset_n) is
--	begin
--	  if reset_n = '0' then
--	    PCL <= (others => '0');
--	  elsif rising_edge(clk) and (ME1_int(data_w-2) or ME2_int(data_w-2))='1' then 
--	    PCL <= PCLin & PCL(data_w-1 downto 1);
--	  end if;
--	end process;
--  PCLout <= PCL(0);	

--	process (clk, reset_n) is
--	begin
--	  if reset_n = '0' then
--	    PC <= (others => '0');
--	  elsif rising_edge(clk) and (ME1_int(5) or ME2_int(5)) = '1' then
--	    PC <= PCplus1;
--	  end if;
--	end process;
--PCplus1 <= PC+1;
--
--pgmadd <= std_logic_vector(PC);

	process (clk, reset_n) is
        begin
	  if reset_n = '0' then
            ME1_int <= "01000000";
            ME2_int <= "00000100";
          elsif rising_edge(clk) then
	    ME1_int <= ME1_int(data_w-2 downto 0) & ME1_int(data_w-1);
	    ME2_int <= ME2_int(data_w-2 downto 0) & ME2_int(data_w-1);
	  end if;
	end process;
ME1 <= ME1_int;
ME2 <= ME2_int;
start_cycle1 <= ME1_int(ME1_int'high);
start_cycle2 <= ME2_int(ME2_int'high);
end_cycle1 <= ME1_int(ME1_int'high-1);
end_cycle2 <= ME2_int(ME2_int'high-1);
PC_strobe1 <= ME1_int(ME1_int'high-2);
PC_strobe2 <= ME2_int(ME2_int'high-2);

end;
