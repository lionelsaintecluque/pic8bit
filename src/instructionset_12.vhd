library ieee;
use ieee.std_logic_1164.all;

Package InstructionSet_12 is
--general dimensioning
  constant inst_w: integer := 12;	--instruction width
  constant data_w, k_w: integer := 8;	--data width of litteral
--  constant kgoto_w: integer := 9;	--goto address width
  constant b_w: integer := 3;		--size of b field in single bit functions
  constant f_w: integer := 5;
  constant goto_w: integer := 9;
  constant call_w: integer := 8;
--  constant insts_w: integer := 4;	--upper nibble of the instruction
--  constant instc_w: integer := 2;	--instruction complementary bits
  constant kind_w: integer := 2;
  constant arit_w: integer := 4;
  constant litt_w: integer := 2;
  constant bito_w: integer := 2;
  constant bran_w: integer := 2;

--instuction kind:
  constant kind_arit: std_logic_vector(kind_w-1 downto 0) := "00";
  constant kind_bito: std_logic_vector(kind_w-1 downto 0) := "01";
  constant kind_litt: std_logic_vector(kind_w-1 downto 0) := "11";
  constant kind_bran: std_logic_vector(kind_w-1 downto 0) := "10";
--opcodes short:
  constant arit_addwf:  std_logic_vector(arit_w-1 downto 0) := "0111";
  constant arit_andwf:  std_logic_vector(arit_w-1 downto 0) := "0101";
  constant arit_clrf:   std_logic_vector(arit_w-1 downto 0) := "0001";
--  constant arit_clrw:   std_logic_vector(arit_w-1 downto 0) := "0001";
  constant arit_comf:   std_logic_vector(arit_w-1 downto 0) := "1001";
  constant arit_decf:   std_logic_vector(arit_w-1 downto 0) := "0011";
  constant arit_decfsz: std_logic_vector(arit_w-1 downto 0) := "1011";
  constant arit_incf:   std_logic_vector(arit_w-1 downto 0) := "1010";
  constant arit_incfsz: std_logic_vector(arit_w-1 downto 0) := "1111";
  constant arit_iorwf:  std_logic_vector(arit_w-1 downto 0) := "0100";
  constant arit_movf:   std_logic_vector(arit_w-1 downto 0) := "1000";
  constant arit_movwf:  std_logic_vector(arit_w-1 downto 0) := "0000";
--  constant arit_nop:    std_logic_vector(arit_w-1 downto 0) := "0000";
  constant arit_rlf:    std_logic_vector(arit_w-1 downto 0) := "1101";
  constant arit_rrf:    std_logic_vector(arit_w-1 downto 0) := "1100";
  constant arit_subwf:  std_logic_vector(arit_w-1 downto 0) := "0010";
  constant arit_swapf:  std_logic_vector(arit_w-1 downto 0) := "1110";
  constant arit_xorwf:  std_logic_vector(arit_w-1 downto 0) := "0110";
  constant bito_bcf:    std_logic_vector(bito_w-1 downto 0) := "00";
  constant bito_bsf:    std_logic_vector(bito_w-1 downto 0) := "01";
  constant bito_btfsc:  std_logic_vector(bito_w-1 downto 0) := "10";
  constant bito_btfss:  std_logic_vector(bito_w-1 downto 0) := "11";
  constant litt_andlw:  std_logic_vector(litt_w-1 downto 0) := "10";
  constant bran_call:   std_logic_vector(bran_w-1 downto 0) := "01";
--  constant arit_clrwdt: std_logic_vector(arit_w-1 downto 0) := "0000";
  constant bran_goto0:   std_logic_vector(bran_w-1 downto 0) := "10"; -- take care
  constant bran_goto1:   std_logic_vector(bran_w-1 downto 0) := "11"; -- take care
  constant litt_iorlw:  std_logic_vector(litt_w-1 downto 0) := "01";
  constant litt_movlw:  std_logic_vector(litt_w-1 downto 0) := "00";
--  constant arit_option: std_logic_vector(arit_w-1 downto 0) := "0000";
  constant bran_retlw:  std_logic_vector(bran_w-1 downto 0) := "00";
