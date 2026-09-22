library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_cpu_part2 is
end entity tb_cpu_part2;

architecture simulation of tb_cpu_part2 is

    signal clk      : std_logic := '0';
    signal rst      : std_logic := '1';
    signal sim_done : std_logic := '0';

    --------------------------------------------------
    -- Memory programming interface
    --------------------------------------------------

    signal prog_we   : std_logic := '0';

    signal prog_addr : std_logic_vector(5 downto 0)
                     := (others => '0');

    signal prog_data : std_logic_vector(5 downto 0)
                     := (others => '0');

    --------------------------------------------------
    -- Debug outputs
    --------------------------------------------------

    signal r0_debug : std_logic_vector(5 downto 0);
    signal r1_debug : std_logic_vector(5 downto 0);
    signal r2_debug : std_logic_vector(5 downto 0);
    signal r3_debug : std_logic_vector(5 downto 0);

    signal pc_debug : std_logic_vector(5 downto 0);
    signal ir_debug : std_logic_vector(5 downto 0);

    signal memory_debug : std_logic_vector(5 downto 0);
    signal alu_debug    : std_logic_vector(5 downto 0);
    signal bus_debug    : std_logic_vector(5 downto 0);

    signal state_debug : std_logic_vector(2 downto 0);

begin

    --------------------------------------------------
    -- Clock generator
    --------------------------------------------------

    clock_process : process
    begin

        while sim_done = '0' loop

            clk <= '0';
            wait for 5 ns;

            clk <= '1';
            wait for 5 ns;

        end loop;

        wait;

    end process;

    --------------------------------------------------
    -- CPU instance
    --------------------------------------------------

    uut : entity work.CPU
        port map (
            clk => clk,
            rst => rst,

            prog_we   => prog_we,
            prog_addr => prog_addr,
            prog_data => prog_data,

            r0_debug => r0_debug,
            r1_debug => r1_debug,
            r2_debug => r2_debug,
            r3_debug => r3_debug,

            pc_debug => pc_debug,
            ir_debug => ir_debug,

            memory_debug => memory_debug,
            alu_debug    => alu_debug,
            bus_debug    => bus_debug,

            state_debug => state_debug
        );

    --------------------------------------------------
    -- Load and execute multiplication program
    --------------------------------------------------

    stimulus : process
    begin

        --------------------------------------------------
        -- Hold CPU in reset while programming memory
        --------------------------------------------------

        rst     <= '1';
        prog_we <= '1';

        wait for 2 ns;

        --------------------------------------------------
        -- Address 0: LOAD R0
        --------------------------------------------------

        prog_addr <= "000000";
        prog_data <= "000000";
        wait until rising_edge(clk);

        --------------------------------------------------
        -- Address 1: value 0
        --------------------------------------------------

        prog_addr <= "000001";
        prog_data <= "000000";
        wait until rising_edge(clk);

        --------------------------------------------------
        -- Address 2: LOAD R1
        --------------------------------------------------

        prog_addr <= "000010";
        prog_data <= "000100";
        wait until rising_edge(clk);

        --------------------------------------------------
        -- Address 3: value 6
        --------------------------------------------------

        prog_addr <= "000011";
        prog_data <= "000110";
        wait until rising_edge(clk);

        --------------------------------------------------
        -- Address 4: LOAD R2
        --------------------------------------------------

        prog_addr <= "000100";
        prog_data <= "001000";
        wait until rising_edge(clk);

        --------------------------------------------------
        -- Address 5: value 8
        --------------------------------------------------

        prog_addr <= "000101";
        prog_data <= "001000";
        wait until rising_edge(clk);

        --------------------------------------------------
        -- Address 6: LOAD R3
        --------------------------------------------------

        prog_addr <= "000110";
        prog_data <= "001100";
        wait until rising_edge(clk);

        --------------------------------------------------
        -- Address 7: value 1
        --------------------------------------------------

        prog_addr <= "000111";
        prog_data <= "000001";
        wait until rising_edge(clk);

        --------------------------------------------------
        -- Address 8: ADD R0, R1
        --------------------------------------------------

        prog_addr <= "001000";
        prog_data <= "010001";
        wait until rising_edge(clk);

        --------------------------------------------------
        -- Address 9: SUB R2, R3
        --------------------------------------------------

        prog_addr <= "001001";
        prog_data <= "101011";
        wait until rising_edge(clk);

        --------------------------------------------------
        -- Address 10: JNZ R2
        --------------------------------------------------

        prog_addr <= "001010";
        prog_data <= "111000";
        wait until rising_edge(clk);

        --------------------------------------------------
        -- Address 11: loop target = 8
        --------------------------------------------------

        prog_addr <= "001011";
        prog_data <= "001000";
        wait until rising_edge(clk);

        --------------------------------------------------
        -- Address 12: JNZ R3
        --------------------------------------------------

        prog_addr <= "001100";
        prog_data <= "111100";
        wait until rising_edge(clk);

        --------------------------------------------------
        -- Address 13: stop target = 12
        --------------------------------------------------

        prog_addr <= "001101";
        prog_data <= "001100";
        wait until rising_edge(clk);

        --------------------------------------------------
        -- End memory programming
        --------------------------------------------------

        prog_we <= '0';

        wait until falling_edge(clk);

        --------------------------------------------------
        -- Start CPU
        --------------------------------------------------

        rst <= '0';

        --------------------------------------------------
        -- Wait for multiplication to complete
        --------------------------------------------------

        wait for 1000 ns;

        --------------------------------------------------
        -- Verify result
        --------------------------------------------------

        assert r0_debug = "110000"
            report "Software multiplication failed: R0 must be 48"
            severity failure;

        assert r1_debug = "000110"
            report "Software multiplication failed: R1 must remain 6"
            severity failure;

        assert r2_debug = "000000"
            report "Software multiplication failed: counter R2 must be zero"
            severity failure;

        assert r3_debug = "000001"
            report "Software multiplication failed: R3 must remain 1"
            severity failure;

        report "Software multiplication passed: 6 x 8 = 48"
            severity note;

        sim_done <= '1';

        wait;

    end process;

end architecture simulation;