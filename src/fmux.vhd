library IEEE;
use IEEE.std_logic_1164.all;

entity fmux is
   port(
	fin_in: in std_logic;
	fout_in: out std_logic;
	fin_out: in std_logic;
        fout_out: out std_logic
        );
end entity fmux;

architecture void of fmux is
begin
  Fout_out <= Fin_out;
  Fout_in <= Fin_in; 
end architecture void;
