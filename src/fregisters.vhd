library IEEE;
use IEEE.std_logic_1164.all;
Library work;
Use work.mapping_508.all;

entity fregisters is
  generic(fadd_w: integer; data_w: integer; w_w: integer);
  port (
--general
        clk: in std_logic;
        reset_n: in std_logic;
--synchro
	start_cycle1, start_cycle2: in std_logic;
	end_cycle1, end_cycle2: in std_logic;
	pc_strobe1, pc_strobe2: in std_logic;
        fadd1, fadd2: in std_logic_vector (fadd_w-1 downto 0);
        fadd1_next, fadd2_next: in std_logic_vector (fadd_w-1 downto 0);
	cancel1, cancel2: in std_logic;
--alu space data
        fin1, fin2: in std_logic;
--        fin1_en, fin2_en: in std_logic;
        fout1, fout2: out std_logic;
        fout1_en, fout2_en: in std_logic;
--register space control and data
	data_out: out std_logic_vector(data_w-1 downto 0);
	data_in: in std_logic_vector(data_w-1 downto 0);
	add_in, add_out: out std_logic_vector(fadd_w-1 downto 0);
	write_strobes: out mapping_t;
	read_strobes: out mapping_t
        );
end entity fregisters;

architecture RTL of fregisters is
--component fmemory
--   generic(
--	fadd_w: integer; data_w: integer
--	);
--   port(
--	clk: in std_logic;
--	reset_n: in std_logic;
--	add1, add2: in std_logic_vector(fadd_w-1 downto 0);
--	data1, data2: inout std_logic_vector (data_w-1 downto 0);
--	wr1, wr2, rd1, rd2: in std_logic
--	);
--end component fmemory;

signal fin1_reg, fin2_reg, fout1_reg, fout2_reg: std_logic_vector(data_w-1 downto 0);
signal addin, addout: std_logic_vector(fadd_w-1 downto 0);
signal datain, dataout: std_logic_vector (data_w-1 downto 0);
signal wr_en, rd_en: std_logic;
signal bback1_en, bback2_en: std_logic;
signal cancel1_reg, cancel2_reg: std_logic;
signal back1_en, back2_en: std_logic;
signal fout1_b, fout2_b, fout1_bb, fout2_bb: std_logic;
signal add1next_eq_add1, add2next_eq_add2, add1next_eq_add2, add2next_eq_add1: std_logic;
signal write_strobes_int, read_strobes_int: mapping_t;

begin
--
--register / peripheral space
--
--fmem: fmemory
--  generic map (
--	fadd_w => fadd_w,  data_w => data_w) 
--  port map (
--	clk => clk, reset_n => reset_n,
--	add1 => addin, add2 => addout,
--        data1 => datain, data2 => dataout,
--        wr1 => '0', wr2 => write_strobes_int(memory_add), rd1 => read_strobes_int(memory_add), rd2 => '0'
--	);


-- register space address mux
	process (end_cycle1, end_cycle2, fadd1_next, fadd2_next) is
	begin
	  if end_cycle1 = '1' then
	    addin <= fadd1_next;
	  elsif end_cycle2 = '1' then
	    addin <= fadd2_next;
	  else
	    addin <= (others => 'Z');
	  end if;
	end process;

	process (end_cycle1, end_cycle2, pc_strobe1, pc_strobe2, fadd1, fadd2) is
	begin
	  if end_cycle1 = '1' or pc_strobe1 = '1'  then
	    addout <= fadd1;
	  elsif end_cycle2 = '1' or PC_strobe2 = '1' then
	    addout <= fadd2;
	  else
	    addout <= (others => 'Z');
	  end if;
	end process;

  add_out <= addout;
  add_in <= addin;


-- register space data mux
	process (end_cycle1, end_cycle2, pc_strobe1, pc_strobe2, fin1_reg, fin2_reg, fin1, fin2) is
	begin
	  if end_cycle1 = '1' or PC_strobe1 = '1' then
	    dataout <= fin1 & fin1_reg(data_w-1 downto 1);
	  elsif end_cycle2 = '1' or PC_strobe2 = '1' then
	    dataout <= fin2 & fin2_reg(data_w-1 downto 1);
	  else
	    dataout <= (others => 'Z');
	  end if;
	end process;

  data_out <= dataout;

-- register space read and write stobes generation
	process (end_cycle1, end_cycle2, cancel1, cancel2, pc_strobe1, pc_strobe2, addout, fout1_en, fout2_en)
	begin
	  if addout = PCL_add_slv then
	    wr_en <= (pc_strobe1 and fout1_en and not cancel2) or (pc_strobe2 and fout2_en and not cancel1);
	  else
	    wr_en <= (end_cycle1 and fout1_en and not cancel2) or (end_cycle2 and fout2_en and not cancel1);
	  end if;
	end process;

  with wr_en select
	write_strobes_int <= mapping_strobes(addout) when '1',
	(others => '0') when others;

  rd_en <= (end_cycle1) or (end_cycle2);
  with rd_en select
	read_strobes_int <= mapping_strobes(addin) when '1',
	(others => '0') when others;

  read_strobes <= read_strobes_int;
  write_strobes <= write_strobes_int;

