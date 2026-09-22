library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity alu6 is
    port (input_a, input_b : in std_logic_vector(5 downto 0); command : in std_logic; result : out std_logic_vector(5 downto 0));
end entity alu6;

architecture rtl of alu6 is
begin
    process(input_a, input_b, command)
    begin
        if command = '0' then result <= std_logic_vector(unsigned(input_a) + unsigned(input_b));
        else result <= std_logic_vector(unsigned(input_a) - unsigned(input_b));
        end if;
    end process;
end architecture rtl;