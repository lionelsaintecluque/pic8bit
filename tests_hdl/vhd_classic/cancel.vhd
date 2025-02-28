Library IEEE;
use IEEE.std_logic_1164.all;
library work;
use work.InstructionSet_12.all;
use work.mapping_508.all;

entity test_clk_reset is
   generic
	(
        pipeline_n: integer := 2;
        w_w: integer := 4;
        data_w: integer := 8;   --processed data size: 4*2
        fadd_w: integer := f_w;-- internal registers adress bus size
        inst_w: integer := inst_w; --instruction size
        pgmadd_w: integer := 10;--program memory adress bus size
        pins_w: integer := 8 -- number of discretes inouts
        );

end entity test_clk_reset;

architecture testbench of test_clk_reset is
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

begin

clk <= not(clk) after 1 ns;
reset_n <= '1' after 10 ns;
instruction <= 
	kind_arit & arit_incf & '1' & memory_add_slv, 
	kind_bito & bito_btfss & "000" & memory_add_slv     after 15 ns,
	kind_arit & arit_incf & '1' & memory_add_slv  after 23 ns,
	kind_arit & arit_incf & '1' & memory_add_slv  after 31 ns, 
	kind_bito & bito_btfss & "000" & memory_add_slv  after 39 ns,
	kind_arit & arit_incf & '1' & memory_add_slv after 47 ns,
	kind_arit & arit_incf & '1' & memory_add_slv after 55 ns,
	kind_arit & arit_incf & '1' & memory_add_slv after 63 ns;

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
