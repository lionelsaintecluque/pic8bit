Library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
library work;
use work.InstructionSet_12.all;
use work.mapping_508.all;
use work.rom_program.all;

entity test_clk_reset_rom is
   generic
	(
        pipeline_n: integer := 2;
        w_w: integer := 4;
        data_w: integer := data_w;   --processed data size: 4*2
        fadd_w: integer := fadd_w;-- internal registers adress bus size
        inst_w: integer := inst_w; --instruction size
        pgmadd_w: integer := pgmadd_w;--program memory adress bus size
        pins_w: integer := 8 -- number of discretes inouts
        );

end entity test_clk_reset_rom;

architecture testbench of test_clk_reset_rom is
component pic 
   generic(
        pipeline_n: integer := 2;
        w_w: integer := 4;
        data_w: integer := 8;   --processed data size: 4*2
        fadd_w: integer := 4;-- internal registers adress bus size
        inst_w: integer := 12; --instruction size
        pgmadd_w: integer := 10;--program memory adress bus size
        pins_w: integer := 8 -- number of discretes inouts
        );
   port (
        clk:    in std_logic; -- global clock, rising edge
        reset_n:        in std_logic; -- global reset active low
        pgmadd: out std_logic_vector (pgmadd_w-1 downto 0);
        instruction: in std_logic_vector (inst_w-1 downto 0)
--      pins: inout std_logic_vector (pins_w-1 downto 0);
        );
end component pic;

signal reset_n, clk: std_logic := '0';
signal instruction: std_logic_vector(inst_w-1 downto 0);
signal pgmadd: std_logic_vector (pgmadd_w-1 downto 0);
signal rom: program_memory_t := program;
begin

clk <= not(clk) after 1 ns;
reset_n <= '1' after 10 ns;
instruction <= rom(to_integer(unsigned(pgmadd))); 

DUT: pic 
   generic map(
        pipeline_n => pipeline_n,
        w_w => w_w,
        data_w => data_w,
        fadd_w => fadd_w,
        inst_w => inst_w,
        pgmadd_w => pgmadd_w,
        pins_w => pins_w
	)
   port map (
        clk => clk,
        reset_n => reset_n,
        pgmadd => pgmadd,
        instruction => instruction
--      pins: inout std_logic_vector (pins_w-1 downto 0);
        );

end;
