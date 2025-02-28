Library ieee;
Use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
Library work;
use work.mapping_508.all;
use work.InstructionSet_12.all;

entity PC_register is
	generic (
	pgmadd_w: integer;
	strobe_index: integer;
	data_w: integer;
	inst_w: integer);
	port (
	clk: in std_logic;
	reset_n: in std_logic;
	data_in: in std_logic_vector(data_w-1 downto 0);
	data_out: out std_logic_vector(data_w-1 downto 0);
	PC_address: out std_logic_vector(pgmadd_w-1 downto 0);
	read_strobes: in mapping_t;
	write_strobes: in mapping_t;
	instruction: in std_logic_vector(inst_w-1 downto 0);
	cancel1, cancel2: in std_logic;
	start_cycle1, start_cycle2: in std_logic;
	pc_strobe1, pc_strobe2: in std_logic;
	push1, push2: in std_logic;
	pop1, pop2: in  std_logic;
	goto1, goto2: in std_logic;
	PA0, PA1: in std_logic
	);
end entity PC_register;

architecture RTL of PC_register is
signal PC_register: std_logic_vector(pgmadd_w-1 downto 0);
signal temp_add1, temp_add2, stack1, stack2: std_logic_vector(pgmadd_w-1 downto 0);
begin
--note for the synthesis: increment of the PC hase a multicycle path: W_W clock cycles.
	process (clk, reset_n) is
	begin
	  if reset_n = '0' then
	    PC_register <= (others => '0');
	  elsif rising_edge(clk) then
	    if (PC_strobe1 or PC_strobe2) = '1' then
	      if write_strobes(PCL_add) = '1' then
	        PC_register(data_w-2 downto 0) <= data_in(data_w-1 downto 1);
	      elsif PC_strobe1 = '1' and push1 = '1' and cancel2 = '0' then
	        PC_register <= temp_add1;
	      elsif PC_strobe2 = '1' and push2 = '1' and cancel1 = '0' then
	        PC_register <= temp_add2;
	      elsif (PC_strobe1 = '1' and pop1 = '1' and cancel2 = '0') or (PC_strobe2 = '1' and pop2 = '1' and cancel1 = '0') then
	        PC_register <= stack1;
	      elsif (PC_strobe1 = '1' and goto1 = '1' and cancel2 = '0') then
	        PC_register <= temp_add1;
	      elsif (PC_strobe2 = '1' and goto2 = '1' and cancel1 = '0') then
	        PC_register <= temp_add2;
	      else
	        PC_register <= std_logic_vector(unsigned(PC_register) + TO_unsigned(1,pgmadd_w));
	      end if;
	    end if;
	  end if;
	end process;
  PC_address <= PC_register;

--temporary registers
	process (reset_n, clk)
	begin
	  if reset_n = '0' then
	    temp_add1 <= (others => '0');
	  elsif rising_edge(clk) then
	    if push1 = '1' and start_cycle1 = '1'  then
	      temp_add1 <= PA1 & PA0 &  instruction(call_w-1 downto 0);
	    end if;
	    if goto1 = '1' and start_cycle1 = '1' then
	      temp_add1 <= PA1 & instruction(goto_w-1 downto 0);
	    end if;
	  end if;
	end process;

	process (reset_n, clk)
	begin
	  if reset_n = '0' then
	    temp_add2 <= (others => '0');
	  elsif rising_edge(clk) then
	    if push2 = '1' and start_cycle2 = '1' then
	      temp_add2 <= PA1 & PA0 &  instruction(call_w-1 downto 0);
	    end if;
	    if goto2 = '1' and start_cycle2 = '1' then
	      temp_add2 <= PA1 & instruction(goto_w-1 downto 0);
	    end if;
	  end if;
	end process;

	process (reset_n, clk)
	begin
	  if reset_n = '0' then
	    stack1 <= (others => '0');
	    stack2 <= (others => '0');
	  elsif rising_edge(clk) then
	    if (PC_strobe1 = '1' and push1 = '1' and not cancel2 = '1') or     
	       (PC_strobe2 = '1' and push2 = '1' and not cancel1 = '1') then
	      stack2 <= stack1;
	      stack1 <= PC_register;
	    end if;
	    if (PC_strobe1 = '1' and pop1 = '1' and not cancel2 = '1') or
	       (PC_strobe2 = '1' and pop2 = '1' and not cancel1 = '1') then
	      stack1 <= stack2;
	    end if;
	  end if;
	end process;


  with read_strobes(strobe_index) select
    data_out <=
	PC_register(data_w-1 downto 0) when '1',
	(others => 'Z') when others;
  
end RTL;
