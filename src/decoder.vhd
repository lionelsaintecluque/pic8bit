Library IEEE;
use ieee.std_logic_1164.all;
Library work;
use work.instructionSet_12.all;

entity decoder is
   generic (
	inst_w: integer;
	fadd_w: integer;
	data_w: integer
	);
   port (
	clk: in std_logic;
	reset_n: in std_logic;
	instruction: in std_logic_vector(inst_w-1 downto 0);
	push, pop, goto: out std_logic;
	litteral: out std_logic;
	inst_alu: out aluucode_t;
	muxalu_cmd: out muxalu_t;
	fadd : out std_logic_vector(fadd_w-1 downto 0);
	fadd_next : out std_logic_vector(fadd_w-1 downto 0);
	--fin_en, 
	fout_en: out std_logic;
	z, c, dc: in std_logic;
	update_z, update_dc, update_c: out std_logic;
	cancel: out std_logic;
	cancel_in: in std_logic;
	start_cycle, end_cycle: in std_logic
	);
end entity decoder;


architecture void of decoder is
--signal instruction_reg: std_logic_vector(inst_w-1 downto 0);
signal litteral_reg: std_logic_vector(k_w-1 downto 0);
signal fadd_reg: std_logic_vector(fadd_w-1 downto 0);
signal aluucode_reg: aluucode_t;
signal muxalucmd_reg: muxalu_t;
signal fouten_reg, cancel_reg: std_logic;
signal cancel_uncond, cancel_cond: std_logic;
signal push_reg, pop_reg, goto_reg: std_logic;
signal updatec_reg, updatedc_reg, updatez_reg: std_logic;
begin
--  process (clk, reset_n) is
--  begin
--    if reset_n = '0' then
--      instruction_reg <= (others => '0');
--    elsif rising_edge(clk) and end_cycle = '1' then
--      instruction_reg <= instruction;
--    end if;
--  end process;

push <= push_reg;
pop <= pop_reg; 
goto <= goto_reg; 
cancel <= cancel_reg;


	process (clk, reset_n) is 
	begin
	  if reset_n = '0' then
	    litteral_reg <= (others => '0');
	  elsif rising_edge(clk) then
	    if end_cycle = '1' then
	      litteral_reg <= inst_kalu(instruction);
	    else
	      litteral_reg <= litteral_reg(0) & litteral_reg(litteral_reg'high downto 1);
	    end if;
	  end if; 
	end process;
litteral <= litteral_reg(0);

	process (clk, reset_n) is
	begin
	  if reset_n = '0' then
	    aluucode_reg <= aluucode_nop;
	    fadd_reg <= (others => '0');
	    muxalucmd_reg <= muxalu_default;
	    fouten_reg <= '0';
	    cancel_uncond <= '0';
	    cancel_cond<= '0';
	    push_reg <= '0';
	    pop_reg <= '0';
	    goto_reg <= '0';
	    updatez_reg <= '0';
	    updatedc_reg <= '0';
	    updatec_reg <= '0';
	  elsif rising_edge(clk) then
	    if end_cycle = '1' then
	      aluucode_reg <= inst_aluucode(instruction);
	      fadd_reg <= f_freg(instruction);
	      muxalucmd_reg <= inst_muxalu(instruction);
	      fouten_reg <= inst_fout(instruction);
	      cancel_uncond <= cancel_unconditional(instruction);
	      cancel_cond <= cancel_conditional(instruction);
	      push_reg <= inst_push(instruction);
	      pop_reg <= inst_pop(instruction);
	      goto_reg <= inst_goto(instruction);
	      updatez_reg <= inst_update_z(instruction);
	      updatedc_reg <= inst_update_dc(instruction);
	      updatec_reg <= inst_update_c(instruction);
	    end if;
	  end if;
	end process;

	process (clk, reset_n) is
	begin
	  if reset_n = '0' then
	    cancel_reg <= '0';
	  elsif rising_edge(clk) then
	    if end_cycle = '1' then
	      cancel_reg <= (not cancel_in) and (cancel_uncond or (cancel_cond and z));
	    end if;
	  end if;
	end process;

fout_en <= fouten_reg;
fadd <= fadd_reg;
fadd_next <= f_freg(instruction);
inst_alu <= aluucode_reg;
muxalu_cmd <= muxalucmd_reg;
update_z <= updatez_reg;
update_dc <= updatedc_reg;
update_c <= updatec_reg;

end;
