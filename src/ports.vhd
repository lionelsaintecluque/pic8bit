Library IEEE;
use IEEE.std_logic.all;

entity ports
	generic (data_w: integer := 8);
	port (
	clk_in
	tris_in1, rb_in1, data_in1: in std_logic;
	tris_in2, rb_in2, data_in2: in std_logic; 
	tris_out1, rb_out1, data_out1: in std_logic; 
	tris_out2, rb_out2, data_out2: in std_logic;
	ports: out std_logic_vector(ports_w-1 downto 0) 
	);
end entity ports;

architecture void of ports is
begin
ports <= (others => '0');
end;
