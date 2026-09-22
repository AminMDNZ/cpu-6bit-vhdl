library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_basic_blocks is
end entity tb_basic_blocks;

architecture simulation of tb_basic_blocks is

    signal clk : std_logic := '0';
    signal rst : std_logic := '0';

    -- Register signals
    signal reg_load : std_logic := '0';
    signal reg_in   : std_logic_vector(5 downto 0) := (others => '0');
    signal reg_out  : std_logic_vector(5 downto 0);
    signal reg_zero : std_logic;

    -- PC signals
    signal pc_load : std_logic := '0';
    signal pc_inc  : std_logic := '0';
    signal pc_in   : std_logic_vector(5 downto 0) := (others => '0');
    signal pc_out  : std_logic_vector(5 downto 0);

    -- ALU signals
    signal alu_a       : std_logic_vector(5 downto 0) := (others => '0');
    signal alu_b       : std_logic_vector(5 downto 0) := (others => '0');
    signal alu_command : std_logic := '0';
    signal alu_result  : std_logic_vector(5 downto 0);

begin

    clk <= not clk after 5 ns;

    reg_instance : entity work.register6
        port map (
            clk      => clk,
            rst      => rst,
            load     => reg_load,
            data_in  => reg_in,
            data_out => reg_out,
            zero     => reg_zero
        );

    pc_instance : entity work.pc6
        port map (
            clk       => clk,
            rst       => rst,
            load      => pc_load,
            increment => pc_inc,
            data_in   => pc_in,
            data_out  => pc_out
        );

    alu_instance : entity work.alu6
        port map (
            input_a => alu_a,
            input_b => alu_b,
            command => alu_command,
            result  => alu_result
        );

    stimulus : process
    begin

        -- Reset
        rst <= '1';
        wait for 20 ns;

        rst <= '0';
        wait for 10 ns;

        -- Load value 7 into register
        reg_in   <= "000111";
        reg_load <= '1';
        wait for 10 ns;

        reg_load <= '0';
        wait for 10 ns;

        assert reg_out = "000111"
            report "Register test failed"
            severity error;

        -- Increment PC twice
        pc_inc <= '1';
        wait for 20 ns;

        pc_inc <= '0';
        wait for 10 ns;

        assert pc_out = "000010"
            report "PC increment test failed"
            severity error;

        -- Load 10 into PC
        pc_in   <= "001010";
        pc_load <= '1';
        wait for 10 ns;

        pc_load <= '0';
        wait for 10 ns;

        assert pc_out = "001010"
            report "PC load test failed"
            severity error;

        -- Test 7 + 4
        alu_a       <= "000111";
        alu_b       <= "000100";
        alu_command <= '0';

        wait for 10 ns;

        assert alu_result = "001011"
            report "ALU addition test failed"
            severity error;

        -- Test 7 - 4
        alu_command <= '1';

        wait for 10 ns;

        assert alu_result = "000011"
            report "ALU subtraction test failed"
            severity error;

        report "All basic block tests passed."
            severity note;

        wait;

    end process;

end architecture simulation;