--  constant arit_sleep:  std_logic_vector(arit_w-1 downto 0) := "0000";
--  constant arit_tris:   std_logic_vector(arit_w-1 downto 0) := "0000";
  constant litt_xorlw:  std_logic_vector(litt_w-1 downto 0) := "11";

  constant comf   : integer := 0;
  constant comw   : integer := 1;
  constant muxw   : integer := 2;
  constant muxf   : integer := 3;
  constant incf   : integer := 4;
  constant decf   : integer := 5;
  constant litt   : integer := 6;
  constant bmask   : integer := 7;
  constant carry_preset   : integer := 8;
  constant carry_preclr   : integer := 9;
  constant rlf    : integer := 10;

  constant aluucode_w: integer := rlf;
  type aluucode_t is array ( natural range aluucode_w downto 0) of std_logic;
  type muxalu_t is (muxalu_kin, muxalu_f, muxalu_w, muxalu_cq, muxalu_0, muxalu_s, muxalu_and, muxalu_xor, muxalu_or, muxalu_com);


--fonction to access instruction ucode  
  function k_litteral (instruction: std_logic_vector(inst_w-1 downto 0)) return std_logic_vector;
  function b_mask     (instruction: std_logic_vector(inst_w-1 downto 0)) return std_logic_vector;
  function f_freg     (instruction: std_logic_vector(inst_w-1 downto 0)) return std_logic_vector;
  function d_dest     (instruction: std_logic_vector(inst_w-1 downto 0)) return std_logic;

-- 
  function inst_kind (instruction: std_logic_vector(inst_w-1 downto 0)) return std_logic_vector;
  function inst_arithmetique  (instruction: std_logic_vector(inst_w-1 downto 0)) return std_logic_vector;
  function inst_bitoriented  (instruction: std_logic_vector(inst_w-1 downto 0)) return std_logic_vector;
  function inst_litteral  (instruction: std_logic_vector(inst_w-1 downto 0)) return std_logic_vector;
  function inst_branch  (instruction: std_logic_vector(inst_w-1 downto 0)) return std_logic_vector;

--
  function aluucode_nop return aluucode_t;
  function muxalu_default return muxalu_t;
  function arit_aluucode (subinstruction:std_logic_vector(arit_w-1 downto 0); direction: std_logic) return aluucode_t;
  function arit_muxalu   (subinstruction:std_logic_vector(arit_w-1 downto 0)) return muxalu_t;
  function bito_aluucode (subinstruction:std_logic_vector(bito_w-1 downto 0)) return aluucode_t;
  function bito_muxalu   (subinstruction:std_logic_vector(bito_w-1 downto 0)) return muxalu_t;
  function litt_aluucode (subinstruction:std_logic_vector(litt_w-1 downto 0)) return aluucode_t;
  function litt_muxalu   (subinstruction:std_logic_vector(litt_w-1 downto 0)) return muxalu_t;
  function bran_aluucode (subinstruction:std_logic_vector(bran_w-1 downto 0)) return aluucode_t;
  function bran_muxalu   (subinstruction:std_logic_vector(bran_w-1 downto 0)) return muxalu_t;

  function inst_aluucode (instruction: std_logic_vector(inst_w-1 downto 0)) return aluucode_t;
  function inst_muxalu   (instruction: std_logic_vector(inst_w-1 downto 0)) return muxalu_t;
  function inst_kalu     (instruction: std_logic_vector(inst_w-1 downto 0)) return std_logic_vector;
  function inst_fout     (instruction: std_logic_vector(inst_w-1 downto 0)) return std_logic;
  function inst_push     (instruction: std_logic_vector(inst_w-1 downto 0)) return std_logic;
  function inst_pop      (instruction: std_logic_vector(inst_w-1 downto 0)) return std_logic;
  function inst_goto      (instruction: std_logic_vector(inst_w-1 downto 0)) return std_logic;
  function cancel_unconditional (instruction: std_logic_vector(inst_w-1 downto 0)) return std_logic;
  function cancel_conditional   (instruction: std_logic_vector(inst_w-1 downto 0)) return std_logic;
  function inst_update_z      (instruction: std_logic_vector(inst_w-1 downto 0)) return std_logic;
  function inst_update_dc     (instruction: std_logic_vector(inst_w-1 downto 0)) return std_logic;
  function inst_update_c      (instruction: std_logic_vector(inst_w-1 downto 0)) return std_logic;
end InstructionSet_12;

