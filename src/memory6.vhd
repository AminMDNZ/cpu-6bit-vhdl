library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use std.textio.all;
use IEEE.std_logic_textio.all;

entity memory6 is
    port (
        clk       : in std_logic;
        prog_we   : in std_logic;
        prog_addr : in std_logic_vector(5 downto 0);
        prog_data : in std_logic_vector(5 downto 0);
        cpu_addr  : in  std_logic_vector(5 downto 0);
        cpu_data  : out std_logic_vector(5 downto 0)
    );
end entity memory6;

architecture rtl of memory6 is
    type memory_array is array (0 to 63) of std_logic_vector(5 downto 0);

    impure function init_memory_from_file(file_name : in string) return memory_array is
        file text_file : text;
        variable text_line : line;
        variable temp_mem  : memory_array := (others => (others => '0'));
        variable i : integer := 0;
        variable bit_v : bit_vector(5 downto 0);
        variable f_status : file_open_status;
    begin
        -- Strict file check: It will crash and report if the file is missing!
        file_open(f_status, text_file, file_name, read_mode);
        if f_status /= open_ok then
            report "CRITICAL ERROR: Cannot find or open the file: " & file_name severity failure;
            return temp_mem;
        end if;

        while not endfile(text_file) and i < 64 loop
            readline(text_file, text_line);
            -- Skip empty lines safely
            if text_line'length > 0 then
                read(text_line, bit_v);
                temp_mem(i) := to_stdlogicvector(bit_v);
                i := i + 1;
            end if;
        end loop;
        file_close(text_file);
        return temp_mem;
    end function;

    -- Single driver memory initialization
    signal memory : memory_array := init_memory_from_file("program.txt");

begin
    process(clk)
    begin
        if rising_edge(clk) then
            if prog_we = '1' then
                memory(to_integer(unsigned(prog_addr))) <= prog_data;
            end if;
        end if;
    end process;

    cpu_data <= memory(to_integer(unsigned(cpu_addr)));
end architecture rtl;