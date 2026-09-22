library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity register6 is
    port (clk, rst, load : in std_logic; data_in : in std_logic_vector(5 downto 0); data_out : out std_logic_vector(5 downto 0); zero : out std_logic);
end entity register6;

architecture rtl of register6 is
    signal reg_data : std_logic_vector(5 downto 0) := (others => '0');
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then reg_data <= (others => '0');
            elsif load = '1' then reg_data <= data_in;
            end if;
        end if;
    end process;
    data_out <= reg_data;
    zero <= '1' when reg_data = "000000" else '0';
end architecture rtl;