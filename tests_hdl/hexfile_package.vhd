Library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
Library std;
use std.textio.all;

package hexfile_package is

  constant rectype_data		: integer range 0 to 2**8-1 := 0;
  constant rectype_eof		: integer range 0 to 2**8-1 := 1;
  constant rectype_ext_seg_add	: integer range 0 to 2**8-1 := 2;
  constant rectype_start_seg_add: integer range 0 to 2**8-1 := 3;
  constant rectype_ext_lin_add	: integer range 0 to 2**8-1 := 4;
  constant rectype_start_lin_add: integer range 0 to 2**8-1 := 5;

  constant pgmadd_w : integer := 10;
  constant inst_w: integer := 12;
  constant opcode_byte_length: integer := 2;
  type program_memory_t is array (natural range 0 to 2**pgmadd_w-1) of std_logic_vector(inst_w-1 downto 0);
  function hexfile_to_pgmmemory (pgmadd_w: integer; inst_w: integer) return program_memory_t;
end;

package body hexfile_package is
--
--
--
  function hexfile_to_pgmmemory (pgmadd_w: integer; inst_w: integer) return program_memory_t is

  file hex_file : text is "tests_hdl/testcase.hex";

  -- variables to handle file content
  variable input_line: line;
  variable ch: character;
  variable byte: integer range 0 to 2**8-1;
  variable sum: std_logic_vector (7 downto 0):= (others => '0');
  variable good: boolean;
  variable line_number: integer;
  
  -- hex line data variables
  variable rec_len: integer range 0 to 2**8-1;
  variable load_offset: integer range 0 to 2**16-1;
  variable rec_type: integer range 0 to 2**8-1;
  variable data: std_logic_vector (8*opcode_byte_length-1 downto 0);
  variable checksum: std_logic_vector (7 downto 0);
  
  --Variables to handle program_memory
  variable address, base_address: integer range program_memory_t'range;
  variable line_index: integer range 0 to 2**8-1;
  variable opcode: integer range 0 to opcode_byte_length*2**8-1;

  --return variable temporary register
  variable program_memory: program_memory_t := (others => (others => '1'));


    function checksum_add (sum_input: std_logic_vector (7 downto 0); byte: integer range 0 to 2**8-1) return std_logic_vector is
    variable sum_output: std_logic_vector (7 downto 0);
    begin
      sum_output := std_logic_vector(unsigned(sum_output) + to_unsigned(byte,8));
      return sum_output;
    end;

    procedure character_to_hexvalue(in_char: in character; hexvalue: out integer range 0 to 2**4-1; good: inout boolean) is
    begin
      if character'pos(in_char) >= character'pos('0') and character'pos(in_char) <= character'pos('9') then
       hexvalue := character'pos(in_char) - character'pos('0');
      elsif character'pos(in_char) >= character'pos('A') and character'pos(in_char) <= character'pos('F') then
        hexvalue := 10 + character'pos(in_char) - character'pos('A');
      elsif character'pos(in_char) >= character'pos('a') and character'pos(in_char) <= character'pos('f') then
        hexvalue := 10 + character'pos(in_char) - character'pos('a');
      else
	hexvalue := 15;
        good := false;
      end if;
    end;