Package body InstructionSet_12 is
--begin
  function k_litteral (instruction: std_logic_vector(inst_w-1 downto 0)) return std_logic_vector is
  begin
    return instruction(k_w-1 downto 0);
  end k_litteral;

  function b_mask (instruction: std_logic_vector(inst_w-1 downto 0)) return std_logic_vector is
  variable bshort: std_logic_vector(b_w-1 downto 0);
  variable blong: std_logic_vector(data_w-1 downto 0);
  begin
    bshort := instruction(f_w+b_w-1 downto f_w);
    case bshort is
      when "000" =>  blong := "00000001";
      when "001" =>  blong := "00000010";
      when "010" =>  blong := "00000100";
      when "011" =>  blong := "00001000";
      when "100" =>  blong := "00010000";
      when "101" =>  blong := "00100000";
      when "110" =>  blong := "01000000";
      when "111" =>  blong := "10000000";
      when others => blong := "00000000";
    end case;
    return blong;
  end b_mask;
  
  function f_freg (instruction: std_logic_vector(inst_w-1 downto 0)) return std_logic_vector is
  begin
    return instruction(f_w-1 downto 0);
  end f_freg;

  function d_dest (instruction: std_logic_vector(inst_w-1 downto 0)) return std_logic is
  begin
    return instruction(f_w);
  end;

  function inst_kind (instruction: std_logic_vector(inst_w-1 downto 0)) return std_logic_vector is
  begin
    return instruction (inst_w-1 downto inst_w-kind_w);
  end;

  function inst_arithmetique  (instruction: std_logic_vector(inst_w-1 downto 0)) return std_logic_vector is
  begin
    return instruction (inst_w-kind_w-1 downto inst_w-kind_w-arit_w);
  end;

  function inst_bitoriented  (instruction: std_logic_vector(inst_w-1 downto 0)) return std_logic_vector is
  begin
    return instruction (inst_w-kind_w-1 downto inst_w-kind_w-bito_w);
  end;
  
  function inst_litteral  (instruction: std_logic_vector(inst_w-1 downto 0)) return std_logic_vector is
  begin
    return instruction (inst_w-kind_w-1 downto inst_w-kind_w-litt_w);
  end;

  function inst_branch  (instruction: std_logic_vector(inst_w-1 downto 0)) return std_logic_vector is
  begin
    return instruction (inst_w-kind_w-1 downto inst_w-kind_w-bran_w);
  end;
  
  function aluucode_nop return aluucode_t is
  begin
    return (comw => '0', comf => '0', muxw => '1', muxf => '1', incf => '0', bmask => '0', decf => '0', litt => '0', carry_preset => '0', carry_preclr => '0', rlf => '0');
  end;

  function muxalu_default return muxalu_t is
  begin
    return muxalu_0;
  end;

  function arit_aluucode (subinstruction:std_logic_vector(arit_w-1 downto 0); direction: std_logic) return aluucode_t is
  variable alu_ucode: aluucode_t;
  begin
    --direction: 0 stores result in W, 1 stores result in f
    --muxw: 1 outputs win to wout, 0 outputs aluresult to wout
    --muxw: 1 outputs fin to fout, 0 outputs aluresult to fout
    case subinstruction is
 when arit_addwf  => alu_ucode := (comw => '0', comf => '0', muxw => direction, muxf => not direction, bmask => '0', incf => '0', decf => '0', litt => '0', carry_preset => '0', carry_preclr => '0', rlf => '0');
 when arit_andwf  => alu_ucode := (comw => '0', comf => '0', muxw => direction, muxf => not direction, bmask => '0', incf => '0', decf => '0', litt => '0', carry_preset => '0', carry_preclr => '0', rlf => '0');
 when arit_clrf   => alu_ucode := (comw => '0', comf => '0', muxw => direction, muxf => not direction, bmask => '0', incf => '0', decf => '0', litt => '0', carry_preset => '0', carry_preclr => '0', rlf => '0');
 when arit_comf   => alu_ucode := (comw => '0', comf => '1', muxw => direction, muxf => not direction, bmask => '0', incf => '0', decf => '0', litt => '0', carry_preset => '0', carry_preclr => '0', rlf => '0');
 when arit_decf   => alu_ucode := (comw => '0', comf => '0', muxw => direction, muxf => not direction, bmask => '0', incf => '0', decf => '1', litt => '0', carry_preset => '0', carry_preclr => '1', rlf => '0');
 when arit_decfsz => alu_ucode := (comw => '0', comf => '0', muxw => direction, muxf => not direction, bmask => '0', incf => '0', decf => '1', litt => '0', carry_preset => '0', carry_preclr => '1', rlf => '0');
 when arit_incf   => alu_ucode := (comw => '0', comf => '0', muxw => direction, muxf => not direction, bmask => '0', incf => '1', decf => '0', litt => '0', carry_preset => '1', carry_preclr => '0', rlf => '0');
 when arit_incfsz => alu_ucode := (comw => '0', comf => '0', muxw => direction, muxf => not direction, bmask => '0', incf => '1', decf => '0', litt => '0', carry_preset => '1', carry_preclr => '0', rlf => '0');
 when arit_iorwf  => alu_ucode := (comw => '0', comf => '0', muxw => direction, muxf => not direction, bmask => '0', incf => '0', decf => '0', litt => '0', carry_preset => '0', carry_preclr => '0', rlf => '0');
 when arit_movf   => alu_ucode := (comw => '0', comf => '0', muxw => direction, muxf => not direction, bmask => '0', incf => '0', decf => '0', litt => '0', carry_preset => '0', carry_preclr => '0', rlf => '0');
 when arit_movwf  => alu_ucode := (comw => '0', comf => '0', muxw => direction, muxf => not direction, bmask => '0', incf => '0', decf => '0', litt => '0', carry_preset => '0', carry_preclr => '0', rlf => '0');
 when arit_rlf    => alu_ucode := (comw => '0', comf => '0', muxw => direction, muxf => not direction, bmask => '0', incf => '0', decf => '0', litt => '0', carry_preset => '0', carry_preclr => '0', rlf => '1');
 when arit_rrf    => alu_ucode := (comw => '0', comf => '0', muxw => direction, muxf => not direction, bmask => '0', incf => '0', decf => '0', litt => '0', carry_preset => '0', carry_preclr => '0', rlf => '0');
 when arit_subwf  => alu_ucode := (comw => '1', comf => '0', muxw => direction, muxf => not direction, bmask => '0', incf => '0', decf => '0', litt => '0', carry_preset => '1', carry_preclr => '0', rlf => '0');
 when arit_swapf  => alu_ucode := (comw => '0', comf => '0', muxw => direction, muxf => not direction, bmask => '0', incf => '0', decf => '0', litt => '0', carry_preset => '0', carry_preclr => '0', rlf => '0');
 when arit_xorwf  => alu_ucode := (comw => '0', comf => '0', muxw => direction, muxf => not direction, bmask => '0', incf => '0', decf => '0', litt => '0', carry_preset => '0', carry_preclr => '0', rlf => '0');
 when others      => alu_ucode := aluucode_nop;
    end case;
    return alu_ucode;
  end;

  function arit_muxalu (subinstruction:std_logic_vector(arit_w-1 downto 0)) return muxalu_t is
  variable mux_cmd: muxalu_t;
  begin
    case subinstruction is
       when arit_addwf  => mux_cmd := muxalu_s;
       when arit_andwf  => mux_cmd := muxalu_and;
       when arit_clrf   => mux_cmd := muxalu_0;
       when arit_comf   => mux_cmd := muxalu_com;
       when arit_decf   => mux_cmd := muxalu_s;
       when arit_decfsz => mux_cmd := muxalu_s;
       when arit_incf   => mux_cmd := muxalu_s;
       when arit_incfsz => mux_cmd := muxalu_s;
       when arit_iorwf  => mux_cmd := muxalu_or;
       when arit_movf   => mux_cmd := muxalu_f;
       when arit_movwf  => mux_cmd := muxalu_w;
       when arit_rlf    => mux_cmd := muxalu_cq;
       when arit_rrf    => mux_cmd := muxalu_0;
       when arit_subwf  => mux_cmd := muxalu_s;
       when arit_swapf  => mux_cmd := muxalu_0;
       when arit_xorwf  => mux_cmd := muxalu_xor;
       when others      => mux_cmd := muxalu_0;
    end case;
    return mux_cmd;
  end;

  function bito_aluucode (subinstruction:std_logic_vector(bito_w-1 downto 0)) return aluucode_t is
  variable alu_ucode: aluucode_t;
  begin
    case subinstruction is
 when bito_bcf    => alu_ucode := (comw => '1', comf => '0', muxw => '1', muxf => '0', bmask => '1', incf => '0', decf => '0', litt => '0', carry_preset => '0', carry_preclr => '0', rlf => '0');
 when bito_bsf    => alu_ucode := (comw => '0', comf => '0', muxw => '1', muxf => '0', bmask => '1', incf => '0', decf => '0', litt => '0', carry_preset => '0', carry_preclr => '0', rlf => '0');
 when bito_btfsc  => alu_ucode := (comw => '0', comf => '0', muxw => '1', muxf => '1', bmask => '1', incf => '0', decf => '0', litt => '0', carry_preset => '0', carry_preclr => '0', rlf => '0');
 when bito_btfss  => alu_ucode := (comw => '0', comf => '1', muxw => '1', muxf => '1', bmask => '1', incf => '0', decf => '0', litt => '0', carry_preset => '0', carry_preclr => '0', rlf => '0');
 --when others      => alu_ucode := (comw => '0', comf => '0', muxw => '1', muxf => '0', bmask => '0', incf => '0', decf => '0', litt => '0', carry_preset => '0', carry_preclr => '0', rlf => '0');
 when others      => alu_ucode := aluucode_nop;
    end case;
    return alu_ucode;
  end;

  function bito_muxalu   (subinstruction:std_logic_vector(bito_w-1 downto 0)) return muxalu_t is
  variable mux_cmd: muxalu_t;
  begin
    case subinstruction is
       when bito_bcf    => mux_cmd := muxalu_and;
       when bito_bsf    => mux_cmd := muxalu_or;
       when bito_btfsc  => mux_cmd := muxalu_and;
       when bito_btfss  => mux_cmd := muxalu_and;
       when others      => mux_cmd := muxalu_w;
    end case;
    return mux_cmd;
  end;

  function litt_aluucode (subinstruction:std_logic_vector(litt_w-1 downto 0)) return aluucode_t is
  variable alu_ucode: aluucode_t;
  begin
    case subinstruction is
 when litt_andlw  => alu_ucode := (comw => '0', comf => '0', muxw => '0', muxf => '1', bmask => '0', incf => '0', decf => '0', litt => '1', carry_preset => '0', carry_preclr => '0', rlf => '0');
 when litt_iorlw  => alu_ucode := (comw => '0', comf => '0', muxw => '0', muxf => '1', bmask => '0', incf => '0', decf => '0', litt => '1', carry_preset => '0', carry_preclr => '0', rlf => '0');
 when litt_movlw  => alu_ucode := (comw => '0', comf => '0', muxw => '0', muxf => '1', bmask => '0', incf => '0', decf => '0', litt => '1', carry_preset => '0', carry_preclr => '0', rlf => '0');
 when litt_xorlw  => alu_ucode := (comw => '0', comf => '0', muxw => '0', muxf => '1', bmask => '0', incf => '0', decf => '0', litt => '1', carry_preset => '0', carry_preclr => '0', rlf => '0');
 --when others      => alu_ucode := (comw => '0', comf => '0', muxw => '0', muxf => '1', bmask => '0', incf => '0', decf => '0', litt => '0', carry_preset => '0', carry_preclr => '0', rlf => '0');
 when others      => alu_ucode := aluucode_nop;
    end case;
    return alu_ucode;
  end;

  function litt_muxalu   (subinstruction:std_logic_vector(litt_w-1 downto 0)) return muxalu_t is
  variable mux_cmd: muxalu_t;
  begin
    case subinstruction is
       when litt_andlw  => mux_cmd := muxalu_and;
       when litt_iorlw  => mux_cmd := muxalu_or;
       when litt_movlw  => mux_cmd := muxalu_kin;
       when litt_xorlw  => mux_cmd := muxalu_xor;
       when others      => mux_cmd := muxalu_0;
    end case;
    return mux_cmd;
  end;

  function bran_aluucode (subinstruction:std_logic_vector(bran_w-1 downto 0)) return aluucode_t is
  variable alu_ucode: aluucode_t;
  begin
    case subinstruction is
 when bran_call   => alu_ucode := (comw => '0', comf => '0', muxw => '1', muxf => '0', bmask => '0', incf => '0', decf => '0', litt => '0', carry_preset => '0', carry_preclr => '0', rlf => '0');
 when bran_goto0   => alu_ucode := (comw => '0', comf => '0', muxw => '1', muxf => '0', bmask => '0', incf => '0', decf => '0', litt => '0', carry_preset => '0', carry_preclr => '0', rlf => '0');
 when bran_goto1   => alu_ucode := (comw => '0', comf => '0', muxw => '1', muxf => '0', bmask => '0', incf => '0', decf => '0', litt => '0', carry_preset => '0', carry_preclr => '0', rlf => '0');
 when bran_retlw  => alu_ucode := (comw => '0', comf => '0', muxw => '0', muxf => '1', bmask => '0', incf => '0', decf => '0', litt => '0', carry_preset => '0', carry_preclr => '0', rlf => '0');
 when others      => alu_ucode := aluucode_nop;
    end case;
    return alu_ucode;
  end;

  function bran_muxalu   (subinstruction:std_logic_vector(bran_w-1 downto 0)) return muxalu_t is
  variable mux_cmd: muxalu_t;
  begin
    case subinstruction is
       when bran_call   => mux_cmd := muxalu_0;
       when bran_goto0   => mux_cmd := muxalu_0;
       when bran_goto1   => mux_cmd := muxalu_0;
       when bran_retlw  => mux_cmd := muxalu_kin;
       when others      => mux_cmd := muxalu_0;
    end case;
    return mux_cmd;
  end;

  function inst_aluucode(instruction: std_logic_vector(inst_w-1 downto 0)) return aluucode_t is
  variable subinstruction_kind: std_logic_vector (kind_w-1 downto 0);
  variable subinstruction_arit: std_logic_vector (arit_w-1 downto 0);
  variable subinstruction_bito: std_logic_vector (bito_w-1 downto 0);
  variable subinstruction_litt: std_logic_vector (litt_w-1 downto 0);
  variable subinstruction_bran: std_logic_vector (bran_w-1 downto 0);
  variable destination: std_logic;
  variable alu_ucode: aluucode_t;
  begin
    subinstruction_kind := inst_kind(instruction);
    case subinstruction_kind is
      when kind_arit =>
        subinstruction_arit := inst_arithmetique(instruction); 
        destination := d_dest(instruction);
        alu_ucode := arit_aluucode(subinstruction_arit, destination);
      when kind_bito =>
        subinstruction_bito := inst_bitoriented(instruction); 
        alu_ucode := bito_aluucode(subinstruction_bito);
      when kind_litt =>
        subinstruction_litt := inst_litteral(instruction); 
        alu_ucode := litt_aluucode(subinstruction_litt);
      when kind_bran =>
        subinstruction_bran := inst_branch(instruction); 
        alu_ucode := bran_aluucode(subinstruction_bran);
      when others => alu_ucode := aluucode_nop;
    end case;

    return alu_ucode;
  end; 

  function inst_muxalu(instruction: std_logic_vector(inst_w-1 downto 0)) return muxalu_t is
  variable subinstruction_kind: std_logic_vector (kind_w-1 downto 0);
  variable subinstruction_arit: std_logic_vector (arit_w-1 downto 0);
  variable subinstruction_bito: std_logic_vector (bito_w-1 downto 0);
  variable subinstruction_litt: std_logic_vector (litt_w-1 downto 0);
  variable subinstruction_bran: std_logic_vector (bran_w-1 downto 0);
  variable mux_cmd: muxalu_t;
  begin
    subinstruction_kind := inst_kind(instruction);
    case subinstruction_kind is
      when kind_arit =>
        subinstruction_arit := inst_arithmetique(instruction); 
        mux_cmd := arit_muxalu(subinstruction_arit);
      when kind_bito =>
        subinstruction_bito := inst_bitoriented(instruction); 
        mux_cmd := bito_muxalu(subinstruction_bito);
      when kind_litt =>
        subinstruction_litt := inst_litteral(instruction); 
        mux_cmd := litt_muxalu(subinstruction_litt);
      when kind_bran =>
        subinstruction_bran := inst_branch(instruction); 
        mux_cmd := bran_muxalu(subinstruction_bran);
      when others => mux_cmd := muxalu_w;
    end case;

    return mux_cmd;
  end;



  function inst_kalu     (instruction: std_logic_vector(inst_w-1 downto 0)) return std_logic_vector is
  variable subinstruction_kind: std_logic_vector (kind_w-1 downto 0);
  variable subinstruction_arit: std_logic_vector (arit_w-1 downto 0);
  variable subinstruction_bito: std_logic_vector (bito_w-1 downto 0);
  variable subinstruction_litt: std_logic_vector (litt_w-1 downto 0);
  variable subinstruction_bran: std_logic_vector (bran_w-1 downto 0);
  variable kalu: std_logic_vector(k_w-1 downto 0);
  begin
    subinstruction_kind := inst_kind(instruction);
    case subinstruction_kind is
      when kind_arit =>
        kalu := (others => '0');
      when kind_bito =>
        kalu := b_mask(instruction);
      when kind_litt =>
        kalu := k_litteral(instruction);
      when kind_bran =>
        kalu := k_litteral(instruction);
      when others => kalu := (others => '0');
    end case;
    return kalu;
  end;

  function inst_fout     (instruction: std_logic_vector(inst_w-1 downto 0)) return std_logic is
  variable subinstruction_kind: std_logic_vector (kind_w-1 downto 0);
  variable subinstruction_arit: std_logic_vector (arit_w-1 downto 0);
  variable subinstruction_bito: std_logic_vector (bito_w-1 downto 0);
  variable subinstruction_litt: std_logic_vector (litt_w-1 downto 0);
  variable subinstruction_bran: std_logic_vector (bran_w-1 downto 0);
  variable fout: std_logic;
  begin
    subinstruction_kind := inst_kind(instruction);
    case subinstruction_kind is
      when kind_arit =>
        fout := d_dest(instruction);
      when kind_bito =>
        subinstruction_bito := inst_bitoriented(instruction);
	case subinstruction_bito is
          when bito_bcf => fout := '1';
          when bito_bsf => fout := '1';
          when bito_btfsc => fout := '0';
          when bito_btfss => fout := '0';
          when others => fout := '0';
        end case;
      when kind_litt =>
        fout := '0';
      when kind_bran =>
        subinstruction_bran := inst_branch(instruction);
	case subinstruction_bran is
          when bran_goto0 => fout := '0';
          when bran_goto1 => fout := '0';
          when bran_call  => fout := '0';
          when bran_retlw => fout := '0';
          when others => fout := '0';
        end case;
      when others => fout := '0';
    end case;
    return fout;
  end;

  function inst_push     (instruction: std_logic_vector(inst_w-1 downto 0)) return std_logic is
  variable subinstruction_kind: std_logic_vector (kind_w-1 downto 0);
  variable subinstruction_bran: std_logic_vector (bran_w-1 downto 0);
  variable push_var: std_logic;
  begin
    push_var := '0';
    subinstruction_kind := inst_kind(instruction);
    if subinstruction_kind = kind_bran then
      subinstruction_bran := inst_branch(instruction);
      if subinstruction_bran = bran_call then
        push_var := '1';
      end if;
    end if;
    return push_var;
  end;

  function inst_pop      (instruction: std_logic_vector(inst_w-1 downto 0)) return std_logic is
  variable subinstruction_kind: std_logic_vector (kind_w-1 downto 0);
  variable subinstruction_bran: std_logic_vector (bran_w-1 downto 0);
  variable pop_var: std_logic;
  begin
    pop_var := '0';
    subinstruction_kind := inst_kind(instruction);
    if subinstruction_kind = kind_bran then
      subinstruction_bran := inst_branch(instruction);
      if subinstruction_bran = bran_retlw then
        pop_var := '1';
      end if;
    end if;
    return pop_var;
  end;

  function inst_goto      (instruction: std_logic_vector(inst_w-1 downto 0)) return std_logic is
  variable subinstruction_kind: std_logic_vector (kind_w-1 downto 0);
  variable subinstruction_bran: std_logic_vector (bran_w-1 downto 0);
  variable goto_var: std_logic;
  begin
    goto_var := '0';
    subinstruction_kind := inst_kind(instruction);
    if subinstruction_kind = kind_bran then
      subinstruction_bran := inst_branch(instruction);
      if subinstruction_bran = bran_goto0 or subinstruction_bran = bran_goto1 then
        goto_var := '1';
      end if;
    end if;
    return goto_var;
  end;

  function cancel_unconditional (instruction: std_logic_vector(inst_w-1 downto 0)) return std_logic is
  variable subinstruction_kind: std_logic_vector (kind_w-1 downto 0);
  variable subinstruction_arit: std_logic_vector (arit_w-1 downto 0);
  variable subinstruction_bito: std_logic_vector (bito_w-1 downto 0);
  variable subinstruction_litt: std_logic_vector (litt_w-1 downto 0);
  variable subinstruction_bran: std_logic_vector (bran_w-1 downto 0);
  variable cancel_var: std_logic;
  begin
    cancel_var := '0';
    subinstruction_kind := inst_kind(instruction);
    case subinstruction_kind is
      when kind_bran =>
        cancel_var := '1';
      when others => cancel_var := '0';
    end case;
    return cancel_var;
  end;

  function cancel_conditional   (instruction: std_logic_vector(inst_w-1 downto 0)) return std_logic is
  variable subinstruction_kind: std_logic_vector (kind_w-1 downto 0);
  variable subinstruction_arit: std_logic_vector (arit_w-1 downto 0);
  variable subinstruction_bito: std_logic_vector (bito_w-1 downto 0);
  variable subinstruction_litt: std_logic_vector (litt_w-1 downto 0);
  variable subinstruction_bran: std_logic_vector (bran_w-1 downto 0);
  variable cancel_var: std_logic;
  begin
    cancel_var := '0';
    subinstruction_kind := inst_kind(instruction);
    case subinstruction_kind is
      when kind_arit =>
        subinstruction_arit := inst_arithmetique(instruction);
        if subinstruction_arit = arit_incfsz or subinstruction_arit = arit_decfsz then
          cancel_var := '1';
        end if;
      when kind_bito =>
        subinstruction_bito := inst_bitoriented(instruction);
        if subinstruction_bito = bito_btfsc or subinstruction_bito = bito_btfss then
          cancel_var := '1';
        end if;
      when others => cancel_var := '0';
    end case;
    return cancel_var;
  end;


  function inst_update_z   (instruction: std_logic_vector(inst_w-1 downto 0)) return std_logic is
  variable subinstruction_kind: std_logic_vector (kind_w-1 downto 0);
  variable subinstruction_arit: std_logic_vector (arit_w-1 downto 0);
  variable subinstruction_bito: std_logic_vector (bito_w-1 downto 0);
  variable subinstruction_litt: std_logic_vector (litt_w-1 downto 0);
  variable subinstruction_bran: std_logic_vector (bran_w-1 downto 0);
  variable update_z: std_logic;
  begin
    update_z := '0';
    subinstruction_kind := inst_kind(instruction);
    case subinstruction_kind is
      when kind_arit =>
        subinstruction_arit := inst_arithmetique(instruction);
        if (
            subinstruction_arit = arit_decfsz or
            subinstruction_arit = arit_incfsz or
            subinstruction_arit = arit_movwf or
--            subinstruction_arit = arit_nop or
            subinstruction_arit = arit_rrf or
            subinstruction_arit = arit_rlf or
            subinstruction_arit = arit_swapf
            ) then
          update_z := '0';
        else
          update_z := '1';
        end if;
      when kind_litt =>
        subinstruction_litt := inst_litteral(instruction);
        if subinstruction_litt = litt_movlw then
          update_z := '0';
        else
          update_z := '1';
        end if;
      when others => update_z := '0';
    end case;
    return update_z;
  end;


  function inst_update_dc   (instruction: std_logic_vector(inst_w-1 downto 0)) return std_logic is
  variable subinstruction_kind: std_logic_vector (kind_w-1 downto 0);
  variable subinstruction_arit: std_logic_vector (arit_w-1 downto 0);
  variable subinstruction_bito: std_logic_vector (bito_w-1 downto 0);
  variable subinstruction_litt: std_logic_vector (litt_w-1 downto 0);
  variable subinstruction_bran: std_logic_vector (bran_w-1 downto 0);
  variable update_dc: std_logic;
  begin
    update_dc := '0';
    subinstruction_kind := inst_kind(instruction);
    if subinstruction_kind = kind_arit then
        subinstruction_arit := inst_arithmetique(instruction);
        if subinstruction_arit = arit_addwf or subinstruction_arit = arit_subwf then
          update_dc := '1';
        end if;
    end if;
    return update_dc;
  end;


  function inst_update_c   (instruction: std_logic_vector(inst_w-1 downto 0)) return std_logic is
  variable subinstruction_kind: std_logic_vector (kind_w-1 downto 0);
  variable subinstruction_arit: std_logic_vector (arit_w-1 downto 0);
  variable subinstruction_bito: std_logic_vector (bito_w-1 downto 0);
  variable subinstruction_litt: std_logic_vector (litt_w-1 downto 0);
  variable subinstruction_bran: std_logic_vector (bran_w-1 downto 0);
  variable update_c: std_logic;
  begin
    update_c := '0';
    subinstruction_kind := inst_kind(instruction);
    if subinstruction_kind = kind_arit then
      subinstruction_arit := inst_arithmetique(instruction);
      if 
        subinstruction_arit = arit_addwf or 
        subinstruction_arit = arit_rlf or 
        subinstruction_arit = arit_rrf or 
        subinstruction_arit = arit_subwf then
        update_c := '1';
      end if;
    end if;
    return update_c;
  end;


end InstructionSet_12;
