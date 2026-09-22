library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity pc6 is
    port (clk, rst, load, increment : in std_logic; data_in : in std_logic_vector(5 downto 0); data_out : out std_logic_vector(5 downto 0));
end entity pc6;

architecture rtl of pc6 is
    signal pc_reg : unsigned(5 downto 0) := (others => '0');
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then pc_reg <= (others => '0');
            elsif load = '1' then pc_reg <= unsigned(data_in);
            elsif increment = '1' then pc_reg <= pc_reg + 1;
            end if;
        end if;
    end process;
    data_out <= std_logic_vector(pc_reg);
end architecture rtl;