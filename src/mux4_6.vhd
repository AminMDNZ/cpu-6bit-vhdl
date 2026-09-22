library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mux4_6 is
    port (input0, input1, input2, input3 : in std_logic_vector(5 downto 0); sel : in std_logic_vector(1 downto 0); data_out : out std_logic_vector(5 downto 0));
end entity mux4_6;

architecture rtl of mux4_6 is
begin
    with sel select data_out <= input0 when "00", input1 when "01", input2 when "10", input3 when "11", (others => '0') when others;
end architecture rtl;