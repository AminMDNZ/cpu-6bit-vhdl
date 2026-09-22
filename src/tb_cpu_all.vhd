library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity TESTBENCH_FOR_cpu is
end entity TESTBENCH_FOR_cpu;

architecture simulation of TESTBENCH_FOR_cpu is

    signal clk : std_logic := '0';
    signal rst : std_logic := '1';
    signal sim_done : std_logic := '0';

    --------------------------------------------------
    -- Memory programming signals
    --------------------------------------------------

    signal prog_we   : std_logic := '0';
    signal prog_addr : std_logic_vector(5 downto 0)
                     := (others => '0');
    signal prog_data : std_logic_vector(5 downto 0)
                     := (others => '0');

    --------------------------------------------------
    -- CPU debug outputs
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
    -- Test program
    --------------------------------------------------

    stimulus : process
    begin

        --------------------------------------------------
        -- Keep CPU in reset while loading memory
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
        -- Address 1: value 7
        --------------------------------------------------

        prog_addr <= "000001";
        prog_data <= "000111";
        wait until rising_edge(clk);

        --------------------------------------------------
        -- Address 2: LOAD R1
        --------------------------------------------------

        prog_addr <= "000010";
        prog_data <= "000100";
        wait until rising_edge(clk);

        --------------------------------------------------
        -- Address 3: value 4
        --------------------------------------------------

        prog_addr <= "000011";
        prog_data <= "000100";
        wait until rising_edge(clk);

        --------------------------------------------------
        -- Address 4: ADD R0, R1
        --------------------------------------------------

        prog_addr <= "000100";
        prog_data <= "010001";
        wait until rising_edge(clk);

        --------------------------------------------------
        -- Address 5: JNZ R0, 5
        -- Used as an endless stop loop
        --------------------------------------------------

        prog_addr <= "000101";
        prog_data <= "110000";
        wait until rising_edge(clk);

        --------------------------------------------------
        -- Address 6: jump target = 5
        --------------------------------------------------

        prog_addr <= "000110";
        prog_data <= "000101";
        wait until rising_edge(clk);

        --------------------------------------------------
        -- Finish programming
        --------------------------------------------------

        prog_we <= '0';
        wait until falling_edge(clk);

        --------------------------------------------------
        -- Start the CPU
        --------------------------------------------------

        rst <= '0';

        --------------------------------------------------
        -- Allow enough time for program execution
        --------------------------------------------------

        wait for 140 ns;

        --------------------------------------------------
        -- Check final results
        --------------------------------------------------

        assert r0_debug = "001011"
            report "CPU failed: R0 must be 11"
            severity failure;

        assert r1_debug = "000100"
            report "CPU failed: R1 must remain 4"
            severity failure;

        assert r2_debug = "000000"
            report "CPU failed: R2 must remain zero"
            severity failure;

        assert r3_debug = "000000"
            report "CPU failed: R3 must remain zero"
            severity failure;

        report "CPU test passed: 7 + 4 = 11"
            severity note;

        --------------------------------------------------
        -- Stop clock generation
        --------------------------------------------------

        sim_done <= '1';
        wait;

    end process;

end architecture simulation;