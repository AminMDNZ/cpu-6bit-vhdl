library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity control_unit is
    port (
        clk : in std_logic;
        rst : in std_logic;
        ir : in std_logic_vector(5 downto 0);
        zr0, zr1, zr2, zr3 : in std_logic;
        mul_zero : in std_logic;
        ld0, ld1, ld2, ld3 : out std_logic;
        ldir, ldpc, pc_inc : out std_logic;
        bus_sel : out std_logic_vector(1 downto 0);
        alu_cmd : out std_logic;
        mul_init, mul_step : out std_logic;
        state_debug : out std_logic_vector(2 downto 0)
    );
end entity control_unit;

architecture rtl of control_unit is
    type state_type is (st_fetch, st_decode, st_load, st_add, st_sub, st_jnz, st_mul_init, st_mul_loop);
    signal current_state, next_state : state_type := st_fetch;
    signal selected_zero : std_logic;
begin
    with ir(3 downto 2) select
        selected_zero <= zr0 when "00", zr1 when "01", zr2 when "10", zr3 when "11", '1' when others;

    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                current_state <= st_fetch;
            else
                current_state <= next_state;
            end if;
        end if;
    end process;

    process(current_state, ir, selected_zero, mul_zero)
    begin
        ld0 <= '0'; ld1 <= '0'; ld2 <= '0'; ld3 <= '0';
        ldir <= '0'; ldpc <= '0'; pc_inc <= '0';
        bus_sel <= "00"; alu_cmd <= '0';
        mul_init <= '0'; mul_step <= '0';
        next_state <= current_state;

        case current_state is
            when st_fetch =>
                ldir <= '1'; pc_inc <= '1'; next_state <= st_decode;
            when st_decode =>
                case ir(5 downto 4) is
                    when "00" => next_state <= st_load;
                    when "01" => next_state <= st_add;
                    when "10" => next_state <= st_sub;
                    when "11" =>
                        case ir(1 downto 0) is
                            when "00" => next_state <= st_jnz;
                            when "01" => next_state <= st_mul_init;
                            when others => next_state <= st_fetch;
                        end case;
                    when others => next_state <= st_fetch;
                end case;
            when st_load =>
                bus_sel <= "00";
                case ir(3 downto 2) is
                    when "00" => ld0 <= '1'; when "01" => ld1 <= '1';
                    when "10" => ld2 <= '1'; when "11" => ld3 <= '1';
                    when others => null;
                end case;
                pc_inc <= '1'; next_state <= st_fetch;
            when st_add =>
                bus_sel <= "01"; alu_cmd <= '0';
                case ir(3 downto 2) is
                    when "00" => ld0 <= '1'; when "01" => ld1 <= '1';
                    when "10" => ld2 <= '1'; when "11" => ld3 <= '1';
                    when others => null;
                end case;
                next_state <= st_fetch;
            when st_sub =>
                bus_sel <= "01"; alu_cmd <= '1';
                case ir(3 downto 2) is
                    when "00" => ld0 <= '1'; when "01" => ld1 <= '1';
                    when "10" => ld2 <= '1'; when "11" => ld3 <= '1';
                    when others => null;
                end case;
                next_state <= st_fetch;
            when st_jnz =>
                bus_sel <= "00";
                if selected_zero = '0' then
                    ldpc <= '1';
                else
                    pc_inc <= '1';
                end if;
                next_state <= st_fetch;
            when st_mul_init =>
                mul_init <= '1'; pc_inc <= '1'; next_state <= st_mul_loop;
            when st_mul_loop =>
                alu_cmd <= '0';
                if mul_zero = '0' then
                    mul_step <= '1'; next_state <= st_mul_loop;
                else
                    bus_sel <= "10";
                    case ir(3 downto 2) is
                        when "00" => ld0 <= '1'; when "01" => ld1 <= '1';
                        when "10" => ld2 <= '1'; when "11" => ld3 <= '1';
                        when others => null;
                    end case;
                    next_state <= st_fetch;
                end if;
        end case;
    end process;

    with current_state select
        state_debug <= "000" when st_fetch, "001" when st_decode, "010" when st_load,
                       "011" when st_add, "100" when st_sub, "101" when st_jnz,
                       "110" when st_mul_init, "111" when st_mul_loop;
end architecture rtl;