--line is such a funny thing that it can not be passed as a function parameter.
    procedure read_byte (input_ligne: inout line; byte: out integer range 0 to 2**8-1; good: inout boolean) is
    variable ch: character;
    variable tmp_half1, tmp_half2: integer range 0 to 2**4-1;
    begin
      read(input_ligne, ch);
      character_to_hexvalue(ch, tmp_half1, good);
      read(input_ligne, ch);
      character_to_hexvalue(ch, tmp_half2, good);
      byte := 2**4*tmp_half1+ tmp_half2;
    end;

  begin
    line_number := 0;
    while not endfile(hex_file) loop
      readline(hex_file, input_line);
      read(input_line, ch); assert (ch = ':') report "Error in hex file: lines does not start with a colon ':' at line  " & integer'image(line_number) severity note;

  --record length in bytes
      good := true;
      read_byte(input_line, byte, good); 
      rec_len := byte;
      sum := checksum_add(sum, byte);
      assert (good=true) report "PB in record length at line " & integer'image(line_number) severity warning;

  --Adress
      good := true;
      read_byte(input_line, byte, good);
      load_offset := byte;
      sum := checksum_add(sum, byte);
      read_byte(input_line, byte, good);
      load_offset := load_offset*2**8+byte;
      sum := checksum_add(sum, byte);
      assert (good=true) report "PB in load offest at line " & integer'image(line_number) severity warning;

  --record type
      good := true;
      read_byte(input_line, byte, good);
      rec_type := byte;
      sum := checksum_add(sum, byte);
      assert (good=true) report "PB in record type at line " & integer'image(line_number) severity warning;

      report "Line: " & integer'image(line_number) & ", record length: " & integer'image(rec_len) & ", Load offset: " & integer'image(load_offset) & ", record type: " & integer'image(rec_type) severity note;
  --type rectype_t is (data, eof, ext_seg_add, start_seg_add, ext_lin_add, start_lin_add);
	case rec_type is
	  when rectype_data		=> 
		assert (rec_len rem opcode_byte_length = 0) 
		  report "Error in hex file: non-integer number of opcodes at line " & integer'image(line_number) severity error;
		assert (rec_len / opcode_byte_length > 0)
		  report "Error in hex file: no data at line " & integer'image(line_number) & " rec_len=" & integer'image(rec_len) severity error;
		good := true;
		address := (base_address+load_offset)/opcode_byte_length;
		for line_index in 0 to (rec_len/opcode_byte_length)-1 loop
		  for byte_index in 0 to opcode_byte_length-1 loop
		    read_byte(input_line, byte, good);
      		assert (good=true) 
		  report "PB in data record at line " & integer'image(line_number) & " opcode " & integer'image(line_index) & " byte " & integer'image(byte_index)
		  severity warning;
		    sum := checksum_add(sum, byte);
		    data := std_logic_vector(to_unsigned(byte, 8)) & data(data'high downto data'high-7 );
		  end loop;
		  program_memory(address) := data (inst_w-1 downto 0);
		  if not (address = program_memory_t'high) then 
	            address := address + 1; 
	          else 
                    report "End of program memory reached after " & integer'image(line_number) & " opcode " & integer'image(line_index) severity warning;
	          end if;
		end loop;
	  when rectype_eof		=>
	  	report "RECTYPE End Of File not implemented at line  " & integer'image(line_number) severity note;
		good := true;
		for line_index in 0 to (rec_len)-1 loop
		  read_byte(input_line, byte, good);
		  sum := checksum_add(sum, byte);
		end loop;
      		assert (good=true) report "PB in data record at line " & integer'image(line_number) severity warning;
	  when rectype_ext_seg_add	=>
	  	report "RECTYPE Extended Segment Address not implemented at line  " & integer'image(line_number) severity warning;
		good := true;
		for line_index in 0 to (rec_len)-1 loop
		  read_byte(input_line, byte, good);
		  sum := checksum_add(sum, byte);
		end loop;
      		assert (good=true) report "PB in extended segment address record at line " & integer'image(line_number)severity warning;
	  when rectype_start_seg_add	=>
	  	report "RECTYPE Start Segment Address not implemented at line  " & integer'image(line_number) severity warning;
		good := true;
		for line_index in 0 to (rec_len)-1 loop
		  read_byte(input_line, byte, good);
		  sum := checksum_add(sum, byte);
		end loop;
      		assert (good=true) report "PB in start segment address record at line " & integer'image(line_number) severity warning;
	  when rectype_ext_lin_add	=>
		good := true;
		base_address := 0;
		for line_index in 0 to (rec_len)-1 loop
		  read_byte(input_line, byte, good);
		  sum := checksum_add(sum, byte);
		  base_address := 2**8*base_address + byte;
		end loop;
      		assert (good=true) report "PB in extended linear address record at line " & integer'image(line_number) severity warning;
	  when rectype_start_lin_add	=>
	  	report "RECTYPE Start Linear Address not implemented at line " & integer'image(line_number) severity warning;
		good := true;
		for line_index in 0 to (rec_len)-1 loop
		  read_byte(input_line, byte, good);
		  sum := checksum_add(sum, byte);
		end loop;
      		assert (good=true) report "PB in start linear address record  at line  " & integer'image(line_number) severity warning;
	  when others => report "Error in hex file: unknown RECTYPE at line  " & integer'image(line_number) severity note;
	end case;
      good := true;
      read_byte(input_line, byte, good);
      assert (good=true) report "PB in checksum value at line " & integer'image(line_number) severity warning;
      sum := checksum_add(sum, byte);
      assert (to_integer(unsigned(sum)) = 0) report "Error in hex file: wrong checksum at line  " & integer'image(line_number) severity warning;	
      line_number := line_number +1;
    end loop;
    return program_memory;
  end;

end package body;
