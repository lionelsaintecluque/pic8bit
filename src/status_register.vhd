library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
library work;
use work.mapping_508.all;

entity status_register is
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
end entity;

architecture test of status_register is
constant c_index: integer range 0 to 7 := 0;
constant dc_index: integer range 0 to 7 := 1;
constant z_index: integer range 0 to 7 := 2;
constant PD_index: integer range 0 to 7 := 3;
constant TO_index: integer range 0 to 7 := 4;
constant PA0_index: integer range 0 to 7 := 5;
constant PA1_index: integer range 0 to 7 := 6;
constant GPWUF_index: integer range 0 to 7 := 7;

signal status_register_int: std_logic_vector(data_w-1 downto 0);
signal status_register_mux: std_logic_vector(data_w-1 downto 0);

signal update_z1_strobe: std_logic;
signal update_dc1_strobe: std_logic;
signal update_c1_strobe: std_logic;
signal update_z2_strobe: std_logic;
signal update_dc2_strobe: std_logic;
signal update_c2_strobe: std_logic;

begin
	process (clk, reset_n) is
	begin
	  if reset_n = '0' then
	    status_register_int <= (
	    z_index => '0',
	    dc_index => '0',
	    c_index => '0',
	    PD_index => '1',
	    TO_index => '1',
	    PA0_index => '0',
	    PA1_index => '0',
	    gpwuf_index => '0'
	    );
	  elsif rising_edge(clk) then
	    if write_strobes(strobe_index) = '1' then
	      status_register_int <= data_in;
	    elsif end_cycle1 = '1' or end_cycle2 = '1' then
	      status_register_int <= status_register_mux;
	    end if;
	  end if;
	end process;

  update_z1_strobe <= end_cycle1 and not cancel2 and update_z1;
  update_dc1_strobe <= end_cycle1 and not cancel2 and update_dc1;
  update_c1_strobe <= end_cycle1 and not cancel2 and update_c1;
  update_z2_strobe <= end_cycle2 and not cancel1 and update_z2;
  update_dc2_strobe <= end_cycle2 and not cancel1 and update_dc2;
  update_c2_strobe <= end_cycle2 and not cancel1 and update_c2;
  status_register_mux <= 
    (
    z_index => 
      (update_z1_strobe and z1) or (update_z2_strobe and z2) or 
      (status_register_int(z_index) and not update_z1_strobe and not update_z2_strobe),
    dc_index => 
      (update_dc1_strobe and dc1) or (update_dc2_strobe and dc2) or 
      (status_register_int(dc_index) and not update_dc1_strobe and not update_dc2_strobe),
    c_index =>
      (update_c1_strobe and c1) or (update_c2_strobe and c2) or 
      (status_register_int(c_index) and not update_c1_strobe and not update_c2_strobe),
    PD_index => status_register_int(PD_index),
    TO_index => status_register_int(TO_index),
    PA0_index => status_register_int(PA0_index),
    PA1_index => status_register_int(PA1_index),
    GPWUF_index => status_register_int(GPWUF_index),
    others => 'Z'
    );

  with read_strobes(strobe_index) select
    data_out <= status_register_mux when '1',
	(others => 'Z') when others;

  carry_out <= status_register_mux(c_index);
  PA0<= status_register_mux(PA0_index);
  PA1<= status_register_mux(PA1_index);
end;