--
-- Processor/ALU space
--

-- input and output shift registers
	process (clk, reset_n) is
	begin
	  if reset_n = '0' then
	    fin1_reg <= (others => '0');
	    fin2_reg <= (others => '0');
	    fout1_reg <= (others => '0');
	    fout2_reg <= (others => '0');
	  elsif rising_edge(clk) then
	      fin1_reg <= fin1 & fin1_reg(data_w-1 downto 1); 
	      fin2_reg <= fin2 & fin2_reg(data_w-1 downto 1); 
	    if (end_cycle1 = '1') then
	      fout1_reg <= datain;
	    else
	      fout1_reg <= fout1_reg(0) & fout1_reg(data_w-1 downto 1); 
	    end if;
	    if (end_cycle2 = '1') then
	      fout2_reg <= datain;
	    else
	      fout2_reg <= fout2_reg(0) & fout2_reg(data_w-1 downto 1); 
	    end if;
	  end if;
	end process;

  datain <= data_in;

-- When last instruction (same alu) issued a result in the same register
	process (clk, reset_n) is
	begin
	  if reset_n = '0' then
	    add1next_eq_add1 <= '0';
	  elsif rising_edge(clk) then
	    if end_cycle1 = '1' then
	      if (fadd1 = fadd1_next)  and (fout1_en = '1') then
	        add1next_eq_add1 <= '1';
	      else
	        add1next_eq_add1 <= '0';
	      end if;
	    end if;
	  end if;
	end process;

	process (clk, reset_n) is
	begin
	  if reset_n = '0' then
	    add2next_eq_add2 <= '0';
	  elsif rising_edge(clk) then
	    if end_cycle2 = '1' then
	      if (fadd2 = fadd2_next) and (fout2_en = '1') then
	        add2next_eq_add2 <= '1';
	      else
	        add2next_eq_add2 <= '0';
	      end if;
	    end if;
	  end if;
	end process;

	process (clk, reset_n) is
	begin
	  if reset_n = '0' then
	    cancel1_reg <= '0';
	    cancel2_reg <= '0';
	  elsif rising_edge(clk) then
	    if end_cycle1 = '1' then
	      cancel2_reg <= cancel2;
	    end if;
	    if end_cycle2 = '1' then
	      cancel1_reg <= cancel1;
	    end if;
	  end if;
	end process;
  bback1_en <= not cancel2_reg and add1next_eq_add1;
  bback2_en <= not cancel1_reg and add2next_eq_add2;

  with bback1_en select
    fout1_bb <=	fout1_reg(0) when '0',
		fin1_reg(0) when '1',
		'U' when others;
  with bback2_en select
    fout2_bb <=	fout2_reg(0) when '0',
		fin2_reg(0) when '1',
		'U' when others;

-- When last instruction (other alu) issued a result in the same register
	process (clk, reset_n) is
	begin
	  if reset_n = '0' then
	    add1next_eq_add2 <= '0';
	  elsif rising_edge(clk) then
	    if end_cycle1 = '1' then
	      if (fadd1_next = fadd2) and (fout2_en = '1') then
	        add1next_eq_add2 <= '1';
	      else
	        add1next_eq_add2 <= '0';
	      end if;
	    end if;
	  end if;
	end process;

	process (clk, reset_n) is
	begin
	  if reset_n = '0' then
	    add2next_eq_add1 <= '0';
	  elsif rising_edge(clk) then
	    if end_cycle2 = '1' then
	      if (fadd2_next = fadd1) and (fout1_en = '1') then
	        add2next_eq_add1 <= '1';
	      else
	        add2next_eq_add1 <= '0';
	      end if;
	    end if;
	  end if;
	end process;

  --back1_en <= fout2_en and not cancel2 and add1next_eq_add2;
  --back2_en <= fout1_en and not cancel1 and add2next_eq_add1;
  back1_en <= add1next_eq_add2 and not cancel1;
  back2_en <= add2next_eq_add1 and not cancel2;

  with back1_en select
    fout1_b <=	fout1_bb when '0',
		fin2_reg(w_w) when '1',
		'U' when others;
  with back2_en select
    fout2_b <=	fout2_bb when '0',
		fin1_reg(w_w) when '1',
		'U' when others;

  fout1 <= fout1_b;
  fout2 <= fout2_b;
end;
