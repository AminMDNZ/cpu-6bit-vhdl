library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity TESTBENCH_FOR_memory6 is
end entity TESTBENCH_FOR_memory6;

architecture simulation of TESTBENCH_FOR_memory6 is

    signal clk : std_logic := '0';

    signal prog_we   : std_logic := '0';
    signal prog_addr : std_logic_vector(5 downto 0)
                     := (others => '0');
    signal prog_data : std_logic_vector(5 downto 0)
                     := (others => '0');

    signal cpu_addr : std_logic_vector(5 downto 0)
                    := (others => '0');
    signal cpu_data : std_logic_vector(5 downto 0);

begin

    -- 10 ns clock period
    clk <= not clk after 5 ns;

    uut : entity work.memory6
        port map (
            clk       => clk,
            prog_we   => prog_we,
            prog_addr => prog_addr,
            prog_data => prog_data,
            cpu_addr  => cpu_addr,
            cpu_data  => cpu_data
        );

    stimulus : process
    begin

        --------------------------------------------------
        -- Load program into memory
        --------------------------------------------------

        prog_we <= '1';

        -- Address 0: LOAD R0
        prog_addr <= "000000";
        prog_data <= "000000";
        wait until rising_edge(clk);

        -- Address 1: Value 7
        prog_addr <= "000001";
        prog_data <= "000111";
        wait until rising_edge(clk);

        -- Address 2: LOAD R1
        prog_addr <= "000010";
        prog_data <= "000100";
        wait until rising_edge(clk);

        -- Address 3: Value 4
        prog_addr <= "000011";
        prog_data <= "000100";
        wait until rising_edge(clk);

        -- Address 4: ADD R0, R1
        prog_addr <= "000100";
        prog_data <= "010001";
        wait until rising_edge(clk);

        -- Disable memory writing
        prog_we <= '0';

        wait for 5 ns;

        --------------------------------------------------
        -- Read and verify memory
        --------------------------------------------------

        cpu_addr <= "000000";
        wait for 2 ns;

        assert cpu_data = "000000"
            report "Memory address 0 failed"
            severity error;

        cpu_addr <= "000001";
        wait for 2 ns;

        assert cpu_data = "000111"
            report "Memory address 1 failed"
            severity error;

        cpu_addr <= "000010";
        wait for 2 ns;

        assert cpu_data = "000100"
            report "Memory address 2 failed"
            severity error;

        cpu_addr <= "000011";
        wait for 2 ns;

        assert cpu_data = "000100"
            report "Memory address 3 failed"
            severity error;

        cpu_addr <= "000100";
        wait for 2 ns;

        assert cpu_data = "010001"
            report "Memory address 4 failed"
            severity error;

        report "Program loaded into memory successfully."
            severity note;

        wait;

    end process;

end architecture simulation;