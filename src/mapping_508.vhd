Library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package mapping_508 is
  constant fadd_w: integer := 5;
  --constant memadd_w: integer := 3;

--mapping (integer type)
  constant indf_add   : integer := 0;
  constant tmr0_add   : integer := 1;
  constant pcl_add    : integer := 2;
  constant status_add : integer := 3;
  constant fsr_add    : integer := 4;
  constant osccal_add : integer := 5;
  constant gpio_add   : integer := 6;
  constant memory_07h : integer := 7;
  constant memory_add : integer := 8;
  
--mapping (vector type)
  constant indf_add_slv   : std_logic_vector(fadd_w-1 downto 0) := std_logic_vector(TO_UNSIGNED(indf_add,fadd_w));
  constant tmr0_add_slv   : std_logic_vector(fadd_w-1 downto 0) := std_logic_vector(TO_UNSIGNED(tmr0_add,fadd_w));
  constant pcl_add_slv    : std_logic_vector(fadd_w-1 downto 0) := std_logic_vector(TO_UNSIGNED(pcl_add,fadd_w));
  constant status_add_slv : std_logic_vector(fadd_w-1 downto 0) := std_logic_vector(TO_UNSIGNED(status_add,fadd_w));
  constant fsr_add_slv    : std_logic_vector(fadd_w-1 downto 0) := std_logic_vector(TO_UNSIGNED(fsr_add,fadd_w));
  constant osccal_add_slv : std_logic_vector(fadd_w-1 downto 0) := std_logic_vector(TO_UNSIGNED(osccal_add,fadd_w));
  constant gpio_add_slv   : std_logic_vector(fadd_w-1 downto 0) := std_logic_vector(TO_UNSIGNED(gpio_add,fadd_w));
  constant memory_07h_slv : std_logic_vector(fadd_w-1 downto 0) := std_logic_vector(TO_UNSIGNED(memory_07h,fadd_w));
  constant memory_add_slv : std_logic_vector(fadd_w-1 downto 0) := std_logic_vector(TO_UNSIGNED(memory_add,fadd_w));
  
  constant mapping_w: integer := memory_add + 1;
  type mapping_t is array (natural range mapping_w-1 downto 0) of std_logic; 

  function mapping_strobes (address: std_logic_vector(fadd_w-1 downto 0)) return mapping_t;
end package;

package body mapping_508 is

  function mapping_strobes (address: std_logic_vector(fadd_w-1 downto 0)) return mapping_t is
  variable strobes: mapping_t;
  variable i, address_i: integer range 2**fadd_w-1 downto 0;
  variable yet: std_logic;
  begin
    address_i := to_integer(unsigned(address));
    yet := '0';
    strobes := (mapping_w-1 => '1', others => '0');
    for i in mapping_w-2 downto 0 loop
      if (yet = '0') then 
        strobes := strobes(0) & strobes(mapping_w-1 downto 1);
      end if;
      if i = address_i then
        yet := '1';
      end if;
    end loop;
    if (yet = '0') then 
      strobes := strobes(0) & strobes(mapping_w-1 downto 1);
    end if;
    return strobes;
  end;
  
end;

